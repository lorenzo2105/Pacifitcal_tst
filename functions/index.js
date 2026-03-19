/**
 * PacifitCal — Firebase Cloud Functions
 * - Création d'utilisateurs côté serveur (Admin SDK)
 * - Notifications push FCM
 * - Rappels automatiques (cours, abonnements)
 *
 * Installation :
 *   cd functions
 *   npm install
 *   firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// ─── Création d'utilisateur par l'admin (sans déconnecter l'admin) ────────────

exports.createUser = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    // Vérifier que l'appelant est un admin
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Non authentifié.');
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Accès réservé aux administrateurs.');
    }

    const { email, password, nom, prenom, subscriptionStart, subscriptionEnd, active } = data;

    if (!email || !password || !nom || !prenom) {
      throw new functions.https.HttpsError('invalid-argument', 'Champs obligatoires manquants.');
    }

    try {
      // Créer l'utilisateur Firebase Auth via Admin SDK (ne déconnecte pas l'admin)
      const userRecord = await admin.auth().createUser({
        email: email.trim(),
        password: password,
        displayName: `${prenom.trim()} ${nom.trim()}`,
      });

      // Créer le document Firestore
      await db.collection('users').doc(userRecord.uid).set({
        nom: nom.trim(),
        prenom: prenom.trim(),
        email: email.trim(),
        role: 'user',
        subscription_start: subscriptionStart
          ? admin.firestore.Timestamp.fromDate(new Date(subscriptionStart))
          : null,
        subscription_end: subscriptionEnd
          ? admin.firestore.Timestamp.fromDate(new Date(subscriptionEnd))
          : null,
        active: active !== undefined ? active : true,
        fcm_token: null,
      });

      return { uid: userRecord.uid, success: true };
    } catch (error) {
      if (error.code === 'auth/email-already-exists') {
        throw new functions.https.HttpsError('already-exists', 'Cet email est déjà utilisé.');
      }
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ─── Suppression d'utilisateur Firebase Auth ──────────────────────────────────

exports.deleteUser = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Non authentifié.');
    }

    const callerDoc = await db.collection('users').doc(context.auth.uid).get();
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Accès réservé aux administrateurs.');
    }

    const { uid } = data;
    if (!uid) {
      throw new functions.https.HttpsError('invalid-argument', 'UID manquant.');
    }

    try {
      await admin.auth().deleteUser(uid);
      return { success: true };
    } catch (error) {
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// ─── Helper : envoyer un message FCM ─────────────────────────────────────────

async function sendPushNotification(fcmToken, title, body, data = {}) {
  if (!fcmToken) return;
  try {
    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      android: {
        notification: {
          channelId: 'pacifitcal_default',
          color: '#FF6B00',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      data,
    });
  } catch (err) {
    console.error('FCM error:', err);
  }
}

// ─── Trigger : nouvelle entrée dans notifications_queue ───────────────────────

exports.processNotificationQueue = functions
  .region('europe-west1')
  .firestore.document('notifications_queue/{notifId}')
  .onCreate(async (snap, context) => {
    const notif = snap.data();
    if (notif.sent) return;

    const userDoc = await db.collection('users').doc(notif.user_id).get();
    if (!userDoc.exists) {
      await snap.ref.update({ sent: true, error: 'user_not_found' });
      return;
    }

    const fcmToken = userDoc.data().fcm_token;
    await sendPushNotification(fcmToken, notif.title, notif.body, {
      type: notif.type || '',
    });

    await snap.ref.update({ sent: true, sent_at: admin.firestore.FieldValue.serverTimestamp() });
  });

// ─── Scheduled : rappel 24h avant un cours ────────────────────────────────────

exports.sendCourseReminders = functions
  .region('europe-west1')
  .pubsub.schedule('every 60 minutes')
  .onRun(async (context) => {
    const now = new Date();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const in25h = new Date(now.getTime() + 25 * 60 * 60 * 1000);

    const classesSnap = await db.collection('classes')
      .where('date', '>=', admin.firestore.Timestamp.fromDate(in24h))
      .where('date', '<=', admin.firestore.Timestamp.fromDate(in25h))
      .get();

    for (const classDoc of classesSnap.docs) {
      const cls = classDoc.data();
      const reservationsSnap = await db.collection('reservations')
        .where('class_id', '==', classDoc.id)
        .get();

      for (const resDoc of reservationsSnap.docs) {
        const res = resDoc.data();
        const userDoc = await db.collection('users').doc(res.user_id).get();
        if (!userDoc.exists) continue;

        const fcmToken = userDoc.data().fcm_token;
        await sendPushNotification(
          fcmToken,
          '⏰ Rappel de cours demain',
          `${cls.name} demain à ${cls.time}. On vous attend !`,
          { type: 'course_reminder', class_id: classDoc.id }
        );
      }
    }

    console.log(`Rappels envoyés pour ${classesSnap.size} cours.`);
  });

// ─── Scheduled : alerte abonnement expirant dans 3 jours ─────────────────────

exports.checkExpiringSubscriptions = functions
  .region('europe-west1')
  .pubsub.schedule('every 24 hours')
  .onRun(async (context) => {
    const now = new Date();
    const in3days = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);
    const in4days = new Date(now.getTime() + 4 * 24 * 60 * 60 * 1000);

    const usersSnap = await db.collection('users')
      .where('role', '==', 'user')
      .where('active', '==', true)
      .where('subscription_end', '>=', admin.firestore.Timestamp.fromDate(in3days))
      .where('subscription_end', '<=', admin.firestore.Timestamp.fromDate(in4days))
      .get();

    for (const userDoc of usersSnap.docs) {
      const user = userDoc.data();
      if (!user.fcm_token) continue;

      await sendPushNotification(
        user.fcm_token,
        '⚠️ Abonnement bientôt expiré',
        `Votre abonnement expire dans 3 jours. Contactez votre coach pour le renouveler !`,
        { type: 'subscription_expiry' }
      );
    }

    console.log(`Alertes expiration envoyées à ${usersSnap.size} utilisateurs.`);
  });

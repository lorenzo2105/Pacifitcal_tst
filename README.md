# PacifitCal — Application CrossFit

Application mobile Flutter pour salle de sport CrossFit.
Compatible **iOS** et **Android**.

---

## Sommaire

1. [Fonctionnalités](#fonctionnalités)
2. [Architecture du projet](#architecture-du-projet)
3. [Installation de Flutter](#1-installation-de-flutter)
4. [Configuration de Firebase](#2-configuration-de-firebase)
5. [Lancer l'application](#3-lancer-lapplication)
6. [Créer le premier compte Admin](#4-créer-le-premier-compte-admin)
7. [Publier sur Android](#5-publier-sur-android-google-play)
8. [Publier sur iOS](#6-publier-sur-ios-app-store)
9. [Règles de sécurité Firestore](#7-règles-firestore)
10. [Structure Firestore](#8-structure-firestore)
11. [Notifications push](#9-notifications-push)

---

## Fonctionnalités

### Adhérent
- Inscription / Connexion avec email + mot de passe
- Voir le planning des cours
- Réserver / annuler un créneau
- Voir ses réservations à venir
- Voir son profil et son abonnement

### Administrateur
- Dashboard avec statistiques
- Créer / modifier / supprimer des adhérents
- Gérer les abonnements (1, 6 ou 12 mois)
- Activer / désactiver un compte
- Créer / modifier / supprimer des cours
- Voir les participants d'un cours
- Supprimer des réservations

### Sécurité
- Abonnement expiré → accès bloqué automatiquement
- Compte désactivé → connexion impossible
- Règles Firestore strictes

---

## Architecture du projet

```
pacifitcal/
├── pubspec.yaml                  # Dépendances Flutter
├── firebase.json                 # Config Firebase CLI
├── firestore.rules               # Règles de sécurité Firestore
├── firestore.indexes.json        # Index Firestore
├── assets/
│   ├── images/                   # Images de l'app
│   ├── animations/               # Fichiers Lottie (.json)
│   └── fonts/                    # Police BebasNeue
└── lib/
    ├── main.dart                 # Point d'entrée
    ├── firebase_options.dart     # Config Firebase (à générer)
    ├── config/
    │   ├── app_theme.dart        # Thème dark CrossFit
    │   └── routes.dart           # Navigation GoRouter
    ├── models/
    │   ├── user_model.dart       # Modèle utilisateur
    │   ├── class_model.dart      # Modèle cours
    │   └── reservation_model.dart
    ├── services/
    │   ├── auth_service.dart     # Firebase Auth
    │   ├── firestore_service.dart # CRUD Firestore
    │   └── notification_service.dart # FCM
    ├── providers/
    │   ├── auth_provider.dart    # État authentification
    │   ├── class_provider.dart   # État cours
    │   └── reservation_provider.dart
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── user/
    │   │   ├── home_screen.dart
    │   │   ├── booking_detail_screen.dart
    │   │   ├── profile_screen.dart
    │   │   └── my_reservations_screen.dart
    │   └── admin/
    │       ├── admin_dashboard_screen.dart
    │       ├── admin_users_screen.dart
    │       ├── admin_user_form_screen.dart
    │       ├── admin_classes_screen.dart
    │       ├── admin_class_form_screen.dart
    │       └── admin_reservations_screen.dart
    └── widgets/
        ├── class_card.dart
        └── subscription_badge.dart
```

---

## 1. Installation de Flutter

### Étape 1 — Télécharger Flutter SDK

Rendez-vous sur https://docs.flutter.dev/get-started/install

Choisissez votre système d'exploitation (Windows / macOS / Linux).

**Sur Windows :**
```powershell
# Téléchargez le SDK Flutter depuis le site officiel
# Extrayez dans C:\flutter
# Ajoutez C:\flutter\bin au PATH système
```

### Étape 2 — Vérifier l'installation

```bash
flutter doctor
```

Tous les items doivent être ✅ (sauf ceux non nécessaires).

### Étape 3 — Installer Android Studio

Téléchargez depuis : https://developer.android.com/studio

Lors de l'installation, cochez :
- Android SDK
- Android Virtual Device (émulateur)

### Étape 4 — Accepter les licences Android

```bash
flutter doctor --android-licenses
```

Tapez `y` pour tout accepter.

---

## 2. Configuration de Firebase

### Étape 1 — Créer un projet Firebase

1. Allez sur https://console.firebase.google.com
2. Cliquez **"Ajouter un projet"**
3. Nom : `pacifitcal` (ou votre choix)
4. Désactivez Google Analytics (optionnel)
5. Cliquez **"Créer le projet"**

### Étape 2 — Activer les services Firebase

Dans la console Firebase, activez :

#### Authentication
- Menu **Authentication** → **Commencer**
- **Méthode de connexion** → Activer **Email/Mot de passe**

#### Firestore Database
- Menu **Firestore Database** → **Créer une base de données**
- Choisissez **"Démarrer en mode production"**
- Sélectionnez une région (ex: `europe-west1`)

#### Cloud Messaging (FCM)
- Menu **Cloud Messaging** → automatiquement activé

### Étape 3 — Installer Firebase CLI + FlutterFire CLI

```bash
# Installer Node.js depuis https://nodejs.org (si pas installé)

# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Installer FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Étape 4 — Connecter Flutter à Firebase

Dans le dossier du projet :

```bash
cd C:\wamp64\www\PacifitCal
flutterfire configure
```

Suivez les instructions :
1. Sélectionnez votre projet Firebase
2. Sélectionnez les plateformes : **Android** et **iOS**
3. Cela génère automatiquement `lib/firebase_options.dart` ✅
4. Cela génère `android/app/google-services.json` ✅
5. Cela génère `ios/Runner/GoogleService-Info.plist` ✅

### Étape 5 — Déployer les règles Firestore

```bash
# Déployer les règles de sécurité
firebase deploy --only firestore:rules

# Déployer les index
firebase deploy --only firestore:indexes
```

---

## 3. Lancer l'application

### Installer les dépendances

```bash
cd C:\wamp64\www\PacifitCal
flutter pub get
```

### Télécharger la police BebasNeue

1. Téléchargez **BebasNeue-Regular.ttf** depuis https://fonts.google.com/specimen/Bebas+Neue
2. Placez le fichier dans `assets/fonts/BebasNeue-Regular.ttf`

### Lancer sur un émulateur Android

```bash
# Créer un émulateur depuis Android Studio :
# Tools → Device Manager → Create Device

# Lancer l'émulateur
flutter emulators --launch <nom_emulateur>

# Lancer l'app
flutter run
```

### Lancer sur un appareil physique

```bash
# Connectez votre téléphone en USB
# Activez "Débogage USB" dans les options développeur
flutter devices          # Voir les appareils connectés
flutter run -d <device_id>
```

### Lancer sur iOS (macOS requis)

```bash
# Installer les dépendances iOS
cd ios && pod install && cd ..

# Ouvrir le simulateur
open -a Simulator

# Lancer
flutter run
```

---

## 4. Créer le premier compte Admin

Après avoir lancé l'application, créez le compte admin **directement dans Firebase** :

### Via la Console Firebase

1. **Authentication** → **Ajouter un utilisateur**
   - Email : `admin@pacifitcal.com`
   - Mot de passe : votre choix sécurisé
   - Copiez l'**UID** généré

2. **Firestore** → **Ajouter un document**
   - Collection : `users`
   - ID du document : **l'UID copié**
   - Champs :
     ```
     nom          : "Admin" (string)
     prenom       : "Super" (string)
     email        : "admin@pacifitcal.com" (string)
     role         : "admin" (string)
     active       : true (boolean)
     subscription_start : null
     subscription_end   : null
     ```

3. Connectez-vous dans l'app avec ces identifiants → vous accédez au Dashboard Admin.

---

## 5. Publier sur Android (Google Play)

### Étape 1 — Configurer l'identifiant de l'application

Dans `android/app/build.gradle` :
```gradle
android {
    defaultConfig {
        applicationId "com.votresociete.pacifitcal"
        ...
    }
}
```

### Étape 2 — Générer une clé de signature

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### Étape 3 — Configurer la signature

Créez `android/key.properties` :
```properties
storePassword=<MOT_DE_PASSE_STORE>
keyPassword=<MOT_DE_PASSE_CLE>
keyAlias=upload
storeFile=<CHEMIN_VERS_keystore.jks>
```

### Étape 4 — Construire le bundle

```bash
flutter build appbundle --release
```

Le fichier est dans `build/app/outputs/bundle/release/app-release.aab`

### Étape 5 — Publier sur Google Play

1. Créez un compte développeur : https://play.google.com/console
2. Créez une nouvelle application
3. Uploadez le fichier `.aab`
4. Remplissez les informations (description, screenshots)
5. Soumettez pour révision

---

## 6. Publier sur iOS (App Store)

> ⚠️ Nécessite un Mac avec Xcode et un compte Apple Developer (99$/an)

### Étape 1 — Configurer le Bundle ID

Dans Xcode → `Runner` → `General` :
- Bundle Identifier : `com.votresociete.pacifitcal`

### Étape 2 — Configurer les certificats

```bash
# Sur Mac uniquement
open ios/Runner.xcworkspace
```

Dans Xcode :
1. `Signing & Capabilities` → Sélectionnez votre Team
2. Activez la signature automatique

### Étape 3 — Construire pour l'App Store

```bash
flutter build ipa --release
```

### Étape 4 — Uploader via Xcode ou Transporter

1. Ouvrez l'archive dans `build/ios/archive/`
2. `Product` → `Archive`
3. `Distribute App` → `App Store Connect`

### Étape 5 — Soumettre sur App Store Connect

1. Allez sur https://appstoreconnect.apple.com
2. Créez une nouvelle app
3. Sélectionnez le build uploadé
4. Remplissez les métadonnées
5. Soumettez pour révision Apple (1-7 jours)

---

## 7. Règles Firestore

Les règles sont définies dans `firestore.rules` et garantissent :

- **Utilisateurs** : chacun ne lit que ses propres données
- **Admin** : accès complet à toutes les collections
- **Réservations** : uniquement si abonnement valide et non expiré
- **Cours** : lecture pour tous, écriture admin uniquement

Déploiement :
```bash
firebase deploy --only firestore:rules
```

---

## 8. Structure Firestore

### Collection `users`
| Champ | Type | Description |
|-------|------|-------------|
| `nom` | string | Nom de famille |
| `prenom` | string | Prénom |
| `email` | string | Email |
| `role` | string | `"user"` ou `"admin"` |
| `subscription_start` | timestamp | Début d'abonnement |
| `subscription_end` | timestamp | Fin d'abonnement |
| `active` | boolean | Compte actif |
| `fcm_token` | string | Token push FCM |

### Collection `classes`
| Champ | Type | Description |
|-------|------|-------------|
| `name` | string | Nom du cours |
| `date` | timestamp | Date du cours |
| `time` | string | Heure (ex: "09:00") |
| `duration` | number | Durée en minutes |
| `max_participants` | number | Places maximum |
| `current_participants` | number | Places prises |
| `coach` | string | Nom du coach |
| `description` | string | Description |

### Collection `reservations`
| Champ | Type | Description |
|-------|------|-------------|
| `user_id` | string | UID de l'utilisateur |
| `class_id` | string | ID du cours |
| `created_at` | timestamp | Date de réservation |
| `user_name` | string | Nom complet |
| `class_name` | string | Nom du cours |
| `class_date` | timestamp | Date du cours |
| `class_time` | string | Heure du cours |

---

## 9. Notifications Push

Les notifications sont gérées via **Firebase Cloud Messaging (FCM)**.

Les notifications planifiées sont stockées dans la collection `notifications_queue`.
Pour les envoyer réellement, déployez une **Firebase Cloud Function** :

```bash
# Installer Firebase Functions
npm install -g firebase-tools
firebase init functions  # Dans le dossier du projet
```

Exemple de Cloud Function (`functions/index.js`) :
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotifications = functions.firestore
  .document('notifications_queue/{notifId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userDoc = await admin.firestore()
      .collection('users').doc(data.user_id).get();
    const fcmToken = userDoc.data()?.fcm_token;

    if (!fcmToken) return;

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: data.title,
        body: data.body,
      },
    });

    await snap.ref.update({ sent: true });
  });
```

---

## Technologies utilisées

| Technologie | Version | Rôle |
|-------------|---------|------|
| Flutter | 3.x | Framework mobile |
| Dart | 3.x | Langage |
| Firebase Auth | ^4.16 | Authentification |
| Cloud Firestore | ^4.14 | Base de données |
| Firebase Messaging | ^14.7 | Notifications push |
| Provider | ^6.1 | State management |
| GoRouter | ^13.0 | Navigation |
| Google Fonts | ^6.1 | Typographie |
| intl | ^0.19 | Dates en français |

---

## Support

Pour toute question, contactez votre administrateur ou consultant Flutter.

# ✅ Checklist Publication - PacifiTcal

Checklist rapide avant publication. **Voir [GUIDE_PUBLICATION.md](GUIDE_PUBLICATION.md) pour le guide complet.**

---

## 🎯 Préparation (1-2 jours)

### Application
- [ ] Tests complets effectués
  - [ ] Connexion / Déconnexion
  - [ ] Réservation / Annulation cours
  - [ ] Interface admin complète
  - [ ] Mot de passe oublié
  - [ ] Rate limiting (5 tentatives)
  
- [ ] Version incrémentée dans `pubspec.yaml`
  ```yaml
  version: 1.0.1+2
  ```

- [ ] Build test réussi
  ```bash
  flutter build appbundle --release  # Android
  flutter build ios --release         # iOS (Mac)
  ```

### Assets
- [ ] Icône créée
  - [ ] 512x512px (Android)
  - [ ] 1024x1024px (iOS, sans transparence)
  
- [ ] Captures d'écran prises (minimum 2)
  - [ ] Écran connexion
  - [ ] Liste cours
  - [ ] Détail cours
  - [ ] Profil utilisateur
  - [ ] Dashboard admin (optionnel)

### Firebase
- [ ] Rules déployées
  ```bash
  firebase deploy --only firestore:rules
  firebase deploy --only firestore:indexes
  ```

- [ ] Cloud Functions déployées (si plan Blaze)
  ```bash
  cd functions
  firebase deploy --only functions
  ```

### Contenu
- [ ] Description courte rédigée (80 caractères)
- [ ] Description longue rédigée (4000 caractères)
- [ ] Politique de confidentialité en ligne
  - URL : https://pacifitcal.com/privacy
  
- [ ] Compte démo créé pour reviewers
  - Email : demo@pacifitcal.com
  - MDP : DemoTest123!@#

---

## 🤖 Android - Google Play (3-7 jours)

### Configuration (1 jour)
- [ ] Compte développeur créé (25$ unique)
- [ ] Clé de signature générée
  ```powershell
  keytool -genkey -v -keystore C:\keys\pacifitcal-upload-key.jks `
    -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
    -alias upload
  ```

- [ ] `android/key.properties` créé
- [ ] Clé sauvegardée dans lieu sûr (backup cloud)
- [ ] `applicationId` modifié dans `build.gradle`

### Build (30 min)
- [ ] AAB compilé
  ```bash
  flutter clean
  flutter pub get
  flutter build appbundle --release
  ```

- [ ] AAB testé (pas d'erreur)

### Play Console (2h)
- [ ] Application créée
- [ ] Titre : PacifiTcal
- [ ] Description courte + longue remplie
- [ ] Captures d'écran uploadées (min 2)
- [ ] Icône 512x512 uploadée
- [ ] Catégorie : Santé et remise en forme
- [ ] Politique de confidentialité (URL)
- [ ] Classement du contenu complété
- [ ] Données de sécurité remplies
- [ ] AAB uploadé
- [ ] Notes de version rédigées
- [ ] Soumis pour révision ✅

### Attente
- [ ] Validation reçue (1-7 jours)
- [ ] Application publiée 🎉

---

## 🍎 iOS - App Store (1-7 jours)

**⚠️ Requis : Mac + Xcode + Compte Apple Developer (99$/an)**

### Configuration (1 jour)
- [ ] Compte Apple Developer créé (99$/an)
- [ ] Validation compte reçue (24-48h)
- [ ] Mac disponible avec Xcode 15+
- [ ] Projet ouvert : `open ios/Runner.xcworkspace`
- [ ] Bundle ID configuré
- [ ] Signing automatique activé
- [ ] Certificats générés par Xcode

### Build (1h)
- [ ] Archive créée
  ```bash
  flutter clean
  flutter pub get
  flutter build ios --release
  ```

- [ ] Archive uploadée via Xcode Organizer
- [ ] Build apparaît dans App Store Connect (30min-1h)

### App Store Connect (2h)
- [ ] Application créée
- [ ] Nom : PacifiTcal
- [ ] Sous-titre : Réservation CrossFit
- [ ] Description complète remplie
- [ ] Mots-clés ajoutés (100 caractères)
- [ ] Captures 6.7" uploadées (min 2)
- [ ] Icône 1024x1024 uploadée
- [ ] Catégorie : Santé et forme
- [ ] Politique de confidentialité (URL)
- [ ] Classification par âge
- [ ] Informations de confidentialité
- [ ] Build sélectionné
- [ ] Notes de version rédigées
- [ ] Compte démo fourni dans notes révision
- [ ] Soumis pour révision ✅

### Attente
- [ ] Révision Apple (24h-7 jours, souvent 1-2 jours)
- [ ] Application approuvée 🎉
- [ ] Publication sur App Store

---

## 🔥 Firebase Production (optionnel)

**Si plan Blaze actif :**

### App Check
- [ ] Android : Play Integrity configuré
- [ ] iOS : App Attest configuré
- [ ] Code modifié (`app_check_service.dart`)
  ```dart
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.deviceCheck,
  ```

### Cloud Functions
- [ ] Fonction `deleteUserAuth` déployée
- [ ] Fonction `sendNotifications` déployée (si notifications)
- [ ] Tests effectués

---

## 📊 Après Publication

### Monitoring (quotidien)
- [ ] Consulter statistiques Play Console
- [ ] Consulter statistiques App Store Connect
- [ ] Vérifier rapports de crash
- [ ] Lire avis utilisateurs
- [ ] Répondre aux avis

### Maintenance (mensuel)
- [ ] Analyser métriques d'utilisation
- [ ] Planifier mises à jour
- [ ] Corriger bugs signalés
- [ ] Ajouter nouvelles fonctionnalités
- [ ] Mettre à jour dépendances

---

## 🎯 Ordre Recommandé

### Semaine 1 : Préparation
- Jour 1-2 : Tests complets
- Jour 3 : Créer assets (icône, screenshots)
- Jour 4 : Rédiger descriptions
- Jour 5 : Créer politique de confidentialité

### Semaine 2 : Android
- Jour 1 : Créer compte + clé signature
- Jour 2 : Build + upload
- Jour 3-7 : Attente validation

### Semaine 3 : iOS (en parallèle possible)
- Jour 1 : Créer compte Apple Developer
- Jour 2-3 : Configuration Xcode + certificats
- Jour 4 : Build + upload
- Jour 5-7 : Attente validation

### Semaine 4 : Publication
- 🎉 Applications disponibles sur les stores !

---

## ⚠️ Points d'Attention

### Android
- **Clé de signature** : SAUVEGARDER ! Si perdue = impossible mettre à jour app
- **AAB vs APK** : Utiliser AAB (Google Play Bundle)
- **Tests** : Utiliser "Test fermé" avant production

### iOS
- **Mac requis** : Impossible de compiler iOS sans Mac
- **Compte démo** : Obligatoire pour Apple reviewers
- **Captures d'écran** : Respecter tailles exactes (rejet fréquent)
- **Politique** : URL obligatoire, doit être accessible

### Commun
- **Délais** : Prévoir 1-2 semaines pour première publication
- **Rejets** : Normal pour première app, corriger et resoumettre
- **Coûts** : 25$ Google + 99$/an Apple
- **Updates** : Plus rapides que première publication

---

## 📞 En Cas de Problème

### Application rejetée
1. Lire attentivement les raisons du rejet
2. Corriger les problèmes mentionnés
3. Resoumettre (délai recommence)
4. Contacter support si raison floue

### Build échoue
```bash
# Nettoyer complètement
flutter clean
rm -rf build/
rm pubspec.lock
flutter pub get
flutter build appbundle --release
```

### Certificats iOS invalides
1. Xcode → Preferences → Accounts
2. Télécharger à nouveau les profils
3. Clean Build Folder (Cmd+Shift+K)
4. Rebuild

---

**Bon courage pour la publication ! 🚀**

Consultez [GUIDE_PUBLICATION.md](GUIDE_PUBLICATION.md) pour les instructions détaillées.

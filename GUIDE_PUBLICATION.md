# 📱 Guide de Publication - PacifiTcal

Guide complet pour publier votre application sur **Google Play Store** et **Apple App Store**.

---

## 📋 Table des Matières

1. [Checklist Pré-Publication](#checklist-pré-publication)
2. [Configuration Initiale](#configuration-initiale)
3. [Android - Google Play Store](#android-google-play-store)
4. [iOS - Apple App Store](#ios-apple-app-store)
5. [Firebase Production](#firebase-production)
6. [Après Publication](#après-publication)

---

## ✅ Checklist Pré-Publication

### 📦 Application

- [ ] **Tests complets effectués**
  - [ ] Connexion/déconnexion
  - [ ] Réservation/annulation cours
  - [ ] Interface admin (users, cours, templates)
  - [ ] Mot de passe oublié
  - [ ] Abonnements expirés
  - [ ] Rate limiting (5 tentatives)

- [ ] **Version incrémentée**
  - [ ] `pubspec.yaml` : `version: 1.0.1+2`
  - [ ] Format : `MAJOR.MINOR.PATCH+BUILD_NUMBER`

- [ ] **Icône application créée**
  - [ ] Android : 512x512px (PNG)
  - [ ] iOS : 1024x1024px (PNG, sans transparence)

- [ ] **Assets vérifiés**
  - [ ] Images optimisées
  - [ ] Polices incluses (BebasNeue)
  - [ ] Pas de fichiers de test

### 🔥 Firebase

- [ ] **Firestore Rules déployées**
  ```bash
  firebase deploy --only firestore:rules
  ```

- [ ] **Index Firestore créés**
  ```bash
  firebase deploy --only firestore:indexes
  ```

- [ ] **Cloud Functions déployées** (si plan Blaze)
  ```bash
  firebase deploy --only functions
  ```

- [ ] **App Check configuré** (optionnel, plan Blaze)
  - [ ] reCAPTCHA Enterprise pour Android
  - [ ] App Attest pour iOS

### 📄 Contenu Marketing

- [ ] **Description courte** (80 caractères max)
- [ ] **Description longue** (4000 caractères max)
- [ ] **Captures d'écran** (minimum 2, recommandé 4-8)
- [ ] **Vidéo démo** (optionnel mais recommandé)
- [ ] **Politique de confidentialité** (URL obligatoire)
- [ ] **Conditions d'utilisation** (URL recommandée)

---

## 🔧 Configuration Initiale

### 1. Modifier l'identifiant de l'application ✅FAIT

#### Android - `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        // MODIFIER CET IDENTIFIANT
        applicationId "com.votresociete.pacifitcal"  // Ex: com.crossfit.pacifitcal
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 2
        versionName "1.0.1"
    }
}
```

#### iOS - Xcode ❌besoin de MAC

1. Ouvrir `ios/Runner.xcworkspace` avec Xcode
2. Sélectionner `Runner` → `General`
3. **Bundle Identifier** : `com.votresociete.pacifitcal`
4. **Version** : `1.0.1`
5. **Build** : `2`

### 2. Icône Application ✅FAIT

**Générer les icônes** :
```bash
# Installer flutter_launcher_icons
flutter pub add dev:flutter_launcher_icons

# Créer flutter_launcher_icons.yaml
```

**`flutter_launcher_icons.yaml`** :
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"  # Votre icône 1024x1024
  adaptive_icon_background: "#1A1A2E"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
```

**Générer** :
```bash
flutter pub run flutter_launcher_icons
```

---

## 📱 Android - Google Play Store

### Étape 1 : Créer Clé de Signature

**Sur Windows** :
```powershell
# Créer le dossier pour la clé
New-Item -ItemType Directory -Force -Path C:\keys

# Générer la clé (CONSERVER PRÉCIEUSEMENT)
keytool -genkey -v -keystore C:\keys\pacifitcal-upload-key.jks `
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload

# Répondre aux questions :
# - Mot de passe du keystore : [CRÉER MOT DE PASSE FORT]
# - Nom et prénom : PacifiTcal Team
# - Nom organisationnel : Votre Société
# - Ville : Paris
# - État : Ile-de-France
# - Code pays : FR
```

⚠️ **IMPORTANT** : Sauvegarder cette clé dans un endroit sûr ! Si vous la perdez, vous ne pourrez plus mettre à jour votre application.

### Étape 2 : Configurer la Signature

**Créer `android/key.properties`** :
```properties
storePassword=VOTRE_MOT_DE_PASSE_KEYSTORE
keyPassword=VOTRE_MOT_DE_PASSE_KEY
keyAlias=upload
storeFile=C:\\keys\\pacifitcal-upload-key.jks
```

⚠️ **Ajouter à `.gitignore`** :
```
android/key.properties
*.jks
```

**Modifier `android/app/build.gradle`** :

```gradle
// AJOUTER AVANT android {
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... config existante ...

    // AJOUTER AVANT buildTypes
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release  // AJOUTER CETTE LIGNE
            // ... reste de la config ...
        }
    }
}
```

### Étape 3 : Build Release

```bash
# Nettoyer le projet
flutter clean
flutter pub get

# Build AAB (App Bundle - recommandé)
flutter build appbundle --release

# OU Build APK (si nécessaire)
flutter build apk --release --split-per-abi
```

**Fichiers générés** :
- AAB : `build/app/outputs/bundle/release/app-release.aab`
- APK : `build/app/outputs/apk/release/app-arm64-v8a-release.apk`

### Étape 4 : Créer Compte Google Play

1. **Aller sur** : https://play.google.com/console
2. **Créer compte développeur** : 25$ (paiement unique)
3. **Remplir les informations** : Nom, adresse, etc.
4. **Validation** : 24-48h

### Étape 5 : Créer Application

**Dans Google Play Console** :

1. **Créer une application**
   - Nom : `PacifiTcal`
   - Langue par défaut : Français
   - Application/Jeu : Application
   - Gratuite/Payante : Gratuite

2. **Configuration de l'application**

#### a) Contenu de l'application

**Fiche du Play Store** :
- **Titre** : PacifiTcal (30 caractères max)
- **Description courte** :
  ```
  Application de réservation de cours CrossFit. Gérez vos séances facilement !
  ```
- **Description complète** :
  ```
  🏋️ PacifiTcal - Votre Compagnon CrossFit
  
  Réservez vos cours de CrossFit en quelques clics :
  ✅ Consultez le planning des séances
  ✅ Réservez ou annulez vos cours
  ✅ Gérez votre profil et abonnement
  ✅ Recevez des notifications
  
  Pour les coachs :
  👨‍💼 Interface d'administration complète
  📊 Gestion des utilisateurs et abonnements
  📅 Création de templates de cours
  📈 Statistiques en temps réel
  
  Sécurité garantie :
  🔒 Authentification Firebase
  🛡️ Protection des données
  ⚡ Synchronisation en temps réel
  ```

**Captures d'écran** (minimum 2, max 8) :
- Écran connexion
- Liste des cours
- Détail cours + réservation
- Profil utilisateur
- Dashboard admin (optionnel)
- Création cours (optionnel)

Dimensions recommandées : 1080x1920px (portrait) ou 1920x1080px (paysage)

**Icône de l'application** :
- Format : PNG
- Taille : 512x512px
- Pas de transparence
- Pas de coins arrondis (Google s'en charge)

**Bannière** (optionnel) :
- Format : PNG/JPEG
- Taille : 1024x500px

#### b) Catégorisation

- **Catégorie** : Santé et remise en forme
- **Tags** : CrossFit, Sport, Fitness, Réservation

#### c) Coordonnées

- **Email** : support@pacifitcal.com
- **Téléphone** : +33 X XX XX XX XX (optionnel)
- **Site web** : https://pacifitcal.com (si disponible)

#### d) Politique de confidentialité

**OBLIGATOIRE** - Créer une page web avec :
```
Politique de Confidentialité - PacifiTcal

Dernière mise à jour : 12/04/2026

1. Données collectées
Nous collectons :
- Email (authentification)
- Nom et prénom (profil utilisateur)
- Réservations de cours

2. Utilisation des données
Les données sont utilisées uniquement pour :
- Gestion de votre compte
- Réservation de cours
- Communication liée au service

3. Stockage
Données hébergées sur Firebase (Google Cloud Platform)
Chiffrement AES-256
Conformité RGPD

4. Droits
Vous pouvez demander :
- Accès à vos données
- Modification de vos données
- Suppression de votre compte

Contact : support@pacifitcal.com
```

Héberger sur : GitHub Pages, Firebase Hosting, ou votre site web.
URL : https://pacifitcal.com/privacy (à fournir dans la console)

### Étape 6 : Configuration Technique

#### a) Classement du contenu

- **Questionnaire** : Répondre aux questions Google
- **Violence** : Non
- **Contenu sexuel** : Non
- **Langage grossier** : Non
- **Âge minimum** : 13 ans (ou 16 selon réglementation)

#### b) Public cible et contenu

- **Public cible** : Adultes (18+)
- **Contenu publicitaire** : Non (sauf si vous ajoutez des pubs)

#### c) Données de sécurité

**Données collectées** :
- ✅ Nom et prénom
- ✅ Adresse email
- ✅ Identifiant utilisateur

**Utilisation** :
- ✅ Fonctionnalité de l'application
- ✅ Gestion de compte

**Partage** :
- ❌ Aucun partage avec des tiers

**Chiffrement** :
- ✅ Données chiffrées en transit (TLS 1.3)
- ✅ Données chiffrées au repos (AES-256)

**Suppression** :
- ✅ Utilisateur peut demander suppression
- ✅ Via paramètres ou contact support

### Étape 7 : Upload du Bundle

1. **Production** → **Versions** → **Créer une version**
2. **Uploader** `app-release.aab`
3. **Nom de version** : `1.0.1 (2)`
4. **Notes de version** :
   ```
   Version initiale :
   - Connexion sécurisée
   - Réservation de cours CrossFit
   - Gestion du profil
   - Interface administrateur
   ```

### Étape 8 : Tests et Publication

#### Option 1 : Test Fermé (Recommandé)

1. **Tests** → **Tests fermés** → **Créer une version**
2. **Ajouter testeurs** (email)
3. **Publier**
4. **Tester pendant 1-2 semaines**
5. **Corriger bugs**
6. **Promouvoir en production**

#### Option 2 : Publication Directe

1. **Production** → **Publier**
2. **Validation Google** : 1-7 jours (parfois quelques heures)
3. **Application disponible** sur Play Store

### Étape 9 : Après Validation

- 🎉 Application publiée !
- 📊 Consulter les statistiques : Play Console
- 💬 Répondre aux avis utilisateurs
- 🐛 Surveiller les rapports de crash

---

## 🍎 iOS - Apple App Store

### Prérequis

⚠️ **OBLIGATOIRE** :
- Mac avec macOS
- Xcode 15+
- Compte Apple Developer (99$/an)
- Certificats de signature

### Étape 1 : Compte Apple Developer

1. **S'inscrire** : https://developer.apple.com
2. **Payer** : 99$/an
3. **Validation** : 24-48h

### Étape 2 : Certificats et Identifiants

**Sur Mac, ouvrir Terminal** :

```bash
# Ouvrir le projet
cd /path/to/Pacifitcal_tst
open ios/Runner.xcworkspace
```

**Dans Xcode** :

1. **Sélectionner Runner** (projet)
2. **Signing & Capabilities**
3. **Team** : Sélectionner votre équipe Apple Developer
4. **Bundle Identifier** : `com.votresociete.pacifitcal`
5. **Cocher** "Automatically manage signing"

Xcode va automatiquement :
- Créer les certificats
- Créer le provisioning profile
- Enregistrer l'App ID

### Étape 3 : Configuration App

**`ios/Runner/Info.plist`** - Vérifier :

```xml
<key>CFBundleDisplayName</key>
<string>PacifiTcal</string>

<key>CFBundleShortVersionString</key>
<string>1.0.1</string>

<key>CFBundleVersion</key>
<string>2</string>
```

### Étape 4 : Build Release

```bash
# Nettoyer
flutter clean
flutter pub get

# Build iOS (sur Mac uniquement)
flutter build ios --release
```

**OU via Xcode** :

1. **Ouvrir** `ios/Runner.xcworkspace`
2. **Product** → **Scheme** → Sélectionner "Runner"
3. **Product** → **Destination** → "Any iOS Device"
4. **Product** → **Archive**
5. Attendre la compilation (5-10 min)

### Étape 5 : Upload vers App Store Connect

**Après l'archive** :

1. **Window** → **Organizer**
2. **Sélectionner** votre archive
3. **Distribute App**
4. **App Store Connect** → Next
5. **Upload** → Next
6. **Signing** : Automatic → Next
7. **Upload** (10-30 min selon connexion)

**OU via Transporter** :

1. **Installer** Transporter depuis Mac App Store
2. **Exporter** l'archive (.ipa)
3. **Ouvrir** Transporter
4. **Ajouter** le fichier .ipa
5. **Deliver**

### Étape 6 : App Store Connect

**Aller sur** : https://appstoreconnect.apple.com

#### a) Créer l'application

1. **Apps** → **+** → **Nouvelle app**
2. **Plateformes** : iOS
3. **Nom** : PacifiTcal
4. **Langue principale** : Français
5. **Bundle ID** : Sélectionner `com.votresociete.pacifitcal`
6. **SKU** : `pacifitcal-001` (identifiant unique interne)
7. **Accès complet** : Oui

#### b) Informations de l'app

**Informations générales** :
- **Nom** : PacifiTcal (30 caractères max)
- **Sous-titre** : Réservation CrossFit (30 caractères max)
- **Catégorie principale** : Santé et forme
- **Catégorie secondaire** : Sports (optionnel)

**Description** :
```
🏋️ PacifiTcal - Votre Compagnon CrossFit

Réservez vos cours de CrossFit en quelques clics :
✅ Consultez le planning des séances
✅ Réservez ou annulez vos cours
✅ Gérez votre profil et abonnement
✅ Notifications pour vos cours

Pour les coachs :
👨‍💼 Interface d'administration
📊 Gestion utilisateurs et abonnements
📅 Création de templates de cours
📈 Statistiques en temps réel

Sécurité garantie :
🔒 Authentification Firebase
🛡️ Protection des données (RGPD)
⚡ Synchronisation temps réel
```

**Mots-clés** (100 caractères, séparés par virgules) :
```
crossfit,sport,fitness,réservation,cours,gym,wod,entraînement
```

**URL de support** : https://pacifitcal.com/support
**URL marketing** : https://pacifitcal.com (optionnel)

#### c) Captures d'écran

**iPhone 6.7"** (iPhone 14 Pro Max) - OBLIGATOIRE :
- Taille : 1290x2796px
- Minimum 2, maximum 10
- Format : PNG ou JPEG

**iPhone 6.5"** (iPhone 11 Pro Max) :
- Taille : 1242x2688px
- Recommandé pour compatibilité

**Utiliser simulateur** :
```bash
# Lancer simulateur
open -a Simulator

# Sélectionner iPhone 14 Pro Max
# Lancer l'app : flutter run
# Prendre captures : Cmd+S
# Fichiers dans : ~/Desktop
```

**Astuce** : Utiliser Figma/Canva pour ajouter des textes marketing sur les captures.

#### d) Icône App Store

- **Taille** : 1024x1024px
- **Format** : PNG ou JPEG
- **Pas de transparence**
- **Pas de coins arrondis**

#### e) Politique de confidentialité

**URL** : https://pacifitcal.com/privacy (même que Android)

#### f) Informations de classement

**Classification par âge** :
- Violence : Aucune
- Contenu médical : Aucun
- Âge : 4+ (tout public)

**Informations de confidentialité** :
- **Données collectées** : Nom, Email
- **Utilisation** : Fonctionnalité app, gestion compte
- **Liaison des données** : Oui (liées à l'identité)
- **Suivi** : Non

### Étape 7 : Version et Build

1. **Sélectionner** le build uploadé (peut prendre 30min-1h pour apparaître)
2. **Informations de version** :
   - **Nouveautés** :
     ```
     Version initiale :
     - Connexion sécurisée
     - Réservation de cours CrossFit
     - Gestion du profil utilisateur
     - Interface administrateur complète
     ```

### Étape 8 : Soumission

1. **Ajouter pour révision**
2. **Questionnaire d'export** :
   - Contient chiffrement : Oui
   - Utilise chiffrement standard : Oui
   - App commercialisée en France uniquement : Oui/Non

3. **Soumettre pour révision**

**Délai de révision** : 24h - 7 jours (généralement 1-2 jours)

### Étape 9 : Après Approbation

- ✅ **Approuvé** : Application disponible sur App Store
- ❌ **Rejeté** : Lire les raisons, corriger, resoumettre

**Raisons fréquentes de rejet** :
- Captures d'écran floues
- Manque de politique de confidentialité
- Fonctionnalité non testable (compte requis)
- Bug lors de la review

**Solution compte requis** :
- Fournir compte de démo dans les notes de révision :
  ```
  Compte test :
  Email : test@pacifitcal.com
  Mot de passe : Test123!@#
  ```

---

## 🔥 Firebase Production

### Configuration App Check (Optionnel - Plan Blaze)

**Si vous avez le plan Blaze** :

#### Android

1. **Console Firebase** → App Check
2. **Activer** pour votre app Android
3. **Provider** : Play Integrity
4. **Enregistrer**

**Modifier `lib/services/app_check_service.dart`** :
```dart
androidProvider: AndroidProvider.playIntegrity, // Au lieu de debug
```

#### iOS

1. **Console Firebase** → App Check
2. **Activer** pour votre app iOS
3. **Provider** : App Attest
4. **Enregistrer**

**Modifier `lib/services/app_check_service.dart`** :
```dart
appleProvider: AppleProvider.deviceCheck, // Au lieu de debug
```

### Rebuild et Redéployer

```bash
flutter clean
flutter pub get

# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📊 Après Publication

### Monitoring

**Google Play Console** :
- 📈 Statistiques d'installation
- ⭐ Notes et avis
- 🐛 Rapports de crash (Crashlytics)
- 📱 Appareils supportés

**App Store Connect** :
- 📊 Analyses (téléchargements, revenus)
- ⭐ Notes et avis
- 🐛 Rapports de crash
- 💬 Avis utilisateurs

### Mises à Jour

**Processus** :
1. Corriger bugs / ajouter fonctionnalités
2. Incrémenter version dans `pubspec.yaml` : `1.0.2+3`
3. Build release
4. Upload sur Play Console / App Store Connect
5. Soumettre pour révision

**Fréquence recommandée** : 1 mise à jour par mois

### Répondre aux Avis

- ✅ Toujours répondre (taux de réponse visible)
- ✅ Être poli et professionnel
- ✅ Proposer solutions aux problèmes
- ✅ Remercier les avis positifs

---

## 🎯 Checklist Finale

### Avant Soumission

- [ ] Tests complets effectués (auth, réservations, admin)
- [ ] Aucun bug critique détecté
- [ ] Firestore Rules déployées
- [ ] Version incrémentée
- [ ] Icône 512x512 (Android) et 1024x1024 (iOS)
- [ ] Captures d'écran préparées (min 2)
- [ ] Description rédigée (courte + longue)
- [ ] Politique de confidentialité en ligne
- [ ] Compte de démo créé (pour reviewers Apple)

### Android

- [ ] Clé de signature créée et sauvegardée
- [ ] `key.properties` configuré
- [ ] AAB compilé sans erreurs
- [ ] Compte Google Play créé (25$)
- [ ] Application créée dans Play Console
- [ ] Fiche Play Store complétée
- [ ] Bundle uploadé
- [ ] Soumis pour révision

### iOS

- [ ] Compte Apple Developer actif (99$/an)
- [ ] Mac disponible avec Xcode
- [ ] Certificats configurés
- [ ] IPA compilé et uploadé
- [ ] Application créée dans App Store Connect
- [ ] Fiche App Store complétée
- [ ] Build sélectionné
- [ ] Soumis pour révision

---

## 📞 Support

**Questions fréquentes** :

**Q: Combien de temps pour la validation ?**
- Google Play : 1-7 jours (souvent quelques heures)
- App Store : 24h-7 jours (généralement 1-2 jours)

**Q: Coût total ?**
- Google Play : 25$ (une fois)
- App Store : 99$/an
- Firebase : Gratuit (ou Blaze si Cloud Functions)

**Q: Puis-je tester avant publication ?**
- Oui ! Utilisez les tests fermés (Google) ou TestFlight (Apple)

**Q: Puis-je publier uniquement sur Android ?**
- Oui, les deux plateformes sont indépendantes

**Q: L'app est rejetée, que faire ?**
- Lire attentivement les raisons
- Corriger les problèmes
- Resoumettre (délai de révision recommence)

---

**Date** : 12/04/2026  
**Version guide** : 1.0  
**Application** : PacifiTcal v1.0.1

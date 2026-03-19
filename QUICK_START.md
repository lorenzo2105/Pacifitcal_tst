lancer le SDK depuis windsurf
lancer le prjet avec flutter run
relod le projet avec R



# 🚀 Guide de Démarrage Rapide — PacifitCal

## Installation et lancement en 10 minutes

### 1. Prérequis

```bash
# Vérifier que Flutter est installé
flutter doctor

# Si Flutter n'est pas installé, téléchargez depuis :
# https://docs.flutter.dev/get-started/install
```

### 2. Cloner et installer les dépendances

```bash
cd C:\wamp64\www\PacifitCal
flutter pub get
```

### 3. Configurer Firebase

#### Option A : FlutterFire CLI (recommandé)

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer Firebase (génère firebase_options.dart automatiquement)
flutterfire configure
```

#### Option B : Manuellement

1. Créez un projet sur https://console.firebase.google.com
2. Activez **Authentication** (Email/Password)
3. Créez une base **Firestore** (mode production)
4. Activez **Cloud Messaging**
5. Téléchargez :
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
6. Remplissez `lib/firebase_options.dart` avec vos clés

### 4. Déployer les règles Firestore

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 5. Déployer les Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
cd ..
```

### 6. Télécharger la police BebasNeue

1. Téléchargez **BebasNeue-Regular.ttf** : https://fonts.google.com/specimen/Bebas+Neue
2. Placez-le dans `assets/fonts/BebasNeue-Regular.ttf`

### 7. Lancer l'application

#### Sur émulateur Android

```bash
flutter run
```

#### Sur appareil physique

```bash
# Connectez votre téléphone en USB avec "Débogage USB" activé
flutter devices
flutter run -d <device_id>
```

#### Sur iOS (macOS uniquement)

```bash
cd ios
pod install
cd ..
open -a Simulator
flutter run
```

### 8. Créer le premier compte Admin

**Via Firebase Console :**

1. **Authentication** → Ajouter utilisateur
   - Email : `admin@pacifitcal.com`
   - Mot de passe : votre choix sécurisé
   - **Copier l'UID généré**

2. **Firestore** → Collection `users` → Ajouter document
   - ID : `<l'UID copié>`
   - Champs :
     ```
     nom: "Admin"
     prenom: "Super"
     email: "admin@pacifitcal.com"
     role: "admin"
     active: true
     subscription_start: null
     subscription_end: null
     fcm_token: null
     ```

3. Connectez-vous dans l'app avec `admin@pacifitcal.com`

---

## Commandes Utiles

```bash
# Nettoyer le build
flutter clean && flutter pub get

# Rebuild complet
flutter run --debug

# Build release Android
flutter build apk --release

# Build release iOS
flutter build ipa --release

# Voir les logs
flutter logs

# Analyser le code
flutter analyze

# Lancer les tests
flutter test
```

---

## Résolution de Problèmes

### ❌ Erreur : "firebase_options.dart not found"

**Solution :** Lancez `flutterfire configure` ou créez le fichier manuellement.

### ❌ Erreur : "BebasNeue font not found"

**Solution :** Téléchargez la police et placez-la dans `assets/fonts/`.

### ❌ Erreur : "FirebaseException: PERMISSION_DENIED"

**Solution :** Déployez les règles Firestore :
```bash
firebase deploy --only firestore:rules
```

### ❌ L'admin est déconnecté après avoir créé un utilisateur

**Solution :** Les Cloud Functions sont activées. Vérifiez qu'elles sont déployées :
```bash
firebase deploy --only functions
```

### ❌ Les notifications ne fonctionnent pas

**Solution :** 
1. Vérifiez que FCM est activé dans Firebase
2. Déployez les Cloud Functions
3. Sur Android : vérifiez `google-services.json`
4. Sur iOS : vérifiez `GoogleService-Info.plist` et les permissions dans `Info.plist`

---

## Structure du Projet

```
lib/
├── config/              # Configuration (theme, routes)
├── models/              # Modèles de données
├── services/            # Services Firebase (Auth, Firestore, FCM)
├── providers/           # State management (Provider)
├── screens/             # UI (auth, user, admin)
├── widgets/             # Widgets réutilisables
├── main.dart            # Point d'entrée
└── firebase_options.dart # Config Firebase (généré)
```

---

## Prochaines Étapes

1. ✅ Tester l'inscription d'un adhérent
2. ✅ Créer un cours depuis le dashboard admin
3. ✅ Réserver un cours depuis l'interface utilisateur
4. ✅ Tester les notifications (déployer les Cloud Functions)
5. 📱 Publier sur Google Play / App Store (voir README.md)

---

**Besoin d'aide ?** Consultez le `README.md` complet pour les instructions détaillées.

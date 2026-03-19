# 📥 Installation Flutter sur Windows

## Étape 1 : Télécharger Flutter SDK

1. **Téléchargez Flutter** : https://docs.flutter.dev/get-started/install/windows
   - Cliquez sur **"flutter_windows_X.X.X-stable.zip"**
   - Taille : ~1.5 GB

2. **Extrayez le fichier ZIP** :
   - Extraire dans `C:\` (ou un autre emplacement **sans espaces**)
   - Recommandé : `C:\flutter`
   - ⚠️ **NE PAS** extraire dans `C:\Program Files\` (espaces dans le nom)

## Étape 2 : Ajouter Flutter au PATH

### Option A : Via l'interface graphique Windows

1. **Ouvrir les Variables d'environnement** :
   - Rechercher "Variables d'environnement" dans le menu Démarrer
   - Ou : Panneau de configuration → Système → Paramètres système avancés

2. **Modifier la variable PATH** :
   - Dans "Variables utilisateur", sélectionnez **Path**
   - Cliquez sur **Modifier**
   - Cliquez sur **Nouveau**
   - Ajoutez : `C:\flutter\bin` (adaptez selon votre emplacement)
   - Cliquez sur **OK** trois fois

### Option B : Via PowerShell (Admin)

```powershell
# Ouvrir PowerShell en tant qu'administrateur
# Ajouter Flutter au PATH de l'utilisateur
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

3. **Redémarrer votre terminal** (PowerShell, CMD, ou VS Code)

## Étape 3 : Vérifier l'installation

```bash
flutter --version
```

**Sortie attendue** :
```
Flutter 3.19.0 • channel stable
Framework • revision abc123...
Engine • revision xyz456...
Tools • Dart 3.3.0
```

## Étape 4 : Installer les dépendances manquantes

```bash
flutter doctor
```

Cette commande vérifie les outils manquants. Vous verrez :

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.19.0)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Visual Studio - develop Windows apps
[!] Android Studio (not installed)
[✓] VS Code (version 1.85)
[✓] Connected device (1 available)
```

### Installer Android Studio (pour Android)

1. **Télécharger** : https://developer.android.com/studio
2. **Installer** avec les options par défaut
3. **Ouvrir Android Studio** :
   - Configure → SDK Manager
   - Cocher **Android SDK Platform-Tools**
   - Cocher **Android SDK Build-Tools**
   - Apply → OK
4. **Accepter les licences** :
   ```bash
   flutter doctor --android-licenses
   ```
   (taper `y` pour accepter toutes)

### Installer Visual Studio (optionnel, pour Windows desktop)

Si vous voulez compiler pour Windows :
1. **Télécharger** : https://visualstudio.microsoft.com/downloads/
2. **Installer** : Visual Studio Community avec **"Développement Desktop en C++"**

## Étape 5 : Configurer un émulateur Android

### Avec Android Studio
1. Ouvrir Android Studio
2. **Tools** → **Device Manager**
3. Cliquer sur **Create Device**
4. Sélectionner **Pixel 7** (recommandé)
5. Télécharger l'image système (API 33 ou supérieur)
6. Finish

### Lancer l'émulateur
```bash
# Lister les émulateurs
emulator -list-avds

# Lancer un émulateur
emulator -avd Pixel_7_API_33
```

## Étape 6 : Tester Flutter

```bash
# Vérifier que tout est OK
flutter doctor -v

# Créer un projet de test
flutter create test_app
cd test_app
flutter run
```

## Étape 7 : Installer les dépendances PacifitCal

```bash
cd C:\wamp64\www\PacifitCal
flutter pub get
```

---

## Résolution de Problèmes

### ❌ `flutter: command not found` après ajout au PATH

**Solution** : Redémarrez complètement votre terminal (fermez VS Code et rouvrez).

### ❌ `cmdline-tools component is missing`

**Solution** :
```bash
# Android Studio → SDK Manager → SDK Tools
# Cocher "Android SDK Command-line Tools (latest)"
# Apply
```

### ❌ `Unable to locate Android SDK`

**Solution** : Configurer manuellement :
```bash
flutter config --android-sdk C:\Users\VOTRE_NOM\AppData\Local\Android\Sdk
```

### ❌ `Error: Unable to find git in your PATH`

**Solution** : Installer Git for Windows : https://git-scm.com/download/win

### ❌ Erreurs de licences Android

**Solution** :
```bash
flutter doctor --android-licenses
# Accepter toutes (taper 'y')
```

---

## Commandes Essentielles

```bash
# Vérifier configuration
flutter doctor

# Installer dépendances
flutter pub get

# Nettoyer build
flutter clean

# Lancer app (émulateur ou appareil)
flutter run

# Lister devices connectés
flutter devices

# Créer APK release
flutter build apk --release
```

---

## Après Installation

1. ✅ Redémarrer VS Code
2. ✅ Installer extension **"Flutter"** dans VS Code
3. ✅ `flutter pub get` dans le projet PacifitCal
4. ✅ Configurer Firebase (voir `QUICK_START.md`)
5. ✅ Lancer l'app : `flutter run`

---

**Besoin d'aide ?** Documentation officielle : https://docs.flutter.dev/get-started/install/windows

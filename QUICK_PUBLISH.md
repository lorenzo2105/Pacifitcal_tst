# 🚀 Publication Rapide - En 5 Étapes

Guide ultra-simplifié pour publier PacifiTcal sur les stores.

---

## 📱 Android (Google Play Store)

### Étape 1 : Créer Clé (5 min)
```powershell
# Sur Windows
keytool -genkey -v -keystore C:\keys\pacifitcal-key.jks `
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```
⚠️ **Sauvegarder la clé !** Si perdue = impossible de mettre à jour l'app.

### Étape 2 : Configurer (10 min)

**Créer `android/key.properties`** :
```properties
storePassword=VotreMDP
keyPassword=VotreMDP
keyAlias=upload
storeFile=C:\\keys\\pacifitcal-key.jks
```

**Modifier `android/app/build.gradle`** :
```gradle
applicationId "com.votresociete.pacifitcal"  // Ligne ~50
versionCode 2                                 // Ligne ~52
versionName "1.0.1"                          // Ligne ~53
```

### Étape 3 : Build (5 min)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
✅ Fichier créé : `build/app/outputs/bundle/release/app-release.aab`

### Étape 4 : Compte Google Play (15 min)
1. Aller sur https://play.google.com/console
2. Payer 25$ (une fois pour toujours)
3. Créer application : Nom "PacifiTcal"
4. Remplir description (voir templates ci-dessous)
5. Uploader 2 captures d'écran minimum
6. Uploader icône 512x512

### Étape 5 : Publier (5 min)
1. Production → Versions → Créer
2. Uploader `app-release.aab`
3. Notes : "Version initiale"
4. Envoyer pour révision
5. ⏳ Attendre 1-7 jours → 🎉 Publié !

**Total : ~1h de travail + 1-7 jours validation**

---

## 🍎 iOS (Apple App Store)

⚠️ **Requis : Mac + Xcode + 99$/an**

### Étape 1 : Compte Apple (10 min)
1. https://developer.apple.com → S'inscrire
2. Payer 99$/an
3. ⏳ Attendre 24-48h validation

### Étape 2 : Xcode (15 min)
```bash
# Sur Mac
cd /chemin/vers/Pacifitcal_tst
open ios/Runner.xcworkspace
```

**Dans Xcode** :
1. Runner → Signing & Capabilities
2. Team → Sélectionner votre équipe
3. Bundle ID → `com.votresociete.pacifitcal`
4. ✅ "Automatically manage signing"

### Étape 3 : Build (10 min)
```bash
flutter clean
flutter pub get
flutter build ios --release
```

**Dans Xcode** :
1. Product → Archive (10 min)
2. Window → Organizer
3. Distribute App → App Store Connect
4. Upload (20 min)

### Étape 4 : App Store Connect (30 min)
1. https://appstoreconnect.apple.com
2. Apps → + → Nouvelle app
3. Nom : "PacifiTcal"
4. Bundle ID : Sélectionner le vôtre
5. Remplir description (voir templates)
6. Uploader captures 1290x2796 (min 2)
7. Uploader icône 1024x1024
8. Sélectionner le build uploadé

### Étape 5 : Publier (5 min)
1. Fournir compte démo dans notes :
   ```
   Email : demo@pacifitcal.com
   MDP : Demo123!@#
   ```
2. Envoyer pour révision
3. ⏳ Attendre 1-3 jours → 🎉 Publié !

**Total : ~1h30 + 1-3 jours validation**

---

## 📝 Templates Prêts à Utiliser

### Description Courte (80 chars)
```
Réservez vos cours CrossFit facilement. Profil, planning, notifications.
```

### Description Longue
```
🏋️ PacifiTcal - Votre Compagnon CrossFit

Réservez vos cours en quelques clics :
✅ Consultez le planning des séances
✅ Réservez ou annulez vos cours
✅ Gérez votre profil et abonnement
✅ Notifications pour vos réservations

Pour les coachs :
👨‍💼 Interface d'administration complète
📊 Gestion des utilisateurs
📅 Création de cours et templates
📈 Statistiques en temps réel

Sécurité :
🔒 Authentification Firebase sécurisée
🛡️ Protection des données (RGPD)
⚡ Synchronisation temps réel
```

### Notes de Version
```
Version 1.0.1 :
- Connexion sécurisée avec email/mot de passe
- Réservation et annulation de cours CrossFit
- Gestion du profil utilisateur
- Interface administrateur (users, cours, stats)
- Réinitialisation mot de passe
- Système d'abonnements
```

---

## 📸 Captures d'Écran à Préparer

**Minimum 2, recommandé 4** :

1. **Écran connexion** - Montre sécurité
2. **Liste cours** - Fonctionnalité principale
3. **Détail cours** - Réservation
4. **Profil** - Gestion compte

**Dimensions** :
- Android : 1080x1920 (portrait) ou 1920x1080 (paysage)
- iOS : 1290x2796 (iPhone 14 Pro Max)

**Astuce** : Utiliser simulateur + screenshot

---

## 🔐 Politique de Confidentialité

**OBLIGATOIRE pour les deux stores !**

1. Copier le contenu de `POLITIQUE_CONFIDENTIALITE.md`
2. Héberger sur :
   - GitHub Pages (gratuit)
   - Firebase Hosting (gratuit)
   - Votre site web
3. Fournir l'URL dans les consoles

**URL exemple** : `https://votresite.com/privacy`

---

## ⚡ Checklist Express

### Avant de Commencer
- [ ] Tests complets effectués
- [ ] Version `1.0.1+2` dans `pubspec.yaml`
- [ ] Icône 512x512 (Android) et 1024x1024 (iOS)
- [ ] 2 captures d'écran minimum
- [ ] Politique confidentialité en ligne

### Android
- [ ] Clé créée et sauvegardée
- [ ] `key.properties` configuré
- [ ] AAB compilé sans erreur
- [ ] Compte Google Play (25$)
- [ ] Fiche Play Store complétée
- [ ] AAB uploadé
- [ ] Soumis ✅

### iOS
- [ ] Compte Apple Developer (99$/an)
- [ ] Mac + Xcode disponibles
- [ ] Signing configuré dans Xcode
- [ ] Archive uploadée
- [ ] Fiche App Store complétée
- [ ] Compte démo fourni
- [ ] Soumis ✅

---

## 💰 Coûts

| Item | Prix | Fréquence |
|------|------|-----------|
| Google Play | 25$ | Une fois |
| Apple Developer | 99$ | Par an |
| Firebase | Gratuit | - |
| **TOTAL** | **124$** | 1ère année |
|  | **99$** | Années suivantes |

---

## ⏱️ Timeline Réaliste

| Jour | Tâche |
|------|-------|
| J1 | Préparer assets (icône, screenshots) |
| J2 | Build Android + créer compte |
| J3 | Upload Android + soumission |
| J4 | Build iOS (Mac) + créer compte |
| J5 | Upload iOS + soumission |
| J6-13 | ⏳ Validation en cours |
| J14 | 🎉 Publié sur les deux stores ! |

---

## 🆘 Problèmes Courants

### "keystore not found"
```bash
# Vérifier le chemin dans key.properties
# Utiliser \\ pour Windows : C:\\keys\\...
```

### "signing failed" (iOS)
```
Xcode → Preferences → Accounts → Download Manual Profiles
```

### "Application rejetée"
- Lire les raisons attentivement
- Corriger les problèmes
- Resoumettre (délai recommence)

### "Build trop lourd"
```bash
flutter clean
flutter build appbundle --release --split-per-abi
```

---

## 📞 Besoin d'Aide ?

**Documentation complète** : [GUIDE_PUBLICATION.md](GUIDE_PUBLICATION.md)  
**Checklist détaillée** : [CHECKLIST_PUBLICATION.md](CHECKLIST_PUBLICATION.md)

**Support Google Play** : https://support.google.com/googleplay/android-developer  
**Support Apple** : https://developer.apple.com/support

---

## 🎯 Résumé Ultra-Rapide

1. **Préparer** : Icône + Screenshots + Description (1h)
2. **Android** : Clé + Build + Upload (1h) → Validation 1-7j
3. **iOS** : Certificats + Build + Upload (1h30, Mac requis) → Validation 1-3j
4. **Total** : ~3h de travail effectif + ~1 semaine validation

**Et voilà, votre app est sur les stores ! 🚀**

---

**Dernière MAJ** : 12/04/2026  
**Guide rapide pour PacifiTcal v1.0.1**

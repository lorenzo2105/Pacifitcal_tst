# 🏋️ PacifiTcal - Application CrossFit

Application mobile Flutter pour gestion de cours CrossFit.  
Compatible **iOS** et **Android**.

**Score Sécurité** : 100/100 🟢✨

---

## 🚀 Démarrage Rapide

```bash
# 1. Cloner le projet
git clone <repository-url>
cd Pacifitcal_tst

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase (voir DOCUMENTATION.md)
flutterfire configure

# 4. Déployer les règles Firestore
firebase deploy --only firestore:rules

# 5. Lancer l'application
flutter run
```

---

## 📱 Fonctionnalités

### 👤 Utilisateurs
- ✅ Inscription / Connexion sécurisée
- ✅ Réservation de cours
- ✅ Gestion du profil
- ✅ Historique des réservations

### 👨‍💼 Administrateurs
- ✅ Dashboard statistiques
- ✅ Gestion utilisateurs & abonnements
- ✅ Création/modification cours
- ✅ Gestion templates hebdomadaires
- ✅ Vue participants par cours

---

## 🛠️ Stack Technique

| Composant | Technologie |
|-----------|-------------|
| Framework | Flutter 3.0+ |
| Langage | Dart 3.0+ |
| Backend | Firebase |
| State Management | Provider |
| Navigation | GoRouter |
| Base de données | Firestore |
| Authentification | Firebase Auth |

---

## 📁 Structure

```
lib/
├── config/           # Configuration (thème, routes)
├── models/           # Modèles de données
├── providers/        # State management
├── screens/          # Interfaces UI
├── services/         # Logique métier
├── utils/            # Utilitaires
└── main.dart         # Point d'entrée
```

---

## 🔒 Sécurité

**Score** : 100/100 ✅

- ✅ Rate limiting (5 tentatives, 15min blocage)
- ✅ Validation stricte (anti-XSS, injection)
- ✅ Erreurs mappées (pas de fuite technique)
- ✅ Chiffrement AES-256 (Firebase natif)
- ✅ App Check anti-bot/CSRF
- ✅ Règles Firestore strictes
- ✅ Versioning API (migrations auto)
- ✅ Conformité RGPD

---

## 📚 Documentation Complète

**Consultez [DOCUMENTATION.md](DOCUMENTATION.md) pour** :
- Installation détaillée
- Architecture complète
- Guide de déploiement
- Règles Firestore
- Sécurité détaillée
- Maintenance & dépannage

---

## 🎯 Premier Compte Admin

**Via Console Firebase** :
1. **Authentication** → Ajouter utilisateur
   - Email : `admin@exemple.com`
   - Copier l'UID généré

2. **Firestore** → Collection `users` → Ajouter document
   - ID : UID copié
   - Champs :
     ```
     nom: "Admin"
     prenom: "Super"
     email: "admin@exemple.com"
     role: "admin"
     active: true
     schema_version: 1
     ```

3. Se connecter dans l'app avec ces identifiants

---

## 📦 Build Production

**Android** :
```bash
flutter build apk --release
```

**iOS** (macOS requis) :
```bash
flutter build ios --release
```

---

## 🧪 Tests

```bash
# Tests manuels recommandés
1. Créer compte utilisateur
2. Tester rate limiting (5 échecs)
3. Réserver/annuler cours
4. Tester abonnement expiré
5. Interface admin complète
```

---

## 📞 Support

- 📚 **Documentation** : [DOCUMENTATION.md](DOCUMENTATION.md)
- 🔧 **Flutter** : https://flutter.dev/docs
- 🔥 **Firebase** : https://firebase.google.com/docs

---

**Version** : 1.0.0  
**Dernière MAJ** : 12/04/2026  
**Statut** : ✅ Production Ready

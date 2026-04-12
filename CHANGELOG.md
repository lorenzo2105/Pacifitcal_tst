# 📝 Changelog - PacifiTcal

Toutes les modifications notables du projet.

---

## [1.0.0] - 2026-04-12

### ✨ Ajouté
- Application Flutter complète pour gestion CrossFit
- Interface utilisateur (réservations, profil)
- Interface administrateur (users, cours, templates)
- Authentification Firebase sécurisée
- Système d'abonnements (1, 6, 12 mois)
- Templates de cours hebdomadaires
- Score sécurité 100/100

### 🔒 Sécurité
- Rate limiting authentification (5 tentatives, 15min blocage)
- Validation stricte entrées (anti-XSS, injection)
- Erreurs mappées (ErrorHandler)
- Chiffrement AES-256 Firebase natif
- Firebase App Check (anti-bot/CSRF)
- Règles Firestore renforcées
- Versioning API (migrations automatiques)
- Logs zéro en production (kDebugMode)
- Conformité RGPD

### 📚 Documentation
- DOCUMENTATION.md (guide complet)
- README.md (démarrage rapide)
- firestore.rules (règles déployées)

### 🧹 Nettoyage
- Suppression imports inutilisés (NotificationService)
- Suppression 14 fichiers .md redondants
- Consolidation documentation
- Code épuré et simplifié

---

**Format** : [Version] - AAAA-MM-JJ  
**Types** : Ajouté, Modifié, Supprimé, Corrigé, Sécurité

# Politique de Confidentialité - PacifiTcal

**Dernière mise à jour** : 12 avril 2026

---

## 1. Introduction

PacifiTcal ("nous", "notre", "l'application") s'engage à protéger la confidentialité de ses utilisateurs. Cette politique de confidentialité explique quelles données nous collectons, comment nous les utilisons et vos droits concernant vos informations personnelles.

---

## 2. Responsable du Traitement

**Nom de l'entreprise** : [Votre Société]  
**Adresse** : [Votre Adresse]  
**Email** : support@pacifitcal.com  
**Téléphone** : [Votre Téléphone]

---

## 3. Données Collectées

### 3.1 Données Fournies Directement

Lors de la création de votre compte (par un administrateur), nous collectons :

- **Nom et prénom** : Pour vous identifier dans l'application
- **Adresse email** : Pour l'authentification et les communications
- **Mot de passe** : Chiffré, jamais stocké en clair

### 3.2 Données Générées Automatiquement

Lors de l'utilisation de l'application, nous collectons :

- **Réservations de cours** : Historique de vos réservations
- **Dates d'abonnement** : Début et fin de votre abonnement
- **Statut du compte** : Actif ou désactivé
- **Identifiant unique** : Généré par Firebase Authentication

### 3.3 Données Non Collectées

Nous **ne collectons pas** :
- Numéro de téléphone
- Adresse postale
- Informations bancaires
- Localisation GPS
- Contacts
- Photos
- Données de santé

---

## 4. Base Légale du Traitement

Conformément au RGPD, nous traitons vos données sur la base de :

- **Exécution du contrat** : Gestion de votre compte et réservations
- **Intérêt légitime** : Amélioration de nos services
- **Consentement** : Pour les communications marketing (si applicable)

---

## 5. Utilisation des Données

Vos données sont utilisées uniquement pour :

### 5.1 Fonctionnalités de l'Application
- Authentification et accès à votre compte
- Gestion de vos réservations de cours
- Affichage de votre profil et abonnement
- Notifications relatives à vos cours (si activées)

### 5.2 Administration
- Gestion des utilisateurs par les administrateurs
- Support technique en cas de problème
- Amélioration de l'application

### 5.3 Sécurité
- Prévention de la fraude et des abus
- Protection contre les accès non autorisés
- Conformité légale

---

## 6. Partage des Données

### 6.1 Partage Interne
Vos données sont accessibles uniquement par :
- Les administrateurs de votre salle de CrossFit
- Vous-même via votre compte

### 6.2 Partage avec des Tiers

Nous utilisons les services suivants pour héberger et sécuriser vos données :

**Firebase (Google Cloud Platform)** :
- **Service** : Hébergement, authentification, base de données
- **Localisation** : Europe (region: europe-west1)
- **Certification** : ISO 27001, SOC 2, RGPD
- **Politique** : https://firebase.google.com/support/privacy

Nous **ne vendons jamais** vos données à des tiers.  
Nous **ne partageons pas** vos données à des fins publicitaires.

---

## 7. Stockage et Sécurité

### 7.1 Localisation des Données
Vos données sont stockées sur des serveurs sécurisés Google Cloud Platform situés en **Europe** (Belgique, Pays-Bas ou Finlande).

### 7.2 Mesures de Sécurité

Nous mettons en œuvre des mesures techniques et organisationnelles pour protéger vos données :

**Chiffrement** :
- ✅ Chiffrement en transit : TLS 1.3
- ✅ Chiffrement au repos : AES-256 (Google Cloud KMS)
- ✅ Mots de passe : Hashage bcrypt/scrypt par Firebase

**Protection** :
- ✅ Règles de sécurité Firestore strictes
- ✅ Rate limiting (protection brute force)
- ✅ Validation des entrées (anti-injection)
- ✅ Firebase App Check (anti-bot)

**Accès** :
- ✅ Authentification obligatoire
- ✅ Permissions basées sur les rôles (admin/user)
- ✅ Logs de sécurité

### 7.3 Durée de Conservation

- **Compte actif** : Données conservées tant que votre compte existe
- **Compte supprimé** : Données supprimées immédiatement de Firestore
- **Authentification** : UID Firebase supprimé sous 180 jours (automatique)
- **Logs de sécurité** : Conservés 90 jours maximum

---

## 8. Vos Droits (RGPD)

Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez des droits suivants :

### 8.1 Droit d'Accès
Vous pouvez demander une copie de toutes vos données personnelles.

### 8.2 Droit de Rectification
Vous pouvez modifier vos données directement dans l'application (Profil) ou nous contacter.

### 8.3 Droit à l'Effacement ("Droit à l'oubli")
Vous pouvez demander la suppression complète de votre compte et de toutes vos données.

### 8.4 Droit à la Limitation
Vous pouvez demander la limitation du traitement de vos données.

### 8.5 Droit à la Portabilité
Vous pouvez recevoir vos données dans un format structuré et lisible (JSON).

### 8.6 Droit d'Opposition
Vous pouvez vous opposer au traitement de vos données pour des motifs légitimes.

### 8.7 Droit de Réclamation
Vous pouvez déposer une plainte auprès de la CNIL (France) ou de votre autorité de protection des données.

**Contact CNIL** : https://www.cnil.fr

---

## 9. Exercer Vos Droits

Pour exercer vos droits, contactez-nous :

**Email** : support@pacifitcal.com  
**Objet** : "Demande RGPD - [Votre Droit]"

**Délai de réponse** : 30 jours maximum

**Informations à fournir** :
- Nom et prénom
- Adresse email du compte
- Nature de votre demande
- Copie d'une pièce d'identité (si nécessaire pour vérification)

---

## 10. Cookies et Technologies de Suivi

### 10.1 Cookies Utilisés

L'application **ne utilise pas de cookies** pour le suivi publicitaire.

**Cookies techniques** (nécessaires au fonctionnement) :
- Token d'authentification Firebase (session)
- Préférences utilisateur (stockage local)

### 10.2 Analyse

Nous n'utilisons pas Google Analytics ou autres outils d'analyse tiers.

Firebase collecte des données anonymes de performance et crash pour améliorer la stabilité de l'application. Vous pouvez désactiver cette collecte dans les paramètres de votre appareil.

---

## 11. Mineurs

L'application est destinée aux **personnes de 16 ans et plus**.

Si nous découvrons qu'un mineur de moins de 16 ans a créé un compte, nous supprimerons immédiatement ses données.

---

## 12. Modifications de cette Politique

Nous pouvons modifier cette politique de confidentialité pour refléter :
- Les changements de nos pratiques
- Les évolutions légales
- L'ajout de nouvelles fonctionnalités

**Notification** : Vous serez informé par email ou notification dans l'application en cas de modification importante.

**Date de mise à jour** : Indiquée en haut de cette page.

---

## 13. Transferts Internationaux

Vos données sont hébergées en **Europe** (serveurs Google Cloud Platform).

En cas de transfert hors UE (par exemple, vers les États-Unis pour l'authentification Firebase) :
- ✅ Clauses contractuelles types de la Commission européenne
- ✅ Certification Privacy Shield (si applicable)
- ✅ Garanties équivalentes au RGPD

---

## 14. Contact

Pour toute question concernant cette politique de confidentialité ou vos données personnelles :

**Email** : support@pacifitcal.com  
**Adresse** : [Votre Adresse Complète]  
**Téléphone** : [Votre Téléphone]

**Délégué à la Protection des Données (DPO)** : [Nom si applicable]  
**Email DPO** : dpo@pacifitcal.com [si applicable]

---

## 15. Consentement

En utilisant l'application PacifiTcal, vous reconnaissez avoir lu et compris cette politique de confidentialité et vous consentez au traitement de vos données personnelles comme décrit ci-dessus.

---

**Fait à** : [Ville]  
**Le** : 12 avril 2026  
**Version** : 1.0

---

## Annexe : Détails Techniques

### Données Stockées dans Firestore

**Collection `users`** :
```
{
  id: string (UID Firebase),
  email: string,
  nom: string,
  prenom: string,
  role: "admin" | "user",
  active: boolean,
  subscription_start: timestamp,
  subscription_end: timestamp,
  weak_password: boolean,
  schema_version: number
}
```

**Collection `reservations`** :
```
{
  id: string,
  user_id: string,
  class_id: string,
  created_at: timestamp,
  user_name: string (dénormalisé),
  class_name: string (dénormalisé),
  class_date: timestamp,
  class_time: string,
  schema_version: number
}
```

### Sécurité Firebase

**Règles Firestore** :
- Utilisateur ne peut lire que ses propres données
- Admin peut lire toutes les données
- Validation côté serveur (types, longueurs)
- Authentification obligatoire

**App Check** (si activé) :
- Protection anti-bot
- Protection CSRF
- Vérification intégrité de l'application

---

**Cette politique est conforme au RGPD (Règlement UE 2016/679) et aux lois françaises sur la protection des données.**

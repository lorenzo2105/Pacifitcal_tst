# Système de Mois Glissant - Séances Récurrentes

## 📋 Résumé des modifications

Le système de génération de séances a été modifié pour passer d'une **génération fixe de 8 semaines** à un **mois glissant automatique de 4 semaines**.

---

## 🔄 Ancien comportement

- ✅ Génération de 8 semaines lors de la création d'une récurrence
- ❌ Aucune génération automatique après les 8 semaines
- ❌ Nécessitait une intervention manuelle pour régénérer les séances

---

## ✨ Nouveau comportement

### Génération initiale
- Création de **4 semaines** de séances lors de la création d'un template
- Message confirmant : *"Récurrence activée ! Mois glissant de 4 semaines"*

### Maintenance automatique
- **Fonction** : `maintainRollingMonthClasses()` dans `FirestoreService`
- **Déclenchement** : À chaque chargement de l'écran admin des cours
- **Logique** :
  1. Récupère tous les templates actifs
  2. Pour chaque template, vérifie les séances futures existantes
  3. Génère automatiquement les séances manquantes pour maintenir 4 semaines à venir
  4. Ne duplique jamais les séances (vérification par date)

### Avantages
- ✅ **Automatique** : Aucune intervention manuelle nécessaire
- ✅ **Continu** : Maintient toujours 4 semaines visibles
- ✅ **Intelligent** : Génère uniquement ce qui manque
- ✅ **Performant** : Utilise des batches Firestore pour limiter les écritures

---

## 📁 Fichiers modifiés

### 1. `lib/services/firestore_service.dart`

#### Changements principaux :
- **Import ajouté** : `package:flutter/foundation.dart` pour `debugPrint`
- **Fonction modifiée** : `createTemplate()` - Passe de `weeksAhead: 8` à `weeksAhead: 4`
- **Nouvelle fonction** : `maintainRollingMonthClasses()`

```dart
/// Maintient automatiquement un mois glissant (4 semaines) de séances
Future<void> maintainRollingMonthClasses() async {
  // Récupère tous les templates actifs
  // Pour chaque template :
  //   - Vérifie les séances existantes
  //   - Génère les séances manquantes pour les 4 prochaines semaines
  //   - Évite les doublons
}
```

### 2. `lib/screens/admin/admin_classes_screen.dart`

#### Changements :
- **Appel automatique** dans `initState()` :
```dart
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  // Maintenir automatiquement le mois glissant de séances
  _firestoreService.maintainRollingMonthClasses();
}
```

### 3. `lib/screens/admin/admin_template_form_screen.dart`

#### Messages UI mis à jour :
- **Message de création** : "Récurrence activée ! Mois glissant de 4 semaines"
- **Info bulle** : "Mois glissant : maintient automatiquement 4 semaines de séances tous les [jour]s"

---

## 🧪 Comment tester

### Test 1 : Création d'une nouvelle récurrence
1. Allez dans **Admin → Cours → Récurrents**
2. Cliquez sur **"+ Séance récurrente"**
3. Remplissez le formulaire (ex: "Small Group", tous les lundis à 16h30)
4. Sauvegardez
5. **Vérification** : Allez dans l'onglet **"À venir"** → Vous devriez voir **4 séances** générées

### Test 2 : Maintenance automatique
1. Attendez quelques jours (ou modifiez manuellement une date dans Firestore pour simuler)
2. Retournez dans **Admin → Cours**
3. **Vérification** : Le système devrait avoir automatiquement généré les séances manquantes pour maintenir 4 semaines

### Test 3 : Pas de doublons
1. Rechargez plusieurs fois l'écran **Admin → Cours**
2. **Vérification** : Le nombre de séances ne doit pas augmenter (pas de doublons créés)

---

## 🔧 Fonctionnement technique

### Algorithme de génération

```
Pour chaque template actif :
  1. Récupérer les séances futures existantes (date >= aujourd'hui)
  2. Calculer la période : aujourd'hui + 28 jours (4 semaines)
  3. Pour chaque semaine (0 à 3) :
     a. Calculer la date cible (prochain jour de semaine correspondant)
     b. Si la date est dans la période ET n'existe pas déjà :
        → Créer la séance
  4. Sauvegarder en batch
```

### Optimisations
- **Vérification d'existence** : Évite les doublons en vérifiant les dates existantes
- **Batch writes** : Regroupe toutes les créations en une seule transaction
- **Filtrage actifs** : Ne génère que pour les templates `active: true`
- **Logs** : Affiche le nombre de séances générées dans la console

---

## 📊 Structure Firestore

### Collection `class_templates`
```json
{
  "name": "Small Group",
  "day_of_week": 1,  // 1=Lundi, 7=Dimanche
  "start_time": "16:30",
  "end_time": "17:30",
  "max_participants": 10,
  "active": true,
  "coach": "Lorenzo",
  "description": "Entraînement en petit groupe"
}
```

### Collection `classes` (générées automatiquement)
```json
{
  "name": "Small Group",
  "date": Timestamp,
  "time": "16:30",
  "end_time": "17:30",
  "duration": 60,
  "max_participants": 10,
  "current_participants": 0,
  "template_id": "abc123",  // Lien vers le template
  "coach": "Lorenzo",
  "description": "Entraînement en petit groupe"
}
```

---

## 🚀 Prochaines améliorations possibles

### Option 1 : Cloud Function automatique
- Créer une Cloud Function Firebase déclenchée quotidiennement
- Appelle `maintainRollingMonthClasses()` automatiquement
- Avantage : Fonctionne même si personne n'ouvre l'écran admin

### Option 2 : Configuration personnalisable
- Permettre à l'admin de choisir la durée (2, 4, 6 ou 8 semaines)
- Stockée dans un document de configuration Firestore

### Option 3 : Notifications
- Envoyer une notification à l'admin si une génération échoue
- Alerter si aucune séance n'a été générée depuis X jours

---

## 📞 Support

Pour toute question sur ce système :
1. Vérifiez les logs dans la console Flutter (recherchez "✅ Généré" ou "❌ Erreur")
2. Consultez Firestore pour voir les séances générées
3. Vérifiez que les templates ont `active: true`

---

**Date de mise en œuvre** : Avril 2026  
**Version** : 1.0.0

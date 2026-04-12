class Validators {
  /// Validation stricte des mots de passe
  /// Minimum 12 caractères avec au moins :
  /// - 1 majuscule
  /// - 1 minuscule
  /// - 1 chiffre
  /// - 1 caractère spécial
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 12) {
      return 'Minimum 12 caractères requis';
    }

    // Vérifier la présence de majuscules
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Doit contenir au moins une majuscule';
    }

    // Vérifier la présence de minuscules
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Doit contenir au moins une minuscule';
    }

    // Vérifier la présence de chiffres
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Doit contenir au moins un chiffre';
    }

    // Vérifier la présence de caractères spéciaux
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/]').hasMatch(value)) {
      return 'Doit contenir au moins un caractère spécial (!@#\$%...)';
    }

    return null;
  }

  /// Validation stricte des emails
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }

    // Regex RFC 5322 simplifiée
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email invalide';
    }

    return null;
  }

  /// Validation simple pour les champs requis
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName requis' : 'Ce champ est requis';
    }
    return null;
  }

  /// Validation de la longueur minimale
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Utiliser required() pour vérifier si vide
    }
    if (value.length < min) {
      return fieldName != null
          ? '$fieldName doit contenir au moins $min caractères'
          : 'Minimum $min caractères';
    }
    return null;
  }

  /// Validation stricte pour les noms et prénoms
  /// - Longueur : 2-50 caractères
  /// - Caractères autorisés : lettres (avec accents), espaces, tirets, apostrophes
  /// - Pas de caractères spéciaux dangereux
  static String? validateName(String? value, {String? fieldName}) {
    final field = fieldName ?? 'Ce champ';

    if (value == null || value.trim().isEmpty) {
      return '$field est requis';
    }

    final trimmed = value.trim();

    // Longueur
    if (trimmed.length < 2) {
      return '$field doit contenir au moins 2 caractères';
    }
    if (trimmed.length > 50) {
      return '$field ne peut pas dépasser 50 caractères';
    }

    // Caractères autorisés : lettres (y compris accents), espaces, tirets, apostrophes
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return '$field contient des caractères invalides';
    }

    // Pas de caractères répétés excessivement (> 3 fois)
    if (RegExp(r'(.)\1{3,}').hasMatch(trimmed)) {
      return '$field contient des caractères répétés excessivement';
    }

    return null;
  }

  /// Validation pour les descriptions (cours, templates, etc.)
  /// - Longueur : 10-500 caractères
  /// - Caractères autorisés : alphanumériques, ponctuation courante
  /// - Pas de HTML, pas de scripts
  static String? validateDescription(String? value, {String? fieldName}) {
    final field = fieldName ?? 'Description';

    if (value == null || value.trim().isEmpty) {
      return '$field requise';
    }

    final trimmed = value.trim();

    // Longueur
    if (trimmed.length < 10) {
      return '$field doit contenir au moins 10 caractères';
    }
    if (trimmed.length > 500) {
      return '$field ne peut pas dépasser 500 caractères';
    }

    // Bloquer HTML/scripts
    if (RegExp(r'<[^>]*>|<script|javascript:|onerror=|onclick=',
            caseSensitive: false)
        .hasMatch(trimmed)) {
      return '$field contient du contenu non autorisé';
    }

    return null;
  }

  /// Validation pour les champs texte courts (ex: nom de cours)
  /// - Longueur : 3-100 caractères
  /// - Caractères standards autorisés
  static String? validateShortText(String? value, {String? fieldName}) {
    final field = fieldName ?? 'Ce champ';

    if (value == null || value.trim().isEmpty) {
      return '$field est requis';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return '$field doit contenir au moins 3 caractères';
    }
    if (trimmed.length > 100) {
      return '$field ne peut pas dépasser 100 caractères';
    }

    // Bloquer caractères dangereux
    if (RegExp(r'[<>{}\\|`]').hasMatch(trimmed)) {
      return '$field contient des caractères non autorisés';
    }

    return null;
  }

  /// Validation pour les numéros de téléphone (format français)
  /// Optionnel mais si fourni, doit être valide
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optionnel
    }

    // Retirer espaces et tirets
    final cleaned = value.replaceAll(RegExp(r'[\s\-\.]'), '');

    // Format français : 10 chiffres commençant par 0, ou +33
    final phoneRegex = RegExp(r'^(?:0[1-9]|\\+33[1-9])\d{8}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Numéro de téléphone invalide (format: 06 12 34 56 78)';
    }

    return null;
  }

  /// Sanitizer pour retirer les espaces excessifs et normaliser
  static String sanitize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Espaces multiples -> 1 espace
        .replaceAll(RegExp(r'^\s+|\s+$'), ''); // Trim
  }

  /// Validation combinée pour formulaire utilisateur complet
  static String? validateFullName(String? nom, String? prenom) {
    final nomError = validateName(nom, fieldName: 'Nom');
    if (nomError != null) return nomError;

    final prenomError = validateName(prenom, fieldName: 'Prénom');
    if (prenomError != null) return prenomError;

    return null;
  }
}

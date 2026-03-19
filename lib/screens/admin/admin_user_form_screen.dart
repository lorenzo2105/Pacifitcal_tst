import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminUserFormScreen extends StatefulWidget {
  final String? userId;
  const AdminUserFormScreen({super.key, this.userId});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  SubscriptionType _subscriptionType = SubscriptionType.oneMonth;
  DateTime _subscriptionStart = DateTime.now();
  bool _active = true;
  bool _isLoading = false;
  UserModel? _existingUser;

  bool get isEditing => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    _existingUser = await _firestoreService.getUser(widget.userId!);
    if (_existingUser != null) {
      _nomCtrl.text = _existingUser!.nom;
      _prenomCtrl.text = _existingUser!.prenom;
      _emailCtrl.text = _existingUser!.email;
      _active = _existingUser!.active;
      _subscriptionStart = _existingUser!.subscriptionStart ?? DateTime.now();
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final subscriptionEnd = UserModel.calculateSubscriptionEnd(
          _subscriptionStart, _subscriptionType);

      if (isEditing) {
        final updated = _existingUser!.copyWith(
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
          subscriptionStart: _subscriptionStart,
          subscriptionEnd: subscriptionEnd,
          active: _active,
        );
        await _firestoreService.updateUser(updated);
        if (_passwordCtrl.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Pour changer le mot de passe, utilisez la Console Firebase.'),
              backgroundColor: AppTheme.warning,
            ),
          );
        }
      } else {
        // Création via une instance Firebase secondaire
        // L'admin reste connecté dans l'app principale
        FirebaseApp? secondaryApp;
        try {
          secondaryApp = await Firebase.initializeApp(
            name: 'secondaryApp',
            options: Firebase.app().options,
          );
        } catch (_) {
          // L'app secondaire existe déjà, on la réutilise
          secondaryApp = Firebase.app('secondaryApp');
        }

        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

        // Créer le nouvel utilisateur dans l'app secondaire (l'admin reste connecté)
        // Note: bug connu firebase_auth avec instances secondaires (PigeonUserDetails cast error)
        // L'utilisateur est bien créé dans Auth même si une exception est levée
        String? newUserId;
        try {
          final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
          newUserId = userCredential.user!.uid;
        } catch (e) {
          // Récupérer l'UID depuis currentUser car l'utilisateur est créé malgré l'erreur
          newUserId = secondaryAuth.currentUser?.uid;
          if (newUserId == null) rethrow;
        }

        // Déconnecter le nouvel utilisateur de l'app secondaire
        await secondaryAuth.signOut();
        await secondaryApp.delete();

        // L'admin est toujours connecté dans l'app principale
        // On peut donc écrire dans Firestore avec les permissions admin
        final newUser = UserModel(
          id: newUserId,
          email: _emailCtrl.text.trim(),
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
          role: UserRole.user,
          active: _active,
          subscriptionStart: _subscriptionStart,
          subscriptionEnd: subscriptionEnd,
        );

        await _firestoreService.createUser(newUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Adhérent mis à jour !'
                : 'Adhérent créé !'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'MODIFIER ADHÉRENT' : 'NOUVEL ADHÉRENT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && isEditing
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informations personnelles'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prenomCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(labelText: 'Prénom'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _nomCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(labelText: 'Nom'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: isEditing,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: isEditing,
                        fillColor: isEditing
                            ? AppTheme.surfaceVariant
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock_outlined),
                        ),
                        validator: (v) {
                          if (!isEditing) {
                            if (v == null || v.isEmpty) return 'Requis';
                            if (v.length < 6)
                              return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    _sectionTitle('Abonnement'),
                    const SizedBox(height: 12),
                    _subscriptionTypeSelector(),
                    const SizedBox(height: 16),
                    _dateSelector(context),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Expiration: ${DateFormat('dd/MM/yyyy').format(UserModel.calculateSubscriptionEnd(_subscriptionStart, _subscriptionType))}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Statut du compte'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: SwitchListTile(
                        title: const Text('Compte actif',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _active ? 'L\'adhérent peut se connecter' : 'L\'adhérent ne peut pas se connecter',
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted,
                              fontSize: 12),
                        ),
                        value: _active,
                        activeColor: AppTheme.success,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.primary))
                        : ElevatedButton.icon(
                            onPressed: _save,
                            icon: Icon(isEditing ? Icons.save : Icons.add),
                            label: Text(
                                isEditing ? 'Mettre à jour' : 'Créer l\'adhérent'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
    );
  }

  Widget _subscriptionTypeSelector() {
    return Column(
      children: SubscriptionType.values.map((type) {
        final label = UserModel.subscriptionTypeLabel(type);
        final isSelected = _subscriptionType == type;
        return GestureDetector(
          onTap: () => setState(() => _subscriptionType = type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.15)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : const Color(0xFF2A2A2A),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primary : AppTheme.onSurfaceMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _subscriptionStart,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppTheme.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _subscriptionStart = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date de début',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11)),
                Text(
                  DateFormat('dd/MM/yyyy').format(_subscriptionStart),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

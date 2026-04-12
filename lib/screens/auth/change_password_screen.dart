import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/utils/error_handler.dart';
import 'package:pacifitcal/utils/validators.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool mandatory;

  const ChangePasswordScreen({super.key, this.mandatory = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Non authentifié');

      String? userId = user.uid;
      String? userEmail = user.email;

      // Ré-authentifier (peut générer erreur PigeonUserDetails)
      try {
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: userEmail!,
          password: _currentPasswordCtrl.text,
        );
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        // Si erreur PigeonUserDetails, continuer quand même
        if (!e.toString().contains('PigeonUserDetails') &&
            !e.toString().contains('type cast')) {
          // Autres erreurs (mauvais mdp, etc.) = propager
          rethrow;
        }
      }

      // Changer le mot de passe (séparé pour garantir l'exécution)
      try {
        await user.updatePassword(_newPasswordCtrl.text);
      } catch (e) {
        // Si erreur PigeonUserDetails, ignorer car le mdp est changé
        if (!e.toString().contains('PigeonUserDetails') &&
            !e.toString().contains('type cast')) {
          rethrow;
        }
      }

      // Marquer weak_password = false dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'weak_password': false});

      if (mounted) {
        // Rafraîchir les données utilisateur pour éviter boucle de redirection
        try {
          await context.read<AuthProvider>().refreshUser();
          // Petit délai pour s'assurer que les données sont bien mises à jour
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          // Ignorer les erreurs de refresh
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe changé avec succès !'),
            backgroundColor: AppTheme.success,
          ),
        );

        // Rediriger vers l'accueil
        if (mounted) {
          if (widget.mandatory) {
            context.go('/home');
          } else {
            context.pop();
          }
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Erreur lors du changement de mot de passe';
      if (e.code == 'wrong-password') {
        message = 'Mot de passe actuel incorrect';
      } else if (e.code == 'weak-password') {
        message = 'Le nouveau mot de passe est trop faible';
      } else if (e.code == 'requires-recent-login') {
        message = 'Reconnectez-vous avant de changer votre mot de passe';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserMessage(e)),
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
    return WillPopScope(
      onWillPop: () async {
        // Empêcher le retour si le changement est obligatoire
        if (widget.mandatory) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Vous devez changer votre mot de passe pour continuer'),
              backgroundColor: AppTheme.warning,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Changer le mot de passe'),
          automaticallyImplyLeading: !widget.mandatory,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.mandatory) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Changement obligatoire',
                                  style: TextStyle(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Votre mot de passe ne respecte pas les nouvelles exigences de sécurité. Veuillez le changer pour continuer.',
                                  style: TextStyle(
                                    color: AppTheme.warning.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Nouveau mot de passe requis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Le mot de passe doit contenir au minimum :',
                    style: TextStyle(color: AppTheme.onSurfaceMuted),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirement('12 caractères'),
                  _buildRequirement('1 majuscule (A-Z)'),
                  _buildRequirement('1 minuscule (a-z)'),
                  _buildRequirement('1 chiffre (0-9)'),
                  _buildRequirement('1 caractère spécial (!@#\$%...)'),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _currentPasswordCtrl,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe actuel',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordCtrl,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _changePassword(),
                    decoration: InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v != _newPasswordCtrl.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('Changer le mot de passe'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppTheme.success),
          const SizedBox(width: 8),
          Text(
            text,
            style:
                const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

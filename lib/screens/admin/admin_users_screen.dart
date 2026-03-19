import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHÉRENTS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push('/admin/users/new'),
            tooltip: 'Nouvel adhérent',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Rechercher un adhérent...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _firestoreService.streamUsers(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary));
                }
                if (snap.hasError) {
                  return Center(child: Text('Erreur: ${snap.error}'));
                }

                var users = snap.data ?? [];
                print('DEBUG: Total users from Firestore: ${users.length}');
                users = users.where((u) => !u.isAdmin).toList();
                print('DEBUG: Non-admin users: ${users.length}');

                if (_searchQuery.isNotEmpty) {
                  users = users
                      .where((u) =>
                          u.fullName.toLowerCase().contains(_searchQuery) ||
                          u.email.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: AppTheme.onSurfaceMuted),
                        SizedBox(height: 16),
                        Text('Aucun adhérent',
                            style: TextStyle(
                                color: AppTheme.onSurfaceMuted,
                                fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (ctx, i) => _userCard(context, users[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/users/new'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _userCard(BuildContext context, UserModel user) {
    Color statusColor;
    String statusLabel;
    if (!user.active) {
      statusColor = AppTheme.onSurfaceMuted;
      statusLabel = 'Désactivé';
    } else if (user.isSubscriptionExpired) {
      statusColor = AppTheme.error;
      statusLabel = 'Expiré';
    } else if (user.daysUntilExpiration <= 7) {
      statusColor = AppTheme.warning;
      statusLabel = 'Expire bientôt';
    } else {
      statusColor = AppTheme.success;
      statusLabel = 'Actif';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/admin/users/edit/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(
                  '${user.prenom[0]}${user.nom[0]}'.toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (user.subscriptionEnd != null)
                      Text(
                        'Expire: ${DateFormat('dd/MM/yyyy').format(user.subscriptionEnd!)}',
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleActive(user),
                        child: Icon(
                          user.active
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: user.active
                              ? AppTheme.success
                              : AppTheme.onSurfaceMuted,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, user),
                        child: const Icon(Icons.delete_outline,
                            color: AppTheme.error, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleActive(UserModel user) async {
    await _firestoreService.setUserActive(user.id, !user.active);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${user.fullName} ${!user.active ? 'activé' : 'désactivé'}'),
          backgroundColor:
              !user.active ? AppTheme.success : AppTheme.warning,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer l\'adhérent'),
        content: Text(
            'Supprimer ${user.fullName} ? Toutes ses réservations seront supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        // Supprimer de Firestore + réservations
        await _firestoreService.deleteUser(user.id);
        // Supprimer de Firebase Auth via Cloud Function
        final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
            .httpsCallable('deleteUser');
        await callable.call({'uid': user.id});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.fullName} supprimé'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur suppression: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }
}

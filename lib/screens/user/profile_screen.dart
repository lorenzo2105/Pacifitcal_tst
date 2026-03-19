import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';
import 'package:pacifitcal/widgets/subscription_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            '${user.prenom[0]}${user.nom[0]}'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.onSurfaceMuted),
                        ),
                        const SizedBox(height: 12),
                        SubscriptionBadge(user: user),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle(context, 'Informations personnelles'),
                  _infoCard([
                    _infoRow(Icons.person_outline, 'Prénom', user.prenom),
                    _infoRow(Icons.person_outline, 'Nom', user.nom),
                    _infoRow(Icons.email_outlined, 'Email', user.email),
                  ]),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Abonnement'),
                  _infoCard([
                    _infoRow(
                      Icons.card_membership_outlined,
                      'Statut',
                      user.isSubscriptionExpired ? 'Expiré' : 'Actif',
                      valueColor: user.isSubscriptionExpired
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                    if (user.subscriptionStart != null)
                      _infoRow(
                        Icons.play_circle_outline,
                        'Début',
                        DateFormat('dd/MM/yyyy').format(user.subscriptionStart!),
                      ),
                    if (user.subscriptionEnd != null)
                      _infoRow(
                        Icons.stop_circle_outlined,
                        'Expiration',
                        DateFormat('dd/MM/yyyy').format(user.subscriptionEnd!),
                        valueColor: user.isSubscriptionExpired
                            ? AppTheme.error
                            : user.daysUntilExpiration <= 7
                                ? AppTheme.warning
                                : null,
                      ),
                    if (!user.isSubscriptionExpired)
                      _infoRow(
                        Icons.timer_outlined,
                        'Jours restants',
                        '${user.daysUntilExpiration} jour(s)',
                        valueColor: user.daysUntilExpiration <= 7
                            ? AppTheme.warning
                            : AppTheme.success,
                      ),
                  ]),
                  if (user.isSubscriptionExpired)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.error.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppTheme.error),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Votre abonnement est expiré. Contactez votre administrateur pour le renouveler.',
                                style:
                                    TextStyle(color: AppTheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Mes réservations à venir'),
                  if (reservationProvider.upcomingReservations.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: const Text(
                        'Aucune réservation à venir',
                        style: TextStyle(
                            color: AppTheme.onSurfaceMuted),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...reservationProvider.upcomingReservations.map(
                      (res) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center,
                              color: AppTheme.primary),
                          title: Text(res.className ?? 'Cours',
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            res.classDate != null
                                ? '${DateFormat('dd/MM/yyyy').format(res.classDate!)} à ${res.classTime}'
                                : '',
                            style: const TextStyle(
                                color: AppTheme.onSurfaceMuted),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout, color: AppTheme.error),
                    label: const Text('Se déconnecter',
                        style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map((entry) => Column(
                  children: [
                    entry.value,
                    if (entry.key < children.length - 1)
                      const Divider(height: 1, indent: 56),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Déconnecter')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ReservationProvider>().reset();
      await context.read<AuthProvider>().signOut();
      if (context.mounted) context.go('/login');
    }
  }
}

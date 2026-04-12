import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';
import 'package:pacifitcal/widgets/subscription_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime _currentMonth = DateTime.now();

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
                        DateFormat('dd/MM/yyyy')
                            .format(user.subscriptionStart!),
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
                                style: TextStyle(color: AppTheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Mes prochaines séances'),
                  _buildUpcomingReservations(reservationProvider),
                  const SizedBox(height: 20),
                  _sectionTitle(context, 'Calendrier des réservations'),
                  _buildCalendar(reservationProvider),
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

  Widget _buildUpcomingReservations(ReservationProvider reservationProvider) {
    final upcomingReservations = reservationProvider.upcomingReservations;

    if (upcomingReservations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48, color: AppTheme.onSurfaceMuted),
              SizedBox(height: 12),
              Text(
                'Aucune séance à venir',
                style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingReservations.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16),
        itemBuilder: (context, index) {
          final reservation = upcomingReservations[index];
          final dateStr = reservation.classDate != null
              ? DateFormat('EEE dd MMM', 'fr_FR').format(reservation.classDate!)
              : '';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: const Icon(Icons.fitness_center,
                  color: AppTheme.primary, size: 20),
            ),
            title: Text(
              reservation.className ?? 'Cours',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '$dateStr à ${reservation.classTime ?? ''}',
              style:
                  const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
              onPressed: () => _confirmCancelReservation(context, reservation),
              tooltip: 'Annuler',
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancelReservation(
      BuildContext context, reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Annuler la réservation'),
        content: Text(
          'Voulez-vous annuler votre réservation pour ${reservation.className} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final auth = context.read<AuthProvider>();
        await context.read<ReservationProvider>().cancel(
              reservationId: reservation.id,
              classId: reservation.classId,
              userId: auth.currentUser!.id,
              className: reservation.className ?? 'Cours',
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée'),
              backgroundColor: AppTheme.warning,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    // Ajouter les jours du mois précédent pour compléter la première semaine
    final firstWeekday = firstDay.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Ajouter tous les jours du mois
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    // Ajouter les jours du mois suivant pour compléter la dernière semaine
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        days.add(DateTime(month.year, month.month + 1, i));
      }
    }

    return days;
  }

  Widget _buildCalendar(ReservationProvider reservationProvider) {
    final days = _getDaysInMonth(_currentMonth);
    final monthFormat = DateFormat('MMMM yyyy', 'fr_FR');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Créer une map des réservations par date
    final reservationsByDate = <String, List<String>>{};
    for (final res in reservationProvider.userReservations) {
      if (res.classDate != null && res.classTime != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(res.classDate!);
        if (!reservationsByDate.containsKey(dateKey)) {
          reservationsByDate[dateKey] = [];
        }
        reservationsByDate[dateKey]!.add(res.classTime!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête avec navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                onPressed: _previousMonth,
              ),
              Text(
                monthFormat.format(_currentMonth),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Jours de la semaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['LUN.', 'MAR.', 'MER.', 'JEU.', 'VEN.', 'SAM.', 'DIM.']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.onSurfaceMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grille des jours
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _currentMonth.month;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final dateKey = DateFormat('yyyy-MM-dd').format(day);
              final hasReservations = reservationsByDate.containsKey(dateKey);
              final reservations = reservationsByDate[dateKey] ?? [];

              return Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.error.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Numéro du jour
                    if (isToday)
                      Positioned(
                        top: 2,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 0,
                        child: Text(
                          '${day.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isCurrentMonth
                                ? Colors.white
                                : AppTheme.onSurfaceMuted,
                            fontSize: 12,
                            fontWeight: isCurrentMonth
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    // Heures des réservations
                    if (hasReservations && isCurrentMonth)
                      Positioned(
                        bottom: 2,
                        left: 2,
                        right: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: reservations
                              .take(2)
                              .map(
                                (time) => Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    time,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
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

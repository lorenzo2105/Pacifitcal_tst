import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<ReservationProvider>();
    final all = reservationProvider.userReservations;
    final upcoming = all.where((r) => r.isUpcoming).toList();
    final past = all.where((r) => !r.isUpcoming).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes réservations'),
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceMuted,
            tabs: [
              Tab(text: 'À venir'),
              Tab(text: 'Passées'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, upcoming, isUpcoming: true),
            _buildList(context, past, isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List reservations,
      {required bool isUpcoming}) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: AppTheme.onSurfaceMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'Aucune réservation à venir'
                  : 'Aucun historique',
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (ctx, i) {
        final res = reservations[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.onSurfaceMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center,
                color: isUpcoming
                    ? AppTheme.primary
                    : AppTheme.onSurfaceMuted,
                size: 24,
              ),
            ),
            title: Text(
              res.className ?? 'Cours',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  res.classDate != null
                      ? DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                          .format(res.classDate!)
                      : '',
                  style: const TextStyle(color: AppTheme.onSurfaceMuted),
                ),
                Text(
                  res.classTime != null ? 'à ${res.classTime}' : '',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: isUpcoming
                ? IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppTheme.error),
                    onPressed: () => _cancelReservation(
                        context, res.id, res.classId, res.className ?? 'Cours'),
                    tooltip: 'Annuler',
                  )
                : const Icon(Icons.check_circle_outline,
                    color: AppTheme.onSurfaceMuted),
          ),
        );
      },
    );
  }

  Future<void> _cancelReservation(BuildContext context, String resId,
      String classId, String className) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Annuler la réservation'),
        content: Text('Annuler votre réservation pour $className ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      await context.read<ReservationProvider>().cancel(
            reservationId: resId,
            classId: classId,
            userId: auth.currentUser!.id,
            className: className,
          );
    }
  }
}

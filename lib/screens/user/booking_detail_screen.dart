import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';

class BookingDetailScreen extends StatelessWidget {
  final ClassModel classModel;

  const BookingDetailScreen({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final isReserved = reservationProvider.isReserved(classModel.id);
    final reservation = reservationProvider.userReservations
        .where((r) => r.classId == classModel.id)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 40, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    classModel.name,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  if (classModel.coach != null)
                    Text(
                      'Coach: ${classModel.coach}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _infoRow(
              context,
              Icons.calendar_today_outlined,
              'Date',
              DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(classModel.date),
            ),
            const Divider(height: 1),
            _infoRow(
              context,
              Icons.access_time_outlined,
              'Heure',
              classModel.time,
            ),
            const Divider(height: 1),
            _infoRow(
              context,
              Icons.timer_outlined,
              'Durée',
              '${classModel.duration} minutes',
            ),
            const Divider(height: 1),
            _infoRow(
              context,
              Icons.people_outline,
              'Places',
              '${classModel.availableSpots} / ${classModel.maxParticipants} disponibles',
              valueColor: classModel.isFull
                  ? AppTheme.error
                  : classModel.availableSpots <= 3
                      ? AppTheme.warning
                      : AppTheme.success,
            ),
            if (classModel.description != null) ...[
              const Divider(height: 1),
              _infoRow(
                context,
                Icons.info_outline,
                'Description',
                classModel.description!,
              ),
            ],
            const SizedBox(height: 32),
            if (classModel.isPast)
              _statusBanner(
                context,
                Icons.history,
                'Ce cours est terminé',
                AppTheme.onSurfaceMuted,
              )
            else if (classModel.isFull && !isReserved)
              _statusBanner(
                context,
                Icons.block,
                'Ce cours est complet',
                AppTheme.error,
              )
            else if (isReserved)
              Column(
                children: [
                  _statusBanner(
                    context,
                    Icons.check_circle_outline,
                    'Vous êtes inscrit à ce cours',
                    AppTheme.success,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: reservationProvider.isLoading
                        ? null
                        : () => _cancelReservation(
                              context,
                              reservation!.id,
                              auth.currentUser!.id,
                            ),
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppTheme.error),
                    label: const Text('Annuler ma réservation',
                        style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error)),
                  ),
                ],
              )
            else
              reservationProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary))
                  : ElevatedButton.icon(
                      onPressed: () => _reserve(context, auth),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Réserver ce cours'),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(
    BuildContext context,
    IconData icon,
    String message,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _reserve(BuildContext context, AuthProvider auth) async {
    try {
      await context.read<ReservationProvider>().reserve(
            userId: auth.currentUser!.id,
            userName: auth.currentUser!.fullName,
            classModel: classModel,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée !'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final error = context.read<ReservationProvider>().error ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _cancelReservation(
      BuildContext context, String reservationId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Annuler la réservation'),
        content: Text('Annuler votre réservation pour ${classModel.name} ?'),
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
        await context.read<ReservationProvider>().cancel(
              reservationId: reservationId,
              classId: classModel.id,
              userId: userId,
              className: classModel.name,
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
                content: Text(e.toString()),
                backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }
}

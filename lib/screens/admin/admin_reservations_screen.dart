import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/reservation_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminReservationsScreen extends StatelessWidget {
  final String? classId;
  const AdminReservationsScreen({super.key, this.classId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final stream = classId != null
        ? firestoreService.streamClassReservations(classId!)
        : firestoreService.streamAllReservations();

    return Scaffold(
      appBar: AppBar(
        title: Text(classId != null ? 'PARTICIPANTS' : 'RÉSERVATIONS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }

          final reservations = snap.data ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64, color: AppTheme.onSurfaceMuted),
                  SizedBox(height: 16),
                  Text('Aucune réservation',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 16)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${reservations.length} réservation(s)',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reservations.length,
                  itemBuilder: (ctx, i) =>
                      _reservationCard(context, reservations[i], firestoreService),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _reservationCard(BuildContext context, ReservationModel res,
      FirestoreService firestoreService) {
    final isUpcoming = res.isUpcoming;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isUpcoming
                  ? AppTheme.primary.withOpacity(0.2)
                  : AppTheme.onSurfaceMuted.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: isUpcoming
                    ? AppTheme.primary
                    : AppTheme.onSurfaceMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    res.userName ?? 'Adhérent',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  if (classId == null) ...[
                    const SizedBox(height: 2),
                    Text(
                      res.className ?? 'Cours',
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11,
                          color: AppTheme.onSurfaceMuted),
                      const SizedBox(width: 4),
                      Text(
                        res.classDate != null
                            ? '${DateFormat('dd/MM/yyyy').format(res.classDate!)} à ${res.classTime}'
                            : '',
                        style: const TextStyle(
                            color: AppTheme.onSurfaceMuted,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Réservé le ${DateFormat('dd/MM/yyyy à HH:mm').format(res.createdAt)}',
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? AppTheme.success.withOpacity(0.15)
                        : AppTheme.onSurfaceMuted.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isUpcoming ? 'À venir' : 'Passé',
                    style: TextStyle(
                      color: isUpcoming
                          ? AppTheme.success
                          : AppTheme.onSurfaceMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isUpcoming) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        _confirmDelete(context, res, firestoreService),
                    child: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ReservationModel res,
      FirestoreService firestoreService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer la réservation'),
        content: Text(
            'Supprimer la réservation de ${res.userName ?? "cet adhérent"} pour ${res.className ?? "ce cours"} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await firestoreService.adminDeleteReservation(res.id, res.classId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation supprimée'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/reservation_model.dart';
import 'package:pacifitcal/models/user_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminReservationsScreen extends StatefulWidget {
  final String? classId;
  const AdminReservationsScreen({super.key, this.classId});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(_selectedDate);
  }

  DateTime _mondayOf(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GÉRER LES RÉSERVATIONS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: StreamBuilder<List<ClassModel>>(
              stream: _firestoreService.streamClassesByDate(_selectedDate),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary));
                }
                if (snap.hasError) {
                  return Center(child: Text('Erreur: ${snap.error}'));
                }

                final classes = snap.data ?? [];
                if (classes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            size: 64, color: AppTheme.onSurfaceMuted),
                        SizedBox(height: 16),
                        Text('Aucune séance ce jour',
                            style: TextStyle(
                                color: AppTheme.onSurfaceMuted, fontSize: 16)),
                      ],
                    ),
                  );
                }

                classes.sort((a, b) => a.time.compareTo(b.time));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (ctx, i) => _buildClassCard(context, classes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final monthFormat = DateFormat('MMMM yyyy', 'fr_FR');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                  onPressed: _prevWeek,
                ),
                Text(
                  monthFormat.format(_weekStart),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.chevron_right, color: AppTheme.primary),
                  onPressed: _nextWeek,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final day = _weekStart.add(Duration(days: i));
              final isSelected = day.year == _selectedDate.year &&
                  day.month == _selectedDate.month &&
                  day.day == _selectedDate.day;
              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  width: 45,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : (isToday
                            ? AppTheme.primary.withOpacity(0.2)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E', 'fr_FR').format(day).substring(0, 3),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : AppTheme.onSurfaceMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassModel classModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((classModel.coach ?? '').isNotEmpty)
                        Text(
                          classModel.coach ?? '',
                          style: const TextStyle(
                            color: AppTheme.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      classModel.time,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${classModel.duration}min',
                      style: const TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: classModel.maxParticipants > 0
                            ? classModel.currentParticipants /
                                classModel.maxParticipants
                            : 0,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          classModel.isFull
                              ? AppTheme.error
                              : classModel.availableSpots <= 3
                                  ? AppTheme.warning
                                  : AppTheme.success,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${classModel.currentParticipants}/${classModel.maxParticipants}',
                  style: TextStyle(
                    color: classModel.isFull
                        ? AppTheme.error
                        : classModel.availableSpots <= 3
                            ? AppTheme.warning
                            : AppTheme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showParticipants(context, classModel),
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('Voir participants'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddReservation(context, classModel),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Réserver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showParticipants(
      BuildContext context, ClassModel classModel) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${classModel.time} - ${classModel.duration}min',
                        style: const TextStyle(
                          color: AppTheme.onSurfaceMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ReservationModel>>(
                stream:
                    _firestoreService.streamClassReservations(classModel.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  final reservations = snapshot.data ?? [];

                  if (reservations.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.onSurfaceMuted,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun participant',
                            style: TextStyle(
                              color: AppTheme.onSurfaceMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    itemBuilder: (ctx, index) {
                      final reservation = reservations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(
                              (reservation.userName ?? 'A')[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            reservation.userName ?? 'Adhérent',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.error,
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppTheme.surface,
                                  title: const Text('Supprimer la réservation'),
                                  content: Text(
                                    'Supprimer la réservation de ${reservation.userName ?? "cet adhérent"} ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.error,
                                      ),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                await _firestoreService.adminDeleteReservation(
                                  reservation.id,
                                  reservation.classId,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Réservation supprimée'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReservation(
      BuildContext context, ClassModel classModel) async {
    if (classModel.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette séance est complète'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final users = await _firestoreService.streamUsers().first;
    final activeUsers = users.where((u) => !u.isSubscriptionExpired).toList();
    activeUsers.sort((a, b) => a.nom.compareTo(b.nom));

    if (!context.mounted) return;

    final selectedUser = await showDialog<UserModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sélectionner un adhérent'),
        content: SizedBox(
          width: double.maxFinite,
          child: activeUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Aucun adhérent actif',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.onSurfaceMuted),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeUsers.length,
                  itemBuilder: (ctx, i) {
                    final user = activeUsers[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        child: Text(
                          user.prenom.isNotEmpty
                              ? user.prenom[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${user.prenom} ${user.nom}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(
                            color: AppTheme.onSurfaceMuted, fontSize: 12),
                      ),
                      onTap: () => Navigator.pop(ctx, user),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedUser != null && context.mounted) {
      try {
        final userName = '${selectedUser.prenom} ${selectedUser.nom}'.trim();
        await _firestoreService.createReservation(
          userId: selectedUser.id,
          userName: userName,
          classModel: classModel,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Réservation créée pour $userName'),
              backgroundColor: AppTheme.success,
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
}

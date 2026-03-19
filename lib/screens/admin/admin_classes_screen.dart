import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('COURS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.onSurfaceMuted,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
          ],
        ),
      ),
      body: StreamBuilder<List<ClassModel>>(
        stream: _firestoreService.streamAllClasses(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }

          final all = snap.data ?? [];
          final upcoming = all.where((c) => !c.isPast).toList();
          final past = all.where((c) => c.isPast).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildClassList(context, upcoming),
              _buildClassList(context, past, isPast: true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/classes/new'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau cours',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildClassList(BuildContext context, List<ClassModel> classes,
      {bool isPast = false}) {
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPast ? Icons.history : Icons.event_available,
                size: 64, color: AppTheme.onSurfaceMuted),
            const SizedBox(height: 16),
            Text(
              isPast ? 'Aucun cours passé' : 'Aucun cours programmé',
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: classes.length,
      itemBuilder: (ctx, i) => _classCard(context, classes[i], isPast),
    );
  }

  Widget _classCard(BuildContext context, ClassModel cls, bool isPast) {
    final spotsColor = cls.isFull
        ? AppTheme.error
        : cls.availableSpots <= 3
            ? AppTheme.warning
            : AppTheme.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isPast
            ? null
            : () => context.push('/admin/classes/edit/${cls.id}'),
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
                      color: (isPast ? AppTheme.onSurfaceMuted : AppTheme.primary)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: isPast
                          ? AppTheme.onSurfaceMuted
                          : AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cls.name,
                      style: GoogleFonts.bebasNeue(
                        color: isPast
                            ? AppTheme.onSurfaceMuted
                            : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (!isPast)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.people_outline,
                              color: AppTheme.primary, size: 20),
                          onPressed: () =>
                              context.push('/admin/reservations/${cls.id}'),
                          tooltip: 'Voir participants',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.primary, size: 20),
                          onPressed: () =>
                              context.push('/admin/classes/edit/${cls.id}'),
                          tooltip: 'Modifier',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.error, size: 20),
                          onPressed: () => _confirmDelete(context, cls),
                          tooltip: 'Supprimer',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _chip(Icons.calendar_today_outlined,
                      DateFormat('EEE dd MMM', 'fr_FR').format(cls.date)),
                  const SizedBox(width: 8),
                  _chip(Icons.access_time_outlined, cls.time),
                  const SizedBox(width: 8),
                  _chip(Icons.timer_outlined, '${cls.duration}min'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cls.maxParticipants > 0
                            ? cls.currentParticipants / cls.maxParticipants
                            : 0,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(spotsColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${cls.currentParticipants}/${cls.maxParticipants}',
                    style: TextStyle(
                        color: spotsColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.onSurfaceMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ClassModel cls) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer le cours'),
        content: Text(
            'Supprimer "${cls.name}" ? Toutes les réservations seront supprimées.'),
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
      await _firestoreService.deleteClass(cls.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${cls.name}" supprimé'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

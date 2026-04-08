import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/class_template_model.dart';
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

  DateTime _selectedDate = DateTime.now();
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _weekStart = _mondayOf(_selectedDate);
    // Maintenir automatiquement le mois glissant de séances
    _firestoreService.maintainRollingMonthClasses();
  }

  DateTime _mondayOf(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  void _prevWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
      });

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
      });

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
            Tab(text: 'Récurrents'),
            Tab(text: 'À venir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplatesTab(context),
          _buildCalendarTab(context),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isTemplateTab = _tabController.index == 0;
          if (!isTemplateTab) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.push('/admin/templates/new'),
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Séance récurrente',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  // ─── Onglet Templates récurrents ──────────────────────────────────────────

  Widget _buildTemplatesTab(BuildContext context) {
    return StreamBuilder<List<ClassTemplateModel>>(
      stream: _firestoreService.streamTemplates(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        final templates = snap.data ?? [];
        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.repeat,
                    size: 64, color: AppTheme.onSurfaceMuted),
                const SizedBox(height: 16),
                const Text('Aucune séance récurrente',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Appuyez sur + pour en créer une',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 14)),
              ],
            ),
          );
        }
        // Grouper par jour
        final byDay = <int, List<ClassTemplateModel>>{};
        for (final t in templates) {
          byDay.putIfAbsent(t.dayOfWeek, () => []).add(t);
        }
        final sortedDays = byDay.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: sortedDays.length,
          itemBuilder: (ctx, i) {
            final day = sortedDays[i];
            final dayTemplates = byDay[day]!
              ..sort((a, b) => a.startTime.compareTo(b.startTime));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dayTemplates.first.dayName,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                ...dayTemplates.map((t) => _templateCard(context, t)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _templateCard(BuildContext context, ClassTemplateModel t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (t.active ? AppTheme.primary : AppTheme.onSurfaceMuted)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.repeat,
              color: t.active ? AppTheme.primary : AppTheme.onSurfaceMuted,
              size: 22),
        ),
        title: Text(
          t.name,
          style: TextStyle(
              color: t.active ? Colors.white : AppTheme.onSurfaceMuted,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${t.startTime} - ${t.endTime}  •  ${t.maxParticipants} places'
          '${t.coach != null ? '  •  ${t.coach}' : ''}',
          style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppTheme.primary, size: 20),
              onPressed: () => context.push('/admin/templates/edit/${t.id}'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.error, size: 20),
              onPressed: () => _confirmDeleteTemplate(context, t),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTemplate(
      BuildContext context, ClassTemplateModel t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer la séance récurrente'),
        content: Text(
            'Supprimer "${t.name}" tous les ${t.dayName}s ?\nToutes les séances et réservations futures seront supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _firestoreService.deleteTemplate(t.id);
    }
  }

  // ─── Onglet Calendrier ────────────────────────────────────────────────────

  Widget _buildCalendarTab(BuildContext context) {
    return Column(
      children: [
        _buildCalendarStrip(),
        Expanded(
          child: StreamBuilder<List<ClassModel>>(
            stream: _firestoreService.streamClassesByDate(_selectedDate),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }
              final classes = snap.data ?? [];
              classes.sort((a, b) => a.time.compareTo(b.time));

              if (classes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 56, color: AppTheme.onSurfaceMuted),
                      SizedBox(height: 12),
                      Text(
                        'Aucun cours ce jour',
                        style: TextStyle(
                            color: AppTheme.onSurfaceMuted, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _adminClassCard(context, classes[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final monthLabel = DateFormat('MMMM yyyy', 'fr_FR').format(_weekStart);

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                onPressed: _prevWeek,
              ),
              Text(
                monthLabel[0].toUpperCase() + monthLabel.substring(1),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                onPressed: _nextWeek,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final isSelected = day.year == _selectedDate.year &&
                  day.month == _selectedDate.month &&
                  day.day == _selectedDate.day;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E', 'fr_FR')
                            .format(day)
                            .substring(0, 3)
                            .toLowerCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppTheme.primary
                                  : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _adminClassCard(BuildContext context, ClassModel cls) {
    final spotsColor = cls.isFull
        ? AppTheme.error
        : cls.availableSpots <= 3
            ? AppTheme.warning
            : AppTheme.success;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cls.time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (cls.endTime != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    cls.endTime!,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFF2A2A2A),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (cls.coach != null && cls.coach!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      cls.coach!,
                      style: const TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        cls.isFull
                            ? Icons.person_off_outlined
                            : Icons.people_outline,
                        size: 13,
                        color: spotsColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${cls.currentParticipants}/${cls.maxParticipants}',
                        style: TextStyle(
                          color: spotsColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  onPressed: () => _confirmDeleteClass(context, cls),
                  tooltip: 'Supprimer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteClass(BuildContext context, ClassModel cls) async {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
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

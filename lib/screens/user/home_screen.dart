import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';
import 'package:pacifitcal/services/firestore_service.dart';
import 'package:pacifitcal/widgets/subscription_badge.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime _selectedDate = DateTime.now();
  // Début de la semaine affichée (lundi)
  late DateTime _weekStart;
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context
            .read<ReservationProvider>()
            .startListeningUserReservations(auth.currentUser!.id);
      }
    });
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reservationProvider = context.watch<ReservationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _bottomIndex,
        children: [
          _buildCoursTab(context, auth, reservationProvider),
          _buildMyReservationsTab(reservationProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.person_outline),
                if (reservationProvider.upcomingReservations.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${reservationProvider.upcomingReservations.length}',
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ─── Onglet Cours ─────────────────────────────────────────────────────────

  Widget _buildCoursTab(BuildContext context, AuthProvider auth,
      ReservationProvider reservationProvider) {
    return CustomScrollView(
      slivers: [
        // AppBar avec bannière
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppTheme.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B2A), AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${auth.currentUser?.prenom ?? ''} 👋',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      if (auth.currentUser != null)
                        SubscriptionBadge(user: auth.currentUser!),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.person_outline,
                          color: Colors.white),
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            'COURS',
            style: GoogleFonts.bebasNeue(
                color: Colors.white, fontSize: 20, letterSpacing: 2),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),

        // Sélecteur de semaine + jours
        SliverToBoxAdapter(child: _buildCalendarStrip()),

        // Liste des cours du jour sélectionné
        SliverToBoxAdapter(
          child: StreamBuilder<List<ClassModel>>(
            stream: _firestoreService.streamClassesByDate(_selectedDate),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary)),
                );
              }
              final classes = snap.data ?? [];
              // Trier par heure
              classes.sort((a, b) => a.time.compareTo(b.time));

              if (classes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy,
                            size: 56, color: AppTheme.onSurfaceMuted),
                        SizedBox(height: 12),
                        Text('Aucun cours ce jour',
                            style: TextStyle(
                                color: AppTheme.onSurfaceMuted,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: classes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final cls = classes[i];
                  final isReserved =
                      reservationProvider.isReserved(cls.id);
                  return _buildSessionCard(
                      context, cls, isReserved, auth);
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    final today = DateTime.now();
    final days =
        List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final monthLabel =
        DateFormat('MMMM yyyy', 'fr_FR').format(_weekStart);

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Navigation mois
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppTheme.primary),
                onPressed: _prevWeek,
              ),
              Text(
                monthLabel[0].toUpperCase() + monthLabel.substring(1),
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: AppTheme.primary),
                onPressed: _nextWeek,
              ),
            ],
          ),
          // Jours de la semaine
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
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.transparent,
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

  Widget _buildSessionCard(BuildContext context, ClassModel cls,
      bool isReserved, AuthProvider auth) {
    final spotsColor = cls.isFull
        ? AppTheme.error
        : cls.availableSpots <= 3
            ? AppTheme.warning
            : AppTheme.success;

    final isPast = cls.isPast;
    final canBook = !isPast && !auth.isSubscriptionExpired;

    // Calculer l'heure de fin depuis end_time ou duration
    final endTime = cls.endTime ?? _computeEndTime(cls.time, cls.duration);

    return GestureDetector(
      onTap: canBook
          ? () => context.push('/booking/${cls.id}', extra: cls)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isReserved
                ? AppTheme.primary.withOpacity(0.6)
                : const Color(0xFF2A2A2A),
            width: isReserved ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Heure
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    cls.time,
                    style: TextStyle(
                      color: isPast
                          ? AppTheme.onSurfaceMuted
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    endTime,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFF2A2A2A),
              ),
              // Nom + places
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.name,
                      style: TextStyle(
                        color: isPast
                            ? AppTheme.onSurfaceMuted
                            : Colors.white,
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
                          cls.isFull
                              ? 'Complet'
                              : 'Places disponibles : ${cls.availableSpots}',
                          style: TextStyle(
                              color: spotsColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge réservé ou bouton
              if (isReserved)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Réservé',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              else if (isPast)
                const Icon(Icons.lock_clock,
                    color: AppTheme.onSurfaceMuted, size: 20)
              else if (cls.isFull)
                const Icon(Icons.block,
                    color: AppTheme.error, size: 20)
              else
                const Icon(Icons.chevron_right,
                    color: AppTheme.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _computeEndTime(String startTime, int durationMinutes) {
    final parts = startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final total = hour * 60 + minute + durationMinutes;
    final h = (total ~/ 60) % 24;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // ─── Onglet Profil/Mes réservations ───────────────────────────────────────

  Widget _buildMyReservationsTab(ReservationProvider reservationProvider) {
    final upcoming = reservationProvider.upcomingReservations;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MON PROFIL',
          style: GoogleFonts.bebasNeue(
              color: Colors.white, fontSize: 20, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: upcoming.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64, color: AppTheme.onSurfaceMuted),
                  SizedBox(height: 16),
                  Text('Aucune réservation à venir',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Réservez un cours depuis le planning',
                      style: TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (ctx, i) {
                final res = upcoming[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fitness_center,
                          color: AppTheme.primary, size: 24),
                    ),
                    title: Text(
                      res.className ?? 'Cours',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      res.classDate != null
                          ? '${DateFormat('EEE dd MMM', 'fr_FR').format(res.classDate!)} à ${res.classTime}'
                          : '',
                      style:
                          const TextStyle(color: AppTheme.onSurfaceMuted),
                    ),
                    trailing: TextButton(
                      onPressed: () => _cancelReservation(
                          res.id, res.classId, res.className ?? 'ce cours'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error),
                      child: const Text('Annuler'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _cancelReservation(
      String resId, String classId, String className) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Annuler la réservation'),
        content: Text('Annuler votre réservation pour $className ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
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

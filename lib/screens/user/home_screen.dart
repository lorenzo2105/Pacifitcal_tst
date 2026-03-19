import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/class_provider.dart';
import 'package:pacifitcal/providers/reservation_provider.dart';
import 'package:pacifitcal/widgets/class_card.dart';
import 'package:pacifitcal/widgets/subscription_badge.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ClassProvider>().startListeningUpcoming();
      if (auth.currentUser != null) {
        context
            .read<ReservationProvider>()
            .startListeningUserReservations(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final classProvider = context.watch<ClassProvider>();
    final reservationProvider = context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PACIFITCAL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildPlanning(context, auth, classProvider, reservationProvider),
          _buildMyReservations(reservationProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.calendar_today_outlined),
                if (classProvider.upcomingClasses.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.calendar_today),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.bookmark_outline),
                if (reservationProvider.upcomingReservations.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${reservationProvider.upcomingReservations.length}',
                        style: const TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.bookmark),
            label: 'Mes cours',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanning(
    BuildContext context,
    AuthProvider auth,
    ClassProvider classProvider,
    ReservationProvider reservationProvider,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${auth.currentUser?.prenom ?? ''} 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                      .format(DateTime.now()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceMuted),
                ),
                const SizedBox(height: 16),
                if (auth.currentUser != null)
                  SubscriptionBadge(user: auth.currentUser!),
                const SizedBox(height: 20),
                Text(
                  'Cours disponibles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (classProvider.upcomingClasses.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppTheme.onSurfaceMuted),
                  SizedBox(height: 16),
                  Text(
                    'Aucun cours programmé',
                    style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final cls = classProvider.upcomingClasses[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClassCard(
                      classModel: cls,
                      isReserved: reservationProvider.isReserved(cls.id),
                      onTap: auth.isSubscriptionExpired
                          ? null
                          : () => context.push('/booking/${cls.id}',
                              extra: cls),
                    ),
                  );
                },
                childCount: classProvider.upcomingClasses.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMyReservations(ReservationProvider reservationProvider) {
    final upcoming = reservationProvider.upcomingReservations;

    if (upcoming.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: AppTheme.onSurfaceMuted),
            SizedBox(height: 16),
            Text(
              'Aucune réservation à venir',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Réservez un cours depuis le planning',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcoming.length,
      itemBuilder: (ctx, i) {
        final res = upcoming[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              style: const TextStyle(color: AppTheme.onSurfaceMuted),
            ),
            trailing: TextButton(
              onPressed: () => _cancelReservation(res.id, res.classId,
                  res.className ?? 'ce cours'),
              style:
                  TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Annuler'),
            ),
          ),
        );
      },
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
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

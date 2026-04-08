import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/class_provider.dart';
import 'package:pacifitcal/services/firestore_service.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/reservation_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    context.read<ClassProvider>().startListeningAll();
    _loadStats();
  }

  Future<void> _loadStats() async {
    _firestoreService.streamUsers().listen((users) {
      if (mounted) {
        setState(() {
          _totalUsers = users.where((u) => !u.isAdmin).length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final classProvider = context.watch<ClassProvider>();
    final upcomingClasses =
        classProvider.allClasses.where((c) => !c.isPast).length;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Bonjour, ${auth.currentUser?.prenom ?? 'Admin'} !',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Bienvenue dans votre espace d\'administration',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Séances d\'aujourd\'hui',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ClassModel>>(
              stream: _firestoreService.streamClassesByDate(todayStart),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  );
                }
                final classes = snapshot.data ?? [];
                classes.sort((a, b) => a.time.compareTo(b.time));

                if (classes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy,
                              size: 48, color: AppTheme.onSurfaceMuted),
                          SizedBox(height: 12),
                          Text(
                            'Aucune séance aujourd\'hui',
                            style: TextStyle(
                                color: AppTheme.onSurfaceMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final classModel = classes[index];
                    return _buildTodayClassCard(classModel);
                  },
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Gestion',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.people,
              title: 'Gérer les adhérents',
              subtitle: '$_totalUsers utilisateurs inscrits',
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.fitness_center,
              title: 'Gérer les cours',
              subtitle: '$upcomingClasses cours à venir',
              onTap: () => context.push('/admin/classes'),
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icon: Icons.bookmark_outline,
              title: 'Gérer les réservations',
              subtitle: 'Voir toutes les réservations',
              onTap: () => context.push('/admin/reservations'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayClassCard(ClassModel classModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Heure
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      classModel.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (classModel.endTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        classModel.endTime!,
                        style: const TextStyle(
                          color: AppTheme.onSurfaceMuted,
                          fontSize: 12,
                        ),
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
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classModel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (classModel.coach != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          classModel.coach!,
                          style: const TextStyle(
                            color: AppTheme.onSurfaceMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            classModel.isFull
                                ? Icons.person_off_outlined
                                : Icons.people_outline,
                            size: 13,
                            color: classModel.isFull
                                ? AppTheme.error
                                : AppTheme.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classModel.currentParticipants}/${classModel.maxParticipants}',
                            style: TextStyle(
                              color: classModel.isFull
                                  ? AppTheme.error
                                  : AppTheme.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton voir inscrits
                StreamBuilder<List<ReservationModel>>(
                  stream:
                      _firestoreService.streamClassReservations(classModel.id),
                  builder: (context, snapshot) {
                    final reservations = snapshot.data ?? [];
                    return IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.people, color: AppTheme.primary),
                          if (reservations.isNotEmpty)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${reservations.length}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () =>
                          _showParticipants(classModel, reservations),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipants(
      ClassModel classModel, List<ReservationModel> reservations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Participants - ${classModel.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${reservations.length} / ${classModel.maxParticipants} places',
              style: const TextStyle(color: AppTheme.onSurfaceMuted),
            ),
            const SizedBox(height: 16),
            if (reservations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aucun participant inscrit',
                    style: TextStyle(color: AppTheme.onSurfaceMuted),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: reservations.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF2A2A2A),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        child: Text(
                          ((reservation.userName?.isNotEmpty ?? false)
                                  ? reservation.userName![0]
                                  : 'U')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        reservation.userName ?? 'Utilisateur inconnu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Inscrit le ${DateFormat('dd/MM/yyyy à HH:mm').format(reservation.createdAt)}',
                        style: const TextStyle(
                          color: AppTheme.onSurfaceMuted,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: AppTheme.onSurfaceMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/providers/class_provider.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _expiredUsers = 0;

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
          _activeUsers = users.where((u) => !u.isAdmin && u.isActive).length;
          _expiredUsers =
              users.where((u) => !u.isAdmin && u.isSubscriptionExpired).length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final classProvider = context.watch<ClassProvider>();
    final upcomingClasses = classProvider.allClasses.where((c) => !c.isPast).length;
    final totalClasses = classProvider.allClasses.length;

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
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.people_outline,
                    label: 'Adhérents',
                    value: '$_totalUsers',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.verified_user_outlined,
                    label: 'Actifs',
                    value: '$_activeUsers',
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.warning_amber_outlined,
                    label: 'Expirés',
                    value: '$_expiredUsers',
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.event_outlined,
                    label: 'Cours à venir',
                    value: '$upcomingClasses / $totalClasses',
                    color: AppTheme.primary,
                  ),
                ),
              ],
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

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.onSurfaceMuted, fontSize: 12),
          ),
        ],
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

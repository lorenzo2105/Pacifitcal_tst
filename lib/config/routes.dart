import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/screens/auth/login_screen.dart';
import 'package:pacifitcal/screens/auth/register_screen.dart';
import 'package:pacifitcal/screens/auth/change_password_screen.dart';
import 'package:pacifitcal/screens/user/home_screen.dart';
import 'package:pacifitcal/screens/user/profile_screen.dart';
import 'package:pacifitcal/screens/user/booking_detail_screen.dart';
import 'package:pacifitcal/screens/user/my_reservations_screen.dart';
import 'package:pacifitcal/screens/admin/admin_dashboard_screen.dart';
import 'package:pacifitcal/screens/admin/admin_users_screen.dart';
import 'package:pacifitcal/screens/admin/admin_classes_screen.dart';
import 'package:pacifitcal/screens/admin/admin_reservations_screen.dart';
import 'package:pacifitcal/screens/admin/admin_user_form_screen.dart';
import 'package:pacifitcal/screens/admin/admin_class_form_screen.dart';
import 'package:pacifitcal/screens/admin/admin_template_form_screen.dart';
import 'package:pacifitcal/screens/splash_screen.dart';
import 'package:pacifitcal/models/class_model.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isAdmin = authProvider.isAdmin;
        final isExpired = authProvider.isSubscriptionExpired;
        final hasWeakPassword = authProvider.currentUser?.weakPassword ?? false;
        final path = state.matchedLocation;

        if (path == '/splash') return null;

        if (!isLoggedIn) {
          if (path == '/login' || path == '/register') return null;
          return '/login';
        }

        // Forcer le changement de mot de passe si weak_password = true
        if (hasWeakPassword && path != '/change-password') {
          return '/change-password';
        }

        if (isExpired && !isAdmin) {
          if (path == '/profile' || path == '/login') return null;
          return '/profile';
        }

        if (isAdmin && !path.startsWith('/admin')) {
          return '/admin';
        }

        if (!isAdmin && path.startsWith('/admin')) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) =>
              const ChangePasswordScreen(mandatory: true),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/reservations',
          builder: (context, state) => const MyReservationsScreen(),
        ),
        GoRoute(
          path: '/booking/:classId',
          builder: (context, state) {
            final classModel = state.extra as ClassModel;
            return BookingDetailScreen(classModel: classModel);
          },
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: '/admin/users/new',
          builder: (context, state) => const AdminUserFormScreen(),
        ),
        GoRoute(
          path: '/admin/users/edit/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return AdminUserFormScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/admin/classes',
          builder: (context, state) => const AdminClassesScreen(),
        ),
        GoRoute(
          path: '/admin/classes/new',
          builder: (context, state) => const AdminClassFormScreen(),
        ),
        GoRoute(
          path: '/admin/classes/edit/:classId',
          builder: (context, state) {
            final classId = state.pathParameters['classId']!;
            return AdminClassFormScreen(classId: classId);
          },
        ),
        GoRoute(
          path: '/admin/reservations',
          builder: (context, state) => const AdminReservationsScreen(),
        ),
        GoRoute(
          path: '/admin/reservations/:classId',
          builder: (context, state) {
            final classId = state.pathParameters['classId']!;
            return AdminReservationsScreen(classId: classId);
          },
        ),
        GoRoute(
          path: '/admin/templates/new',
          builder: (context, state) => const AdminTemplateFormScreen(),
        ),
        GoRoute(
          path: '/admin/templates/edit/:templateId',
          builder: (context, state) {
            final templateId = state.pathParameters['templateId']!;
            return AdminTemplateFormScreen(templateId: templateId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page introuvable: ${state.error}'),
        ),
      ),
    );
  }
}

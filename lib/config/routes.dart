import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pacifitcal/providers/auth_provider.dart';
import 'package:pacifitcal/screens/auth/login_screen.dart';
import 'package:pacifitcal/screens/auth/register_screen.dart';
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
        final path = state.matchedLocation;

        if (path == '/splash') return null;

        if (!isLoggedIn) {
          if (path == '/login' || path == '/register') return null;
          return '/login';
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
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page introuvable: ${state.error}'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/home_dashboard_screen.dart';
import 'features/transactions/transactions_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // refresca redirects cuando cambia el auth state
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      final loggedIn = authState is AuthLoggedIn;
      final loggedOut = authState is AuthLoggedOut;

      if (loggedOut && !isLoggingIn) return '/login';
      if (loggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
  );
});

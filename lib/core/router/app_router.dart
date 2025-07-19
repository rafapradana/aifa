import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final currentPath = state.matchedLocation;

      // If not logged in and trying to access protected routes
      if (!isLoggedIn && currentPath != '/login') {
        return '/login';
      }

      // If logged in and trying to access login page
      if (isLoggedIn && currentPath == '/login') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/', redirect: (context, state) => '/dashboard'),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionPage(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
      GoRoute(path: '/budget', builder: (context, state) => const BudgetPage()),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsPage()),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
    ],
  );
});

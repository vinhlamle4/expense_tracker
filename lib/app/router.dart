import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/categories/domain/entities/category.dart';
import '../features/categories/presentation/screens/add_edit_category_screen.dart';
import '../features/categories/presentation/screens/category_list_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

final appRouter = GoRouter(
  initialLocation: '/reports',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          builder: (context, state) => const TransactionListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'add-transaction',
              builder: (context, state) =>
                  const AddEditTransactionScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              name: 'edit-transaction',
              builder: (context, state) {
                final transaction = state.extra as Transaction?;
                return AddEditTransactionScreen(existing: transaction);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'categories',
              name: 'categories',
              builder: (context, state) => const CategoryListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'add-category',
                  builder: (context, state) =>
                      const AddEditCategoryScreen(),
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'edit-category',
                  builder: (context, state) {
                    final category = state.extra as Category?;
                    return AddEditCategoryScreen(existing: category);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Shell — bottom navigation bar (3 tabs: Reports | Transactions | Settings)
// ---------------------------------------------------------------------------

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/transactions')) currentIndex = 1;
    if (location.startsWith('/settings')) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/reports');
            case 1:
              context.go('/transactions');
            case 2:
              context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

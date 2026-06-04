import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/domain/transaction_entry.dart';
import '../../features/transactions/presentation/widgets/transaction_form_sheet.dart';

class MonetraShell extends ConsumerStatefulWidget {
  const MonetraShell({super.key});

  @override
  ConsumerState<MonetraShell> createState() => _MonetraShellState();
}

class _MonetraShellState extends ConsumerState<MonetraShell> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _selectedIndex <= 1
          ? FloatingActionButton.extended(
              onPressed: () => _openAddExpenseSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Обзор',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Записи',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Бюджеты',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Аналитика',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Еще',
          ),
        ],
      ),
    );
  }

  Future<void> _openAddExpenseSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const TransactionFormSheet(
        initialType: TransactionType.expense,
      ),
    );
  }
}

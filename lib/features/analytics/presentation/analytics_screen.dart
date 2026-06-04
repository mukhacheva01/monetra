import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/section_card.dart';
import '../../budgets/application/budgets_controller.dart';
import '../../budgets/domain/budget_summary.dart';
import '../../transactions/application/transactions_controller.dart';
import '../../transactions/domain/transaction_entry.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetSummariesProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final uncategorizedSpend = ref.watch(uncategorizedMonthlySpendProvider);
    final transactions = ref.watch(transactionsProvider);

    final now = DateTime.now();
    final thisMonthExpenses = _sumExpensesForMonth(
      transactions: transactions,
      year: now.year,
      month: now.month,
    );
    final previousMonth = DateTime(now.year, now.month - 1);
    final previousMonthExpenses = _sumExpensesForMonth(
      transactions: transactions,
      year: previousMonth.year,
      month: previousMonth.month,
    );
    final delta = thisMonthExpenses - previousMonthExpenses;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Быстрый срез',
            child: Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Доходы',
                    value: '${totalIncome.round()} ₽',
                    tone: const Color(0xFF1DAA7A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'Расходы',
                    value: '${totalExpenses.round()} ₽',
                    tone: const Color(0xFFFF8A65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Сравнение месяцев',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SignalLine(
                  label: 'Текущий месяц',
                  value: '${thisMonthExpenses.round()} ₽',
                ),
                _SignalLine(
                  label: 'Прошлый месяц',
                  value: '${previousMonthExpenses.round()} ₽',
                ),
                _SignalLine(
                  label: 'Разница',
                  value:
                      '${delta >= 0 ? '+' : ''}${delta.round()} ₽',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Структура расходов',
            child: _BarsPreview(budgets: budgets),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Бюджетные сигналы',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SignalLine(
                  label: 'Лимитов на месяц',
                  value: '${budgets.length}',
                ),
                _SignalLine(
                  label: 'Нераспределенные траты',
                  value: '${uncategorizedSpend.round()} ₽',
                ),
                _SignalLine(
                  label: 'Текущий месяц',
                  value: currentMonthKey(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _sumExpensesForMonth({
    required List<TransactionEntry> transactions,
    required int year,
    required int month,
  }) {
    return transactions.where((entry) {
      return entry.isExpense &&
          entry.createdAt.year == year &&
          entry.createdAt.month == month;
    }).fold<double>(0, (sum, entry) => sum + entry.amount);
  }
}

class _BarsPreview extends StatelessWidget {
  const _BarsPreview({
    required this.budgets,
  });

  final List<BudgetSummary> budgets;

  @override
  Widget build(BuildContext context) {
    const palette = [
      Color(0xFFFF8A65),
      Color(0xFF9575CD),
      Color(0xFF4DB6AC),
      Color(0xFF64B5F6),
    ];

    if (budgets.isEmpty) {
      return const Text('Пока нет данных для аналитики.');
    }

    return Column(
      children: budgets.asMap().entries.map((entry) {
        final item = entry.value;
        final color = palette[entry.key % palette.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(item.title),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    minHeight: 14,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.16),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SignalLine extends StatelessWidget {
  const _SignalLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

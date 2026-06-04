import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/money_formatter.dart';
import '../../transactions/application/transactions_controller.dart';
import '../../../shared/widgets/section_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetSummariesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Месячные лимиты',
            child: Column(
              children: budgets.map((budget) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _BudgetCard(
                    title: budget.title,
                    spent: budget.spent,
                    limit: budget.limit,
                    progress: budget.progress,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const SectionCard(
            title: 'Следующий шаг',
            child: Text(
              'На этом экране позже появятся создание новых бюджетов, архив прошлых месяцев и уведомления о приближении к лимиту.',
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.title,
    required this.spent,
    required this.limit,
    required this.progress,
  });

  final String title;
  final double spent;
  final double limit;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Потрачено ${MoneyFormatter.rub(spent)} из ${MoneyFormatter.rub(limit)}',
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
}

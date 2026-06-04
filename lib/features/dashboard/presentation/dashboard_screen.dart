import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../budgets/application/budgets_controller.dart';
import '../../transactions/application/transactions_controller.dart';
import '../../../shared/widgets/section_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(totalExpensesProvider);
    final income = ref.watch(totalIncomeProvider);
    final budgets = ref.watch(budgetSummariesProvider);
    final transactions = ref.watch(transactionsProvider);
    final topCategory = ref.watch(topExpenseCategoryProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroSummary(
            income: income,
            expenses: expenses,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Фокус месяца',
            child: Row(
              children: [
                Expanded(
                  child: _InsightTile(
                    label: 'Остаток бюджета',
                    value: MoneyFormatter.rub(
                      budgets.fold<double>(
                        0,
                        (sum, item) => sum + item.left,
                      ),
                    ),
                    tone: Color(0xFF1DAA7A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightTile(
                    label: 'Самая затратная категория',
                    value: topCategory?.name ?? 'Нет данных',
                    tone: Color(0xFFFF8A65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Бюджеты',
            trailing: Text(
              'Июнь',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            child: Column(
              children: budgets
                  .map(
                    (budget) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BudgetProgressRow(
                        title: budget.title,
                        progress: budget.progress,
                        spent: budget.spent,
                        limit: budget.limit,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Последние операции',
            child: Column(
              children: transactions.take(4).map((entry) {
                final category = ref.read(categoriesProvider).firstWhere(
                  (item) => item.id == entry.categoryId,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionRow(
                    emoji: category.emoji,
                    title: category.name,
                    subtitle: entry.note ?? 'Без комментария',
                    amount: entry.amount,
                    isExpense: entry.isExpense,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.income,
    required this.expenses,
  });

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1DAA7A),
            Color(0xFF117A8B),
            Color(0xFF0F4C81),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.appName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.appTagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Чистый баланс месяца',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            MoneyFormatter.rub(income - expenses),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricPanel(
                  label: 'Доходы',
                  value: MoneyFormatter.rub(income),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricPanel(
                  label: 'Расходы',
                  value: MoneyFormatter.rub(expenses),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
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
        borderRadius: BorderRadius.circular(18),
        color: tone.withValues(alpha: 0.14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
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

class _BudgetProgressRow extends StatelessWidget {
  const _BudgetProgressRow({
    required this.title,
    required this.progress,
    required this.spent,
    required this.limit,
  });

  final String title;
  final double progress;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final color = progress > 0.9
        ? const Color(0xFFFF6B6B)
        : progress > 0.7
            ? const Color(0xFFFFB74D)
            : const Color(0xFF1DAA7A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${MoneyFormatter.rub(spent)} / ${MoneyFormatter.rub(limit)}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: color,
            backgroundColor: color.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        isExpense ? const Color(0xFFFF8A65) : const Color(0xFF1DAA7A);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          '${isExpense ? '-' : '+'}${MoneyFormatter.rub(amount)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

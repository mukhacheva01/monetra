import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/money_formatter.dart';
import '../../../shared/widgets/section_card.dart';
import '../application/budgets_controller.dart';
import '../domain/budget_entry.dart';
import '../domain/budget_summary.dart';
import 'widgets/budget_form_sheet.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(budgetSummariesProvider);
    final entries = ref.watch(currentMonthBudgetsProvider);
    final uncategorizedSpend = ref.watch(uncategorizedMonthlySpendProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Лимиты месяца',
            trailing: FilledButton.tonal(
              onPressed: () => _openBudgetForm(context),
              child: const Text('Добавить'),
            ),
            child: summaries.isEmpty
                ? const Text('Пока нет лимитов на текущий месяц.')
                : Column(
                    children: summaries.map((budget) {
                      final entry = entries.firstWhere(
                        (item) => item.id == budget.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _BudgetCard(
                          budget: budget,
                          onEdit: () => _openBudgetForm(
                            context,
                            entry: entry,
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            ref,
                            entry.id,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Сводка бюджета',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(
                  label: 'Категорий с лимитом',
                  value: '${summaries.length}',
                ),
                _InfoLine(
                  label: 'Нераспределенные траты',
                  value: MoneyFormatter.rub(uncategorizedSpend),
                ),
                _InfoLine(
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

  Future<void> _openBudgetForm(
    BuildContext context, {
    BudgetEntry? entry,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => BudgetFormSheet(entry: entry),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String budgetId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить лимит?'),
          content: const Text(
            'Бюджет будет удален из локальной базы данных.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(budgetEntriesProvider.notifier).deleteBudget(budgetId);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetSummary budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = budget.progress > 0.9
        ? const Color(0xFFFF6B6B)
        : budget.progress > 0.7
            ? const Color(0xFFFFB74D)
            : const Color(0xFF1DAA7A);

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
                  budget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${(budget.progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Редактировать'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Удалить'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Потрачено ${MoneyFormatter.rub(budget.spent)} из ${MoneyFormatter.rub(budget.limit)}',
          ),
          const SizedBox(height: 6),
          Text(
            'Остаток: ${MoneyFormatter.rub(budget.left)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 12,
              color: color,
              backgroundColor: color.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
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

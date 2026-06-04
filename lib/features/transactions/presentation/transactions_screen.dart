import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/money_formatter.dart';
import '../../categories/domain/category_item.dart';
import '../application/transactions_controller.dart';
import '../domain/transaction_entry.dart';
import 'widgets/transaction_form_sheet.dart';
import '../../../shared/widgets/section_card.dart';

enum TransactionTypeFilter {
  all,
  expenses,
  incomes,
}

enum TransactionPeriodFilter {
  all,
  week,
  month,
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionTypeFilter _typeFilter = TransactionTypeFilter.all;
  TransactionPeriodFilter _periodFilter = TransactionPeriodFilter.all;
  String _categoryFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final filtered = _applyFilters(
      transactions: transactions,
      categories: categories,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Быстрые действия',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickActionChip(
                  icon: Icons.add_card_rounded,
                  label: 'Добавить расход',
                  onTap: () => _openForm(TransactionType.expense),
                ),
                _QuickActionChip(
                  icon: Icons.savings_outlined,
                  label: 'Добавить доход',
                  onTap: () => _openForm(TransactionType.income),
                ),
                _QuickActionChip(
                  icon: Icons.filter_alt_outlined,
                  label: 'Сбросить фильтры',
                  onTap: _resetFilters,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Фильтры',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilterTitle(label: 'Тип'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChoiceChip(
                      label: 'Все',
                      selected: _typeFilter == TransactionTypeFilter.all,
                      onSelected: () => setState(() {
                        _typeFilter = TransactionTypeFilter.all;
                      }),
                    ),
                    _ChoiceChip(
                      label: 'Расходы',
                      selected: _typeFilter == TransactionTypeFilter.expenses,
                      onSelected: () => setState(() {
                        _typeFilter = TransactionTypeFilter.expenses;
                      }),
                    ),
                    _ChoiceChip(
                      label: 'Доходы',
                      selected: _typeFilter == TransactionTypeFilter.incomes,
                      onSelected: () => setState(() {
                        _typeFilter = TransactionTypeFilter.incomes;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FilterTitle(label: 'Период'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChoiceChip(
                      label: 'Все время',
                      selected: _periodFilter == TransactionPeriodFilter.all,
                      onSelected: () => setState(() {
                        _periodFilter = TransactionPeriodFilter.all;
                      }),
                    ),
                    _ChoiceChip(
                      label: '7 дней',
                      selected: _periodFilter == TransactionPeriodFilter.week,
                      onSelected: () => setState(() {
                        _periodFilter = TransactionPeriodFilter.week;
                      }),
                    ),
                    _ChoiceChip(
                      label: 'Месяц',
                      selected: _periodFilter == TransactionPeriodFilter.month,
                      onSelected: () => setState(() {
                        _periodFilter = TransactionPeriodFilter.month;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FilterTitle(label: 'Категория'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChoiceChip(
                      label: 'Все',
                      selected: _categoryFilter == 'all',
                      onSelected: () => setState(() {
                        _categoryFilter = 'all';
                      }),
                    ),
                    ...categories.map((category) {
                      return _ChoiceChip(
                        label: category.name,
                        selected: _categoryFilter == category.id,
                        onSelected: () => setState(() {
                          _categoryFilter = category.id;
                        }),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Лента операций',
            trailing: Text(
              '${filtered.length} записей',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            child: filtered.isEmpty
                ? const Text('По текущим фильтрам ничего не найдено.')
                : Column(
                    children: filtered.map((entry) {
                      final category = categories.firstWhere(
                        (item) => item.id == entry.categoryId,
                      );

                      return _TransactionTile(
                        entry: entry,
                        category: category,
                        onEdit: () => _openForm(entry.type, entry: entry),
                        onDelete: () => _confirmDelete(entry),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  List<TransactionEntry> _applyFilters({
    required List<TransactionEntry> transactions,
    required List<CategoryItem> categories,
  }) {
    final now = DateTime.now();

    return transactions.where((entry) {
      final typeMatches = switch (_typeFilter) {
        TransactionTypeFilter.all => true,
        TransactionTypeFilter.expenses => entry.isExpense,
        TransactionTypeFilter.incomes => !entry.isExpense,
      };

      final periodMatches = switch (_periodFilter) {
        TransactionPeriodFilter.all => true,
        TransactionPeriodFilter.week =>
          entry.createdAt.isAfter(now.subtract(const Duration(days: 7))),
        TransactionPeriodFilter.month =>
          entry.createdAt.year == now.year && entry.createdAt.month == now.month,
      };

      final categoryMatches = _categoryFilter == 'all' ||
          entry.categoryId == _categoryFilter;

      return typeMatches && periodMatches && categoryMatches;
    }).toList(growable: false);
  }

  void _resetFilters() {
    setState(() {
      _typeFilter = TransactionTypeFilter.all;
      _periodFilter = TransactionPeriodFilter.all;
      _categoryFilter = 'all';
    });
  }

  Future<void> _openForm(
    TransactionType type, {
    TransactionEntry? entry,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TransactionFormSheet(
        initialType: type,
        entry: entry,
      ),
    );
  }

  Future<void> _confirmDelete(TransactionEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить операцию?'),
          content: const Text(
            'Запись будет удалена из локальной базы данных.',
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
      await ref.read(transactionsProvider.notifier).deleteTransaction(entry.id);
    }
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
    );
  }
}

class _FilterTitle extends StatelessWidget {
  const _FilterTitle({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.entry,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionEntry entry;
  final CategoryItem category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Color(category.colorHex).withValues(alpha: 0.15),
        child: Text(category.emoji),
      ),
      title: Text(category.name),
      subtitle: Text(entry.note ?? 'Без заметки'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${entry.isExpense ? '-' : '+'}${MoneyFormatter.rub(entry.amount)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: entry.isExpense
                      ? const Color(0xFFFF8A65)
                      : const Color(0xFF1DAA7A),
                ),
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
    );
  }
}

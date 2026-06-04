import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/domain/category_item.dart';
import '../../../transactions/application/transactions_controller.dart';
import '../../application/budgets_controller.dart';
import '../../domain/budget_entry.dart';

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({
    this.entry,
    super.key,
  });

  final BudgetEntry? entry;

  bool get isEditing => entry != null;

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  String? _selectedCategoryId;
  late String _monthKey;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _limitController.text = widget.entry?.limit.toStringAsFixed(0) ?? '';
    _selectedCategoryId = widget.entry?.categoryId;
    _monthKey = widget.entry?.monthKey ?? currentMonthKey();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((item) => item.id != 'salary')
        .toList(growable: false);

    _selectedCategoryId ??= categories.first.id;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Редактировать бюджет' : 'Новый бюджет',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Лимит будет учитываться в текущей месячной сводке.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                ),
                items: categories.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: _CategoryLabel(item: item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Лимит',
                  hintText: 'Например, 15000',
                ),
                validator: (value) {
                  final normalized = value?.replaceAll(',', '.').trim() ?? '';
                  final amount = double.tryParse(normalized);

                  if (amount == null || amount <= 0) {
                    return 'Введите корректный лимит';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _monthKey,
                decoration: const InputDecoration(
                  labelText: 'Месяц',
                  hintText: 'YYYY-MM',
                ),
                onChanged: (value) => _monthKey = value.trim(),
                validator: (value) {
                  final monthPattern = RegExp(r'^\d{4}-\d{2}$');
                  if (!monthPattern.hasMatch((value ?? '').trim())) {
                    return 'Формат месяца: YYYY-MM';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(
                    _isSubmitting
                        ? 'Сохраняем...'
                        : widget.isEditing
                            ? 'Сохранить изменения'
                            : 'Создать бюджет',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final limit = double.parse(
      _limitController.text.replaceAll(',', '.').trim(),
    );

    final controller = ref.read(budgetEntriesProvider.notifier);

    if (widget.entry == null) {
      await controller.addBudget(
        categoryId: _selectedCategoryId!,
        limit: limit,
        monthKey: _monthKey,
      );
    } else {
      await controller.updateBudget(
        original: widget.entry!,
        categoryId: _selectedCategoryId!,
        limit: limit,
        monthKey: _monthKey,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({
    required this.item,
  });

  final CategoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(item.emoji),
        const SizedBox(width: 8),
        Text(item.name),
      ],
    );
  }
}

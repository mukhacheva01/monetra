import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/categories/domain/category_item.dart';
import '../../application/transactions_controller.dart';
import '../../domain/transaction_entry.dart';

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    this.initialType = TransactionType.expense,
    this.entry,
    super.key,
  });

  final TransactionType initialType;
  final TransactionEntry? entry;

  bool get isEditing => entry != null;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  late TransactionType _selectedType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.entry?.type ?? widget.initialType;
    _amountController.text = widget.entry?.amount.toStringAsFixed(0) ?? '';
    _noteController.text = widget.entry?.note ?? '';
    _selectedCategoryId = widget.entry?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((item) => _selectedType == TransactionType.income
            ? item.id == 'salary'
            : item.id != 'salary')
        .toList(growable: false);

    _selectedCategoryId ??= categories.first.id;
    if (!categories.any((item) => item.id == _selectedCategoryId)) {
      _selectedCategoryId = categories.first.id;
    }

    final title = widget.isEditing
        ? 'Редактировать операцию'
        : _selectedType == TransactionType.expense
            ? 'Новый расход'
            : 'Новый доход';

    final subtitle = widget.isEditing
        ? 'Изменения сразу сохранятся в локальной базе.'
        : 'Запись сразу попадет в историю и обновит сводку.';

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
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Расход'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Доход'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedType = selection.first;
                    _selectedCategoryId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  hintText: 'Например, 850',
                ),
                validator: (value) {
                  final normalized = value?.replaceAll(',', '.').trim() ?? '';
                  final amount = double.tryParse(normalized);

                  if (amount == null || amount <= 0) {
                    return 'Введите корректную сумму';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Комментарий',
                  hintText: 'Например, ужин с друзьями',
                ),
                maxLines: 2,
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
                            : 'Сохранить операцию',
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

    final amount = double.parse(
      _amountController.text.replaceAll(',', '.').trim(),
    );

    final controller = ref.read(transactionsProvider.notifier);

    if (widget.entry == null) {
      await controller.addTransaction(
        amount: amount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text.trim(),
        type: _selectedType,
      );
    } else {
      await controller.updateTransaction(
        original: widget.entry!,
        amount: amount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text.trim(),
        type: _selectedType,
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

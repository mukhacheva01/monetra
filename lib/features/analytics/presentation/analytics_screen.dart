import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/application/transactions_controller.dart';
import '../../../shared/widgets/section_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetSummariesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Структура расходов',
            child: _BarsPreview(budgets: budgets),
          ),
          const SizedBox(height: 16),
          const SectionCard(
            title: 'Что появится дальше',
            child: Text(
              'Следующим этапом сюда добавятся круговые и линейные графики, сравнение месяцев и простые финансовые инсайты.',
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPreview extends StatelessWidget {
  const _BarsPreview({
    required this.budgets,
  });

  final List<dynamic> budgets;

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

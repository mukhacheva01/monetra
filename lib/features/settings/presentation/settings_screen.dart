import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(
            title: 'Оформление',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingLine(
                  title: 'Тема',
                  value: 'Темная по умолчанию',
                ),
                _SettingLine(
                  title: 'Визуальный стиль',
                  value: 'Спокойный контрастный интерфейс',
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SectionCard(
            title: 'Данные',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingLine(
                  title: 'Хранение',
                  value: 'Локально на устройстве',
                ),
                _SettingLine(
                  title: 'Синхронизация',
                  value: 'Будет подключена на следующем этапе',
                ),
                _SettingLine(
                  title: 'Экспорт',
                  value: 'CSV и backup позже',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingLine extends StatelessWidget {
  const _SettingLine({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

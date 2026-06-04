import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SectionCard(
          title: 'Categories',
          child: Text('Custom category management belongs in this module.'),
        ),
      ),
    );
  }
}

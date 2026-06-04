import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../shared/widgets/monetra_shell.dart';
import 'theme/app_theme.dart';

class MonetraApp extends StatelessWidget {
  const MonetraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const MonetraShell(),
    );
  }
}

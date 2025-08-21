import 'package:flutter/material.dart';
import 'core/design/app_theme.dart';
import 'screens/budget_screen.dart';

void main() {
  runApp(const AltForceApp());
}

class AltForceApp extends StatelessWidget {
  const AltForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AltForce - Orçamentos Dinâmicos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BudgetScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/budget_screen.dart';

void main() {
  runApp(const AltForceApp());
}

class AltForceApp extends StatelessWidget {
  const AltForceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AltForce - Orçamentos Dinâmicos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BudgetScreen(),
    );
  }
}

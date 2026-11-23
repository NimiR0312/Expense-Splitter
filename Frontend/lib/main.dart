import 'package:flutter/material.dart';

import 'package:expense_splitter/core/theme/app_theme.dart';
import 'package:expense_splitter/features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTheme.initTheme();

  runApp(const ExpenseSplitterApp());
}

class ExpenseSplitterApp extends StatelessWidget {
  const ExpenseSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Splitter',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

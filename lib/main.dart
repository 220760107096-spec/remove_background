import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/presentation/providers/app_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const BgEraserApp(),
    ),
  );
}

class BgEraserApp extends StatelessWidget {
  const BgEraserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'BgEraser – AI Background Remover',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

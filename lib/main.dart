import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'state/planora_controller.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlanoraApp());
}

class PlanoraApp extends StatefulWidget {
  const PlanoraApp({super.key});

  @override
  State<PlanoraApp> createState() => _PlanoraAppState();
}

class _PlanoraAppState extends State<PlanoraApp> {
  late final PlanoraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlanoraController();
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return PlanoraScope(
          controller: _controller,
          child: MaterialApp(
            title: 'Planora',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _controller.preferDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppShell(),
          ),
        );
      },
    );
  }
}

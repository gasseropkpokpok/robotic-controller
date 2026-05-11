import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'state/app_state.dart';
import 'screens/control_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const RoboticApp(),
      ),
    );
  });
}

class RoboticApp extends StatelessWidget {
  const RoboticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Team RC',
      theme: AppTheme.darkRedTheme,
      debugShowCheckedModeBanner: false,
      home: const ControlScreen(),
    );
  }
}

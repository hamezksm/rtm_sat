import 'package:flutter/material.dart';
import 'package:rtm_sat/core/routes/app_router.dart';
import 'package:rtm_sat/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route To Market',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rtm_sat/app.dart';
import 'package:rtm_sat/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initDependencies();

  runApp(const App());
}

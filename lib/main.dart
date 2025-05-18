import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rtm_sat/app.dart';
import 'package:rtm_sat/core/di/service_locator.dart' as di;
import 'package:rtm_sat/core/init/app_init_cubit.dart';
import 'package:rtm_sat/core/init/app_init_state.dart';
import 'package:rtm_sat/core/init/prefetch_init_data.dart';
import 'package:rtm_sat/core/providers/providers.dart';
import 'package:rtm_sat/features/splash/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before initializing dependencies
  await dotenv.load();

  // Initialize the service locator (GetIt) after env vars are loaded
  await di.initDependencies();

  // After initialization, we can safely create the prefetch service
  final prefetch = PrefetchInitData(
    customerRepo: di.sl(),
    activityRepo: di.sl(),
  );

  runApp(
    BlocProvider(
      create: (_) => AppInitCubit(prefetch)..initialize(),
      child: const AppWithPrefetch(),
    ),
  );
}

class AppWithPrefetch extends StatelessWidget {
  const AppWithPrefetch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppInitCubit, AppInitState>(
      builder: (context, state) {
        if (state is AppInitLoading) {
          return MaterialApp(
            title: 'Route To Market',
            home: SplashPage(),
            debugShowCheckedModeBanner: false,
          );
        } else if (state is AppInitSuccess) {
          // When data is loaded, return the main app with all providers
          return MultiBlocProvider(
            providers: getProviders(),
            child: const App(),
          );
        } else if (state is AppInitFailure) {
          return MaterialApp(
            title: 'Route To Market',
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AppInitCubit>().initialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }
        return const MaterialApp(home: SplashPage());
      },
    );
  }
}

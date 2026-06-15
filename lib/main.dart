import 'dart:async';

import 'package:booklub/config/env/env_config.dart';
import 'package:booklub/config/providers/providers_config.dart';
import 'package:booklub/config/theme/theme_context.dart';
import 'package:booklub/ui/core/splash_animations/splash_wrapper.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

/// Global key used to show toasts (snackbars) from outside the widget tree,
/// such as from the global error handlers.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  EnvConfig.checkEnvVars();

  final logger = AppLogger.create();

  // Handles framework-level errors (e.g. widget build failures).
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(
      'Flutter error: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Catches errors that escape the framework (e.g. async errors without
  // a catch block). Prevents the app from crashing and shows a friendly
  // toast to the user instead.
  runZonedGuarded<Future<void>>(() async {
    if (kDebugMode) {
      MarionetteBinding.ensureInitialized();
    } else {
      WidgetsFlutterBinding.ensureInitialized();
    }

    runApp(
      MultiProvider(
        providers: ProvidersConfig.providers,
        child: const MyApp(),
      ),
    );
  }, (Object error, StackTrace stack) {
    logger.e('Uncaught error', error: error, stackTrace: stack);
    final messenger = scaffoldMessengerKey.currentState;
    messenger?.showSnackBar(
      const SnackBar(content: Text('Algo deu errado. Tente novamente.')),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeContext = context.watch<ThemeContext>();
    final router = context.read<GoRouter>();

    return SplashWrapper(
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Booklub',
        theme: themeContext.activeTheme.themeData,
        routerConfig: router,
      ),
    );
  }
}

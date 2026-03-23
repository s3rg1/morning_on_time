import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/alarm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize AlarmManager FIRST - this is critical for wake-up alarms
  await AlarmService.initialize();
  
  // Initialize Firebase for analytics (non-critical, wrapped in try-catch)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed (non-critical): $e');
    // Continue anyway - alarms are more important than analytics
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: MaterialApp(
        title: 'Never Late',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 2,
          ),
        ),
        home: const _InitScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/setup': (context) => const SetupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

/// Invisible init screen that waits for AppState to load while the
/// native splash screen remains visible, then navigates to the
/// appropriate screen.
class _InitScreen extends StatefulWidget {
  const _InitScreen();

  @override
  State<_InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<_InitScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Timeout after 15 seconds to prevent infinite splash if initialization stalls
    int waited = 0;
    while (appState.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      waited += 100;
      if (waited >= 15000) {
        print('⚠️ Splash timeout reached — proceeding with navigation');
        break;
      }
    }

    // Remove the native splash now that we're ready to show real UI.
    FlutterNativeSplash.remove();

    if (!mounted) return;

    if (!appState.isOnboardingComplete) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (!appState.isSetupComplete) {
      Navigator.of(context).pushReplacementNamed('/setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty container — the native splash covers the screen.
    return const SizedBox.shrink();
  }
}

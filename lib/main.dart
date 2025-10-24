import 'package:everyday_christian/core/navigation/app_routes.dart';
import 'package:everyday_christian/core/navigation/navigation_service.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:everyday_christian/screens/bible_browser_screen.dart';
import 'package:everyday_christian/screens/chapter_reading_screen.dart';
import 'package:everyday_christian/screens/chat_screen.dart';
import 'package:everyday_christian/screens/devotional_screen.dart';
import 'package:everyday_christian/screens/home_screen.dart';
import 'package:everyday_christian/screens/legal_agreements_screen.dart';
import 'package:everyday_christian/screens/onboarding_screen.dart';
import 'package:everyday_christian/screens/prayer_journal_screen.dart';
import 'package:everyday_christian/screens/profile_screen.dart';
import 'package:everyday_christian/screens/reading_plan_screen.dart';
import 'package:everyday_christian/screens/settings_screen.dart';
import 'package:everyday_christian/screens/splash_screen.dart';
import 'package:everyday_christian/screens/verse_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  final subscriptionService = SubscriptionService.instance;
  await subscriptionService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        subscriptionServiceProvider.overrideWithValue(subscriptionService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Everyday Christian',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.legalAgreements:
            return MaterialPageRoute(builder: (_) => const LegalAgreementsScreen());
          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.chat:
            return MaterialPageRoute(builder: (_) => const ChatScreen());
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case AppRoutes.prayerJournal:
            return MaterialPageRoute(builder: (_) => const PrayerJournalScreen());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.devotional:
            return MaterialPageRoute(builder: (_) => const DevotionalScreen());
          case AppRoutes.readingPlan:
            return MaterialPageRoute(builder: (_) => const ReadingPlanScreen());
          case AppRoutes.bibleBrowser:
            return MaterialPageRoute(builder: (_) => const BibleBrowserScreen());
          case AppRoutes.verseLibrary:
            return MaterialPageRoute(builder: (_) => const VerseLibraryScreen());
          case AppRoutes.chapterReading:
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ChapterReadingScreen(
                book: args?['book'] ?? '',
                startChapter: args?['startChapter'] ?? 1,
                endChapter: args?['endChapter'] ?? 1,
                readingId: args?['readingId'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

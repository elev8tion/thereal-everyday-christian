import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:everyday_christian/screens/bible_reader/chapter_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final subscriptionService = SubscriptionService();
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
      home: const ChapterReadingScreen(
        book: 'Genesis',
        startChapter: 1,
        endChapter: 50,
      ),
    );
  }
}

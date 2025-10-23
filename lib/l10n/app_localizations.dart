import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// First part of app name on splash screen
  ///
  /// In en, this message translates to:
  /// **'EVERYDAY'**
  String get appName;

  /// Second part of app name on splash screen
  ///
  /// In en, this message translates to:
  /// **'CHRISTIAN'**
  String get appNameSecond;

  /// App tagline on splash screen
  ///
  /// In en, this message translates to:
  /// **'Faith-guided wisdom for life\'s moments'**
  String get tagline;

  /// Loading message on splash screen
  ///
  /// In en, this message translates to:
  /// **'Preparing your spiritual journey...'**
  String get loadingJourney;

  /// App version number
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// Footer message on splash screen
  ///
  /// In en, this message translates to:
  /// **'Built with ❤️ for faith'**
  String get builtWithFaith;

  /// Onboarding subtitle
  ///
  /// In en, this message translates to:
  /// **'Your faith-guided companion for life\'s moments'**
  String get faithGuidedCompanion;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'AI Biblical Guidance'**
  String get aiBiblicalGuidance;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Get personalized Bible verses and wisdom for any situation'**
  String get aiBiblicalGuidanceDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Daily Verses'**
  String get dailyVerses;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Receive encouraging Scripture at 9:30 AM or your preferred time'**
  String get dailyVersesDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Complete Privacy'**
  String get completePrivacy;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'All your spiritual conversations stay on your device'**
  String get completePrivacyDesc;

  /// Call to action button
  ///
  /// In en, this message translates to:
  /// **'Begin Your Journey'**
  String get beginYourJourney;

  /// Skip onboarding option
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Auth screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Auth screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your spiritual journey'**
  String get signInToContinue;

  /// Privacy assurance message
  ///
  /// In en, this message translates to:
  /// **'Your spiritual conversations remain completely private on your device'**
  String get privacyNote;

  /// Sign in button and tab
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button and tab
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Biometric authentication button
  ///
  /// In en, this message translates to:
  /// **'Use Biometric'**
  String get useBiometric;

  /// Terms agreement message
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to keep your spiritual journey private and secure.'**
  String get agreeTerms;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Divider text between options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Rise and shine'**
  String get riseAndShine;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Home screen subtitle
  ///
  /// In en, this message translates to:
  /// **'How can I encourage you today?'**
  String get howCanIEncourage;

  /// Streak stat label
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Prayers stat label
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get prayers;

  /// Verses read stat label
  ///
  /// In en, this message translates to:
  /// **'Verses Read'**
  String get versesRead;

  /// Devotionals stat label
  ///
  /// In en, this message translates to:
  /// **'Devotionals'**
  String get devotionals;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'AI Guidance'**
  String get aiGuidance;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Get biblical wisdom for any situation you\'re facing'**
  String get aiGuidanceDesc;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Daily Devotional'**
  String get dailyDevotional;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Grow closer to God with daily reflections'**
  String get dailyDevotionalDesc;

  /// Feature card title and screen title
  ///
  /// In en, this message translates to:
  /// **'Prayer Journal'**
  String get prayerJournal;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Track your prayers and see God\'s faithfulness'**
  String get prayerJournalDesc;

  /// Feature card title and screen title
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get readingPlans;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Structured Bible reading with daily guidance'**
  String get readingPlansDesc;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Bible Library'**
  String get bibleLibrary;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Add Prayer'**
  String get addPrayer;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Share Verse'**
  String get shareVerse;

  /// Settings screen title and menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile screen title and menu item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Daily verse section title
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get verseOfTheDay;

  /// Category badge
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get comfort;

  /// Chat CTA button
  ///
  /// In en, this message translates to:
  /// **'Start Spiritual Conversation'**
  String get startSpiritualConversation;

  /// Chat screen title
  ///
  /// In en, this message translates to:
  /// **'Biblical AI Guidance'**
  String get biblicalAIGuidance;

  /// Chat subtitle
  ///
  /// In en, this message translates to:
  /// **'Powered by local AI'**
  String get poweredByLocalAI;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Ask for biblical guidance...'**
  String get askForBiblicalGuidance;

  /// Welcome message greeting
  ///
  /// In en, this message translates to:
  /// **'Peace be with you! 🙏'**
  String get peaceBeWithYou;

  /// Welcome message content
  ///
  /// In en, this message translates to:
  /// **'I\'m here to provide biblical guidance and spiritual support. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?'**
  String get chatWelcomeMessage;

  /// Prayer journal subtitle
  ///
  /// In en, this message translates to:
  /// **'Plan Pray Reflect'**
  String get bringRequestsToGod;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Active Prayers'**
  String get noActivePrayers;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your prayer journey by adding your first prayer request'**
  String get startPrayerJourney;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Answered Prayers Yet'**
  String get noAnsweredPrayersYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'When God answers your prayers, mark them as answered to see them here'**
  String get markPrayersAnswered;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Mark as Answered'**
  String get markAsAnswered;

  /// Menu action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Answered prayer label
  ///
  /// In en, this message translates to:
  /// **'How God Answered:'**
  String get howGodAnswered;

  /// Answered date label
  ///
  /// In en, this message translates to:
  /// **'Answered {date}'**
  String answered_date(String date);

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Prayer Request'**
  String get addPrayerRequest;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Title field placeholder
  ///
  /// In en, this message translates to:
  /// **'What are you praying for?'**
  String get whatArePrayingFor;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description field placeholder
  ///
  /// In en, this message translates to:
  /// **'Share more details about your prayer request...'**
  String get shareMoreDetails;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Add Prayer'**
  String get addPrayerButton;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Mark Answered'**
  String get markAnswered;

  /// Answer description prompt
  ///
  /// In en, this message translates to:
  /// **'How did God answer this prayer?'**
  String get howDidGodAnswer;

  /// Answer field placeholder
  ///
  /// In en, this message translates to:
  /// **'Share how God answered your prayer...'**
  String get shareHowGodAnswered;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Work/Career'**
  String get workCareer;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get guidance;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get gratitude;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Relative date
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Streak count
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreakCount(int count);

  /// Completion count
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String completed(int count);

  /// Day indicator
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(int number);

  /// Verse section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Verse'**
  String get todaysVerse;

  /// Reflection section title
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// Completion status
  ///
  /// In en, this message translates to:
  /// **'Devotional Completed'**
  String get devotionalCompleted;

  /// Completion date
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get completedToday;

  /// Completion date
  ///
  /// In en, this message translates to:
  /// **'Completed yesterday'**
  String get completedYesterday;

  /// Completion date
  ///
  /// In en, this message translates to:
  /// **'Completed {count} days ago'**
  String completedDaysAgo(int count);

  /// Navigation button
  ///
  /// In en, this message translates to:
  /// **'Previous Day'**
  String get previousDay;

  /// Navigation button
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get nextDay;

  /// Progress section title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Progress counter
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String progressCount(int current, int total);

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Devotionals Available'**
  String get noDevotionalsAvailable;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Check back later for daily devotionals'**
  String get checkBackForDevotionals;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Error Loading Devotionals'**
  String get errorLoadingDevotionals;

  /// Reading plan subtitle
  ///
  /// In en, this message translates to:
  /// **'Grow in God\'s word daily'**
  String get growInGodsWord;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Active Reading Plan'**
  String get noActiveReadingPlan;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start a reading plan to see today\'s readings here'**
  String get startReadingPlanPrompt;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Explore Plans'**
  String get explorePlans;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Readings'**
  String get todaysReadings;

  /// Empty readings title
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// Empty readings subtitle
  ///
  /// In en, this message translates to:
  /// **'No readings scheduled for today'**
  String get noReadingsToday;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Active Plans'**
  String get noActivePlans;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start a reading plan to track your progress'**
  String get startReadingPlanToTrack;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Start Plan'**
  String get startPlan;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Marked as incomplete'**
  String get markedAsIncomplete;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Great job! Keep up the good work!'**
  String get greatJobKeepUp;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Reading plan started! Let\'s begin your journey.'**
  String get readingPlanStarted;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error starting plan: {error}'**
  String errorStartingPlan(String error);

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Reading Plan?'**
  String get resetReadingPlan;

  /// Dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset \"{planTitle}\"? All progress will be lost.'**
  String resetPlanConfirmation(String planTitle);

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Reading plan has been reset'**
  String get readingPlanReset;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error resetting plan: {error}'**
  String errorResettingPlan(String error);

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWrong;

  /// Progress percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(String percent);

  /// Screen title
  ///
  /// In en, this message translates to:
  /// **'Verse Library'**
  String get verseLibrary;

  /// Subtitle
  ///
  /// In en, this message translates to:
  /// **'Find comfort in God\'s word'**
  String get findComfortInGodsWord;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search verses or references...'**
  String get searchVersesOrReferences;

  /// Category filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Faith'**
  String get faith;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Hope'**
  String get hope;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get love;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get peace;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get wisdom;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Forgiveness'**
  String get forgiveness;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'All Verses'**
  String get allVerses;

  /// Tab label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Tab label with count
  ///
  /// In en, this message translates to:
  /// **'All Verses ({count})'**
  String allVersesCount(int count);

  /// Tab label with count
  ///
  /// In en, this message translates to:
  /// **'Favorites ({count})'**
  String favoritesCount(int count);

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No verses found'**
  String get noVersesFound;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or category filter'**
  String get tryAdjustingSearch;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'No verses available in this category'**
  String get noVersesInCategory;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No favorite verses yet'**
  String get noFavoriteVersesYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any verse to add it to your favorites'**
  String get tapHeartToFavorite;

  /// Bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Share Verse'**
  String get shareVerseTitle;

  /// Share option
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// Share option
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// Share option
  ///
  /// In en, this message translates to:
  /// **'Create Image Quote'**
  String get createImageQuote;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Daily Notifications'**
  String get dailyNotifications;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Receive daily spiritual reminders'**
  String get dailyNotificationsDesc;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get prayerReminders;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Get reminded to pray throughout the day'**
  String get prayerRemindersDesc;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get verseOfTheDaySetting;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Daily Bible verse notifications'**
  String get verseOfTheDayDesc;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Bible Settings'**
  String get bibleSettings;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Bible Version'**
  String get bibleVersion;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred translation'**
  String get bibleVersionDesc;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get languageDesc;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Adjust reading text size for better readability'**
  String get textSizeDesc;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// Setting label
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Use app without internet connection'**
  String get offlineModeDesc;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get clearCacheDesc;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Backup your prayers and notes'**
  String get exportDataDesc;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFAQ;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Get answers to common questions'**
  String get helpFAQDesc;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Get help with technical issues'**
  String get contactSupportDesc;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Share your feedback on the App Store'**
  String get rateAppDesc;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Info label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// Info label
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicyDesc;

  /// Setting action
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Setting description
  ///
  /// In en, this message translates to:
  /// **'Read terms and conditions'**
  String get termsOfServiceDesc;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheDialogTitle;

  /// Dialog message
  ///
  /// In en, this message translates to:
  /// **'This will free up storage space but may require re-downloading some content.'**
  String get clearCacheDialogMessage;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Data export started - you will be notified when complete'**
  String get dataExportStarted;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpDialogTitle;

  /// Dialog message
  ///
  /// In en, this message translates to:
  /// **'For help and support, please visit our website or contact us through the app.'**
  String get helpDialogMessage;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Opening email client...'**
  String get openingEmailClient;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Opening App Store...'**
  String get openingAppStore;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Opening privacy policy...'**
  String get openingPrivacyPolicy;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Opening terms of service...'**
  String get openingTermsOfService;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Your Spiritual Journey'**
  String get yourSpiritualJourney;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Prayer Streak'**
  String get prayerStreak;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Total Prayers'**
  String get totalPrayers;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Achievement progress
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total}'**
  String achievementCount(int unlocked, int total);

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Prayer Warrior'**
  String get prayerWarrior;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Prayed for 7 days in a row'**
  String get prayerWarriorDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Bible Scholar'**
  String get bibleScholar;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Read 100 verses'**
  String get bibleScholarDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Faithful Friend'**
  String get faithfulFriend;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete 30 devotionals'**
  String get faithfulFriendDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Scripture Master'**
  String get scriptureMaster;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete 5 reading plans'**
  String get scriptureMasterDesc;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Snackbar message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutQuestion;

  /// Dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Member badge
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

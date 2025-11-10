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

  /// Biblical Chat feature title
  ///
  /// In en, this message translates to:
  /// **'Biblical Chat'**
  String get biblicalChat;

  /// Biblical Chat feature description
  ///
  /// In en, this message translates to:
  /// **'Get biblical wisdom for any situation you\'re facing'**
  String get biblicalChatDesc;

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

  /// Reading plan notification setting
  ///
  /// In en, this message translates to:
  /// **'Reading Plan'**
  String get readingPlan;

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

  /// Navigation label for home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeScreen;

  /// Quick action label
  ///
  /// In en, this message translates to:
  /// **'Read Bible'**
  String get readBible;

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

  /// Stat card label for saved verses count
  ///
  /// In en, this message translates to:
  /// **'Saved Verses'**
  String get savedVerses;

  /// Tooltip message for FAB menu
  ///
  /// In en, this message translates to:
  /// **'Tap here to navigate ✨'**
  String get fabTooltipMessage;

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

  /// Settings screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get settingsSubtitle;

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
  /// **'I\'m here to provide intelligent scripture support directly from the word itself, for everyday Christian questions. Feel free to ask me about:\n\n• Scripture interpretation\n• Prayer requests\n• Life challenges\n• Faith questions\n• Daily encouragement\n\nHow can I help you today?'**
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

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Faith'**
  String get faith;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @ministry.
  ///
  /// In en, this message translates to:
  /// **'Ministry'**
  String get ministry;

  /// No description provided for @thanksgiving.
  ///
  /// In en, this message translates to:
  /// **'Thanksgiving'**
  String get thanksgiving;

  /// No description provided for @intercession.
  ///
  /// In en, this message translates to:
  /// **'Intercession'**
  String get intercession;

  /// No description provided for @finances.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get finances;

  /// No description provided for @relationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationships;

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

  /// Daily devotional notification description
  ///
  /// In en, this message translates to:
  /// **'Morning inspiration to start your day'**
  String get dailyDevotionalNotificationDesc;

  /// Prayer reminders notification description
  ///
  /// In en, this message translates to:
  /// **'Gentle nudges to pause and pray'**
  String get prayerRemindersNotificationDesc;

  /// Verse of the day notification description
  ///
  /// In en, this message translates to:
  /// **'Daily scripture to reflect on'**
  String get verseOfTheDayNotificationDesc;

  /// Reading plan notification description
  ///
  /// In en, this message translates to:
  /// **'Stay on track with your Bible reading'**
  String get readingPlanNotificationDesc;

  /// Subscription section title
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Manage subscription setting
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// World English Bible version abbreviation
  ///
  /// In en, this message translates to:
  /// **'WEB'**
  String get webBibleVersion;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Delete all data action
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Delete all data description
  ///
  /// In en, this message translates to:
  /// **'⚠️ Permanently delete all your data'**
  String get deleteAllDataDesc;

  /// App lock setting
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// App lock description
  ///
  /// In en, this message translates to:
  /// **'Require Face ID / Touch ID to open app'**
  String get appLockDesc;

  /// Set time button text
  ///
  /// In en, this message translates to:
  /// **'Set Time'**
  String get setTime;

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

  /// Name deletion success message
  ///
  /// In en, this message translates to:
  /// **'Name deleted successfully'**
  String get nameDeleted;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Unbroken'**
  String get achievementUnbroken;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day prayer streak'**
  String get achievementUnbrokenDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Relentless'**
  String get achievementRelentless;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Log 50 prayers'**
  String get achievementRelentlessDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Curator'**
  String get achievementCurator;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Save 100 Bible verses'**
  String get achievementCuratorDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Daily Bread'**
  String get achievementDailyBread;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete 30 devotionals'**
  String get achievementDailyBreadDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Deep Diver'**
  String get achievementDeepDiver;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Start 5 reading plans'**
  String get achievementDeepDiverDesc;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'Disciple'**
  String get achievementDisciple;

  /// Achievement description
  ///
  /// In en, this message translates to:
  /// **'Share 10 items (verses, chats, prayers, or devotionals)'**
  String get achievementDiscipleDesc;

  /// Email error message
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get couldNotOpenEmailApp;

  /// Email error with details
  ///
  /// In en, this message translates to:
  /// **'Error opening email: {error}'**
  String errorOpeningEmailWithError(String error);

  /// Bible browser screen title
  ///
  /// In en, this message translates to:
  /// **'Bible Browser'**
  String get bibleBrowser;

  /// Bible browser subtitle
  ///
  /// In en, this message translates to:
  /// **'Read any chapter freely'**
  String get readAnyChapterFreely;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search books...'**
  String get searchBooks;

  /// Loading message during verse search
  ///
  /// In en, this message translates to:
  /// **'Searching verses...'**
  String get searchingVerses;

  /// Old Testament tab label
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get oldTestament;

  /// New Testament tab label
  ///
  /// In en, this message translates to:
  /// **'New Testament'**
  String get newTestament;

  /// Empty state when no books match search
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get noBooksFound;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// Single chapter count
  ///
  /// In en, this message translates to:
  /// **'{count} chapter'**
  String chapterCount(int count);

  /// Multiple chapters count
  ///
  /// In en, this message translates to:
  /// **'{count} chapters'**
  String chaptersCount(int count);

  /// Chapter selector title
  ///
  /// In en, this message translates to:
  /// **'Select Chapter - {book}'**
  String selectChapterBook(String book);

  /// Verse search results count
  ///
  /// In en, this message translates to:
  /// **'{count} verses found'**
  String versesFoundCount(int count);

  /// Audio playback completion message
  ///
  /// In en, this message translates to:
  /// **'Chapter playback complete'**
  String get chapterPlaybackComplete;

  /// Reading completion success message
  ///
  /// In en, this message translates to:
  /// **'Reading marked as complete!'**
  String get readingMarkedComplete;

  /// Error message when updating reading fails
  ///
  /// In en, this message translates to:
  /// **'Error updating reading: {error}'**
  String errorUpdatingReading(String error);

  /// Audio playback error message
  ///
  /// In en, this message translates to:
  /// **'Audio playback error'**
  String get audioPlaybackError;

  /// Chapter progress indicator
  ///
  /// In en, this message translates to:
  /// **'Chapter {current} of {total}'**
  String chapterOfTotal(int current, int total);

  /// Single chapter label
  ///
  /// In en, this message translates to:
  /// **'1 chapter'**
  String get oneChapter;

  /// Empty verse message for specific book chapter
  ///
  /// In en, this message translates to:
  /// **'No verses found for {book} {chapter}'**
  String noVersesFoundForBook(String book, int chapter);

  /// Verse interaction tutorial tooltip
  ///
  /// In en, this message translates to:
  /// **'Press & hold verse for actions ✨'**
  String get pressHoldVerseForActions;

  /// Verse removal confirmation
  ///
  /// In en, this message translates to:
  /// **'Removed from Verse Library'**
  String get removedFromVerseLibrary;

  /// Verse added confirmation
  ///
  /// In en, this message translates to:
  /// **'Added to Verse Library!'**
  String get addedToVerseLibrary;

  /// Reading completion button text when completed
  ///
  /// In en, this message translates to:
  /// **'✓ Reading Completed'**
  String get readingCompleted;

  /// Chapter loading error title
  ///
  /// In en, this message translates to:
  /// **'Error loading chapter'**
  String get errorLoadingChapter;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No verses empty state title
  ///
  /// In en, this message translates to:
  /// **'No verses available'**
  String get noVersesAvailable;

  /// No verses found for chapter range
  ///
  /// In en, this message translates to:
  /// **'Could not find verses for {book} {startChapter}-{endChapter}'**
  String couldNotFindVersesForRange(
      String book, int startChapter, int endChapter);

  /// Devotional options bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Devotional Options'**
  String get devotionalOptions;

  /// Share devotional menu option
  ///
  /// In en, this message translates to:
  /// **'Share Devotional'**
  String get shareDevotional;

  /// Devotional share success message
  ///
  /// In en, this message translates to:
  /// **'Devotional shared!'**
  String get devotionalShared;

  /// Devotional share error message
  ///
  /// In en, this message translates to:
  /// **'Unable to share devotional: {error}'**
  String unableToShareDevotional(String error);

  /// Opening scripture section title
  ///
  /// In en, this message translates to:
  /// **'Opening Scripture'**
  String get openingScripture;

  /// Key verse section title
  ///
  /// In en, this message translates to:
  /// **'Key Verse Spotlight'**
  String get keyVerseSpotlight;

  /// Life application section title
  ///
  /// In en, this message translates to:
  /// **'Life Application'**
  String get lifeApplication;

  /// Prayer section title
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// Action step section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Action Step'**
  String get todaysActionStep;

  /// Extended section title for going deeper
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get extended;

  /// Monthly progress indicator
  ///
  /// In en, this message translates to:
  /// **'{month} {year} Progress'**
  String monthYearProgress(String month, String year);

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Prayer journal category filter label
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// Clear category filter button
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Share action label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Category selection dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Category loading error message
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// Prayer addition success message
  ///
  /// In en, this message translates to:
  /// **'Prayer added successfully'**
  String get prayerAddedSuccessfully;

  /// Prayer addition error message
  ///
  /// In en, this message translates to:
  /// **'Error adding prayer: {error}'**
  String errorAddingPrayer(String error);

  /// Prayer marked answered success message
  ///
  /// In en, this message translates to:
  /// **'Prayer marked as answered! 🙏'**
  String get prayerMarkedAnswered;

  /// Prayer share success message
  ///
  /// In en, this message translates to:
  /// **'Prayer shared successfully! 🙏'**
  String get prayerSharedSuccessfully;

  /// Prayer share error message
  ///
  /// In en, this message translates to:
  /// **'Unable to share prayer: {error}'**
  String unableToSharePrayer(String error);

  /// Delete prayer dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Prayer'**
  String get deletePrayer;

  /// Delete prayer confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deletePrayerConfirmation(String title);

  /// Prayer deletion success message
  ///
  /// In en, this message translates to:
  /// **'Prayer deleted'**
  String get prayerDeleted;

  /// Prayer deletion error message
  ///
  /// In en, this message translates to:
  /// **'Error deleting prayer: {error}'**
  String errorDeletingPrayer(String error);

  /// Prayer loading error message
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayers'**
  String get unableToLoadPrayers;

  /// Answered prayers loading error message
  ///
  /// In en, this message translates to:
  /// **'Unable to load answered prayers'**
  String get unableToLoadAnsweredPrayers;

  /// Paywall screen title
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get paywallTitle;

  /// Paywall screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock AI chat features'**
  String get paywallSubtitle;

  /// Trial days remaining badge
  ///
  /// In en, this message translates to:
  /// **'{days} days left in trial'**
  String paywallTrialDaysLeft(int days);

  /// Message shown when trial was already used
  ///
  /// In en, this message translates to:
  /// **'Welcome back!\n\nYour trial has been used on this device.\nSubscribe to continue using AI chat.'**
  String get paywallTrialBlockedMessage;

  /// Message shown when trial has expired
  ///
  /// In en, this message translates to:
  /// **'Your trial has ended.\nUpgrade to continue using AI chat.'**
  String get paywallTrialEndedMessage;

  /// Messages remaining stat label
  ///
  /// In en, this message translates to:
  /// **'Messages\nLeft'**
  String get paywallMessagesLeft;

  /// Messages used this month label
  ///
  /// In en, this message translates to:
  /// **'Used This\nMonth'**
  String get paywallUsedThisMonth;

  /// Messages used in trial label
  ///
  /// In en, this message translates to:
  /// **'Used in\nTrial'**
  String get paywallUsedInTrial;

  /// Monthly message limit label
  ///
  /// In en, this message translates to:
  /// **'Monthly\nLimit'**
  String get paywallMonthlyLimit;

  /// Trial days remaining stat label
  ///
  /// In en, this message translates to:
  /// **'Trial Days\nLeft'**
  String get paywallTrialDaysLeft2;

  /// Per year pricing label
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallPerYear;

  /// Pricing disclaimer
  ///
  /// In en, this message translates to:
  /// **'(pricing may vary by region and currency)'**
  String get paywallPricingDisclaimer;

  /// Monthly message limit feature
  ///
  /// In en, this message translates to:
  /// **'150 AI messages per month'**
  String get paywall150MessagesPerMonth;

  /// Cost breakdown message
  ///
  /// In en, this message translates to:
  /// **'Less than \$3 per month'**
  String get paywallLessThan3PerMonth;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'What\'s Included'**
  String get paywallWhatsIncluded;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Intelligent Scripture Chat'**
  String get paywallFeatureIntelligentChat;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Custom Real World Pastoral Training'**
  String get paywallFeatureIntelligentChatDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'150 Messages Monthly'**
  String get paywallFeature150Messages;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'More than enough for daily conversations'**
  String get paywallFeature150MessagesDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Context-Aware Responses'**
  String get paywallFeatureContextAware;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Biblical intelligence tailored to provide insight'**
  String get paywallFeatureContextAwareDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Crisis Detection'**
  String get paywallFeatureCrisisDetection;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Built-in safeguards and professional referrals'**
  String get paywallFeatureCrisisDetectionDesc;

  /// Feature title
  ///
  /// In en, this message translates to:
  /// **'Full Bible Access'**
  String get paywallFeatureFullBibleAccess;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'All free features remain available'**
  String get paywallFeatureFullBibleAccessDesc;

  /// Processing purchase button text
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get paywallProcessing;

  /// Start premium subscription button
  ///
  /// In en, this message translates to:
  /// **'Start Premium - {price}/year'**
  String paywallStartPremiumButton(String price);

  /// Restore purchase button text
  ///
  /// In en, this message translates to:
  /// **'Restore Previous Purchase'**
  String get paywallRestorePurchase;

  /// Subscription terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Payment will be charged to your App Store account. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. Cancel anytime in your App Store account settings.'**
  String get paywallSubscriptionTerms;

  /// Premium activation success message
  ///
  /// In en, this message translates to:
  /// **'Premium activated! 150 Messages Monthly.'**
  String get paywallPremiumActivatedSuccess;

  /// Purchase failure error message
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get paywallPurchaseFailed;

  /// Purchase restore success message
  ///
  /// In en, this message translates to:
  /// **'Purchase restored successfully!'**
  String get paywallPurchaseRestoredSuccess;

  /// No previous purchase error message
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get paywallNoPreviousPurchaseFound;

  /// Verse library subtitle
  ///
  /// In en, this message translates to:
  /// **'Everyday verses'**
  String get everydayVerses;

  /// Shared verses tab label
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get shared;

  /// Empty shared verses state title
  ///
  /// In en, this message translates to:
  /// **'No shared verses yet'**
  String get noSharedVersesYet;

  /// Empty saved verses state title
  ///
  /// In en, this message translates to:
  /// **'No saved verses yet'**
  String get noSavedVersesYet;

  /// Empty saved verses state subtitle
  ///
  /// In en, this message translates to:
  /// **'💡 Save verses while reading to build your collection'**
  String get saveVersesWhileReading;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Verse copied success message
  ///
  /// In en, this message translates to:
  /// **'Verse copied to clipboard'**
  String get verseCopiedToClipboard;

  /// Share as text option
  ///
  /// In en, this message translates to:
  /// **'Share Text'**
  String get shareText;

  /// Verse share error message
  ///
  /// In en, this message translates to:
  /// **'Unable to share verse: {error}'**
  String unableToShareVerse(String error);

  /// Verse library options bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Verse Library Options'**
  String get verseLibraryOptions;

  /// About verse library menu option
  ///
  /// In en, this message translates to:
  /// **'About Verse Library'**
  String get aboutVerseLibrary;

  /// View shared history menu option
  ///
  /// In en, this message translates to:
  /// **'View shared history'**
  String get viewSharedHistory;

  /// Clear saved verses menu option
  ///
  /// In en, this message translates to:
  /// **'Clear saved verses'**
  String get clearSavedVerses;

  /// Clear shared history menu option
  ///
  /// In en, this message translates to:
  /// **'Clear shared history'**
  String get clearSharedHistory;

  /// Shared verse deleted success message
  ///
  /// In en, this message translates to:
  /// **'Removed from shared history'**
  String get removedFromSharedHistory;

  /// Shared verse deletion error message
  ///
  /// In en, this message translates to:
  /// **'Unable to remove shared verse: {error}'**
  String unableToRemoveSharedVerse(String error);

  /// Verse deletion error message
  ///
  /// In en, this message translates to:
  /// **'Unable to remove verse: {error}'**
  String unableToRemoveVerse(String error);

  /// Clear shared history dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear shared history?'**
  String get clearSharedHistoryQuestion;

  /// Clear shared history dialog message
  ///
  /// In en, this message translates to:
  /// **'This removes every verse from your Shared tab. Future shares will continue to appear here.'**
  String get clearSharedHistoryConfirmation;

  /// Clear all button text
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Shared history cleared success message
  ///
  /// In en, this message translates to:
  /// **'Shared history cleared'**
  String get sharedHistoryCleared;

  /// Clear shared history error message
  ///
  /// In en, this message translates to:
  /// **'Unable to clear shared history: {error}'**
  String unableToClearSharedHistory(String error);

  /// Clear saved verses dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear saved verses?'**
  String get clearSavedVersesQuestion;

  /// Clear saved verses dialog message
  ///
  /// In en, this message translates to:
  /// **'This will remove every verse from your Saved list. You can always add them again later.'**
  String get clearSavedVersesConfirmation;

  /// Saved verses cleared success message
  ///
  /// In en, this message translates to:
  /// **'Saved verses cleared'**
  String get savedVersesCleared;

  /// Clear saved verses error message
  ///
  /// In en, this message translates to:
  /// **'Unable to clear saved verses: {error}'**
  String unableToClearSavedVerses(String error);

  /// Onboarding welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Everyday Christian'**
  String get welcomeToEverydayChristian;

  /// Onboarding subtitle
  ///
  /// In en, this message translates to:
  /// **'Bible Study, Prayer, & Devotionals'**
  String get dailyScriptureGuidance;

  /// Legal agreements introduction
  ///
  /// In en, this message translates to:
  /// **'Before we begin, please review:'**
  String get beforeWeBeginReview;

  /// Terms checkbox label
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service'**
  String get acceptTermsOfService;

  /// Privacy checkbox label
  ///
  /// In en, this message translates to:
  /// **'I accept the Privacy Policy'**
  String get acceptPrivacyPolicy;

  /// Age confirmation checkbox label
  ///
  /// In en, this message translates to:
  /// **'I confirm I am 13+ years old'**
  String get confirmAge13Plus;

  /// Crisis resources section title
  ///
  /// In en, this message translates to:
  /// **'Crisis Resources'**
  String get crisisResources;

  /// Crisis resources contact information
  ///
  /// In en, this message translates to:
  /// **'If you\'re in crisis, please contact:\n\n988 Suicide & Crisis Lifeline\nCall or text 988\n\nCrisis Text Line\nText HOME to 741741\n\nRAINN National Sexual Assault Hotline\nCall 800-656-4673\n\nThis app provides structured tools for faith practices but is not a substitute for professional help.'**
  String get crisisResourcesText;

  /// Legal agreements accept button
  ///
  /// In en, this message translates to:
  /// **'Accept & Continue'**
  String get acceptAndContinue;

  /// View document link text
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Devotional demo page title
  ///
  /// In en, this message translates to:
  /// **'Try Your First Devotional'**
  String get tryYourFirstDevotional;

  /// Devotional demo page description
  ///
  /// In en, this message translates to:
  /// **'Here\'s a preview of a daily devotional to start your day with the word'**
  String get devotionalPreviewDesc;

  /// Demo devotional title line 1
  ///
  /// In en, this message translates to:
  /// **'Cultivating a'**
  String get demoDevotionalTitle1;

  /// Demo devotional title line 2
  ///
  /// In en, this message translates to:
  /// **'Thankful Heart'**
  String get demoDevotionalTitle2;

  /// Demo devotional opening scripture verse text
  ///
  /// In en, this message translates to:
  /// **'\"Give thanks to the LORD, for he is good, for his loving kindness endures forever.\"'**
  String get demoVerseText;

  /// Demo devotional opening scripture reference
  ///
  /// In en, this message translates to:
  /// **'Psalm 107:1'**
  String get demoVerseReference;

  /// Demo devotional reflection preview
  ///
  /// In en, this message translates to:
  /// **'Gratitude doesn\'t always come naturally—especially when life feels overwhelming. Yet Psalm 107 opens with a powerful invitation: give thanks...'**
  String get demoReflectionText;

  /// Completed button text
  ///
  /// In en, this message translates to:
  /// **'✓ Completed!'**
  String get completedExclamation;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// AI chat demo page title
  ///
  /// In en, this message translates to:
  /// **'Ask Me Anything'**
  String get askMeAnything;

  /// AI chat demo page subtitle
  ///
  /// In en, this message translates to:
  /// **'Intelligent Scripture Chat 24/7'**
  String get intelligentScriptureChat;

  /// Demo chat user message
  ///
  /// In en, this message translates to:
  /// **'How do I overcome worry?'**
  String get demoChatUserMessage;

  /// Demo chat AI response
  ///
  /// In en, this message translates to:
  /// **'Great question! The Bible offers beautiful wisdom on overcoming worry. In Philippians 4:6-7, we\'re reminded to bring our concerns to God through prayer with thanksgiving, and His peace will guard our hearts...'**
  String get demoChatAIResponse;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Scripture Chat...'**
  String get scriptureChatPlaceholder;

  /// Final onboarding page title
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get youreAllSet;

  /// Final onboarding page subtitle
  ///
  /// In en, this message translates to:
  /// **'One last thing...'**
  String get oneLastThing;

  /// Name input prompt
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get whatShouldWeCallYou;

  /// Name input placeholder
  ///
  /// In en, this message translates to:
  /// **'First name (optional)'**
  String get firstNameOptional;

  /// Final onboarding encouragement
  ///
  /// In en, this message translates to:
  /// **'Your spiritual journey starts now!'**
  String get spiritualJourneyStartsNow;

  /// Subscription settings screen title
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// Subscription settings screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your premium access'**
  String get subscriptionSubtitle;

  /// Premium subscription active status
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get subscriptionStatusPremiumActive;

  /// Premium subscription active description
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited AI guidance'**
  String get subscriptionStatusPremiumActiveDesc;

  /// Free trial status
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get subscriptionStatusFreeTrial;

  /// Trial days remaining status
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String subscriptionStatusTrialDaysRemaining(int days);

  /// Trial expired status
  ///
  /// In en, this message translates to:
  /// **'Trial Expired'**
  String get subscriptionStatusTrialExpired;

  /// Trial expired description
  ///
  /// In en, this message translates to:
  /// **'Upgrade to continue using AI chat'**
  String get subscriptionStatusTrialExpiredDesc;

  /// Free version status
  ///
  /// In en, this message translates to:
  /// **'Free Version'**
  String get subscriptionStatusFreeVersion;

  /// Free version description
  ///
  /// In en, this message translates to:
  /// **'Start your free trial'**
  String get subscriptionStatusFreeVersionDesc;

  /// Messages remaining label
  ///
  /// In en, this message translates to:
  /// **'Messages\nLeft'**
  String get subscriptionMessagesLeft;

  /// Messages used this month label
  ///
  /// In en, this message translates to:
  /// **'Used This\nMonth'**
  String get subscriptionUsedThisMonth;

  /// Messages used today label
  ///
  /// In en, this message translates to:
  /// **'Used\nToday'**
  String get subscriptionUsedToday;

  /// Monthly message limit label
  ///
  /// In en, this message translates to:
  /// **'Monthly\nLimit'**
  String get subscriptionMonthlyLimit;

  /// Trial days remaining label
  ///
  /// In en, this message translates to:
  /// **'Trial Days\nLeft'**
  String get subscriptionTrialDaysLeft;

  /// Premium benefits section title
  ///
  /// In en, this message translates to:
  /// **'Your Premium Benefits'**
  String get subscriptionYourPremiumBenefits;

  /// Upgrade to premium section title
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get subscriptionUpgradeToPremium;

  /// Benefit title
  ///
  /// In en, this message translates to:
  /// **'Intelligent Scripture Chat'**
  String get subscriptionBenefitIntelligentChat;

  /// Benefit description
  ///
  /// In en, this message translates to:
  /// **'Custom Real World Pastoral Training'**
  String get subscriptionBenefitIntelligentChatDesc;

  /// Benefit title
  ///
  /// In en, this message translates to:
  /// **'150 Messages Monthly'**
  String get subscriptionBenefit150Messages;

  /// Benefit description
  ///
  /// In en, this message translates to:
  /// **'More than enough for daily conversations'**
  String get subscriptionBenefit150MessagesDesc;

  /// Benefit title
  ///
  /// In en, this message translates to:
  /// **'Context-Aware Responses'**
  String get subscriptionBenefitContextAware;

  /// Benefit description
  ///
  /// In en, this message translates to:
  /// **'Biblical intelligence tailored to provide insight'**
  String get subscriptionBenefitContextAwareDesc;

  /// Benefit title
  ///
  /// In en, this message translates to:
  /// **'Crisis Detection'**
  String get subscriptionBenefitCrisisDetection;

  /// Benefit description
  ///
  /// In en, this message translates to:
  /// **'Built-in safeguards and referrals'**
  String get subscriptionBenefitCrisisDetectionDesc;

  /// Benefit title
  ///
  /// In en, this message translates to:
  /// **'Full Bible Access'**
  String get subscriptionBenefitFullBibleAccess;

  /// Benefit description
  ///
  /// In en, this message translates to:
  /// **'All free features remain available'**
  String get subscriptionBenefitFullBibleAccessDesc;

  /// Subscribe now button text
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now - ~\$35.99/year*'**
  String get subscriptionSubscribeNowButton;

  /// Start free trial button text
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get subscriptionStartFreeTrialButton;

  /// Manage subscription button text
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get subscriptionManageButton;

  /// Premium subscription renewal info
  ///
  /// In en, this message translates to:
  /// **'Your subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage your subscription in App Store account settings.'**
  String get subscriptionRenewalInfoPremium;

  /// Trial subscription info
  ///
  /// In en, this message translates to:
  /// **'Start your 3-day free trial with 15 AI messages total (use anytime). After trial: ~\$35.99/year (pricing may vary by region and currency) for 150 messages per month. Cancel anytime in App Store settings.'**
  String get subscriptionRenewalInfoTrial;

  /// Error message when unable to open subscription settings
  ///
  /// In en, this message translates to:
  /// **'Unable to open subscription settings'**
  String get subscriptionUnableToOpenSettings;

  /// Legal agreements screen title
  ///
  /// In en, this message translates to:
  /// **'Legal Agreements'**
  String get legalAgreements;

  /// Legal agreements screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Please review and accept to continue'**
  String get pleaseReviewAndAccept;

  /// Legal agreements intro section title
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get importantInformation;

  /// Legal agreements intro section text
  ///
  /// In en, this message translates to:
  /// **'Before using Everyday Christian, please understand the following disclaimers and accept our terms of service.'**
  String get legalIntroText;

  /// Disclaimer section title
  ///
  /// In en, this message translates to:
  /// **'Not Professional Counseling'**
  String get notProfessionalCounseling;

  /// Disclaimer section description
  ///
  /// In en, this message translates to:
  /// **'This app provides biblical guidance and spiritual support. It is NOT a substitute for professional mental health services, medical advice, or crisis intervention.'**
  String get notProfessionalCounselingDesc;

  /// Disclaimer section title
  ///
  /// In en, this message translates to:
  /// **'No Medical or Legal Advice'**
  String get noMedicalLegalAdvice;

  /// Disclaimer section description
  ///
  /// In en, this message translates to:
  /// **'Information provided is for spiritual guidance only. Always consult qualified professionals for medical, legal, or financial matters.'**
  String get noMedicalLegalAdviceDesc;

  /// Disclaimer section title
  ///
  /// In en, this message translates to:
  /// **'AI Limitations'**
  String get aiLimitations;

  /// Disclaimer section description
  ///
  /// In en, this message translates to:
  /// **'Responses are generated by AI and may occasionally be inaccurate or incomplete. Use discernment and verify important information with trusted sources.'**
  String get aiLimitationsDesc;

  /// Disclaimer section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Use'**
  String get recommendedUse;

  /// Disclaimer section description
  ///
  /// In en, this message translates to:
  /// **'Best used as a companion to regular prayer, Bible study, and fellowship with a local church community. Not a replacement for spiritual community.'**
  String get recommendedUseDesc;

  /// Crisis resource title
  ///
  /// In en, this message translates to:
  /// **'988 Suicide & Crisis Lifeline'**
  String get crisis988Title;

  /// Crisis resource description
  ///
  /// In en, this message translates to:
  /// **'Tap to call or text 988'**
  String get crisis988Desc;

  /// Crisis resource title
  ///
  /// In en, this message translates to:
  /// **'Crisis Text Line'**
  String get crisisTextLine;

  /// Crisis resource description
  ///
  /// In en, this message translates to:
  /// **'Tap to text HOME to 741741'**
  String get crisisTextLineDesc;

  /// Warning about immediate danger
  ///
  /// In en, this message translates to:
  /// **'If you are in immediate danger, call 911 or go to your nearest emergency room.'**
  String get crisisImmediateDanger;

  /// Button text to acknowledge crisis resources
  ///
  /// In en, this message translates to:
  /// **'I understand and have noted these resources'**
  String get crisisAcknowledge;

  /// Section header for additional crisis resources
  ///
  /// In en, this message translates to:
  /// **'Additional Resources:'**
  String get additionalResources;

  /// 988 Lifeline website resource title
  ///
  /// In en, this message translates to:
  /// **'988 Lifeline Website'**
  String get lifeline988Website;

  /// 988 Lifeline chat website URL
  ///
  /// In en, this message translates to:
  /// **'Chat online at 988lifeline.org'**
  String get lifeline988Chat;

  /// RAINN online chat resource title
  ///
  /// In en, this message translates to:
  /// **'RAINN Online Chat'**
  String get rainnOnlineChat;

  /// RAINN website URL
  ///
  /// In en, this message translates to:
  /// **'rainn.org/get-help'**
  String get rainnWebsite;

  /// Crisis resource title
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// Crisis resource description
  ///
  /// In en, this message translates to:
  /// **'Tap to call 911'**
  String get emergencyServicesDesc;

  /// Consent section title
  ///
  /// In en, this message translates to:
  /// **'Acceptance Required'**
  String get acceptanceRequired;

  /// Checkbox label prefix for terms/privacy
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get haveReadAndAgree;

  /// Age confirmation checkbox label
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am 18 years of age or older'**
  String get confirmAge18Plus;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Please accept all required items to continue'**
  String get pleaseAcceptAllRequired;

  /// Error message for acceptance save failure
  ///
  /// In en, this message translates to:
  /// **'Failed to save acceptance. Please try again.'**
  String get failedToSaveAcceptance;

  /// Error message for 988 call failure
  ///
  /// In en, this message translates to:
  /// **'Unable to make call. Please dial 988 manually.'**
  String get unableToCall988;

  /// Error message for crisis text line failure
  ///
  /// In en, this message translates to:
  /// **'Unable to open messaging. Please text HOME to 741741 manually.'**
  String get unableToTextCrisisLine;

  /// Error message for 911 call failure
  ///
  /// In en, this message translates to:
  /// **'Unable to make call. Please dial 911 manually.'**
  String get unableToCall911;

  /// Error message when chat message fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get chatFailedToSend;

  /// Trial feature: message limit description
  ///
  /// In en, this message translates to:
  /// **'15 AI messages over 3 days'**
  String get trialFeatureMessages;

  /// Trial feature: scripture interpretation
  ///
  /// In en, this message translates to:
  /// **'Scripture interpretation & guidance'**
  String get trialFeatureScripture;

  /// Trial feature: prayer support
  ///
  /// In en, this message translates to:
  /// **'Prayer support & encouragement'**
  String get trialFeaturePrayer;

  /// Trial pricing information shown in dialog
  ///
  /// In en, this message translates to:
  /// **'After trial: ~\$35.99/year for 150 messages/month'**
  String get trialPricingAfterTrial;

  /// FAQ dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get faqSubtitle;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get faqGettingStarted;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Bible Reading'**
  String get faqBibleReading;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Prayer Journal'**
  String get faqPrayerJournal;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Devotionals & Reading Plans'**
  String get faqDevotionalsPlans;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'AI Chat & Support'**
  String get faqAIChatSupport;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get faqNotifications;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Settings & Customization'**
  String get faqSettingsCustomization;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get faqDataPrivacy;

  /// FAQ question 1
  ///
  /// In en, this message translates to:
  /// **'How do I get started?'**
  String get faqQ1;

  /// FAQ answer 1
  ///
  /// In en, this message translates to:
  /// **'Welcome! Start by exploring the Home screen where you\'ll find daily devotionals, verse of the day, and quick access to prayer and Bible reading. Navigate using the menu in the top left corner.'**
  String get faqA1;

  /// FAQ question 2
  ///
  /// In en, this message translates to:
  /// **'Is the app free to use?'**
  String get faqQ2;

  /// FAQ answer 2
  ///
  /// In en, this message translates to:
  /// **'Yes! Everyday Christian offers a free trial with daily message limits for AI chat. Upgrade to Premium for unlimited AI conversations and full access to all features.'**
  String get faqA2;

  /// FAQ question 3
  ///
  /// In en, this message translates to:
  /// **'Which Bible version is used?'**
  String get faqQ3;

  /// FAQ answer 3
  ///
  /// In en, this message translates to:
  /// **'The app uses the World English Bible (WEB), a modern public domain translation that\'s faithful to the original texts and easy to read.'**
  String get faqA3;

  /// FAQ question 4
  ///
  /// In en, this message translates to:
  /// **'Can I read the Bible offline?'**
  String get faqQ4;

  /// FAQ answer 4
  ///
  /// In en, this message translates to:
  /// **'Yes! The entire Bible is downloaded when you first install the app. You can read all 66 books, chapters, and verses without an internet connection.'**
  String get faqA4;

  /// FAQ question 5
  ///
  /// In en, this message translates to:
  /// **'How do I search for verses?'**
  String get faqQ5;

  /// FAQ answer 5
  ///
  /// In en, this message translates to:
  /// **'Navigate to the Bible section from the home menu. Use the search bar to find verses by keywords, or browse by book, chapter, and verse.'**
  String get faqA5;

  /// FAQ question 6
  ///
  /// In en, this message translates to:
  /// **'Can I change the Bible version?'**
  String get faqQ6;

  /// FAQ answer 6
  ///
  /// In en, this message translates to:
  /// **'The World English Bible (WEB) is currently the only version available. This ensures consistent offline access and optimal performance.'**
  String get faqA6;

  /// FAQ question 7
  ///
  /// In en, this message translates to:
  /// **'How do I add a prayer?'**
  String get faqQ7;

  /// FAQ answer 7
  ///
  /// In en, this message translates to:
  /// **'Open the Prayer Journal from the home menu and tap the floating + button. Enter your prayer title, description, and choose a category (Personal, Family, Health, etc.), then save.'**
  String get faqA7;

  /// FAQ question 8
  ///
  /// In en, this message translates to:
  /// **'Can I mark prayers as answered?'**
  String get faqQ8;

  /// FAQ answer 8
  ///
  /// In en, this message translates to:
  /// **'Yes! Open any prayer and tap \"Mark as Answered\". You can add a description of how God answered your prayer. View all answered prayers in the \"Answered\" tab.'**
  String get faqA8;

  /// FAQ question 9
  ///
  /// In en, this message translates to:
  /// **'How do I export my prayer journal?'**
  String get faqQ9;

  /// FAQ answer 9
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data & Privacy > Export Data. This creates a formatted text file containing all your prayers (both active and answered) that you can save or share.'**
  String get faqA9;

  /// FAQ question 10
  ///
  /// In en, this message translates to:
  /// **'Can I organize prayers by category?'**
  String get faqQ10;

  /// FAQ answer 10
  ///
  /// In en, this message translates to:
  /// **'Yes! Each prayer can be assigned to a category. Use the category filter at the top of the Prayer Journal to view prayers by specific categories.'**
  String get faqA10;

  /// FAQ question 11
  ///
  /// In en, this message translates to:
  /// **'Where can I find daily devotionals?'**
  String get faqQ11;

  /// FAQ answer 11
  ///
  /// In en, this message translates to:
  /// **'Daily devotionals appear on your Home screen. You can mark devotionals as completed to track your progress and build your devotional streak.'**
  String get faqA11;

  /// FAQ question 12
  ///
  /// In en, this message translates to:
  /// **'How do reading plans work?'**
  String get faqQ12;

  /// FAQ answer 12
  ///
  /// In en, this message translates to:
  /// **'Choose a reading plan from the Reading Plans section. Tap \"Start Plan\" to begin. The app tracks your progress as you complete daily readings. Only one plan can be active at a time.'**
  String get faqA12;

  /// FAQ question 13
  ///
  /// In en, this message translates to:
  /// **'Can I track my devotional streak?'**
  String get faqQ13;

  /// FAQ answer 13
  ///
  /// In en, this message translates to:
  /// **'Yes! The app automatically tracks how many consecutive days you\'ve completed devotionals. View your current streak on your Profile screen.'**
  String get faqA13;

  /// FAQ question 14
  ///
  /// In en, this message translates to:
  /// **'What can I ask the AI?'**
  String get faqQ14;

  /// FAQ answer 14
  ///
  /// In en, this message translates to:
  /// **'You can ask about Scripture interpretation, prayer requests, life challenges, faith questions, and daily encouragement. The AI provides biblically-grounded guidance and support.'**
  String get faqA14;

  /// FAQ question 15
  ///
  /// In en, this message translates to:
  /// **'How many messages can I send?'**
  String get faqQ15;

  /// FAQ answer 15
  ///
  /// In en, this message translates to:
  /// **'Free users have a daily message limit. Premium subscribers get unlimited messages. Check Settings > Subscription to see your current plan and remaining messages.'**
  String get faqA15;

  /// FAQ question 16
  ///
  /// In en, this message translates to:
  /// **'Are my conversations saved?'**
  String get faqQ16;

  /// FAQ answer 16
  ///
  /// In en, this message translates to:
  /// **'Yes! All your AI conversations are saved to your device. Each chat creates a new session that you can access from the conversation history.'**
  String get faqA16;

  /// FAQ question 17
  ///
  /// In en, this message translates to:
  /// **'How do I change notification times?'**
  String get faqQ17;

  /// FAQ answer 17
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Notifications > Notification Time. Select your preferred time for daily reminders.'**
  String get faqA17;

  /// FAQ question 18
  ///
  /// In en, this message translates to:
  /// **'Can I turn off specific notifications?'**
  String get faqQ18;

  /// FAQ answer 18
  ///
  /// In en, this message translates to:
  /// **'Yes! In Settings > Notifications, you can toggle each notification type (Daily Devotional, Prayer Reminders, Verse of the Day) independently.'**
  String get faqA18;

  /// FAQ question 19
  ///
  /// In en, this message translates to:
  /// **'Why aren\'t I receiving notifications?'**
  String get faqQ19;

  /// FAQ answer 19
  ///
  /// In en, this message translates to:
  /// **'Check your device settings to ensure notifications are enabled for Everyday Christian. Also verify that each notification type is enabled in Settings > Notifications.'**
  String get faqA19;

  /// FAQ question 20
  ///
  /// In en, this message translates to:
  /// **'How do I adjust text size?'**
  String get faqQ20;

  /// FAQ answer 20
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Appearance > Text Size. Use the slider to adjust text size throughout the app from 80% to 150% of normal size.'**
  String get faqA20;

  /// FAQ question 21
  ///
  /// In en, this message translates to:
  /// **'Can I add a profile picture?'**
  String get faqQ21;

  /// FAQ answer 21
  ///
  /// In en, this message translates to:
  /// **'Yes! Tap your profile avatar in Settings or on your Profile screen. Choose to take a photo or select one from your gallery.'**
  String get faqA21;

  /// FAQ question 22
  ///
  /// In en, this message translates to:
  /// **'What does offline mode do?'**
  String get faqQ22;

  /// FAQ answer 22
  ///
  /// In en, this message translates to:
  /// **'Offline mode allows you to use core features (Bible reading, viewing saved prayers and devotionals) without an internet connection. AI chat requires internet.'**
  String get faqA22;

  /// FAQ question 23
  ///
  /// In en, this message translates to:
  /// **'Is my data private and secure?'**
  String get faqQ23;

  /// FAQ answer 23
  ///
  /// In en, this message translates to:
  /// **'Yes! Your prayers, notes, and personal data are stored securely on your device. We never sell your information to third parties.'**
  String get faqA23;

  /// FAQ question 24
  ///
  /// In en, this message translates to:
  /// **'What data is stored on my device?'**
  String get faqQ24;

  /// FAQ answer 24
  ///
  /// In en, this message translates to:
  /// **'The Bible content, your prayers, conversation history, reading plan progress, devotional completion records, and app preferences are all stored locally.'**
  String get faqA24;

  /// FAQ question 25
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between Clear Cache and Delete All Data?'**
  String get faqQ25;

  /// FAQ answer 25
  ///
  /// In en, this message translates to:
  /// **'Clear Cache removes temporary files (image cache, temp directories) to free up storage space. Your prayers, settings, and all personal data remain safe. Delete All Data permanently erases everything including prayers, conversations, settings, and resets the app to factory defaults.'**
  String get faqA25;

  /// FAQ question 26
  ///
  /// In en, this message translates to:
  /// **'How do I clear cached data?'**
  String get faqQ26;

  /// FAQ answer 26
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data & Privacy > Clear Cache. This removes temporary files and image cache to free up storage space. Your prayers, conversations, and personal data are NOT deleted - only temporary cache files are removed.'**
  String get faqA26;

  /// FAQ question 27
  ///
  /// In en, this message translates to:
  /// **'How do I delete all my data?'**
  String get faqQ27;

  /// FAQ answer 27
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Data & Privacy > Delete All Data. You\'ll be asked to type \"DELETE\" to confirm. This permanently erases all prayers, conversations, reading plans, favorites, settings, and profile picture. Export your prayer journal first if you want to keep a backup. This action cannot be undone.'**
  String get faqA27;

  /// Label for answered prayer status in share images
  ///
  /// In en, this message translates to:
  /// **'Answered Prayer'**
  String get answeredPrayer;

  /// Label for prayer request status in share images
  ///
  /// In en, this message translates to:
  /// **'Prayer Request'**
  String get prayerRequest;

  /// Call to action in prayer share images
  ///
  /// In en, this message translates to:
  /// **'Join Me in Prayer'**
  String get joinMeInPrayer;

  /// Call to action to download app in share images
  ///
  /// In en, this message translates to:
  /// **'Download Everyday Christian'**
  String get downloadApp;

  /// Call to action in share images
  ///
  /// In en, this message translates to:
  /// **'Get Everyday Christian'**
  String get getApp;

  /// QR code instruction in share images
  ///
  /// In en, this message translates to:
  /// **'Scan to download'**
  String get scanToDownload;

  /// Subtitle for verse share images
  ///
  /// In en, this message translates to:
  /// **'Daily Scripture & Guidance'**
  String get dailyScriptureAndGuidance;

  /// Subtitle for chat share images
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Biblical Guidance'**
  String get aiPoweredBiblicalGuidance;
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

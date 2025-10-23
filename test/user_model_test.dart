import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/features/auth/models/user_model.dart';

void main() {
  group('User Model', () {
    group('User Creation', () {
      test('should create User with required fields', () {
        const user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
        );

        expect(user.id, equals('123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.spiritualInterests, isEmpty);
        expect(user.preferredVerseThemes, isEmpty);
        expect(user.preferredTranslation, equals('ESV'));
        expect(user.isAnonymous, isFalse);
      });

      test('should create User with all fields', () {
        final now = DateTime.now();
        const profile = UserProfile(
          bio: 'Test bio',
          favoriteVerse: 'John 3:16',
          prayerStreak: 5,
        );

        final user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          denomination: 'Baptist',
          spiritualInterests: ['Prayer', 'Bible Study'],
          preferredVerseThemes: ['hope', 'faith'],
          preferredTranslation: 'KJV',
          dateJoined: now,
          isAnonymous: false,
          profile: profile,
        );

        expect(user.id, equals('123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.denomination, equals('Baptist'));
        expect(user.spiritualInterests, equals(['Prayer', 'Bible Study']));
        expect(user.preferredVerseThemes, equals(['hope', 'faith']));
        expect(user.preferredTranslation, equals('KJV'));
        expect(user.dateJoined, equals(now));
        expect(user.isAnonymous, isFalse);
        expect(user.profile, equals(profile));
      });

      test('should create anonymous user', () {
        final user = User.anonymous();

        expect(user.id, startsWith('anonymous_'));
        expect(user.isAnonymous, isTrue);
        expect(user.dateJoined, isNotNull);
        expect(user.preferredVerseThemes, equals(['hope', 'strength', 'comfort']));
      });
    });

    group('User Display Properties', () {
      test('should get display name from name', () {
        const user = User(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
        );

        expect(user.displayName, equals('John Doe'));
      });

      test('should get display name from email when no name', () {
        const user = User(
          id: '123',
          email: 'john@example.com',
        );

        expect(user.displayName, equals('john'));
      });

      test('should get display name as Guest User for anonymous', () {
        const user = User(
          id: '123',
          isAnonymous: true,
        );

        expect(user.displayName, equals('Guest User'));
      });

      test('should default to User when no name or email', () {
        const user = User(id: '123');

        expect(user.displayName, equals('User'));
      });

      test('should get initials from full name', () {
        const user = User(
          id: '123',
          name: 'John Doe',
        );

        expect(user.initials, equals('JD'));
      });

      test('should get initials from single name', () {
        const user = User(
          id: '123',
          name: 'John',
        );

        expect(user.initials, equals('J'));
      });

      test('should get initials from email when no name', () {
        const user = User(
          id: '123',
          email: 'john@example.com',
        );

        expect(user.initials, equals('J'));
      });

      test('should default to G for guest users', () {
        const user = User(
          id: '123',
          isAnonymous: true,
        );

        expect(user.initials, equals('G'));
      });
    });

    group('User Profile Status', () {
      test('should return true when profile is complete', () {
        const user = User(
          id: '123',
          name: 'John Doe',
          preferredVerseThemes: ['hope', 'faith'],
        );

        expect(user.hasCompletedProfile, isTrue);
      });

      test('should return false when name is missing', () {
        const user = User(
          id: '123',
          preferredVerseThemes: ['hope'],
        );

        expect(user.hasCompletedProfile, isFalse);
      });

      test('should return false when preferred themes are empty', () {
        const user = User(
          id: '123',
          name: 'John Doe',
          preferredVerseThemes: [],
        );

        expect(user.hasCompletedProfile, isFalse);
      });
    });

    group('Membership Duration', () {
      test('should calculate membership duration', () {
        final dateJoined = DateTime.now().subtract(const Duration(days: 30));
        final user = User(
          id: '123',
          dateJoined: dateJoined,
        );

        expect(user.membershipDuration, isNotNull);
        expect(user.membershipDuration!.inDays, greaterThanOrEqualTo(29));
        expect(user.membershipDuration!.inDays, lessThanOrEqualTo(31));
      });

      test('should return null when no date joined', () {
        const user = User(id: '123');

        expect(user.membershipDuration, isNull);
      });
    });

    group('User Serialization', () {
      test('should serialize to JSON', () {
        final now = DateTime.now();
        final user = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          denomination: 'Baptist',
          spiritualInterests: ['Prayer'],
          preferredVerseThemes: ['hope'],
          preferredTranslation: 'KJV',
          dateJoined: now,
          isAnonymous: false,
        );

        final json = user.toJson();

        expect(json['id'], equals('123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['name'], equals('Test User'));
        expect(json['denomination'], equals('Baptist'));
        expect(json['spiritual_interests'], equals(['Prayer']));
        expect(json['preferred_verse_themes'], equals(['hope']));
        expect(json['preferred_translation'], equals('KJV'));
        expect(json['date_joined'], equals(now.millisecondsSinceEpoch));
        expect(json['is_anonymous'], isFalse);
      });

      test('should deserialize from JSON', () {
        final now = DateTime.now();
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'denomination': 'Baptist',
          'spiritual_interests': ['Prayer', 'Study'],
          'preferred_verse_themes': ['hope', 'faith'],
          'preferred_translation': 'NIV',
          'date_joined': now.millisecondsSinceEpoch,
          'is_anonymous': false,
        };

        final user = User.fromJson(json);

        expect(user.id, equals('123'));
        expect(user.email, equals('test@example.com'));
        expect(user.name, equals('Test User'));
        expect(user.denomination, equals('Baptist'));
        expect(user.spiritualInterests, equals(['Prayer', 'Study']));
        expect(user.preferredVerseThemes, equals(['hope', 'faith']));
        expect(user.preferredTranslation, equals('NIV'));
        expect(user.dateJoined!.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
        expect(user.isAnonymous, isFalse);
      });

      test('should parse spiritual interests from JSON string', () {
        final json = {
          'id': '123',
          'spiritual_interests': '["Prayer", "Study"]',
        };

        final user = User.fromJson(json);

        expect(user.spiritualInterests, equals(['Prayer', 'Study']));
      });

      test('should handle null spiritual interests', () {
        final json = {
          'id': '123',
          'spiritual_interests': null,
        };

        final user = User.fromJson(json);

        expect(user.spiritualInterests, isEmpty);
      });

      test('should default translation to ESV when null', () {
        final json = {
          'id': '123',
          'preferred_translation': null,
        };

        final user = User.fromJson(json);

        expect(user.preferredTranslation, equals('ESV'));
      });
    });

    group('User CopyWith', () {
      test('should copy with updated fields', () {
        const original = User(
          id: '123',
          email: 'test@example.com',
          name: 'Original Name',
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          preferredTranslation: 'KJV',
        );

        expect(updated.id, equals('123'));
        expect(updated.email, equals('test@example.com'));
        expect(updated.name, equals('Updated Name'));
        expect(updated.preferredTranslation, equals('KJV'));
      });

      test('should preserve original fields when not updated', () {
        const original = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          preferredTranslation: 'ESV',
        );

        final updated = original.copyWith(name: 'New Name');

        expect(updated.preferredTranslation, equals('ESV'));
        expect(updated.email, equals('test@example.com'));
      });
    });

    group('User Equality', () {
      test('should be equal when IDs match', () {
        const user1 = User(id: '123', name: 'User 1');
        const user2 = User(id: '123', name: 'User 2');

        expect(user1, equals(user2));
      });

      test('should not be equal when IDs differ', () {
        const user1 = User(id: '123');
        const user2 = User(id: '456');

        expect(user1, isNot(equals(user2)));
      });

      test('should have same hash code when IDs match', () {
        const user1 = User(id: '123');
        const user2 = User(id: '123');

        expect(user1.hashCode, equals(user2.hashCode));
      });
    });

    group('User toString', () {
      test('should return readable string representation', () {
        const user = User(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          isAnonymous: false,
        );

        final str = user.toString();

        expect(str, contains('123'));
        expect(str, contains('John Doe'));
        expect(str, contains('john@example.com'));
        expect(str, contains('anonymous: false'));
      });
    });
  });

  group('UserProfile Model', () {
    group('UserProfile Creation', () {
      test('should create UserProfile with default values', () {
        const profile = UserProfile();

        expect(profile.bio, isNull);
        expect(profile.favoriteVerse, isNull);
        expect(profile.churchName, isNull);
        expect(profile.spiritualGoals, isEmpty);
        expect(profile.prayerStreak, equals(0));
        expect(profile.verseStreak, equals(0));
        expect(profile.totalPrayers, equals(0));
        expect(profile.answeredPrayers, equals(0));
        expect(profile.lastActiveDate, isNull);
      });

      test('should create UserProfile with all fields', () {
        final now = DateTime.now();
        final profile = UserProfile(
          bio: 'Test bio',
          favoriteVerse: 'John 3:16',
          churchName: 'First Baptist',
          spiritualGoals: ['Daily prayer', 'Bible study'],
          prayerStreak: 10,
          verseStreak: 5,
          totalPrayers: 100,
          answeredPrayers: 25,
          lastActiveDate: now,
        );

        expect(profile.bio, equals('Test bio'));
        expect(profile.favoriteVerse, equals('John 3:16'));
        expect(profile.churchName, equals('First Baptist'));
        expect(profile.spiritualGoals, equals(['Daily prayer', 'Bible study']));
        expect(profile.prayerStreak, equals(10));
        expect(profile.verseStreak, equals(5));
        expect(profile.totalPrayers, equals(100));
        expect(profile.answeredPrayers, equals(25));
        expect(profile.lastActiveDate, equals(now));
      });
    });

    group('Answered Prayer Percentage', () {
      test('should calculate answered prayer percentage', () {
        const profile = UserProfile(
          totalPrayers: 100,
          answeredPrayers: 25,
        );

        expect(profile.answeredPrayerPercentage, equals(25.0));
      });

      test('should return 0 when no prayers', () {
        const profile = UserProfile(
          totalPrayers: 0,
          answeredPrayers: 0,
        );

        expect(profile.answeredPrayerPercentage, equals(0.0));
      });

      test('should handle 100% answered', () {
        const profile = UserProfile(
          totalPrayers: 10,
          answeredPrayers: 10,
        );

        expect(profile.answeredPrayerPercentage, equals(100.0));
      });
    });

    group('UserProfile Serialization', () {
      test('should serialize to JSON', () {
        final now = DateTime.now();
        final profile = UserProfile(
          bio: 'Test bio',
          favoriteVerse: 'John 3:16',
          churchName: 'First Baptist',
          spiritualGoals: ['Prayer'],
          prayerStreak: 5,
          verseStreak: 3,
          totalPrayers: 50,
          answeredPrayers: 10,
          lastActiveDate: now,
        );

        final json = profile.toJson();

        expect(json['bio'], equals('Test bio'));
        expect(json['favorite_verse'], equals('John 3:16'));
        expect(json['church_name'], equals('First Baptist'));
        expect(json['spiritual_goals'], equals(['Prayer']));
        expect(json['prayer_streak'], equals(5));
        expect(json['verse_streak'], equals(3));
        expect(json['total_prayers'], equals(50));
        expect(json['answered_prayers'], equals(10));
        expect(json['last_active_date'], equals(now.millisecondsSinceEpoch));
      });

      test('should deserialize from JSON', () {
        final now = DateTime.now();
        final json = {
          'bio': 'Test bio',
          'favorite_verse': 'Psalms 23:1',
          'church_name': 'Grace Church',
          'spiritual_goals': ['Study', 'Pray'],
          'prayer_streak': 7,
          'verse_streak': 4,
          'total_prayers': 75,
          'answered_prayers': 20,
          'last_active_date': now.millisecondsSinceEpoch,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.bio, equals('Test bio'));
        expect(profile.favoriteVerse, equals('Psalms 23:1'));
        expect(profile.churchName, equals('Grace Church'));
        expect(profile.spiritualGoals, equals(['Study', 'Pray']));
        expect(profile.prayerStreak, equals(7));
        expect(profile.verseStreak, equals(4));
        expect(profile.totalPrayers, equals(75));
        expect(profile.answeredPrayers, equals(20));
        expect(profile.lastActiveDate!.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
      });

      test('should handle null values in JSON', () {
        final json = {
          'bio': null,
          'prayer_streak': null,
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.bio, isNull);
        expect(profile.prayerStreak, equals(0));
      });
    });

    group('UserProfile CopyWith', () {
      test('should copy with updated fields', () {
        const original = UserProfile(
          bio: 'Original bio',
          prayerStreak: 5,
        );

        final updated = original.copyWith(
          bio: 'Updated bio',
          prayerStreak: 10,
        );

        expect(updated.bio, equals('Updated bio'));
        expect(updated.prayerStreak, equals(10));
      });

      test('should preserve original fields when not updated', () {
        const original = UserProfile(
          bio: 'Test bio',
          verseStreak: 3,
          totalPrayers: 50,
        );

        final updated = original.copyWith(prayerStreak: 10);

        expect(updated.bio, equals('Test bio'));
        expect(updated.verseStreak, equals(3));
        expect(updated.totalPrayers, equals(50));
      });
    });

    group('UserProfile toString', () {
      test('should return readable string representation', () {
        const profile = UserProfile(
          prayerStreak: 10,
          verseStreak: 5,
          totalPrayers: 100,
        );

        final str = profile.toString();

        expect(str, contains('prayerStreak: 10'));
        expect(str, contains('verseStreak: 5'));
        expect(str, contains('totalPrayers: 100'));
      });
    });
  });

  group('SpiritualData Helper', () {
    test('should have denominations list', () {
      expect(SpiritualData.denominations, isNotEmpty);
      expect(SpiritualData.denominations, contains('Baptist'));
      expect(SpiritualData.denominations, contains('Catholic'));
      expect(SpiritualData.denominations, contains('Non-denominational'));
    });

    test('should have spiritual interests list', () {
      expect(SpiritualData.spiritualInterests, isNotEmpty);
      expect(SpiritualData.spiritualInterests, contains('Bible Study'));
      expect(SpiritualData.spiritualInterests, contains('Prayer & Meditation'));
    });

    test('should have spiritual goals list', () {
      expect(SpiritualData.spiritualGoals, isNotEmpty);
      expect(SpiritualData.spiritualGoals, contains('Read the Bible daily'));
      expect(SpiritualData.spiritualGoals, contains('Develop a consistent prayer life'));
    });
  });
}

/// Content Filter Integration Tests
/// Validates that content filtering works correctly in chat flow

import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/content_filter_service.dart';

void main() {
  group('Content Filter Service', () {
    late ContentFilterService service;

    setUp(() {
      service = ContentFilterService();
    });

    group('Prosperity Gospel Detection', () {
      test('blocks name it and claim it', () {
        final result = service.filterResponse(
          'If you just name it and claim it, God will give you wealth!',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Prosperity gospel'));
        expect(result.matchedPhrases, contains('name it and claim it'));
      });

      test('blocks seed faith language', () {
        final result = service.filterResponse(
          'Sow a seed of faith and reap financial blessings!',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Prosperity gospel'));
      });

      test('blocks weak faith accusations', () {
        final result = service.filterResponse(
          'Your faith is weak, that\'s why you\'re not healed.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Prosperity gospel'));
      });
    });

    group('Spiritual Bypassing Detection', () {
      test('blocks "just pray harder"', () {
        final result = service.filterResponse(
          'If you\'re struggling, just pray harder and have more faith.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Spiritual bypassing'));
      });

      test('blocks "everything happens for a reason"', () {
        final result = service.filterResponse(
          'Don\'t worry, everything happens for a reason. It\'s all part of God\'s plan.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Spiritual bypassing'));
      });

      test('blocks punishment theology', () {
        final result = service.filterResponse(
          'This is God punishing you for your sin.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Spiritual bypassing'));
      });
    });

    group('Toxic Positivity Detection', () {
      test('blocks "don\'t be sad"', () {
        final result = service.filterResponse(
          'Don\'t be sad! Just think positive and count your blessings.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Toxic positivity'));
      });

      test('blocks "it could be worse"', () {
        final result = service.filterResponse(
          'It could be worse. Other people have it worse than you.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Toxic positivity'));
      });

      test('blocks "depression is a sin"', () {
        final result = service.filterResponse(
          'Depression is a sin. God doesn\'t want you sad.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Toxic positivity'));
      });
    });

    group('Legalism Detection', () {
      test('blocks works-based salvation', () {
        final result = service.filterResponse(
          'You have to earn God\'s love through good works.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Legalistic'));
      });

      test('blocks conditional love statements', () {
        final result = service.filterResponse(
          'God only loves you if you follow all the rules.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Legalistic'));
      });

      test('blocks hell threats', () {
        final result = service.filterResponse(
          'You\'re going to hell for doing that!',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Legalistic'));
      });
    });

    group('Hate Speech Detection', () {
      test('blocks "god hates" statements', () {
        final result = service.filterResponse(
          'God hates certain people.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Hate speech'));
      });

      test('blocks abomination language', () {
        final result = service.filterResponse(
          'You\'re an abomination!',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Hate speech'));
      });
    });

    group('Medical Overreach Detection', () {
      test('blocks anti-medication advice', () {
        final result = service.filterResponse(
          'Don\'t take medication. Just pray instead.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Medical overreach'));
      });

      test('blocks therapy dismissal', () {
        final result = service.filterResponse(
          'You don\'t need therapy. God is all you need.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Medical overreach'));
      });

      test('blocks mental illness denial', () {
        final result = service.filterResponse(
          'Mental illness isn\'t real. Depression is a choice.',
        );

        expect(result.isRejected, isTrue);
        expect(result.rejectionReason, contains('Medical overreach'));
      });
    });

    group('Approved Content', () {
      test('approves balanced, compassionate response', () {
        final result = service.filterResponse(
          'I hear you\'re struggling. Remember that God is with you in this pain. '
          '"The Lord is near to the brokenhearted" (Psalm 34:18). '
          'Consider reaching out to a counselor who can provide support.',
        );

        expect(result.approved, isTrue);
        expect(result.rejectionReason, isNull);
      });

      test('approves scripture with grace', () {
        final result = service.filterResponse(
          'God\'s grace is sufficient for you. "My grace is sufficient for you, '
          'for my power is made perfect in weakness" (2 Corinthians 12:9).',
        );

        expect(result.approved, isTrue);
      });

      test('approves lament acknowledgment', () {
        final result = service.filterResponse(
          'It\'s okay to feel sad. The Psalms are full of lament. '
          'Bring your honest emotions to God - He can handle them.',
        );

        expect(result.approved, isTrue);
      });

      test('approves encouragement for professional help', () {
        final result = service.filterResponse(
          'Prayer is important, and so is seeking professional help. '
          'God often works through counselors and doctors to bring healing.',
        );

        expect(result.approved, isTrue);
      });
    });

    group('Fallback Responses', () {
      test('provides anxiety fallback', () {
        final fallback = service.getFallbackResponse('anxiety');

        expect(fallback, contains('anxiety'));
        expect(fallback, contains('Philippians 4:6'));
        expect(fallback, contains('counselor'));
      });

      test('provides depression fallback', () {
        final fallback = service.getFallbackResponse('depression');

        expect(fallback, contains('Depression'));
        expect(fallback, contains('Psalm 34:18'));
        expect(fallback, contains('mental health professional'));
      });

      test('provides default fallback', () {
        final fallback = service.getFallbackResponse('unknown');

        expect(fallback, contains('support'));
        expect(fallback, contains('1 Peter 5:7'));
      });
    });

    group('Scripture Reference Detection', () {
      test('detects common scripture patterns', () {
        expect(
          service.hasScriptureReference('John 3:16 says...'),
          isTrue,
        );

        expect(
          service.hasScriptureReference('As it says in Romans 8:28...'),
          isTrue,
        );

        expect(
          service.hasScriptureReference('Psalm 23 reminds us...'),
          isTrue,
        );
      });

      test('returns false for no scripture', () {
        expect(
          service.hasScriptureReference('This is just a normal message.'),
          isFalse,
        );
      });
    });

    group('Edge Cases', () {
      test('approves empty response', () {
        final result = service.filterResponse('');
        expect(result.approved, isTrue);
      });

      test('handles case insensitivity', () {
        final result = service.filterResponse(
          'NAME IT AND CLAIM IT for wealth!',
        );
        expect(result.isRejected, isTrue);
      });

      test('handles punctuation variations', () {
        final result = service.filterResponse(
          'You should just pray harder!!! It\'s that simple.',
        );
        expect(result.isRejected, isTrue);
      });

      test('detects phrases within longer text', () {
        final result = service.filterResponse(
          'I want to encourage you. However, if you had more faith, '
          'this wouldn\'t be happening. God bless you.',
        );
        expect(result.isRejected, isTrue);
      });
    });
  });
}

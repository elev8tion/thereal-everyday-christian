import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/services/unified_verse_service.dart';

void main() {
  group('Theme-Based Verse Search Tests', () {
    late UnifiedVerseService service;

    setUp(() {
      service = UnifiedVerseService();
    });

    test('Depression theme returns verses from Psalms/NT', () async {
      final verses = await service.searchByTheme('depression', limit: 10);
      
      expect(verses.isNotEmpty, true, reason: 'Should find depression-themed verses');
      
      // Check that we get Psalms or NT books (not just Genesis/Exodus)
      final hasPsalmsOrNT = verses.any((v) => 
        v.reference.contains('Psalm') || 
        v.reference.contains('Matthew') ||
        v.reference.contains('John') ||
        v.reference.contains('Romans') ||
        v.reference.contains('Philippians')
      );
      
      expect(hasPsalmsOrNT, true, reason: 'Should include Psalms or NT verses');
      
      print('✓ Depression verses: ${verses.map((v) => v.reference).take(5).join(", ")}');
    });

    test('Hope theme returns verses from Psalms/NT', () async {
      final verses = await service.searchByTheme('hope', limit: 10);
      
      expect(verses.isNotEmpty, true, reason: 'Should find hope-themed verses');
      
      final hasPsalmsOrNT = verses.any((v) => 
        v.reference.contains('Psalm') || 
        v.reference.contains('Matthew') ||
        v.reference.contains('John') ||
        v.reference.contains('Romans')
      );
      
      expect(hasPsalmsOrNT, true, reason: 'Should include Psalms or NT verses');
      
      print('✓ Hope verses: ${verses.map((v) => v.reference).take(5).join(", ")}');
    });

    test('Anxiety theme returns verses from Psalms', () async {
      final verses = await service.searchByTheme('anxiety', limit: 10);
      
      expect(verses.isNotEmpty, true, reason: 'Should find anxiety-themed verses');
      
      final hasPsalms = verses.any((v) => v.reference.contains('Psalm'));
      
      expect(hasPsalms, true, reason: 'Should include Psalms verses');
      
      print('✓ Anxiety verses: ${verses.map((v) => v.reference).take(5).join(", ")}');
    });

    test('RANDOM() provides verse variety', () async {
      final first = await service.searchByTheme('hope', limit: 5);
      final second = await service.searchByTheme('hope', limit: 5);
      
      final firstRefs = first.map((v) => v.reference).toList();
      final secondRefs = second.map((v) => v.reference).toList();
      
      // At least one verse should be different due to RANDOM()
      expect(firstRefs.join() != secondRefs.join(), true, 
        reason: 'RANDOM() should produce different verse sets');
      
      print('✓ First:  ${firstRefs.join(", ")}');
      print('✓ Second: ${secondRefs.join(", ")}');
    });

    test('All returned verses have themes', () async {
      final verses = await service.searchByTheme('comfort', limit: 10);
      
      for (var verse in verses) {
        expect(verse.themes, isNotEmpty, 
          reason: '${verse.reference} should have themes');
      }
      
      print('✓ All ${verses.length} verses have themes');
    });
  });
}

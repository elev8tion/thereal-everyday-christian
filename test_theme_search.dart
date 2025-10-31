import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/services/unified_verse_service.dart';

void main() async {
  // Initialize FFI for desktop/CLI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  print('🧪 Testing Theme-Based Verse Search\n');
  print('=' * 70);
  
  final service = UnifiedVerseService();
  
  // Test 1: Depression theme (should find Psalms now)
  print('\n📊 TEST 1: Search for "depression" theme');
  print('-' * 70);
  final depressionVerses = await service.searchByTheme('depression', limit: 5);
  print('Found ${depressionVerses.length} verses');
  for (var verse in depressionVerses) {
    print('  ✓ ${verse.reference}: ${verse.text.substring(0, 60)}...');
    print('    Themes: ${verse.themes}');
  }
  
  // Test 2: Hope theme
  print('\n📊 TEST 2: Search for "hope" theme');
  print('-' * 70);
  final hopeVerses = await service.searchByTheme('hope', limit: 5);
  print('Found ${hopeVerses.length} verses');
  for (var verse in hopeVerses) {
    print('  ✓ ${verse.reference}: ${verse.text.substring(0, 60)}...');
    print('    Themes: ${verse.themes}');
  }
  
  // Test 3: Anxiety theme
  print('\n📊 TEST 3: Search for "anxiety" theme');
  print('-' * 70);
  final anxietyVerses = await service.searchByTheme('anxiety', limit: 5);
  print('Found ${anxietyVerses.length} verses');
  for (var verse in anxietyVerses) {
    print('  ✓ ${verse.reference}: ${verse.text.substring(0, 60)}...');
    print('    Themes: ${verse.themes}');
  }
  
  // Test 4: Verify RANDOM() works (run same query twice)
  print('\n📊 TEST 4: Verify verse variety (RANDOM())');
  print('-' * 70);
  final first = await service.searchByTheme('hope', limit: 3);
  final second = await service.searchByTheme('hope', limit: 3);
  
  final firstRefs = first.map((v) => v.reference).toList();
  final secondRefs = second.map((v) => v.reference).toList();
  
  print('First query: ${firstRefs.join(", ")}');
  print('Second query: ${secondRefs.join(", ")}');
  
  if (firstRefs.join() != secondRefs.join()) {
    print('  ✓ RANDOM() is working - different verses returned');
  } else {
    print('  ✗ WARNING: Same verses returned (RANDOM() might not be working)');
  }
  
  print('\n' + '=' * 70);
  print('✅ Tests complete!\n');
  
  exit(0);
}

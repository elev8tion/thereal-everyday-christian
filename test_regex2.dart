void main() {
  final tests = [
    'fucking',
    'fuck',
    'fuuck',
    'fck',
    'this is fucking stupid',
  ];
  
  final pattern = RegExp(r'\bf\w+ck\b', caseSensitive: false);
  
  for (final test in tests) {
    print('Input: "$test" -> Matches: ${pattern.hasMatch(test)}');
  }
  
  print('\nTrying different pattern:');
  final pattern2 = RegExp(r'\bf\w*ck\b', caseSensitive: false);
  for (final test in tests) {
    print('Input: "$test" -> Matches: ${pattern2.hasMatch(test)}');
  }
}

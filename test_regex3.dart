void main() {
  final tests = [
    'fucking',
    'fuck',
    'fuuck', 
    'this is fucking stupid',
  ];
  
  // Try matching "fuck" as a standalone word or with suffixes
  final pattern = RegExp(r'\bf\w*ck(ing|ed|er|s)?\b', caseSensitive: false);
  
  for (final test in tests) {
    print('Input: "$test" -> Matches: ${pattern.hasMatch(test)}');
  }
}

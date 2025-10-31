void main() {
  final input = 'this is fucking stupid';
  final pattern = RegExp(r'\bf\w+ck\b', caseSensitive: false);
  print('Input: $input');
  print('Pattern: ${pattern.pattern}');
  print('Matches: ${pattern.hasMatch(input)}');
  print('Match: ${pattern.firstMatch(input)?.group(0)}');
}

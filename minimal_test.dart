import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/input_security_service.dart';

void main() {
  test('Debug legitimate input', () {
    final service = InputSecurityService();
    final input = "I need prayer for my family";
    final result = service.validateInput(input);
    
    print('Input: $input');
    print('Approved: ${result.approved}');
    print('Rejected: ${result.isRejected}');
    
    if (result.isRejected) {
      print('Reason: ${result.rejectionReason}');
      print('Threat Level: ${result.threatLevel}');
      print('Patterns: ${result.detectedPatterns}');
    }
    
    expect(result.approved, true);
  });
}

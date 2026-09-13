import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/profile_validation.dart';

void main() {
  test('Phone normalization supports Arabic digits and Saudi local input', () {
    expect(normalizeProfilePhone('٠٥٥ ١٢٣ ٤٥٦٧'), '+966551234567');
    expect(normalizeProfilePhone('00966 55 123 4567'), '+966551234567');
    expect(validateProfileField('Phone number', '0551234567'), isNull);
    expect(validateProfileField('Phone number', '+966123'), isNotNull);
    expect(validateProfileField('Phone number', '+442079460000'), isNull);
  });
  test('Completion excludes demo placeholders and rejects invalid details', () {
    expect(isProfileFieldComplete('Email', 'user@example.com'), isFalse);
    expect(isProfileFieldComplete('Full name', 'Riyal User'), isFalse);
    expect(validateProfileField('Full name', 'نورة'), isNull);
    expect(validateProfileField('Full name', '1234'), isNotNull);
    expect(validateProfileField('Email', 'invalid'), isNotNull);
    expect(isProfileFieldComplete('Email', 'noura@example.com'), isTrue);
  });
}

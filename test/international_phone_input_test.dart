import 'package:flutter_test/flutter_test.dart';
import 'package:international_phone_input/src/international_phone_input.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('validates phone number input value', () async {
    final n = '0508232165';
    final g = 'gh';
    final number = await InternationalPhoneInput.internationalizeNumber(n, g);
    expect(number, '+233508232165');
  });
}

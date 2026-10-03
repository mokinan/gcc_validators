import 'package:gcc_validators/gcc_validators.dart';
import 'package:test/test.dart';

void main() {
  group('GccPhone.validateMobile', () {
    const valid = {
      '+966501234567': '+966501234567',
      '00966 50 123 4567': '+966501234567',
      '+971 55 123 4567': '+971551234567',
      '+965 9123 4567': '+96591234567',
      '+974 5512 3456': '+97455123456',
      '+973 3612 3456': '+97336123456',
      '+973 6612 3456': '+97366123456',
      '+968 9123 4567': '+96891234567',
    };
    valid.forEach((input, e164) {
      test('normalizes "$input" to $e164', () {
        expect(GccPhone.validateMobile(input).value, e164);
      });
    });

    test('accepts local Saudi format with trunk zero', () {
      expect(
        GccPhone.validateMobile('050 123 4567', country: GccCountry.saudiArabia)
            .value,
        '+966501234567',
      );
    });

    test('accepts local format without trunk zero', () {
      expect(
        GccPhone.validateMobile('9123 4567', country: GccCountry.kuwait).value,
        '+96591234567',
      );
    });

    test('accepts Arabic-Indic digits', () {
      expect(
        GccPhone.isValidMobile('٠٥٠١٢٣٤٥٦٧', country: GccCountry.saudiArabia),
        isTrue,
      );
    });

    test('requires a country for local numbers', () {
      expect(GccPhone.validateMobile('0501234567').error,
          PhoneError.missingCountryCode);
    });

    test('rejects non-GCC and mismatched dialling codes', () {
      expect(GccPhone.validateMobile('+201001234567').error,
          PhoneError.unsupportedCountry);
      expect(
        GccPhone.validateMobile('+971551234567',
                country: GccCountry.saudiArabia)
            .error,
        PhoneError.unsupportedCountry,
      );
    });

    test('rejects wrong length and landline prefixes', () {
      expect(GccPhone.validateMobile('+96650123456').error,
          PhoneError.invalidLength);
      expect(GccPhone.validateMobile('+966112345678').error,
          PhoneError.invalidPrefix);
      expect(GccPhone.validateMobile('+971531234567').error,
          PhoneError.invalidPrefix);
    });

    test('rejects empty input and letters', () {
      expect(GccPhone.validateMobile(' ').error, PhoneError.empty);
      expect(GccPhone.validateMobile('+96650ABC4567').error,
          PhoneError.invalidCharacters);
    });
  });
}

import 'package:gcc_validators/gcc_validators.dart';
import 'package:test/test.dart';

void main() {
  group('GccVat', () {
    test('accepts Saudi and UAE numbers', () {
      expect(
          GccVat.validate('300 000 000 000 003',
                  country: GccCountry.saudiArabia)
              .value,
          '300000000000003');
      expect(
          GccVat.isValid('100123456789012', country: GccCountry.uae), isTrue);
    });

    test('rejects structure violations', () {
      const sa = GccCountry.saudiArabia;
      expect(GccVat.validate('', country: sa).error, VatError.empty);
      expect(GccVat.validate('30000000000000X', country: sa).error,
          VatError.invalidCharacters);
      expect(GccVat.validate('30000000000003', country: sa).error,
          VatError.invalidLength);
      expect(GccVat.validate('200000000000003', country: sa).error,
          VatError.invalidFormat);
      expect(GccVat.validate('300000000000002', country: sa).error,
          VatError.invalidFormat);
    });

    test('reports unsupported countries', () {
      expect(
          GccVat.supportedCountries, {GccCountry.saudiArabia, GccCountry.uae});
      expect(GccVat.validate('123', country: GccCountry.oman).error,
          VatError.unsupportedCountry);
    });
  });

  group('GccValidators', () {
    test('returns null for valid input', () {
      expect(GccValidators.iban()('SA0380000000608010167519'), isNull);
      expect(GccValidators.saudiNationalId()('1012345672'), isNull);
      expect(GccValidators.emiratesId()('784199012345676'), isNull);
      expect(GccValidators.mobile()('+966501234567'), isNull);
      expect(GccValidators.vat(country: GccCountry.uae)('100123456789012'),
          isNull);
    });

    test('returns the message for invalid input', () {
      expect(GccValidators.iban(message: 'bad')('SA00'), 'bad');
    });

    test('uses per-error messages when given', () {
      final validator = GccValidators.iban(
        messages: (error) => switch (error) {
          IbanError.invalidChecksum => 'checksum',
          _ => 'other',
        },
      );
      expect(validator('SA0480000000608010167519'), 'checksum');
      expect(validator('DE89370400440532013000'), 'other');
    });

    test('handles empty values according to required', () {
      expect(GccValidators.mobile(message: 'needed')(null), 'needed');
      expect(GccValidators.mobile(required: false)(''), isNull);
    });
  });

  group('normalizeDigits', () {
    test('converts both Arabic digit sets', () {
      expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(normalizeDigits('abc 12'), 'abc 12');
    });
  });

  group('GccCountry', () {
    test('looks up by ISO code', () {
      expect(GccCountry.fromIsoCode('sa'), GccCountry.saudiArabia);
      expect(GccCountry.fromIsoCode('EG'), isNull);
    });
  });

  group('ValidationResult', () {
    test('has value equality and a readable toString', () {
      const a = ValidationResult<VatError>.valid('1');
      const b = ValidationResult<VatError>.valid('1');
      const c = ValidationResult<VatError>.invalid(VatError.empty);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), 'ValidationResult.valid(1)');
      expect(c.toString(), 'ValidationResult.invalid(VatError.empty)');
    });
  });
}

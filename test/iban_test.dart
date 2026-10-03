import 'package:gcc_validators/gcc_validators.dart';
import 'package:test/test.dart';

void main() {
  // Examples published in the SWIFT IBAN registry.
  const registryExamples = {
    GccCountry.saudiArabia: 'SA0380000000608010167519',
    GccCountry.uae: 'AE070331234567890123456',
    GccCountry.kuwait: 'KW81CBKU0000000000001234560101',
    GccCountry.qatar: 'QA58DOHB00001234567890ABCDEFG',
    GccCountry.bahrain: 'BH67BMAG00001299123456',
    GccCountry.oman: 'OM810180000001299123456',
  };

  group('Iban.validate', () {
    for (final MapEntry(key: country, value: iban)
        in registryExamples.entries) {
      test('accepts registry example for ${country.name}', () {
        expect(Iban.validate(iban), ValidationResult<IbanError>.valid(iban));
        expect(Iban.countryOf(iban), country);
      });
    }

    test('normalizes spaces, dashes and lower case', () {
      expect(
        Iban.validate('sa03 8000-0000 6080 1016 7519').value,
        'SA0380000000608010167519',
      );
    });

    test('normalizes Arabic-Indic digits', () {
      expect(Iban.isValid('SA٠٣٨٠٠٠٠٠٠٠٦٠٨٠١٠١٦٧٥١٩'), isTrue);
    });

    test('rejects empty input', () {
      expect(Iban.validate('  ').error, IbanError.empty);
    });

    test('rejects invalid characters', () {
      expect(Iban.validate('SA03#8000').error, IbanError.invalidCharacters);
    });

    test('rejects non-GCC countries', () {
      expect(
        Iban.validate('DE89370400440532013000').error,
        IbanError.unsupportedCountry,
      );
    });

    test('respects allowedCountries', () {
      expect(
        Iban.validate(
          registryExamples[GccCountry.uae]!,
          allowedCountries: {GccCountry.saudiArabia},
        ).error,
        IbanError.unsupportedCountry,
      );
    });

    test('rejects wrong length', () {
      expect(
        Iban.validate('SA038000000060801016751').error,
        IbanError.invalidLength,
      );
    });

    test('rejects wrong BBAN structure', () {
      // UAE BBAN must be all digits.
      expect(
        Iban.validate('AE07033123456789012345A').error,
        IbanError.invalidFormat,
      );
    });

    test('rejects wrong check digits', () {
      expect(
        Iban.validate('SA0480000000608010167519').error,
        IbanError.invalidChecksum,
      );
    });

    test('detects a single transposition', () {
      expect(
        Iban.validate('SA0380000000608010167591').error,
        IbanError.invalidChecksum,
      );
    });
  });

  group('Iban.format', () {
    test('groups in fours', () {
      expect(
        Iban.format('SA0380000000608010167519'),
        'SA03 8000 0000 6080 1016 7519',
      );
    });

    test('handles a trailing partial group', () {
      expect(Iban.format('ae070331234567890123456'),
          'AE07 0331 2345 6789 0123 456');
    });
  });
}

import 'package:gcc_validators/gcc_validators.dart';
import 'package:test/test.dart';

void main() {
  const citizenId = '1012345672';
  const residentId = '2109876546';

  group('SaudiNationalId', () {
    test('accepts a valid citizen ID', () {
      expect(SaudiNationalId.validate(citizenId).value, citizenId);
      expect(SaudiNationalId.typeOf(citizenId), SaudiIdType.citizen);
    });

    test('accepts a valid Iqama', () {
      expect(SaudiNationalId.isValid(residentId), isTrue);
      expect(SaudiNationalId.typeOf(residentId), SaudiIdType.resident);
    });

    test('accepts Arabic-Indic digits and separators', () {
      expect(SaudiNationalId.validate('١٠١ ٢٣٤ ٥٦٧٢').value, citizenId);
    });

    test('filters by holder type', () {
      expect(
        SaudiNationalId.validate(residentId, type: SaudiIdType.citizen).error,
        SaudiIdError.invalidPrefix,
      );
    });

    test('rejects empty, letters, length, prefix and checksum', () {
      expect(SaudiNationalId.validate('').error, SaudiIdError.empty);
      expect(SaudiNationalId.validate('10123456A2').error,
          SaudiIdError.invalidCharacters);
      expect(SaudiNationalId.validate('101234567').error,
          SaudiIdError.invalidLength);
      expect(SaudiNationalId.validate('3012345672').error,
          SaudiIdError.invalidPrefix);
      expect(SaudiNationalId.validate('1012345673').error,
          SaudiIdError.invalidChecksum);
    });

    test('typeOf returns null for invalid IDs', () {
      expect(SaudiNationalId.typeOf('1012345673'), isNull);
    });
  });

  group('EmiratesId', () {
    const id = '784199012345676';

    test('accepts a valid ID with or without dashes', () {
      expect(EmiratesId.isValid(id), isTrue);
      expect(EmiratesId.validate('784-1990-1234567-6').value, id);
    });

    test('formats a valid ID', () {
      expect(EmiratesId.format(id), '784-1990-1234567-6');
      expect(EmiratesId.format('123'), isNull);
    });

    test('rejects empty, letters, length, prefix and checksum', () {
      expect(EmiratesId.validate('').error, EmiratesIdError.empty);
      expect(EmiratesId.validate('78419901234567X').error,
          EmiratesIdError.invalidCharacters);
      expect(EmiratesId.validate('78419901234567').error,
          EmiratesIdError.invalidLength);
      expect(EmiratesId.validate('785199012345676').error,
          EmiratesIdError.invalidPrefix);
      expect(EmiratesId.validate('784199012345677').error,
          EmiratesIdError.invalidChecksum);
    });
  });
}

import 'country.dart';
import 'digits.dart';
import 'validation_result.dart';

/// Why a mobile number failed validation.
enum PhoneError {
  /// Input was empty after removing separators.
  empty,

  /// Input contains characters other than digits and a leading `+`.
  invalidCharacters,

  /// Number is in local format but no `country` was given.
  missingCountryCode,

  /// The dialling code is not a GCC country, or does not match `country`.
  unsupportedCountry,

  /// The national number has the wrong number of digits.
  invalidLength,

  /// The national number does not start with a known mobile prefix.
  invalidPrefix,
}

/// Mobile numbering plan per country: national significant number length,
/// mobile prefix pattern, and whether a leading trunk `0` is used locally.
const _mobilePlans =
    <GccCountry, ({int length, String pattern, bool trunkZero})>{
  GccCountry.saudiArabia: (length: 9, pattern: r'5\d{8}', trunkZero: true),
  GccCountry.uae: (length: 9, pattern: r'5[024568]\d{7}', trunkZero: true),
  GccCountry.kuwait: (length: 8, pattern: r'[4569]\d{7}', trunkZero: false),
  GccCountry.qatar: (length: 8, pattern: r'[3567]\d{7}', trunkZero: false),
  GccCountry.bahrain: (length: 8, pattern: r'(3\d|66)\d{6}', trunkZero: false),
  GccCountry.oman: (length: 8, pattern: r'[79]\d{7}', trunkZero: false),
};

/// Validation and E.164 normalization for GCC mobile numbers.
abstract final class GccPhone {
  /// Validates a mobile number and returns it in E.164 form
  /// (e.g. `+966501234567`).
  ///
  /// Accepts international (`+966 50 123 4567`, `00966501234567`) and local
  /// (`0501234567`) formats. Local numbers require [country]. When [country]
  /// is given, international numbers must belong to it.
  static ValidationResult<PhoneError> validateMobile(
    String input, {
    GccCountry? country,
  }) {
    var number = compact(input);
    if (number.isEmpty) return const ValidationResult.invalid(PhoneError.empty);

    final international = number.startsWith('+') || number.startsWith('00');
    number = number.startsWith('+')
        ? number.substring(1)
        : number.startsWith('00')
            ? number.substring(2)
            : number;
    if (!isDigits(number)) {
      return const ValidationResult.invalid(PhoneError.invalidCharacters);
    }

    final GccCountry resolved;
    if (international) {
      final match = _countryByDialCode(number);
      if (match == null || (country != null && match != country)) {
        return const ValidationResult.invalid(PhoneError.unsupportedCountry);
      }
      resolved = match;
      number = number.substring(match.dialCode.length);
    } else {
      if (country == null) {
        return const ValidationResult.invalid(PhoneError.missingCountryCode);
      }
      resolved = country;
      if (_mobilePlans[country]!.trunkZero && number.startsWith('0')) {
        number = number.substring(1);
      }
    }

    final plan = _mobilePlans[resolved]!;
    if (number.length != plan.length) {
      return const ValidationResult.invalid(PhoneError.invalidLength);
    }
    if (!RegExp('^${plan.pattern}\$').hasMatch(number)) {
      return const ValidationResult.invalid(PhoneError.invalidPrefix);
    }
    return ValidationResult.valid('+${resolved.dialCode}$number');
  }

  /// Shorthand for `validateMobile(input, country: country).isValid`.
  static bool isValidMobile(String input, {GccCountry? country}) =>
      validateMobile(input, country: country).isValid;

  static GccCountry? _countryByDialCode(String digits) {
    for (final country in GccCountry.values) {
      if (digits.startsWith(country.dialCode)) return country;
    }
    return null;
  }
}

import 'country.dart';
import 'digits.dart';
import 'validation_result.dart';

/// Why an IBAN failed validation.
enum IbanError {
  /// Input was empty after removing separators.
  empty,

  /// Input contains characters other than letters and digits.
  invalidCharacters,

  /// The country prefix is not a GCC country, or not in `allowedCountries`.
  unsupportedCountry,

  /// Length does not match the country's IBAN length.
  invalidLength,

  /// The BBAN part does not match the country's structure.
  invalidFormat,

  /// The ISO 7064 mod 97-10 check digits are wrong.
  invalidChecksum,
}

/// IBAN structure for each GCC country, per the SWIFT IBAN registry.
const _ibanSpecs = <GccCountry, ({int length, String bban})>{
  GccCountry.saudiArabia: (length: 24, bban: r'\d{2}[A-Z0-9]{18}'),
  GccCountry.uae: (length: 23, bban: r'\d{3}\d{16}'),
  GccCountry.kuwait: (length: 30, bban: r'[A-Z]{4}[A-Z0-9]{22}'),
  GccCountry.qatar: (length: 29, bban: r'[A-Z]{4}[A-Z0-9]{21}'),
  GccCountry.bahrain: (length: 22, bban: r'[A-Z]{4}[A-Z0-9]{14}'),
  GccCountry.oman: (length: 23, bban: r'\d{3}[A-Z0-9]{16}'),
};

final _alphanumeric = RegExp(r'^[A-Z0-9]+$');

/// Validation and formatting for GCC IBANs.
abstract final class Iban {
  /// Validates [input] and returns the compact, upper-case IBAN on success.
  ///
  /// Spaces, dashes and Arabic-Indic digits are accepted. Restrict accepted
  /// countries with [allowedCountries] (defaults to all GCC countries).
  static ValidationResult<IbanError> validate(
    String input, {
    Set<GccCountry>? allowedCountries,
  }) {
    final iban = compact(input).toUpperCase();
    if (iban.isEmpty) return const ValidationResult.invalid(IbanError.empty);
    if (!_alphanumeric.hasMatch(iban)) {
      return const ValidationResult.invalid(IbanError.invalidCharacters);
    }
    if (iban.length < 4) {
      return const ValidationResult.invalid(IbanError.invalidLength);
    }

    final country = GccCountry.fromIsoCode(iban.substring(0, 2));
    if (country == null ||
        (allowedCountries != null && !allowedCountries.contains(country))) {
      return const ValidationResult.invalid(IbanError.unsupportedCountry);
    }

    final spec = _ibanSpecs[country]!;
    if (iban.length != spec.length) {
      return const ValidationResult.invalid(IbanError.invalidLength);
    }
    if (!RegExp('^\\d{2}${spec.bban}\$').hasMatch(iban.substring(2))) {
      return const ValidationResult.invalid(IbanError.invalidFormat);
    }
    if (_mod97(iban.substring(4) + iban.substring(0, 4)) != 1) {
      return const ValidationResult.invalid(IbanError.invalidChecksum);
    }
    return ValidationResult.valid(iban);
  }

  /// Shorthand for `validate(input).isValid`.
  static bool isValid(String input, {Set<GccCountry>? allowedCountries}) =>
      validate(input, allowedCountries: allowedCountries).isValid;

  /// Formats an IBAN in groups of four for display, e.g.
  /// `SA03 8000 0000 6080 1016 7519`. Does not validate.
  static String format(String input) {
    final iban = compact(input).toUpperCase();
    final groups = <String>[];
    for (var i = 0; i < iban.length; i += 4) {
      groups.add(iban.substring(i, i + 4 > iban.length ? iban.length : i + 4));
    }
    return groups.join(' ');
  }

  /// Returns the country of a (not necessarily valid) IBAN, if it is GCC.
  static GccCountry? countryOf(String input) {
    final iban = compact(input).toUpperCase();
    return iban.length < 2
        ? null
        : GccCountry.fromIsoCode(iban.substring(0, 2));
  }

  /// ISO 7064 mod 97-10, processed piecewise to avoid big integers.
  static int _mod97(String rearranged) {
    var remainder = 0;
    for (final unit in rearranged.codeUnits) {
      // Letters A–Z map to 10–35.
      final value = unit >= 0x41 ? unit - 0x41 + 10 : unit - 0x30;
      remainder = value >= 10
          ? (remainder * 100 + value) % 97
          : (remainder * 10 + value) % 97;
    }
    return remainder;
  }
}

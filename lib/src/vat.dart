import 'country.dart';
import 'digits.dart';
import 'validation_result.dart';

/// Why a VAT registration number failed validation.
enum VatError {
  /// Input was empty after removing separators.
  empty,

  /// Format rules for this country are not bundled yet.
  unsupportedCountry,

  /// Input contains non-digit characters.
  invalidCharacters,

  /// Input has the wrong number of digits.
  invalidLength,

  /// Input does not match the country's structure.
  invalidFormat,
}

const _vatRules = <GccCountry, ({int length, String pattern})>{
  // ZATCA VAT number: 15 digits, starts and ends with 3.
  GccCountry.saudiArabia: (length: 15, pattern: r'3\d{13}3'),
  // FTA Tax Registration Number (TRN): 15 digits, starts with 100.
  GccCountry.uae: (length: 15, pattern: r'100\d{12}'),
};

/// Structural validation for VAT registration numbers.
///
/// Currently supports Saudi Arabia (ZATCA) and the UAE (FTA TRN). This checks
/// structure only; it does not confirm registration with the tax authority.
abstract final class GccVat {
  /// Countries whose VAT formats are supported.
  static Set<GccCountry> get supportedCountries => _vatRules.keys.toSet();

  /// Validates [input] for [country] and returns the digits on success.
  static ValidationResult<VatError> validate(
    String input, {
    required GccCountry country,
  }) {
    final vat = compact(input);
    if (vat.isEmpty) return const ValidationResult.invalid(VatError.empty);
    final rule = _vatRules[country];
    if (rule == null) {
      return const ValidationResult.invalid(VatError.unsupportedCountry);
    }
    if (!isDigits(vat)) {
      return const ValidationResult.invalid(VatError.invalidCharacters);
    }
    if (vat.length != rule.length) {
      return const ValidationResult.invalid(VatError.invalidLength);
    }
    if (!RegExp('^${rule.pattern}\$').hasMatch(vat)) {
      return const ValidationResult.invalid(VatError.invalidFormat);
    }
    return ValidationResult.valid(vat);
  }

  /// Shorthand for `validate(input, country: country).isValid`.
  static bool isValid(String input, {required GccCountry country}) =>
      validate(input, country: country).isValid;
}

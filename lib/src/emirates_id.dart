import 'digits.dart';
import 'validation_result.dart';

/// Why an Emirates ID failed validation.
enum EmiratesIdError {
  /// Input was empty after removing separators.
  empty,

  /// Input contains non-digit characters.
  invalidCharacters,

  /// Input is not exactly 15 digits.
  invalidLength,

  /// Input does not start with the UAE code `784`.
  invalidPrefix,

  /// The Luhn check digit is wrong.
  invalidChecksum,
}

/// Validation and formatting for UAE Emirates ID numbers
/// (`784-YYYY-NNNNNNN-C`).
abstract final class EmiratesId {
  /// Validates [input] and returns the 15-digit ID on success.
  static ValidationResult<EmiratesIdError> validate(String input) {
    final id = compact(input);
    if (id.isEmpty) {
      return const ValidationResult.invalid(EmiratesIdError.empty);
    }
    if (!isDigits(id)) {
      return const ValidationResult.invalid(EmiratesIdError.invalidCharacters);
    }
    if (id.length != 15) {
      return const ValidationResult.invalid(EmiratesIdError.invalidLength);
    }
    if (!id.startsWith('784')) {
      return const ValidationResult.invalid(EmiratesIdError.invalidPrefix);
    }
    if (!passesLuhn(id)) {
      return const ValidationResult.invalid(EmiratesIdError.invalidChecksum);
    }
    return ValidationResult.valid(id);
  }

  /// Shorthand for `validate(input).isValid`.
  static bool isValid(String input) => validate(input).isValid;

  /// Formats a valid ID as `784-YYYY-NNNNNNN-C`; returns `null` if invalid.
  static String? format(String input) {
    final id = validate(input).value;
    if (id == null) return null;
    return '${id.substring(0, 3)}-${id.substring(3, 7)}-'
        '${id.substring(7, 14)}-${id.substring(14)}';
  }
}

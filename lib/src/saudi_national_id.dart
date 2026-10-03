import 'digits.dart';
import 'validation_result.dart';

/// Why a Saudi national ID or Iqama number failed validation.
enum SaudiIdError {
  /// Input was empty after removing separators.
  empty,

  /// Input contains non-digit characters.
  invalidCharacters,

  /// Input is not exactly 10 digits.
  invalidLength,

  /// First digit is not `1` (citizen) or `2` (resident).
  invalidPrefix,

  /// The check digit is wrong.
  invalidChecksum,
}

/// Holder type encoded in the first digit of a Saudi ID.
enum SaudiIdType {
  /// National ID — starts with `1`.
  citizen,

  /// Iqama (residence permit) — starts with `2`.
  resident,
}

/// Validation for Saudi national IDs and Iqama numbers.
abstract final class SaudiNationalId {
  /// Validates [input] and returns the 10-digit ID on success.
  ///
  /// Restrict to one holder type with [type].
  static ValidationResult<SaudiIdError> validate(
    String input, {
    SaudiIdType? type,
  }) {
    final id = compact(input);
    if (id.isEmpty) return const ValidationResult.invalid(SaudiIdError.empty);
    if (!isDigits(id)) {
      return const ValidationResult.invalid(SaudiIdError.invalidCharacters);
    }
    if (id.length != 10) {
      return const ValidationResult.invalid(SaudiIdError.invalidLength);
    }
    final actualType = _typeFromPrefix(id);
    if (actualType == null || (type != null && actualType != type)) {
      return const ValidationResult.invalid(SaudiIdError.invalidPrefix);
    }
    if (!passesLuhn(id)) {
      return const ValidationResult.invalid(SaudiIdError.invalidChecksum);
    }
    return ValidationResult.valid(id);
  }

  /// Shorthand for `validate(input).isValid`.
  static bool isValid(String input, {SaudiIdType? type}) =>
      validate(input, type: type).isValid;

  /// Returns the holder type of a valid ID, or `null` if invalid.
  static SaudiIdType? typeOf(String input) {
    final result = validate(input);
    return result.isValid ? _typeFromPrefix(result.value!) : null;
  }

  static SaudiIdType? _typeFromPrefix(String id) => switch (id[0]) {
        '1' => SaudiIdType.citizen,
        '2' => SaudiIdType.resident,
        _ => null,
      };
}

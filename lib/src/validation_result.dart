/// Outcome of a validation: either a normalized value or a typed error.
///
/// Errors are enums rather than strings so that apps can map them to their
/// own localized messages.
final class ValidationResult<E extends Enum> {
  /// A successful result carrying the normalized [value].
  const ValidationResult.valid(String this.value) : error = null;

  /// A failed result carrying the reason.
  const ValidationResult.invalid(E this.error) : value = null;

  /// The normalized value, or `null` when invalid.
  final String? value;

  /// Why validation failed, or `null` when valid.
  final E? error;

  /// Whether the input passed validation.
  bool get isValid => error == null;

  @override
  bool operator ==(Object other) =>
      other is ValidationResult<E> &&
      other.value == value &&
      other.error == error;

  @override
  int get hashCode => Object.hash(value, error);

  @override
  String toString() => isValid
      ? 'ValidationResult.valid($value)'
      : 'ValidationResult.invalid($error)';
}

import 'country.dart';
import 'emirates_id.dart';
import 'iban.dart';
import 'phone.dart';
import 'saudi_national_id.dart';
import 'validation_result.dart';
import 'vat.dart';

/// Signature of Flutter's `FormFieldValidator<String>`, declared here so the
/// package stays pure Dart.
typedef FieldValidator = String? Function(String? value);

/// Builds a message for a typed validation error.
typedef ErrorMessageBuilder<E extends Enum> = String Function(E error);

/// Ready-made validators for `TextFormField.validator`.
///
/// Each takes either a single [message] or a per-error [messages] builder, so
/// you can show "IBAN checksum is wrong" instead of a generic message.
///
/// ```dart
/// TextFormField(
///   validator: GccValidators.iban(message: 'Enter a valid IBAN'),
/// )
/// ```
abstract final class GccValidators {
  /// Validates a GCC IBAN.
  static FieldValidator iban({
    String message = 'Invalid IBAN',
    ErrorMessageBuilder<IbanError>? messages,
    Set<GccCountry>? allowedCountries,
    bool required = true,
  }) =>
      _build(
        (v) => Iban.validate(v, allowedCountries: allowedCountries),
        message,
        messages,
        required,
      );

  /// Validates a Saudi national ID or Iqama.
  static FieldValidator saudiNationalId({
    String message = 'Invalid ID number',
    ErrorMessageBuilder<SaudiIdError>? messages,
    SaudiIdType? type,
    bool required = true,
  }) =>
      _build(
        (v) => SaudiNationalId.validate(v, type: type),
        message,
        messages,
        required,
      );

  /// Validates a UAE Emirates ID.
  static FieldValidator emiratesId({
    String message = 'Invalid Emirates ID',
    ErrorMessageBuilder<EmiratesIdError>? messages,
    bool required = true,
  }) =>
      _build(EmiratesId.validate, message, messages, required);

  /// Validates a GCC mobile number.
  static FieldValidator mobile({
    GccCountry? country,
    String message = 'Invalid mobile number',
    ErrorMessageBuilder<PhoneError>? messages,
    bool required = true,
  }) =>
      _build(
        (v) => GccPhone.validateMobile(v, country: country),
        message,
        messages,
        required,
      );

  /// Validates a VAT registration number.
  static FieldValidator vat({
    required GccCountry country,
    String message = 'Invalid VAT number',
    ErrorMessageBuilder<VatError>? messages,
    bool required = true,
  }) =>
      _build(
        (v) => GccVat.validate(v, country: country),
        message,
        messages,
        required,
      );

  static FieldValidator _build<E extends Enum>(
    ValidationResult<E> Function(String) validate,
    String message,
    ErrorMessageBuilder<E>? messages,
    bool required,
  ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return required ? message : null;
      }
      final result = validate(value);
      if (result.isValid) return null;
      return messages?.call(result.error!) ?? message;
    };
  }
}

/// Validation and normalization for GCC identifiers.
///
/// Every validator accepts raw user input (spaces, dashes, Arabic-Indic
/// digits) and returns a [ValidationResult] holding either the normalized
/// value or a typed error you can map to your own messages.
library;

export 'src/country.dart';
export 'src/digits.dart' show normalizeDigits;
export 'src/emirates_id.dart';
export 'src/form_validators.dart';
export 'src/iban.dart';
export 'src/phone.dart';
export 'src/saudi_national_id.dart';
export 'src/validation_result.dart';
export 'src/vat.dart';

import 'package:gcc_validators/gcc_validators.dart';

void main() {
  // IBAN: accepts spaces, lower case and Arabic-Indic digits.
  final iban = Iban.validate('sa03 8000 0000 6080 1016 7519');
  print(iban.isValid); // true
  print(Iban.format(iban.value!)); // SA03 8000 0000 6080 1016 7519

  // Typed errors you can map to your own localized messages.
  final bad = Iban.validate('SA04 8000 0000 6080 1016 7519');
  print(bad.error); // IbanError.invalidChecksum

  // Saudi national ID / Iqama.
  print(SaudiNationalId.typeOf('1012345672')); // SaudiIdType.citizen

  // Mobile numbers normalized to E.164.
  final phone = GccPhone.validateMobile(
    '٠٥٠ ١٢٣ ٤٥٦٧',
    country: GccCountry.saudiArabia,
  );
  print(phone.value); // +966501234567

  // Drop-in validator for Flutter's TextFormField.validator.
  final validator = GccValidators.mobile(
    country: GccCountry.uae,
    messages: (error) => switch (error) {
      PhoneError.invalidPrefix => 'Not a UAE mobile number',
      _ => 'Enter a valid mobile number',
    },
  );
  print(validator('053 123 4567')); // Not a UAE mobile number
}

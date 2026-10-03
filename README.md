# gcc_validators

[![CI](https://github.com/mokinan/gcc_validators/actions/workflows/ci.yml/badge.svg)](https://github.com/mokinan/gcc_validators/actions/workflows/ci.yml)

Validation and normalization for identifiers used in GCC apps — IBANs, Saudi
national IDs and Iqamas, Emirates IDs, mobile numbers and VAT numbers.

Pure Dart, zero dependencies, works in Flutter forms and on the server.

## Why

Fintech, e-commerce and government-facing apps in the Gulf validate the same
fields again and again, and usually get the edge cases wrong:

- Users on Arabic keyboards type `٠٥٠١٢٣٤٥٦٧`, not `0501234567`.
- Phone numbers arrive as `+966…`, `00966…` or `05…` and must be stored in one form.
- A regex accepts an IBAN with the right length but a wrong checksum.
- A single "Invalid input" message is not enough when the user mistyped one digit.

This package handles all of that and returns **typed errors** you can map to your
own localized messages.

## Supported identifiers

| Identifier | Countries | Checks |
|---|---|---|
| IBAN | 🇸🇦 🇦🇪 🇰🇼 🇶🇦 🇧🇭 🇴🇲 | length, BBAN structure, ISO 7064 mod 97-10 checksum |
| National ID / Iqama | 🇸🇦 | length, citizen/resident prefix, check digit |
| Emirates ID | 🇦🇪 | length, `784` prefix, Luhn check digit |
| Mobile number | 🇸🇦 🇦🇪 🇰🇼 🇶🇦 🇧🇭 🇴🇲 | international & local formats, mobile prefixes, E.164 output |
| VAT number | 🇸🇦 🇦🇪 | length and structure (ZATCA, FTA TRN) |

All validators accept spaces, dashes and Arabic-Indic digits.

## Install

```bash
dart pub add gcc_validators
```

## Usage

### Validate and normalize

```dart
import 'package:gcc_validators/gcc_validators.dart';

final iban = Iban.validate('sa03 8000 0000 6080 1016 7519');
iban.isValid;               // true
iban.value;                 // SA0380000000608010167519
Iban.format(iban.value!);   // SA03 8000 0000 6080 1016 7519

final phone = GccPhone.validateMobile('٠٥٠ ١٢٣ ٤٥٦٧', country: GccCountry.saudiArabia);
phone.value;                // +966501234567

SaudiNationalId.typeOf('1012345672'); // SaudiIdType.citizen
```

### Typed errors

Every result carries either a normalized `value` or an `error` enum:

```dart
final result = Iban.validate(input);
if (!result.isValid) {
  final message = switch (result.error!) {
    IbanError.invalidChecksum => 'Check the IBAN for a typo',
    IbanError.unsupportedCountry => 'Only GCC bank accounts are supported',
    _ => 'Enter a valid IBAN',
  };
}
```

### Flutter forms

`GccValidators` returns functions that plug straight into
`TextFormField.validator`:

```dart
TextFormField(
  keyboardType: TextInputType.phone,
  validator: GccValidators.mobile(
    country: GccCountry.saudiArabia,
    messages: (error) => switch (error) {
      PhoneError.invalidPrefix => 'Saudi mobile numbers start with 05',
      _ => 'Enter a valid mobile number',
    },
  ),
)
```

Set `required: false` to allow empty optional fields.

## Design notes

- **Normalize, then validate.** Input is converted to ASCII digits and stripped of
  separators before any rule runs, and the normalized form is returned so you can
  store exactly one representation.
- **Enums, not strings.** Errors are typed so messages stay in your app's
  localization layer.
- **Structure, not existence.** Validators confirm an identifier is well formed;
  they do not query banks, telecom operators or tax authorities.

## Contributing

Issues and pull requests are welcome — especially numbering-plan updates with a
link to the official source.

```bash
dart pub get
dart test
dart analyze
```

## License

MIT

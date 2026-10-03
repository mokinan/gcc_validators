const _arabicIndicZero = 0x0660; // ٠
const _easternArabicIndicZero = 0x06F0; // ۰
const _asciiZero = 0x30;

/// Converts Arabic-Indic (`٠١٢`) and Eastern Arabic-Indic (`۰۱۲`) digits to
/// ASCII digits, leaving every other character untouched.
///
/// Users on Arabic keyboards frequently type these digits, so every validator
/// in this package runs input through this function first.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
      buffer.writeCharCode(rune - _arabicIndicZero + _asciiZero);
    } else if (rune >= _easternArabicIndicZero &&
        rune <= _easternArabicIndicZero + 9) {
      buffer.writeCharCode(rune - _easternArabicIndicZero + _asciiZero);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

final _separators = RegExp(r'[\s\-().]');

/// Normalizes digits and strips common separators (spaces, dashes, dots,
/// parentheses).
String compact(String input) =>
    normalizeDigits(input).replaceAll(_separators, '');

final _digitsOnly = RegExp(r'^\d+$');

/// Whether [input] is non-empty and consists only of ASCII digits.
bool isDigits(String input) => _digitsOnly.hasMatch(input);

/// Luhn (mod 10) checksum over a string of ASCII digits.
bool passesLuhn(String digits) {
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - _asciiZero;
    if (doubleIt) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}

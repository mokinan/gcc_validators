/// The six Gulf Cooperation Council member states.
enum GccCountry {
  /// Saudi Arabia.
  saudiArabia('SA', '966'),

  /// United Arab Emirates.
  uae('AE', '971'),

  /// Kuwait.
  kuwait('KW', '965'),

  /// Qatar.
  qatar('QA', '974'),

  /// Bahrain.
  bahrain('BH', '973'),

  /// Oman.
  oman('OM', '968');

  const GccCountry(this.isoCode, this.dialCode);

  /// ISO 3166-1 alpha-2 code, e.g. `SA`.
  final String isoCode;

  /// International dialling code without the leading `+`, e.g. `966`.
  final String dialCode;

  /// Looks up a country by its ISO code (case-insensitive).
  static GccCountry? fromIsoCode(String code) {
    final upper = code.toUpperCase();
    for (final country in values) {
      if (country.isoCode == upper) return country;
    }
    return null;
  }
}

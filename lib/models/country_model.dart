class CountryModel {
  final String name;
  final String isoCode;
  final String dialCode;

  const CountryModel({
    required this.name,
    required this.isoCode,
    required this.dialCode,
  });

  String get flagEmoji {
    return isoCode
        .toUpperCase()
        .codeUnits
        .map((char) => String.fromCharCode(char + 127397))
        .join();
  }
}

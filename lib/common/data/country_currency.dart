/// Holds a currency's ISO 4217 code and its common display symbol.
class CurrencyInfo {
  final String code;
  final String symbol;

  const CurrencyInfo(this.code, this.symbol);
}

/// Returns the currency (ISO code + symbol) used by the given ISO country
/// code. Use this alongside `country_data.dart`.
///
/// Example usage inside a widget/state class:
/// ```dart
/// CurrencyInfo get currency => getCurrency(selectedCountry.isoCode);
/// ```
CurrencyInfo getCurrency(String isoCode) {
  switch (isoCode) {
    // --- South Asia ---
    case 'PK':
      return const CurrencyInfo('PKR', '₨');
    case 'IN':
      return const CurrencyInfo('INR', '₹');
    case 'BD':
      return const CurrencyInfo('BDT', '৳');
    case 'NP':
      return const CurrencyInfo('NPR', '₨');
    case 'LK':
      return const CurrencyInfo('LKR', '₨');
    case 'BT':
      return const CurrencyInfo('BTN', 'Nu.');
    case 'MV':
      return const CurrencyInfo('MVR', 'Rf');
    case 'AF':
      return const CurrencyInfo('AFN', '؋');

    // --- North America ---
    case 'US':
      return const CurrencyInfo('USD', '\$');
    case 'CA':
      return const CurrencyInfo('CAD', '\$');

    // --- UK & Ireland ---
    case 'GB':
      return const CurrencyInfo('GBP', '£');
    case 'IE':
      return const CurrencyInfo('EUR', '€');

    // --- Eurozone (EUR) ---
    case 'DE':
    case 'FR':
    case 'ES':
    case 'IT':
    case 'PT':
    case 'NL':
    case 'BE':
    case 'AT':
    case 'LU':
    case 'MC':
    case 'SM':
    case 'VA':
    case 'MT':
    case 'GR':
    case 'SI':
    case 'SK':
    case 'EE':
    case 'LV':
    case 'LT':
    case 'FI':
    case 'CY':
    case 'AD':
      return const CurrencyInfo('EUR', '€');

    // --- Non-eurozone Western/Central Europe ---
    case 'CH':
      return const CurrencyInfo('CHF', 'CHF');
    case 'LI':
      return const CurrencyInfo('CHF', 'CHF');
    case 'SE':
      return const CurrencyInfo('SEK', 'kr');
    case 'NO':
      return const CurrencyInfo('NOK', 'kr');
    case 'DK':
      return const CurrencyInfo('DKK', 'kr');
    case 'IS':
      return const CurrencyInfo('ISK', 'kr');
    case 'PL':
      return const CurrencyInfo('PLN', 'zł');
    case 'CZ':
      return const CurrencyInfo('CZK', 'Kč');
    case 'HU':
      return const CurrencyInfo('HUF', 'Ft');
    case 'RO':
      return const CurrencyInfo('RON', 'lei');
    case 'BG':
      return const CurrencyInfo('BGN', 'лв');
    case 'HR':
      return const CurrencyInfo('EUR', '€');
    case 'RS':
      return const CurrencyInfo('RSD', 'дин.');
    case 'BA':
      return const CurrencyInfo('BAM', 'KM');
    case 'ME':
      return const CurrencyInfo('EUR', '€');
    case 'MK':
      return const CurrencyInfo('MKD', 'ден');
    case 'AL':
      return const CurrencyInfo('ALL', 'L');
    case 'MD':
      return const CurrencyInfo('MDL', 'L');
    case 'UA':
      return const CurrencyInfo('UAH', '₴');
    case 'BY':
      return const CurrencyInfo('BYN', 'Br');
    case 'RU':
      return const CurrencyInfo('RUB', '₽');
    case 'KZ':
      return const CurrencyInfo('KZT', '₸');
    case 'GE':
      return const CurrencyInfo('GEL', '₾');
    case 'AM':
      return const CurrencyInfo('AMD', '֏');
    case 'AZ':
      return const CurrencyInfo('AZN', '₼');
    case 'KG':
      return const CurrencyInfo('KGS', 'с');
    case 'TJ':
      return const CurrencyInfo('TJS', 'ЅМ');
    case 'TM':
      return const CurrencyInfo('TMT', 'm');
    case 'UZ':
      return const CurrencyInfo('UZS', "so'm");

    // --- Middle East ---
    case 'AE':
      return const CurrencyInfo('AED', 'د.إ');
    case 'SA':
      return const CurrencyInfo('SAR', '﷼');
    case 'QA':
      return const CurrencyInfo('QAR', '﷼');
    case 'KW':
      return const CurrencyInfo('KWD', 'د.ك');
    case 'BH':
      return const CurrencyInfo('BHD', '.د.ب');
    case 'OM':
      return const CurrencyInfo('OMR', '﷼');
    case 'JO':
      return const CurrencyInfo('JOD', 'د.ا');
    case 'LB':
      return const CurrencyInfo('LBP', 'ل.ل');
    case 'SY':
      return const CurrencyInfo('SYP', 'ل.س');
    case 'IQ':
      return const CurrencyInfo('IQD', 'ع.د');
    case 'IR':
      return const CurrencyInfo('IRR', '﷼');
    case 'IL':
      return const CurrencyInfo('ILS', '₪');
    case 'PS':
      return const CurrencyInfo('ILS', '₪');
    case 'YE':
      return const CurrencyInfo('YER', '﷼');
    case 'TR':
      return const CurrencyInfo('TRY', '₺');

    // --- East & Southeast Asia ---
    case 'CN':
      return const CurrencyInfo('CNY', '¥');
    case 'JP':
      return const CurrencyInfo('JPY', '¥');
    case 'KR':
      return const CurrencyInfo('KRW', '₩');
    case 'KP':
      return const CurrencyInfo('KPW', '₩');
    case 'TW':
      return const CurrencyInfo('TWD', 'NT\$');
    case 'HK':
      return const CurrencyInfo('HKD', '\$');
    case 'MO':
      return const CurrencyInfo('MOP', 'MOP\$');
    case 'MN':
      return const CurrencyInfo('MNT', '₮');
    case 'VN':
      return const CurrencyInfo('VND', '₫');
    case 'TH':
      return const CurrencyInfo('THB', '฿');
    case 'MY':
      return const CurrencyInfo('MYR', 'RM');
    case 'SG':
      return const CurrencyInfo('SGD', '\$');
    case 'ID':
      return const CurrencyInfo('IDR', 'Rp');
    case 'PH':
      return const CurrencyInfo('PHP', '₱');
    case 'MM':
      return const CurrencyInfo('MMK', 'K');
    case 'KH':
      return const CurrencyInfo('KHR', '៛');
    case 'LA':
      return const CurrencyInfo('LAK', '₭');
    case 'BN':
      return const CurrencyInfo('BND', '\$');
    case 'TL':
      return const CurrencyInfo('USD', '\$');

    // --- Oceania ---
    case 'AU':
      return const CurrencyInfo('AUD', '\$');
    case 'NZ':
      return const CurrencyInfo('NZD', '\$');
    case 'FJ':
      return const CurrencyInfo('FJD', '\$');
    case 'PG':
      return const CurrencyInfo('PGK', 'K');
    case 'WS':
      return const CurrencyInfo('WST', 'T');
    case 'TO':
      return const CurrencyInfo('TOP', 'T\$');
    case 'VU':
      return const CurrencyInfo('VUV', 'VT');
    case 'SB':
      return const CurrencyInfo('SBD', '\$');
    case 'KI':
      return const CurrencyInfo('AUD', '\$');
    case 'TV':
      return const CurrencyInfo('AUD', '\$');
    case 'NR':
      return const CurrencyInfo('AUD', '\$');
    case 'PW':
      return const CurrencyInfo('USD', '\$');
    case 'FM':
      return const CurrencyInfo('USD', '\$');
    case 'MH':
      return const CurrencyInfo('USD', '\$');

    // --- Africa ---
    case 'ZA':
      return const CurrencyInfo('ZAR', 'R');
    case 'NG':
      return const CurrencyInfo('NGN', '₦');
    case 'EG':
      return const CurrencyInfo('EGP', '£');
    case 'KE':
      return const CurrencyInfo('KES', 'KSh');
    case 'GH':
      return const CurrencyInfo('GHS', '₵');
    case 'ET':
      return const CurrencyInfo('ETB', 'Br');
    case 'TZ':
      return const CurrencyInfo('TZS', 'TSh');
    case 'UG':
      return const CurrencyInfo('UGX', 'USh');
    case 'DZ':
      return const CurrencyInfo('DZD', 'د.ج');
    case 'MA':
      return const CurrencyInfo('MAD', 'د.م.');
    case 'TN':
      return const CurrencyInfo('TND', 'د.ت');
    case 'LY':
      return const CurrencyInfo('LYD', 'ل.د');
    case 'SD':
      return const CurrencyInfo('SDG', 'ج.س.');
    case 'SS':
      return const CurrencyInfo('SSP', '£');
    case 'ZM':
      return const CurrencyInfo('ZMW', 'ZK');
    case 'ZW':
      return const CurrencyInfo('ZWL', '\$');
    case 'MZ':
      return const CurrencyInfo('MZN', 'MT');
    case 'AO':
      return const CurrencyInfo('AOA', 'Kz');
    case 'CM':
    case 'CI':
    case 'SN':
    case 'ML':
    case 'BF':
    case 'NE':
    case 'TG':
    case 'BJ':
    case 'GW':
      return const CurrencyInfo('XOF', 'CFA');
    case 'GA':
    case 'CG':
    case 'CD':
      return const CurrencyInfo('CDF', 'FC');
    case 'CF':
    case 'TD':
    case 'GQ':
      return const CurrencyInfo('XAF', 'FCFA');
    case 'GN':
      return const CurrencyInfo('GNF', 'FG');
    case 'SL':
      return const CurrencyInfo('SLL', 'Le');
    case 'LR':
      return const CurrencyInfo('LRD', '\$');
    case 'CV':
      return const CurrencyInfo('CVE', '\$');
    case 'ST':
      return const CurrencyInfo('STN', 'Db');
    case 'GM':
      return const CurrencyInfo('GMD', 'D');
    case 'MR':
      return const CurrencyInfo('MRU', 'UM');
    case 'DJ':
      return const CurrencyInfo('DJF', 'Fdj');
    case 'SO':
      return const CurrencyInfo('SOS', 'S');
    case 'ER':
      return const CurrencyInfo('ERN', 'Nfk');
    case 'RW':
      return const CurrencyInfo('RWF', 'FRw');
    case 'BI':
      return const CurrencyInfo('BIF', 'FBu');
    case 'MW':
      return const CurrencyInfo('MWK', 'MK');
    case 'MG':
      return const CurrencyInfo('MGA', 'Ar');
    case 'KM':
      return const CurrencyInfo('KMF', 'CF');
    case 'SC':
      return const CurrencyInfo('SCR', '₨');
    case 'MU':
      return const CurrencyInfo('MUR', '₨');
    case 'NA':
      return const CurrencyInfo('NAD', '\$');
    case 'BW':
      return const CurrencyInfo('BWP', 'P');
    case 'LS':
      return const CurrencyInfo('LSL', 'L');
    case 'SZ':
      return const CurrencyInfo('SZL', 'E');

    // --- Latin America & Caribbean ---
    case 'MX':
      return const CurrencyInfo('MXN', '\$');
    case 'BR':
      return const CurrencyInfo('BRL', 'R\$');
    case 'AR':
      return const CurrencyInfo('ARS', '\$');
    case 'CL':
      return const CurrencyInfo('CLP', '\$');
    case 'CO':
      return const CurrencyInfo('COP', '\$');
    case 'PE':
      return const CurrencyInfo('PEN', 'S/');
    case 'VE':
      return const CurrencyInfo('VES', 'Bs.');
    case 'EC':
      return const CurrencyInfo('USD', '\$');
    case 'BO':
      return const CurrencyInfo('BOB', 'Bs.');
    case 'PY':
      return const CurrencyInfo('PYG', '₲');
    case 'UY':
      return const CurrencyInfo('UYU', '\$');
    case 'GY':
      return const CurrencyInfo('GYD', '\$');
    case 'SR':
      return const CurrencyInfo('SRD', '\$');
    case 'CR':
      return const CurrencyInfo('CRC', '₡');
    case 'PA':
      return const CurrencyInfo('PAB', 'B/.');
    case 'NI':
      return const CurrencyInfo('NIO', 'C\$');
    case 'HN':
      return const CurrencyInfo('HNL', 'L');
    case 'SV':
      return const CurrencyInfo('USD', '\$');
    case 'GT':
      return const CurrencyInfo('GTQ', 'Q');
    case 'BZ':
      return const CurrencyInfo('BZD', '\$');
    case 'CU':
      return const CurrencyInfo('CUP', '\$');
    case 'DO':
      return const CurrencyInfo('DOP', 'RD\$');
    case 'HT':
      return const CurrencyInfo('HTG', 'G');
    case 'JM':
      return const CurrencyInfo('JMD', '\$');
    case 'TT':
      return const CurrencyInfo('TTD', '\$');
    case 'BB':
      return const CurrencyInfo('BBD', '\$');
    case 'BS':
      return const CurrencyInfo('BSD', '\$');
    case 'GD':
    case 'LC':
    case 'VC':
    case 'AG':
    case 'DM':
    case 'KN':
      return const CurrencyInfo('XCD', '\$');

    default:
      return const CurrencyInfo('USD', '\$');
  }
}

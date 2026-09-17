/// Returns a locale-appropriate example phone number (as hint text)
/// for the given ISO country code. Use this alongside `country_data.dart`.
///
/// Example usage inside a widget/state class:
/// ```dart
/// String get phoneHint => getPhoneHint(selectedCountry.isoCode);
/// ```
String getPhoneHint(String isoCode) {
  switch (isoCode) {
    // --- South Asia ---
    case 'PK':
      return '300 1234567';
    case 'IN':
      return '98765 43210';
    case 'BD':
      return '1812-345678';
    case 'NP':
      return '984-1234567';
    case 'LK':
      return '071 234 5678';
    case 'BT':
      return '17 123 456';
    case 'MV':
      return '771-2345';
    case 'AF':
      return '070 123 4567';

    // --- North America ---
    case 'US':
    case 'CA':
      return '(201) 555-0123';

    // --- UK & Ireland ---
    case 'GB':
      return '07700 900123';
    case 'IE':
      return '085 123 4567';

    // --- Western Europe ---
    case 'DE':
      return '0151 23456789';
    case 'FR':
      return '06 12 34 56 78';
    case 'ES':
      return '612 34 56 78';
    case 'IT':
      return '312 345 6789';
    case 'PT':
      return '912 345 678';
    case 'NL':
      return '06 12345678';
    case 'BE':
      return '0470 12 34 56';
    case 'CH':
      return '078 123 45 67';
    case 'AT':
      return '0664 123456';
    case 'LU':
      return '621 123 456';
    case 'MC':
      return '06 12 34 56 78';
    case 'LI':
      return '077 123 45 67';
    case 'MT':
      return '9912 3456';
    case 'AD':
      return '312 345';
    case 'SM':
      return '335 123 4567';
    case 'VA':
      return '312 345 6789';

    // --- Nordics ---
    case 'SE':
      return '070-123 45 67';
    case 'NO':
      return '406 12 345';
    case 'DK':
      return '20 12 34 56';
    case 'FI':
      return '040 123 4567';
    case 'IS':
      return '611 2345';

    // --- Eastern Europe ---
    case 'PL':
      return '512 345 678';
    case 'CZ':
      return '601 123 456';
    case 'SK':
      return '0912 345 678';
    case 'HU':
      return '06 20 123 4567';
    case 'RO':
      return '0712 345 678';
    case 'BG':
      return '048 123 456';
    case 'GR':
      return '691 234 5678';
    case 'HR':
      return '091 234 5678';
    case 'SI':
      return '031 234 567';
    case 'RS':
      return '060 1234567';
    case 'BA':
      return '061 123 456';
    case 'ME':
      return '067 123 456';
    case 'MK':
      return '070 123 456';
    case 'AL':
      return '067 212 3456';
    case 'MD':
      return '069 123 456';
    case 'UA':
      return '050 123 4567';
    case 'BY':
      return '29 123-45-67';
    case 'LT':
      return '(8-612) 34567';
    case 'LV':
      return '21 234 567';
    case 'EE':
      return '5123 4567';
    case 'RU':
      return '912 345-67-89';
    case 'KZ':
      return '701 234 5678';

    // --- Middle East ---
    case 'AE':
      return '050 123 4567';
    case 'SA':
      return '050 123 4567';
    case 'QA':
      return '3312 3456';
    case 'KW':
      return '500 12345';
    case 'BH':
      return '3600 1234';
    case 'OM':
      return '9212 3456';
    case 'JO':
      return '079 012 3456';
    case 'LB':
      return '71 123 456';
    case 'SY':
      return '093 123 4567';
    case 'IQ':
      return '0790 123 4567';
    case 'IR':
      return '0912 345 6789';
    case 'IL':
      return '050-123-4567';
    case 'PS':
      return '0599 123 456';
    case 'YE':
      return '0712 345 678';
    case 'TR':
      return '0501 234 56 78';

    // --- East & Southeast Asia ---
    case 'CN':
      return '138 0013 8000';
    case 'JP':
      return '090-1234-5678';
    case 'KR':
      return '010-1234-5678';
    case 'KP':
      return '0192 123 4567';
    case 'TW':
      return '0912 345 678';
    case 'HK':
      return '5123 4567';
    case 'MO':
      return '6123 4567';
    case 'MN':
      return '8812 3456';
    case 'VN':
      return '091 234 56 78';
    case 'TH':
      return '081 234 5678';
    case 'MY':
      return '012-345 6789';
    case 'SG':
      return '8123 4567';
    case 'ID':
      return '0812-3456-789';
    case 'PH':
      return '0917 123 4567';
    case 'MM':
      return '09 212 345 67';
    case 'KH':
      return '012 345 678';
    case 'LA':
      return '020 23 123 456';
    case 'BN':
      return '712 3456';
    case 'TL':
      return '7712 3456';

    // --- Oceania ---
    case 'AU':
      return '0412 345 678';
    case 'NZ':
      return '021 123 4567';
    case 'FJ':
      return '701 2345';
    case 'PG':
      return '7012 3456';
    case 'WS':
      return '72 12345';
    case 'TO':
      return '771 2345';
    case 'VU':
      return '591 2345';
    case 'SB':
      return '742 1234';
    case 'KI':
      return '72012345';
    case 'TV':
      return '901234';
    case 'NR':
      return '555 1234';
    case 'PW':
      return '620 1234';
    case 'FM':
      return '350 1234';
    case 'MH':
      return '235 1234';

    // --- Africa ---
    case 'ZA':
      return '071 123 4567';
    case 'NG':
      return '0801 234 5678';
    case 'EG':
      return '010 12345678';
    case 'KE':
      return '0712 345678';
    case 'GH':
      return '024 123 4567';
    case 'ET':
      return '091 123 4567';
    case 'TZ':
      return '0621 234 567';
    case 'UG':
      return '0712 345678';
    case 'DZ':
      return '0551 23 45 67';
    case 'MA':
      return '0612-345678';
    case 'TN':
      return '20 123 456';
    case 'LY':
      return '091-2345678';
    case 'SD':
      return '091 123 4567';
    case 'SS':
      return '0912 345 678';
    case 'ZM':
      return '095 5123456';
    case 'ZW':
      return '071 234 5678';
    case 'MZ':
      return '82 123 4567';
    case 'AO':
      return '923 123 456';
    case 'CM':
      return '6 71 23 45 67';
    case 'CI':
      return '01 23 456 789';
    case 'SN':
      return '77 123 45 67';
    case 'ML':
      return '65 12 34 56';
    case 'BF':
      return '70 12 34 56';
    case 'NE':
      return '90 12 34 56';
    case 'TD':
      return '63 01 23 45';
    case 'GN':
      return '601 12 34 56';
    case 'GW':
      return '955 123 456';
    case 'SL':
      return '076 123456';
    case 'LR':
      return '077 012 3456';
    case 'TG':
      return '90 12 34 56';
    case 'BJ':
      return '90 01 23 45';
    case 'GA':
      return '06 03 12 34';
    case 'CG':
      return '06 123 4567';
    case 'CD':
      return '0991 234 567';
    case 'CF':
      return '70 01 23 45';
    case 'GQ':
      return '222 123 456';
    case 'GM':
      return '301 2345';
    case 'CV':
      return '991 12 34';
    case 'ST':
      return '981 2345';
    case 'MR':
      return '22 12 34 56';
    case 'DJ':
      return '77 12 34 56';
    case 'SO':
      return '90 123 4567';
    case 'ER':
      return '07 123 456';
    case 'RW':
      return '0722 123 456';
    case 'BI':
      return '79 56 12 34';
    case 'MW':
      return '099 123 4567';
    case 'MG':
      return '032 12 345 67';
    case 'KM':
      return '321 2345';
    case 'SC':
      return '2 510 123';
    case 'MU':
      return '5712 3456';
    case 'NA':
      return '081 123 4567';
    case 'BW':
      return '71 123 456';
    case 'LS':
      return '5012 3456';
    case 'SZ':
      return '7612 3456';

    // --- Latin America & Caribbean ---
    case 'MX':
      return '1 55 1234 5678';
    case 'BR':
      return '(11) 91234-5678';
    case 'AR':
      return '11 2345-6789';
    case 'CL':
      return '9 1234 5678';
    case 'CO':
      return '321 1234567';
    case 'PE':
      return '912 345 678';
    case 'VE':
      return '0412-1234567';
    case 'EC':
      return '099 123 4567';
    case 'BO':
      return '712 34567';
    case 'PY':
      return '0981 123456';
    case 'UY':
      return '094 123 456';
    case 'GY':
      return '609 1234';
    case 'SR':
      return '741-2345';
    case 'CR':
      return '8312 3456';
    case 'PA':
      return '6123-4567';
    case 'NI':
      return '8123 4567';
    case 'HN':
      return '9123-4567';
    case 'SV':
      return '7012 3456';
    case 'GT':
      return '5123 4567';
    case 'BZ':
      return '610-1234';
    case 'CU':
      return '05 1234567';
    case 'DO':
      return '809 234 5678';
    case 'HT':
      return '34 12 3456';
    case 'JM':
      return '876 210 1234';
    case 'TT':
      return '868 291 1234';
    case 'BB':
      return '246 250 1234';
    case 'BS':
      return '242 359 1234';
    case 'GD':
      return '473 403 1234';
    case 'LC':
      return '758 284 1234';
    case 'VC':
      return '784 430 1234';
    case 'AG':
      return '268 464 1234';
    case 'DM':
      return '767 225 1234';
    case 'KN':
      return '869 765 1234';

    default:
      return 'Enter phone number';
  }
}

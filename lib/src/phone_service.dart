import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:international_phone_input/src/country.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:flutter/services.dart';

class PhoneService {
  static Country _findByCode(List<Country> countries, String code) {
    final itsNull = () => null;
    return countries.firstWhere((c) => c.dialCode == code, orElse: itsNull);
  }

  static List<Country> getPotentialCountries(
      String number, List<Country> countries) {
    if (number.length > 0) {
      final _num = number.length >= 5 ? number.substring(0, 4) : number;
      final _len = number.length >= 5 ? 4 : number.length;
      final potentialCodes = generatePotentialDialCodes(_num, _len);
      return potentialCodes
          .map((code) => _findByCode(countries, code))
          .where((element) => element != null)
          .toList();
    } else {
      return [];
    }
  }

  static List<String> generatePotentialDialCodes(String number, int length) {
    final digits = number.split('');
    String aggregate = '+';
    return digits.sublist(0, length).map((val) {
      aggregate = aggregate + val;
      return aggregate;
    }).toList();
  }

  static Future<bool> parsePhoneNumber(String number, String iso) async {
    try {
      return await PhoneNumberUtil.isValidPhoneNumber(
          phoneNumber: number, isoCode: iso);
    } on PlatformException {
      return false;
    }
  }

  static Future<String> getNormalizedPhoneNumber(
      String number, String iso) async {
    try {
      return await PhoneNumberUtil.normalizePhoneNumber(
          phoneNumber: number, isoCode: iso);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<Country>> fetchCountryData(BuildContext context) async {
    const jsonFile = 'packages/international_phone_input/assets/countries.json';
    final list = await DefaultAssetBundle.of(context).loadString(jsonFile);
    final jsonCountries = json.decode(list) as List;
    return jsonCountries.map((dynamic country) {
      Map elem = Map.from(country);
      return Country(
        name: elem['en_short_name'],
        code: elem['alpha_2_code'],
        dialCode: elem['dial_code'],
        flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png',
      );
    }).toList();
  }
}

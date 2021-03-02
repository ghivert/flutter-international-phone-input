import 'package:flutter/foundation.dart';

class Country {
  final String name;
  final String flagUri;
  final String code;
  final String dialCode;

  Country({
    @required this.name,
    @required this.code,
    @required this.flagUri,
    @required this.dialCode,
  });
}

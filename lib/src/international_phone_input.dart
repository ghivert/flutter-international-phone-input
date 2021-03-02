import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:international_phone_input/src/phone_service.dart';

import 'country.dart';

class InternationalPhoneInput extends StatefulWidget {
  final void Function(
    String phoneNumber,
    String internationalizedPhoneNumber,
    String isoCode,
    String dialCode,
  ) onPhoneNumberChange;
  final String initialPhoneNumber;
  final String initialSelection;
  final String errorText;
  final String hintText;
  final String labelText;
  final TextStyle errorStyle;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final int errorMaxLines;
  final List<String> enabledCountries;
  final InputDecoration decoration;
  final bool showCountryCodes;
  final bool showCountryFlags;
  final Widget dropdownIcon;
  final InputBorder border;
  final TextEditingController controller;
  final Color focusColor;

  InternationalPhoneInput({
    this.onPhoneNumberChange,
    this.initialPhoneNumber,
    this.initialSelection,
    this.errorText,
    this.hintText,
    this.labelText,
    this.errorStyle,
    this.hintStyle,
    this.labelStyle,
    this.enabledCountries = const [],
    this.errorMaxLines,
    this.decoration,
    this.showCountryCodes = true,
    this.showCountryFlags = true,
    this.dropdownIcon,
    this.border,
    this.controller,
    this.focusColor,
  });

  static Future<String> internationalizeNumber(String number, String iso) {
    return PhoneService.getNormalizedPhoneNumber(number, iso);
  }

  @override
  _InternationalPhoneInputState createState() =>
      _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInput> {
  Country selectedItem;
  List<Country> countries;
  bool hasError;
  TextEditingController phoneTextController;
  FocusNode focusNode;

  @override
  void initState() {
    countries = [];
    hasError = false;
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
    phoneTextController = widget.controller ?? TextEditingController()
      ..text = widget.initialPhoneNumber;
    _asyncInitState();
    super.initState();
  }

  Future<void> _asyncInitState() async {
    final data = await _fetchCountryData();
    final preSelectedItem = _findPreselectedItem(data);
    setState(() {
      countries = data;
      selectedItem = preSelectedItem;
    });
  }

  Country _findPreselectedItem(List<Country> countries) {
    if (widget.initialSelection != null) {
      final firstItem = () => countries[0];
      return countries.firstWhere(_findByCode, orElse: firstItem);
    } else {
      return countries[0];
    }
  }

  bool _findByCode(Country e) {
    final initialSelection = widget.initialSelection.toString();
    final upperSelection = widget.initialSelection.toUpperCase();
    final isCode = e.code.toUpperCase() == upperSelection;
    final isDial = e.dialCode == initialSelection;
    return isCode || isDial;
  }

  Future<void> _validatePhoneNumber() async {
    final phone = phoneTextController.text;
    final code = selectedItem.code;
    final dial = selectedItem.dialCode;
    if (phone != null && phone.isNotEmpty) {
      final isValid = await PhoneService.parsePhoneNumber(phone, code);
      setState(() => hasError = !isValid);
      if (widget.onPhoneNumberChange != null) {
        final number = await PhoneService.getNormalizedPhoneNumber(phone, code);
        final _phone = isValid ? phone : '';
        final _number = isValid ? number : '';
        widget.onPhoneNumberChange(_phone, _number, code, dial);
      }
    }
  }

  Future<List<Country>> _fetchCountryData() async {
    final list = await PhoneService.fetchCountryData(context);
    return list.where((country) {
      return widget.enabledCountries.isEmpty ||
          widget.enabledCountries.contains(country.code) ||
          widget.enabledCountries.contains(country.dialCode);
    }).toList();
  }

  Future<void> _onDropdownChanged(Country newValue) async {
    setState(() => selectedItem = newValue);
    await _validatePhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _DropdownButtonFlag(
            selectedItem: selectedItem,
            countries: countries,
            onChanged: _onDropdownChanged,
            showCountryCodes: widget.showCountryCodes,
            showCountryFlags: widget.showCountryFlags,
            dropdownIcon: widget.dropdownIcon,
            decoration: widget.decoration,
          ),
          _PhoneTextField(
            focusNode: focusNode,
            phoneTextController: phoneTextController,
            onChanged: (_) => _validatePhoneNumber(),
            hasError: hasError,
            decoration: widget.decoration,
            hintText: widget.hintText,
            labelText: widget.labelText,
            errorText: widget.errorText,
            hintStyle: widget.hintStyle,
            labelStyle: widget.labelStyle,
            errorStyle: widget.errorStyle,
            errorMaxLines: widget.errorMaxLines,
            border: widget.border,
            textColor: focusNode.hasFocus ? widget.focusColor : null,
          ),
        ],
      ),
    );
  }
}

class _PhoneTextField extends StatelessWidget {
  final TextEditingController phoneTextController;
  final bool hasError;
  final void Function(String) onChanged;
  final InputDecoration decoration;
  final String hintText;
  final String labelText;
  final String errorText;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final TextStyle errorStyle;
  final int errorMaxLines;
  final InputBorder border;
  final FocusNode focusNode;
  final Color textColor;

  const _PhoneTextField({
    Key key,
    @required this.phoneTextController,
    @required this.hasError,
    @required this.onChanged,
    @required this.decoration,
    @required this.hintText,
    @required this.labelText,
    @required this.errorText,
    @required this.hintStyle,
    @required this.labelStyle,
    @required this.errorStyle,
    @required this.errorMaxLines,
    @required this.border,
    @required this.focusNode,
    @required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const hint = 'eg. 244056345';
    const error = 'Please enter a valid phone number';
    const lines = 3;
    final defaultError = hasError ? (errorText ?? error) : null;
    final l = labelStyle.copyWith(color: textColor) ?? decoration?.labelStyle;
    return Flexible(
      child: TextField(
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.phone,
        controller: phoneTextController,
        decoration: (decoration ?? InputDecoration()).copyWith(
          labelStyle: l,
          hintText: hintText ?? decoration?.hintText ?? hint,
          labelText: labelText ?? decoration?.labelText,
          errorText: decoration?.errorText ?? defaultError,
          hintStyle: hintStyle ?? decoration?.hintStyle,
          errorStyle: errorStyle ?? decoration?.errorStyle,
          errorMaxLines: errorMaxLines ?? decoration?.errorMaxLines ?? lines,
          border: border ?? decoration?.border,
        ),
      ),
    );
  }
}

class _DropdownButtonFlag extends StatelessWidget {
  final void Function(Country) onChanged;
  final Country selectedItem;
  final List<Country> countries;
  final InputDecoration decoration;
  final Widget dropdownIcon;
  final bool showCountryFlags;
  final bool showCountryCodes;

  const _DropdownButtonFlag({
    Key key,
    @required this.selectedItem,
    @required this.countries,
    @required this.onChanged,
    @required this.decoration,
    @required this.dropdownIcon,
    @required this.showCountryFlags,
    @required this.showCountryCodes,
  }) : super(key: key);

  Widget icon() {
    return Padding(
      padding: EdgeInsets.only(bottom: (decoration != null) ? 6 : 0),
      child: dropdownIcon ?? Icon(Icons.arrow_drop_down),
    );
  }

  List<Widget> renderCountryFlag(Country country) {
    final package = 'international_phone_input';
    return [Image.asset(country.flagUri, width: 32.0, package: package)];
  }

  List<Widget> renderCountryCode(Country country) {
    return [SizedBox(width: 4), Text(country.dialCode)];
  }

  List<DropdownMenuItem<Country>> renderItems() {
    return countries.map<DropdownMenuItem<Country>>((Country value) {
      final countryFlag = showCountryFlags ? renderCountryFlag(value) : [];
      final countryCode = showCountryCodes ? renderCountryCode(value) : [];
      return DropdownMenuItem<Country>(
        value: value,
        child: Container(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[...countryFlag, ...countryCode],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: DropdownButton<Country>(
          value: selectedItem,
          icon: icon(),
          onChanged: onChanged,
          items: renderItems(),
        ),
      ),
    );
  }
}

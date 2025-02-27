import 'dart:ui' as ui;

import 'package:country_list_pick/country_selection_theme.dart';
import 'package:country_list_pick/selection_list.dart';
import 'package:country_list_pick/support/code_countries_en.dart';
import 'package:country_list_pick/support/code_country.dart';
import 'package:country_list_pick/support/code_countrys.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

export 'country_selection_theme.dart';
export 'support/code_country.dart';

class CountryListPick extends StatefulWidget {
  CountryListPick({this.onChanged, this.initialSelection, this.appBar, this.pickerBuilder, this.countryBuilder, this.theme, this.useUiOverlay = true, this.useSafeArea = false});

  final String? initialSelection;
  final ValueChanged<CountryCode?>? onChanged;
  final PreferredSizeWidget? appBar;
  final Widget Function(BuildContext context, CountryCode? countryCode)? pickerBuilder;
  final CountryTheme? theme;
  final Widget Function(BuildContext context, CountryCode countryCode)? countryBuilder;
  final bool useUiOverlay;
  final bool useSafeArea;

  @override
  _CountryListPickState createState() {
    List<Map> jsonList = this.theme?.showEnglishName ?? true ? countriesEnglish : codes;

    List elements = jsonList
        .map((s) => CountryCode(
              name: s['name'],
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: 'flags/${s['code'].toLowerCase()}.png',
            ))
        .toList();
    return _CountryListPickState(elements);
  }
}

class _CountryListPickState extends State<CountryListPick> {
  CountryCode? selectedItem;
  List elements = [];

  _CountryListPickState(this.elements);

  @override
  void initState() {
    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere((e) => (e.code.toUpperCase() == widget.initialSelection!.toUpperCase()) || (e.dialCode == widget.initialSelection), orElse: () => elements[0] as CountryCode);
    } else {
      selectedItem = elements[0];
    }

    super.initState();
  }

  void _awaitFromSelectScreen(BuildContext context, PreferredSizeWidget? appBar, CountryTheme? theme) async {
    launchSelectCountryScreen(context, theme);
  }

  Future<void> launchSelectCountryScreen(BuildContext context, CountryTheme? theme) async {
    final result = await showModalBottomSheet(
      context: context,
      shape: FigmaSquircleConst.bottomSheetShape,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQueryData.fromWindow(ui.window).padding.top + 8.0),
        child: SafeArea(
          bottom: false,
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: ShapeDecoration(
              shape: FigmaSquircleConst.bottomSheetShape,
            ),
            child: SelectionList(
              elements,
              selectedItem,
              appBar: widget.appBar ??
                  AppBar(
                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    title: Text("Select Country"),
                  ),
              theme: theme,
              countryBuilder: widget.countryBuilder,
              useUiOverlay: widget.useUiOverlay,
              useSafeArea: widget.useSafeArea,
            ),
          ),
        ),
      ),
    );
    print(result);
    setState(() {
      selectedItem = result ?? selectedItem;
      widget.onChanged!(result ?? selectedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: EdgeInsets.zero, minimumSize: Size(0, 0), alignment: Alignment.center),
      onPressed: () {
        _awaitFromSelectScreen(context, widget.appBar, widget.theme);
      },
      child: widget.pickerBuilder != null
          ? widget.pickerBuilder!(context, selectedItem)
          : Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.theme?.isShowFlag ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.asset(
                        selectedItem!.flagUri!,
                        package: 'country_list_pick',
                        width: 32.0,
                      ),
                    ),
                  ),
                if (widget.theme?.isShowCode ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(selectedItem.toString()),
                    ),
                  ),
                if (widget.theme?.isShowTitle ?? true == true)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(selectedItem!.toCountryStringOnly()),
                    ),
                  ),
                if (widget.theme?.isDownIcon ?? true == true)
                  Flexible(
                    child: Icon(Icons.keyboard_arrow_down),
                  )
              ],
            ),
    );
  }
}

class FigmaSquircleConst {
  static const bottomSheetShape = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 18, cornerSmoothing: 0.6),
      topRight: SmoothRadius(
        cornerRadius: 18,
        cornerSmoothing: 0.6,
      ),
    ),
  );

  static const bigScanButton = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 34, cornerSmoothing: 0.6),
      topRight: SmoothRadius(cornerRadius: 34, cornerSmoothing: 0.6),
      bottomLeft: SmoothRadius(cornerRadius: 34, cornerSmoothing: 0.6),
      bottomRight: SmoothRadius(cornerRadius: 34, cornerSmoothing: 0.6),
    ),
  );

  static const smallScanButton = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.6),
      topRight: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.6),
      bottomLeft: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.6),
      bottomRight: SmoothRadius(cornerRadius: 14, cornerSmoothing: 0.6),
    ),
  );

  static const itemButton = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      topRight: SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      bottomLeft: SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      bottomRight: SmoothRadius(cornerRadius: 12, cornerSmoothing: 0.6),
    ),
  );

  static const shareButton = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 28, cornerSmoothing: 0.6),
      topRight: SmoothRadius(cornerRadius: 28, cornerSmoothing: 0.6),
      bottomLeft: SmoothRadius(cornerRadius: 28, cornerSmoothing: 0.6),
      bottomRight: SmoothRadius(cornerRadius: 28, cornerSmoothing: 0.6),
    ),
  );

  static const privacyButton = SmoothRectangleBorder(
    borderRadius: SmoothBorderRadius.only(
      topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
      topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
      bottomLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
      bottomRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
    ),
  );

  static final SmoothBorderRadius scanCameraPreview = SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.6);
  static final SmoothBorderRadius photoCameraPreview = SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6);
}

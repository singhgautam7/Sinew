// Immutable asset model and lazy loader for figure style, rig, and props.
//
// Parsed once, lazily, the first time a figure is rendered (never at startup).

import 'dart:convert';

import 'package:flutter/services.dart';

class FigureAssets {
  const FigureAssets({
    required this.style,
    required this.rig,
    required this.props,
  });

  final Map<String, dynamic> style;
  final Map<String, dynamic> rig;
  final Map<String, dynamic> props;

  static FigureAssets? _instance;

  static Future<FigureAssets> load() async {
    if (_instance != null) return _instance!;

    final String styleStr = await rootBundle.loadString('assets/figure/figure_style.json');
    final String rigStr = await rootBundle.loadString('assets/figure/rig.json');
    final String propsStr = await rootBundle.loadString('assets/figure/props.json');

    final Map<String, dynamic> style = jsonDecode(styleStr) as Map<String, dynamic>;
    final Map<String, dynamic> rig = jsonDecode(rigStr) as Map<String, dynamic>;
    final Map<String, dynamic> props = jsonDecode(propsStr) as Map<String, dynamic>;

    _instance = FigureAssets(style: style, rig: rig, props: props);
    return _instance!;
  }

  static void resetForTest() {
    _instance = null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/theme/app_theme.dart';

/// Pumps [child] in a themed [MaterialApp] (Sinew light by default) inside a
/// [Scaffold]. [textScale] and [size] model a phone.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Tone tone = Tone.light,
  double textScale = 1,
  Size size = const Size(360, 780),
  bool scaffold = true,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.of(Tone.light),
      darkTheme: AppTheme.of(tone == Tone.light ? Tone.dark : tone),
      themeMode: tone == Tone.light ? ThemeMode.light : ThemeMode.dark,
      builder: (BuildContext context, Widget? w) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: w!,
      ),
      home: scaffold ? Scaffold(body: Center(child: child)) : child,
    ),
  );
}

/// A button that runs [onTap] with its own context, for opening sheets,
/// dialogs and menus from a test.
class Opener extends StatelessWidget {
  const Opener({super.key, required this.onTap, this.label = 'open'});

  final void Function(BuildContext context) onTap;
  final String label;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => onTap(context), child: Text(label));
}

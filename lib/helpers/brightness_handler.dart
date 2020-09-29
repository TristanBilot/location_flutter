import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class BrightnessHandler with WidgetsBindingObserver {
  BuildContext _context;

  BrightnessHandler(this._context) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    Provider.of<ThemeNotifier>(_context, listen: false).setTheme(brightness);
  }
}

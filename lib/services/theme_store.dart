import 'package:flutter/material.dart';

class ThemeStore {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static bool get isDark =>
      themeMode.value == ThemeMode.dark;

  static void setDarkMode(bool enabled) {
    themeMode.value =
        enabled ? ThemeMode.dark : ThemeMode.light;
  }
}

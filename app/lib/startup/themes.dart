import 'package:flutter/material.dart';
import 'package:tictactoe/common/utils.dart';

ThemeData buildTheme(Brightness brightness) {
  final scheme =
      ColorScheme.fromSeed(seedColor: Colors.pink, brightness: brightness);
  final roundedRect = RoundedRectangleBorder(
    borderRadius: defaultBorderRadius,
  );
  return ThemeData.from(colorScheme: scheme, useMaterial3: true).copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: roundedRect,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: roundedRect,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: roundedRect,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: roundedRect),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      isDense: true,
      alignLabelWithHint: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: scheme.outline.withOpacity(0.1),
      focusColor: scheme.outline.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: defaultBorderRadius,
        borderSide: BorderSide(
          color: scheme.error,
        ),
      ),
    ),
    splashFactory: NoSplash.splashFactory,
  );
}

import 'package:flutter/material.dart';

const kMobileThresholdWidth = 1000;

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
  });

  final WidgetBuilder mobileBuilder, desktopBuilder;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > kMobileThresholdWidth
        ? desktopBuilder(context)
        : mobileBuilder(context);
  }
}

T responsiveValue<T>(BuildContext context,
        {required T mobileValue, required T desktopValue}) =>
    MediaQuery.of(context).size.width > kMobileThresholdWidth
        ? desktopValue
        : mobileValue;

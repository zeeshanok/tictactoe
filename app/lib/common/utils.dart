import 'dart:math';

import 'package:flutter/material.dart';

const _abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";

final defaultBorderRadius = BorderRadius.circular(8);

String getRandomString(int length) {
  final r = Random.secure();
  return List.generate(length, (_) => _abc[r.nextInt(_abc.length)]).join('');
}

/// Class that notifies its listeners when any of the provided notifiers have
/// notified a change
class CombineChangeNotifiers extends ChangeNotifier {
  CombineChangeNotifiers(List<ChangeNotifier> notifiers) {
    for (final notifier in notifiers) {
      notifier.addListener(notifyListeners);
    }
  }
}

// Key used to show snackbars globally
final snackbarKey = GlobalKey<ScaffoldMessengerState>();

void globalNotify(String message) {
  snackbarKey.currentState?.showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
  ));
}

extension BoolUtils on bool {
  bool xor(bool b) => (this && !b) || (!this && b);
}

String plural(int howMany, String noun) {
  return howMany == 1 ? noun : "${noun}s";
}

String formatDuration(Duration duration, {bool showSeconds = false}) {
  final days = duration.inDays;
  final hours = duration.inHours - days * 24;
  final minutes = duration.inMinutes - duration.inHours * 60;
  final seconds = duration.inSeconds - duration.inMinutes * 60;

  final d = plural(days, "day");
  final h = plural(hours, "hour");
  final m = plural(minutes, "min");

  final buffer = StringBuffer();

  if (days > 0) buffer.write("$days $d ");
  if (hours > 0) buffer.write("$hours $h ");
  if (minutes > 0) buffer.write("$minutes $m ");
  if (buffer.isEmpty || (seconds >= 0 && showSeconds)) {
    buffer.write("${seconds}s ");
  }

  return buffer.toString().trimRight();
}

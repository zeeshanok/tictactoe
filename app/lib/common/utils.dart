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

import 'dart:math';

import 'package:flutter/foundation.dart';

const _abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";

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

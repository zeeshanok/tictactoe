import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/common/utils.dart';

const serverAliveCheckInterval = 13;

class ServerStatusService extends ChangeNotifier {
  bool get isAlive => _isAlive ?? false;
  bool? _isAlive;

  void _setAlive(bool value) {
    if (value != _isAlive) {
      _isAlive = value;
      if (value) {
        _aliveCompleter.complete();
        _aliveCompleter = Completer();
      } else {
        globalNotify("We are having trouble connecting to the server");
      }
      notifyListeners();
    }
  }

  Completer<void> _aliveCompleter = Completer();

  final _dio = Dio(BaseOptions(validateStatus: (status) => true));

  Future<void> waitForServerAlive() {
    return _aliveCompleter.future;
  }

  void initialise() {
    runCheck();
    Timer.periodic(serverAliveCheckInterval.seconds, (timer) async {
      runCheck();
    });
  }

  void runCheck() async {
    try {
      final result = await _dio.get('${serverUrl()}/status');
      _setAlive(result.statusCode == 200);
    } catch (_) {
      _setAlive(false);
    }
  }
}

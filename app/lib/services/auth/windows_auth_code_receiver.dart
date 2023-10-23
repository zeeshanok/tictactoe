import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tictactoe/services/auth/auth_service.dart';

const _responseHtml = """
<html>
<head>
  <style>body{font-family: sans-serif;}</style>
  <title>TicTacToe</title>
</head>
<body>
  <center>You can go back to the tictactoe app now</center>
</body></html>
""";

const _port = 8080;

Future<String?> _receiveSessionToken(Duration timeout) async {
  final server = await HttpServer.bind('localhost', _port);

  debugPrint("started server");

  try {
    final stream = server.timeout(timeout);

    final request = await stream.first;
    final res = request.response;
    final params = request.requestedUri.queryParameters;
    final sessionToken = params['session_token'];
    if (sessionToken == null) {
      throw AuthException("Did not receive session token");
    }

    res.statusCode = HttpStatus.ok;
    res.headers.contentType = ContentType.html;
    res.write(_responseHtml);

    await res.close();
    return sessionToken;
  } on TimeoutException {
    debugPrint("timed out");
  } on AuthException {
    debugPrint("failed to authorise");
  } finally {
    debugPrint("stopped server");
    server.close();
  }
  return null;
}

class SessionTokenReceiver {
  /// Start a temporary http server and wait for the user to be redirected
  /// to it. On redirection, the server captures the session token
  /// that the server provides.
  static Future<String?> receive(
      {Duration timeout = const Duration(minutes: 2)}) async {
    return compute(_receiveSessionToken, timeout);
  }
}

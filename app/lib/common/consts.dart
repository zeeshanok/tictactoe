import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Returns url of the main tictactoe server
String serverUrl() => defaultTargetPlatform == TargetPlatform.android
    ? dotenv.env['MOBILE_SERVER_URL']!
    : dotenv.env['DESKTOP_SERVER_URL']!;

/// Returns url of the websocket server
String websocketUrl() => defaultTargetPlatform == TargetPlatform.android
    ? dotenv.env['MOBILE_WEBSOCKET_URL']!
    : dotenv.env['DESKTOP_WEBSOCKET_URL']!;

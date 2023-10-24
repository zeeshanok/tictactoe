import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String serverUrl() => defaultTargetPlatform == TargetPlatform.android
    ? dotenv.env['MOBILE_SERVER_URL']!
    : dotenv.env['DESKTOP_SERVER_URL']!;

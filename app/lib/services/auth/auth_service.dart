import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tictactoe/common/consts.dart';
import 'package:tictactoe/services/auth/windows_auth_code_receiver.dart';
import 'package:tictactoe/preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final _dio = Dio(BaseOptions(baseUrl: serverUrl()));

/// Attempt to login with a locally saved session token.
Future<bool> _attemptSessionLogin() async {
  final prefs = GetIt.instance<LocalPreferences>();
  final token = prefs.sessionToken;
  if (token == null) return false;

  final res = await _dio.post('/auth',
      options: Options(
        headers: {'authorization': 'Bearer $token'},
        validateStatus: (status) => true,
      ));
  final success = res.statusCode == 200;
  if (!success) {
    // remove session code that does not work
    prefs.setSessionToken(null);
  }
  return success;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() {
    return "AuthException: $message";
  }
}

/// Get platform dependent AuthService
AuthService getAuthService() {
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) {
    return AndroidWebAuthService();
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    return WindowsAuthService();
  }
  throw UnsupportedError(
      "The current platform does not support authentication");
}

/// Service that manages the apps authentication state.
abstract class AuthService extends ChangeNotifier {
  /// Whether the user is in a signed in state
  bool get isAuthed;

  /// Whether the `AuthService` is ready to attempt a browser/one-tap
  /// sign in. This value is set to `true` after the `AuthService` has
  /// attempted a signin from locally saved credentials
  /// (eg. session tokens)
  bool get isInitialised;

  /// Attempt sign in. Returns true for a successful sign in
  Future<bool> signIn();
  Future<void> signOut();

  /// To be called when the app is ready to listen to auth changets
  Future<void> start();
}

/// `AuthService` that launches an OAuth window on the users default browser
/// to authenticate with the server.
class WindowsAuthService extends ChangeNotifier implements AuthService {
  late LocalPreferences _prefs;

  @override
  bool get isAuthed => _isAuthed;
  void _setIsAuthed(bool val) {
    _isAuthed = val;
    if (_isAuthed) {
      _dio.options.headers['authorization'] = "Bearer ${_prefs.sessionToken}";
    }
    notifyListeners();
  }

  bool _isAuthed;

  @override
  bool get isInitialised => _isInitialised;
  void _setIsInitialised(bool val) {
    _isInitialised = val;
    notifyListeners();
  }

  bool _isInitialised;

  WindowsAuthService()
      : _isAuthed = false,
        _isInitialised = false;

  @override
  Future<void> start() async {
    _prefs = GetIt.instance<LocalPreferences>();
    if (await _attemptSessionLogin()) {
      _setIsAuthed(true);
    }
    _setIsInitialised(true);
  }

  @override
  Future<bool> signIn() async {
    return await _signInWithServer();
  }

  Future<bool> _signInWithServer() async {
    await launchUrl(Uri.parse('${serverUrl()}/auth'),
        mode: LaunchMode.externalApplication);
    final sessionToken = await SessionTokenReceiver.receive();

    if (sessionToken != null) {
      await _prefs.setSessionToken(sessionToken);
      _setIsAuthed(true);
      return true;
    }
    _setIsAuthed(false);
    return false;
  }

  @override
  Future<void> signOut() async {
    final res = await _dio.delete('/auth');
    if (res.statusCode == 200) {
      await _prefs.setSessionToken(null);
      _setIsAuthed(false);
    }
  }
}

/// `AuthService` that uses Google One-Tap sign in on android
/// and Google's silent sign in on web.
class AndroidWebAuthService extends ChangeNotifier implements AuthService {
  late LocalPreferences _prefs;
  @override
  bool get isAuthed => _isAuthed;
  void _setIsAuthed(bool val) {
    _isAuthed = val;
    if (_isAuthed) {
      _dio.options.headers['authorization'] = "Bearer ${_prefs.sessionToken}";
    }
    notifyListeners();
  }

  bool _isAuthed;

  @override
  bool get isInitialised => _isInitialised;
  void _setIsInitialised(bool val) {
    _isInitialised = val;
    notifyListeners();
  }

  bool _isInitialised;

  final googleSignIn = GoogleSignIn(scopes: ['email', 'profile', 'openid']);

  AndroidWebAuthService()
      : _isAuthed = false,
        _isInitialised = false;

  @override
  Future<void> start() async {
    _prefs = GetIt.instance<LocalPreferences>();
    if (await _attemptSessionLogin()) {
      _setIsAuthed(true);
    } else {
      final acc = await googleSignIn.signInSilently();
      if (acc != null) {
        final token =
            await _getSessionToken((await acc.authentication).accessToken!);

        if (token != null) {
          _setIsAuthed(true);
        }
      }
    }
    _setIsInitialised(true);
  }

  @override
  Future<bool> signIn() async {
    final acc = await googleSignIn.signIn();
    if (acc == null) return false;
    final token =
        await _getSessionToken((await acc.authentication).accessToken!);

    if (token != null) {
      _setIsAuthed(true);
      return true;
    }
    return false;
  }

  Future<String?> _getSessionToken(String accessToken) async {
    final Response<Map> response = await _dio.post('/auth/direct', data: {
      "access_token": accessToken,
    });
    debugPrint(response.data.toString());
    if (response.statusCode == 200) {
      final token = response.data!['sessionToken'] as String;
      _prefs.setSessionToken(token);
      return token;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    final res = await _dio.delete('/auth');
    if (res.statusCode == 200) {
      googleSignIn.disconnect();
      await _prefs.setSessionToken(null);
      _setIsAuthed(false);
    }
  }
}

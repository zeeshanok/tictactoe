import 'package:shared_preferences/shared_preferences.dart';

const _sessionToken = 'sessionToken';

/// Class wrapping all the locally stored preferences used
/// by the app.
class LocalPreferences {
  late SharedPreferences _prefs;

  String? get sessionToken => _prefs.getString(_sessionToken);
  Future<void> setSessionToken(String? val) async {
    if (val == null) {
      await _prefs.remove(_sessionToken);
    } else {
      await _prefs.setString(_sessionToken, val);
    }
  }

  Future<void> initialise() async {
    _prefs = await SharedPreferences.getInstance();
  }
}

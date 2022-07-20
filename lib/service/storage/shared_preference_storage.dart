import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceStorage {
  saveFCMKey(String fcmKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FCMKey', fcmKey);
  }

  Future<String?> getFCMKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fcmKey = prefs.getString('FCMKey');
    return fcmKey;
  }

  saveFCMData(String fcmData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FCMData', fcmData);
  }

  Future<String?> getFCMData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fcmData = prefs.getString('FCMData');
    return fcmData;
  }
}

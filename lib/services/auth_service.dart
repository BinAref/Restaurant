import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _phoneKey = 'user_phone';
  static const String _isRegisteredKey = 'is_registered';

  // محاكاة إرسال OTP
  static Future<String> sendOTP(String phoneNumber) async {
    // تأخير لمحاكاة الشبكة
    await Future.delayed(Duration(seconds: 2));

    // توليد OTP عشوائي
    final random = Random();
    final otp = (1000 + random.nextInt(9000)).toString();

    // في التطبيق الحقيقي، سنرسل هذا عبر SMS
    print('OTP المرسل إلى $phoneNumber: $otp');

    // حفظ OTP مؤقتاً (في التطبيق الحقيقي لن نفعل هذا!)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_otp_$phoneNumber', otp);

    return otp;
  }

  // التحقق من OTP
  static Future<bool> verifyOTP(String phoneNumber, String enteredOTP) async {
    await Future.delayed(Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final savedOTP = prefs.getString('temp_otp_$phoneNumber');

    if (savedOTP == enteredOTP) {
      // حفظ الهاتف كمسجل
      await prefs.setString(_phoneKey, phoneNumber);
      await prefs.setBool(_isRegisteredKey, true);

      // حذف OTP المؤقت
      await prefs.remove('temp_otp_$phoneNumber');

      // محاكاة API call
      await _registerPhoneWithAPI(phoneNumber);

      return true;
    }

    return false;
  }

  // التحقق من تسجيل الهاتف محلياً
  static Future<bool> isPhoneRegistered(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString(_phoneKey);
    final isRegistered = prefs.getBool(_isRegisteredKey) ?? false;

    return savedPhone == phoneNumber && isRegistered;
  }

  // الحصول على الهاتف المحفوظ
  static Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  // محاكاة API call لتسجيل الهاتف
  static Future<void> _registerPhoneWithAPI(String phoneNumber) async {
    await Future.delayed(Duration(seconds: 1));

    // محاكاة POST request
    final requestBody = {
      'phone': phoneNumber,
      'timestamp': DateTime.now().toIso8601String(),
      'device_type': 'mobile',
    };

    print('تم إرسال بيانات التسجيل إلى API: $requestBody');

    // في التطبيق الحقيقي:
    // final response = await http.post(
    //   Uri.parse('${dotenv.env['API_BASE_URL']}/verify-phone'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(requestBody),
    // );
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
    await prefs.remove(_isRegisteredKey);
  }
}

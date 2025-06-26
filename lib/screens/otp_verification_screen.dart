import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedLanguage;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendTimer();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.selectedLanguage == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lightCream,
                AppColors.background,
                AppColors.cream,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // AppBar مخصص
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          isRTL ? Icons.arrow_forward : Icons.arrow_back,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48), // لتوازن الـ IconButton
                    ],
                  ),

                  Expanded(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // أيقونة التحقق مع تصميم عربي
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryGold,
                                      AppColors.darkGold
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGold
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.sms_outlined,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(height: 40),

                              // العنوان
                              Text(
                                _getMainTitle(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 16),

                              // رقم الهاتف
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        AppColors.primaryGold.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '+90 ${widget.phoneNumber}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16),

                              Text(
                                _getSubtitle(),
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 40),

                              // حقل OTP مع تصميم عربي
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Pinput(
                                  controller: _otpController,
                                  length: 4,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  defaultPinTheme: PinTheme(
                                    width: 60,
                                    height: 60,
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.lightGold,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGold
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: 60,
                                    height: 60,
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.primaryGold,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGold
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onCompleted: _verifyOTP,
                                ),
                              ),

                              if (_errorMessage != null) ...[
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.traditionalRed
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.traditionalRed
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.traditionalRed,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: AppColors.traditionalRed,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: 32),

                              // زر إعادة الإرسال
                              TextButton(
                                onPressed:
                                    _resendCountdown == 0 && !_isResending
                                        ? _resendOTP
                                        : null,
                                child: _isResending
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryGreen,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _resendCountdown > 0
                                            ? '${_getResendText()} $_resendCountdown'
                                            : _getResendButtonText(),
                                        style: TextStyle(
                                          color: _resendCountdown == 0
                                              ? AppColors.primaryGreen
                                              : AppColors.textLight,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // زر التحقق
                  if (_isLoading)
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.darkGreen],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _otpController.text.length == 4
                            ? () => _verifyOTP(_otpController.text)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          _getVerifyButtonText(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP(String otp) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = await AuthService.verifyOTP(widget.phoneNumber, otp);

      if (isValid) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNumber: widget.phoneNumber,
              selectedLanguage: widget.selectedLanguage,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = _getErrorMessage();
          _otpController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    try {
      await AuthService.sendOTP(widget.phoneNumber);
      setState(() {
        _resendCountdown = 60;
        _errorMessage = null;
      });
      _startResendTimer();
    } catch (e) {
      setState(() {
        _errorMessage = _getNetworkErrorMessage();
      });
    } finally {
      setState(() => _isResending = false);
    }
  }

  String _getTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'رمز التحقق';
      case 'tr':
        return 'Doğrulama Kodu';
      default:
        return 'Verification Code';
    }
  }

  String _getMainTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل رمز التحقق';
      case 'tr':
        return 'Doğrulama Kodunu Girin';
      default:
        return 'Enter Verification Code';
    }
  }

  String _getSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل الرمز المكون من 4 أرقام المرسل إلى هاتفك';
      case 'tr':
        return 'Telefonunuza gönderilen 4 haneli kodu girin';
      default:
        return 'Enter the 4-digit code sent to your phone';
    }
  }

  String _getVerifyButtonText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تحقق';
      case 'tr':
        return 'Doğrula';
      default:
        return 'Verify';
    }
  }

  String _getResendText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إعادة الإرسال خلال';
      case 'tr':
        return 'Yeniden gönder';
      default:
        return 'Resend in';
    }
  }

  String _getResendButtonText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إعادة إرسال الرمز';
      case 'tr':
        return 'Kodu Yeniden Gönder';
      default:
        return 'Resend Code';
    }
  }

  String _getErrorMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'رمز التحقق غير صحيح';
      case 'tr':
        return 'Doğrulama kodu yanlış';
      default:
        return 'Invalid verification code';
    }
  }

  String _getNetworkErrorMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'خطأ في الشبكة، حاول مرة أخرى';
      case 'tr':
        return 'Ağ hatası, tekrar deneyin';
      default:
        return 'Network error, please try again';
    }
  }
}

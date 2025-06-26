import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  final String selectedLanguage;

  const PhoneNumberScreen({
    Key? key,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPhoneValid = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _phoneController.addListener(_validatePhone);
    _checkExistingUser();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _checkExistingUser() async {
    final savedPhone = await AuthService.getSavedPhone();
    if (savedPhone != null) {
      _phoneController.text = _formatPhoneNumber(savedPhone);
    }
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isPhoneValid = phone.length == 10 && phone.startsWith('5');
      _errorMessage = null;
    });
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
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // أيقونة الهاتف مع تصميم عربي كلاسيكي
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryGold,
                                        AppColors.darkGold
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(70),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGold
                                            .withOpacity(0.4),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // نمط هندسي عربي في الخلفية
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.phone_android,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 40),

                                // العنوان
                                Text(
                                  _getWelcomeText(),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 12),

                                Text(
                                  _getSubtitleText(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textLight,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 50),

                                // حقل رقم الهاتف مع تصميم عربي
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _isPhoneValid
                                            ? AppColors.primaryGold
                                            : AppColors.lightGold,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // رمز البلد مع تصميم جميل
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGold
                                                .withOpacity(0.2),
                                            borderRadius: isRTL
                                                ? BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18),
                                                    bottomRight:
                                                        Radius.circular(18),
                                                  )
                                                : BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(18),
                                                    bottomLeft:
                                                        Radius.circular(18),
                                                  ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: Container(
                                                    color: Colors.red,
                                                    child: Center(
                                                      child: Text(
                                                        '🇹🇷',
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                '+90',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // حقل الإدخال
                                        Expanded(
                                          child: TextField(
                                            controller: _phoneController,
                                            keyboardType: TextInputType.phone,
                                            textDirection: TextDirection.ltr,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  10),
                                              _PhoneNumberFormatter(),
                                            ],
                                            decoration: InputDecoration(
                                              hintText: _getPhoneHint(),
                                              hintStyle: TextStyle(
                                                color: AppColors.textLight
                                                    .withOpacity(0.6),
                                                fontSize: 16,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(20),
                                            ),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),

                                        // أيقونة التحقق
                                        if (_isPhoneValid)
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 20, left: 20),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: AppColors.primaryGreen,
                                              size: 24,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),

                                // رسالة المساعدة أو الخطأ
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _errorMessage != null
                                        ? AppColors.traditionalRed
                                            .withOpacity(0.1)
                                        : AppColors.primaryGold
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _errorMessage != null
                                          ? AppColors.traditionalRed
                                              .withOpacity(0.3)
                                          : AppColors.primaryGold
                                              .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _errorMessage != null
                                            ? Icons.error_outline
                                            : Icons.info_outline,
                                        color: _errorMessage != null
                                            ? AppColors.traditionalRed
                                            : AppColors.primaryGold,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage ?? _getHelpText(),
                                          style: TextStyle(
                                            color: _errorMessage != null
                                                ? AppColors.traditionalRed
                                                : AppColors.textLight,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // زر المتابعة
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _isPhoneValid
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isPhoneValid && !_isLoading
                            ? _continueToNextStep
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: _isPhoneValid ? 5 : 0,
                          disabledBackgroundColor:
                              AppColors.textLight.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getContinueButtonText(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    widget.selectedLanguage == 'ar'
                                        ? Icons.arrow_back
                                        : Icons.arrow_forward,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueToNextStep() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = _phoneController.text.replaceAll(' ', '');

      // التحقق من وجود الرقم محلياً
      final isRegistered = await AuthService.isPhoneRegistered(phoneNumber);

      if (isRegistered) {
        // المستخدم مسجل، الانتقال مباشرة إلى الشاشة الرئيسية
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNumber: phoneNumber,
              selectedLanguage: widget.selectedLanguage,
            ),
          ),
        );
      } else {
        // مستخدم جديد، إرسال OTP
        await AuthService.sendOTP(phoneNumber);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: phoneNumber,
              selectedLanguage: widget.selectedLanguage,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getNetworkErrorMessage();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'رقم الهاتف';
      case 'tr':
        return 'Telefon Numarası';
      default:
        return 'Phone Number';
    }
  }

  String _getWelcomeText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أهلاً وسهلاً';
      case 'tr':
        return 'Hoş Geldiniz';
      default:
        return 'Welcome';
    }
  }

  String _getSubtitleText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل رقم هاتفك للوصول إلى\nقائمة الطعام اللذيذة';
      case 'tr':
        return 'Lezzetli menümüze erişmek için\ntelefon numaranızı girin';
      default:
        return 'Enter your phone number to access\nour delicious menu';
    }
  }

  String _getPhoneHint() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return '5XX XXX XX XX';
      case 'tr':
        return '5XX XXX XX XX';
      default:
        return '5XX XXX XX XX';
    }
  }

  String _getHelpText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل رقم هاتف تركي صحيح يبدأ بـ 5';
      case 'tr':
        return '5 ile başlayan geçerli bir Türk telefon numarası girin';
      default:
        return 'Enter a valid Turkish phone number starting with 5';
    }
  }

  String _getContinueButtonText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'متابعة';
      case 'tr':
        return 'Devam Et';
      default:
        return 'Continue';
    }
  }

  String _getNetworkErrorMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'خطأ في الاتصال، حاول مرة أخرى';
      case 'tr':
        return 'Bağlantı hatası, tekrar deneyin';
      default:
        return 'Connection error, please try again';
    }
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)} ${text.substring(3)}',
        selection: TextSelection.collapsed(
          offset: text.length + 1,
        ),
      );
    } else if (text.length <= 8) {
      return newValue.copyWith(
        text:
            '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6)}',
        selection: TextSelection.collapsed(
          offset: text.length + 2,
        ),
      );
    } else {
      return newValue.copyWith(
        text:
            '${text.substring(0, 3)} ${text.substring(3, 6)} ${text.substring(6, 8)} ${text.substring(8)}',
        selection: TextSelection.collapsed(
          offset: text.length + 3,
        ),
      );
    }
  }
}

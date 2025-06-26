import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'phone_number_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedLanguage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            48,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // شعار التطبيق مع تصميم عربي كلاسيكي
                          Container(
                            width: isSmallScreen ? 120 : 160,
                            height: isSmallScreen ? 120 : 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  AppColors.darkGold
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 60 : 80),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // أنماط هندسية عربية
                                Container(
                                  width: isSmallScreen ? 90 : 120,
                                  height: isSmallScreen ? 90 : 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        isSmallScreen ? 45 : 60),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 60 : 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        isSmallScreen ? 30 : 40),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.restaurant_menu,
                                  size: isSmallScreen ? 50 : 70,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          // عنوان التطبيق
                          Column(
                            children: [
                              Text(
                                'مطعم الأصالة',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 24 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primaryGold
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Asalet Restaurant',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Authentic Restaurant',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryGold.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'اختر اللغة - Dil Seçin - Select Language',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // أزرار اللغات
                          Column(
                            children: [
                              _buildLanguageButton(
                                'العربية',
                                '🇸🇦',
                                'ar',
                                'اللغة العربية',
                                isSmallScreen,
                              ),
                              SizedBox(height: 12),
                              _buildLanguageButton(
                                'Türkçe',
                                '🇹🇷',
                                'tr',
                                'Türk Dili',
                                isSmallScreen,
                              ),
                              SizedBox(height: 12),
                              _buildLanguageButton(
                                'English',
                                '🇺🇸',
                                'en',
                                'English Language',
                                isSmallScreen,
                              ),
                            ],
                          ),

                          // زر المتابعة
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: selectedLanguage != null
                                ? (isSmallScreen ? 50 : 60)
                                : 0,
                            child: selectedLanguage != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGreen
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: isSmallScreen ? 50 : 60,
                                      child: ElevatedButton(
                                        onPressed: _navigateToPhoneScreen,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryGreen,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _getNextButtonText(),
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 16 : 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              _getNextButtonIcon(),
                                              size: isSmallScreen ? 18 : 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),

                          // معلومات التطبيق
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.lightGold.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: AppColors.primaryGold,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'تطبيق طلب الطعام للمطاعم العربية',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: isSmallScreen ? 10 : 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    String language,
    String flag,
    String languageCode,
    String description,
    bool isSmallScreen,
  ) {
    final isSelected = selectedLanguage == languageCode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 60 : 70,
        child: OutlinedButton(
          onPressed: () => setState(() => selectedLanguage = languageCode),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? AppColors.primaryGold.withOpacity(0.1)
                : Colors.white,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryGold
                  : AppColors.lightGold.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 16 : 20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 16 : 20),
                    child: Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Text(
                          flag,
                          style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: isSmallScreen ? 24 : 28,
                    height: isSmallScreen ? 24 : 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius:
                          BorderRadius.circular(isSmallScreen ? 12 : 14),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNextButtonText() {
    switch (selectedLanguage) {
      case 'ar':
        return 'التالي';
      case 'tr':
        return 'İleri';
      default:
        return 'Next';
    }
  }

  IconData _getNextButtonIcon() {
    return selectedLanguage == 'ar' ? Icons.arrow_back : Icons.arrow_forward;
  }

  void _navigateToPhoneScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PhoneNumberScreen(
          selectedLanguage: selectedLanguage!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'language_selection_screen.dart';
import 'menu_screen.dart';
import 'offers_screen.dart';
import 'previous_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedLanguage;

  const HomeScreen({
    Key? key,
    required this.phoneNumber,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
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

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    Future.delayed(Duration(milliseconds: 600), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.selectedLanguage == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth <= 600;

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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // AppBar مخصص
                          _buildCustomAppBar(isRTL, isMobile),

                          SizedBox(height: isMobile ? 20 : 30),

                          // رسالة الترحيب
                          _buildWelcomeSection(isMobile, isRTL),

                          SizedBox(height: isMobile ? 30 : 40),

                          // الأزرار الرئيسية
                          AnimatedBuilder(
                            animation: _cardAnimationController,
                            builder: (context, child) {
                              return _buildMainButtons(
                                  isMobile, isTablet, isRTL);
                            },
                          ),

                          SizedBox(height: isMobile ? 30 : 40),

                          // قسم الإحصائيات
                          _buildStatsSection(isMobile, isRTL),

                          SizedBox(height: isMobile ? 20 : 30),

                          // معلومات التطبيق
                          _buildAppInfo(isMobile),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isRTL, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: [
          // أيقونة المطعم
          Container(
            width: isMobile ? 40 : 50,
            height: isMobile ? 40 : 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold, AppColors.darkGold],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: isMobile ? 20 : 25,
            ),
          ),

          SizedBox(width: 12),

          // عنوان المطعم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRestaurantName(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _getRestaurantSubtitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // زر القائمة
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.primaryGreen,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.traditionalRed),
                    SizedBox(width: 8),
                    Text(_getLogoutText()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isMobile, bool isRTL) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withOpacity(0.1),
            AppColors.lightGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // أيقونة الترحيب
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.darkGreen],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 30 : 40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              Icons.waving_hand,
              color: Colors.white,
              size: isMobile ? 30 : 40,
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // رسالة الترحيب
          Text(
            _getWelcomeMessage(),
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          // رقم الهاتف
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone,
                  color: AppColors.primaryGreen,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: 8),
                Text(
                  '+90 ${_formatPhoneNumber(widget.phoneNumber)}',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButtons(bool isMobile, bool isTablet, bool isRTL) {
    final buttons = [
      _MainButtonData(
        title: _getStartOrderText(),
        subtitle: _getStartOrderSubtitle(),
        icon: Icons.restaurant,
        gradient: [AppColors.primaryGreen, AppColors.darkGreen],
        onTap: () => _navigateToMenu(),
      ),
      _MainButtonData(
        title: _getOffersText(),
        subtitle: _getOffersSubtitle(),
        icon: Icons.local_offer,
        gradient: [AppColors.primaryGold, AppColors.darkGold],
        onTap: () => _navigateToOffers(),
      ),
      _MainButtonData(
        title: _getFavoriteOrdersText(),
        subtitle: _getFavoriteOrdersSubtitle(),
        icon: Icons.favorite,
        gradient: [AppColors.traditionalRed, AppColors.darkRed],
        onTap: () => _navigateToPreviousOrders(),
      ),
    ];

    if (isTablet) {
      // تخطيط أفقي للتابلت
      return Row(
        children: buttons
            .map(
              (button) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _buildMainButton(button, isMobile, isRTL),
                ),
              ),
            )
            .toList(),
      );
    } else {
      // تخطيط عمودي للموبايل
      return Column(
        children: buttons
            .map(
              (button) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildMainButton(button, isMobile, isRTL),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildMainButton(
      _MainButtonData buttonData, bool isMobile, bool isRTL) {
    return Transform.scale(
      scale: _cardAnimation.value,
      child: Container(
        width: double.infinity,
        height: isMobile ? 100 : 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: buttonData.gradient[0].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: buttonData.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: buttonData.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Row(
                  children: [
                    // أيقونة
                    Container(
                      width: isMobile ? 50 : 60,
                      height: isMobile ? 50 : 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isMobile ? 25 : 30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        buttonData.icon,
                        color: Colors.white,
                        size: isMobile ? 25 : 30,
                      ),
                    ),

                    SizedBox(width: isMobile ? 12 : 16),

                    // النصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonData.title,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            buttonData.subtitle,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // سهم
                    Icon(
                      isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile, bool isRTL) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getStatsTitle(),
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              _buildStatItem(
                _getTotalOrdersText(),
                '12',
                Icons.shopping_bag,
                AppColors.primaryGreen,
                isMobile,
              ),
              _buildStatItem(
                _getFavoriteItemsText(),
                '5',
                Icons.favorite,
                AppColors.traditionalRed,
                isMobile,
              ),
              _buildStatItem(
                _getPointsText(),
                '248',
                Icons.stars,
                AppColors.primaryGold,
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: isMobile ? 40 : 50,
            height: isMobile ? 40 : 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
            ),
            child: Icon(
              icon,
              color: color,
              size: isMobile ? 20 : 25,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.lightGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            color: AppColors.primaryGold,
            size: isMobile ? 16 : 20,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              _getAppVersionText(),
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: isMobile ? 10 : 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  void _navigateToMenu() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          selectedLanguage: widget.selectedLanguage,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  void _navigateToOffers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OffersScreen(
          selectedLanguage: widget.selectedLanguage,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  void _navigateToPreviousOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviousOrdersScreen(
          selectedLanguage: widget.selectedLanguage,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _getLogoutTitle(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            _getLogoutMessage(),
            style: TextStyle(
              color: AppColors.textLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _getCancelText(),
                style: TextStyle(
                  color: AppColors.textLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectionScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.traditionalRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _getLogoutText(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // النصوص المترجمة
  String _getRestaurantName() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'مطعم الأصالة';
      case 'tr':
        return 'Asalet Restaurant';
      default:
        return 'Authentic Restaurant';
    }
  }

  String _getRestaurantSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الطعم الأصيل';
      case 'tr':
        return 'Özgün Lezzet';
      default:
        return 'Authentic Taste';
    }
  }

  String _getWelcomeMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أهلاً وسهلاً بك!';
      case 'tr':
        return 'Hoş Geldiniz!';
      default:
        return 'Welcome!';
    }
  }

  String _getStartOrderText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ابدأ الطلب';
      case 'tr':
        return 'Sipariş Ver';
      default:
        return 'Start Order';
    }
  }

  String _getStartOrderSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تصفح منيو لذيذ';
      case 'tr':
        return 'Lezzetli menüye göz atın';
      default:
        return 'Browse our delicious menu';
    }
  }

  String _getOffersText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عروضي الخاصة';
      case 'tr':
        return 'Özel Tekliflerim';
      default:
        return 'My Special Offers';
    }
  }

  String _getOffersSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عروض حصرية لك';
      case 'tr':
        return 'Sizin için özel teklifler';
      default:
        return 'Exclusive offers for you';
    }
  }

  String _getFavoriteOrdersText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'طلباتي المفضلة';
      case 'tr':
        return 'Favori Siparişlerim';
      default:
        return 'My Favorite Orders';
    }
  }

  String _getFavoriteOrdersSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'كرر طلباتك المفضلة';
      case 'tr':
        return 'Favori siparişlerinizi tekrarlayın';
      default:
        return 'Repeat your favorite orders';
    }
  }

  String _getStatsTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إحصائياتك';
      case 'tr':
        return 'İstatistikleriniz';
      default:
        return 'Your Statistics';
    }
  }

  String _getTotalOrdersText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إجمالي الطلبات';
      case 'tr':
        return 'Toplam Sipariş';
      default:
        return 'Total Orders';
    }
  }

  String _getFavoriteItemsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الأصناف المفضلة';
      case 'tr':
        return 'Favori Ürünler';
      default:
        return 'Favorite Items';
    }
  }

  String _getPointsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'نقاط الولاء';
      case 'tr':
        return 'Sadakat Puanı';
      default:
        return 'Loyalty Points';
    }
  }

  String _getAppVersionText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تطبيق طلب الطعام للمطاعم العربية - إصدار 1.0.0';
      case 'tr':
        return 'Arap Tarzı Restoran Sipariş Uygulaması - Sürüm 1.0.0';
      default:
        return 'Arabic Style Restaurant Ordering App - Version 1.0.0';
    }
  }

  String _getLogoutTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تسجيل الخروج';
      case 'tr':
        return 'Çıkış Yap';
      default:
        return 'Logout';
    }
  }

  String _getLogoutMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';
      case 'tr':
        return 'Çıkış yapmak istediğinizden emin misiniz?';
      default:
        return 'Are you sure you want to logout?';
    }
  }

  String _getCancelText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إلغاء';
      case 'tr':
        return 'İptal';
      default:
        return 'Cancel';
    }
  }

  String _getLogoutText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'خروج';
      case 'tr':
        return 'Çıkış';
      default:
        return 'Logout';
    }
  }
}

class _MainButtonData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _MainButtonData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

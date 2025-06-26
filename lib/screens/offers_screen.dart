import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/offer.dart';
import '../services/offers_service.dart';
import '../widgets/offers/offer_card_widget.dart';

class OffersScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;

  const OffersScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerAnimation;

  PersonalizedOffers? _personalizedOffers;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadOffers();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _headerAnimationController.repeat(reverse: true);
  }

  Future<void> _loadOffers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final offers =
          await OffersService.getPersonalizedOffers(widget.phoneNumber);

      setState(() {
        _personalizedOffers = offers;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.selectedLanguage == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
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
            child: Column(
              children: [
                // AppBar مخصص
                _buildCustomAppBar(isRTL, isMobile),

                if (_isLoading)
                  Expanded(child: _buildLoadingWidget(isMobile))
                else if (_errorMessage != null)
                  Expanded(child: _buildErrorWidget(isMobile))
                else if (_personalizedOffers != null) ...[
                  // معلومات العميل
                  _buildCustomerInfo(isMobile),

                  // قائمة العروض
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildOffersList(isMobile),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isRTL, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 16),
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
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              isRTL ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.primaryGreen,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),

          SizedBox(width: 12),

          // أيقونة العروض
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_headerAnimation.value * 0.1),
                child: Container(
                  width: isMobile ? 40 : 45,
                  height: isMobile ? 40 : 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryGold, AppColors.darkGold],
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 22.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                ),
              );
            },
          ),

          SizedBox(width: 12),

          // عنوان الصفحة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPageTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _getPageSubtitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة التحديث
          IconButton(
            onPressed: _loadOffers,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primaryGold,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(bool isMobile) {
    final profile = _personalizedOffers!.profile;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 8,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.lightGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // رمز مستوى العميل
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getTierColors(profile.tier),
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 25 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: _getTierColors(profile.tier)[0].withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _getTierIcon(profile.tier),
                  color: Colors.white,
                  size: isMobile ? 24 : 30,
                ),
              ),

              SizedBox(width: 16),

              // معلومات العميل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTierName(profile.tier),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getCustomerStats(profile),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // إحصائيات سريعة
          Row(
            children: [
              _buildStatItem(
                Icons.shopping_bag,
                '${profile.totalOrders}',
                _getTotalOrdersText(),
                isMobile,
              ),
              _buildStatItem(
                Icons.attach_money,
                '${profile.totalSpent.toStringAsFixed(0)} ₺',
                _getTotalSpentText(),
                isMobile,
              ),
              _buildStatItem(
                Icons.local_offer,
                '${_personalizedOffers!.offers.length}',
                _getAvailableOffersText(),
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, bool isMobile) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGold,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
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

  Widget _buildOffersList(bool isMobile) {
    if (_personalizedOffers!.offers.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primaryGold,
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        itemCount: _personalizedOffers!.offers.length,
        itemBuilder: (context, index) {
          final offer = _personalizedOffers!.offers[index];
          return OfferCardWidget(
            offer: offer,
            selectedLanguage: widget.selectedLanguage,
            onTap: () => _showOfferDetails(offer),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: isMobile ? 80 : 100,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            _getNoOffersTitle(),
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getNoOffersMessage(),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 80 : 100,
            height: isMobile ? 80 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold, AppColors.darkGold],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
            ),
            child: Icon(
              Icons.local_offer,
              color: Colors.white,
              size: isMobile ? 40 : 50,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
          ),
          SizedBox(height: 16),
          Text(
            _getLoadingText(),
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 80 : 100,
            color: AppColors.traditionalRed,
          ),
          SizedBox(height: 16),
          Text(
            _getErrorTitle(),
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadOffers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _getRetryText(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferDetails(Offer offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfferDetailsModal(offer),
    );
  }

  Widget _buildOfferDetailsModal(Offer offer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // مقبض السحب
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // محتوى العرض
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان العرض
                  Text(
                    offer.getTitle(widget.selectedLanguage),
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  SizedBox(height: 16),

                  // صورة العرض
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: isMobile ? 180 : 220,
                      child: Image.network(
                        offer.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.lightCream,
                            child: Icon(
                              Icons.local_offer,
                              size: 60,
                              color: AppColors.primaryGold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // تفاصيل العرض
                  Text(
                    offer.getDescription(widget.selectedLanguage),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: AppColors.textLight,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 20),

                  // معلومات العرض
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightCream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getDiscountText()),
                            Text(
                              '${offer.discountPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (offer.originalPrice != null) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getOriginalPriceText()),
                              Text(
                                  '${offer.originalPrice!.toStringAsFixed(0)} ₺'),
                            ],
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getValidUntilText()),
                            Text(
                              '${offer.endDate.day}/${offer.endDate.month}/${offer.endDate.year}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر التطبيق
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: offer.isValid ? () => _applyOffer(offer) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      offer.isValid ? AppColors.primaryGreen : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  offer.isValid ? _getApplyOfferText() : _getOfferExpiredText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyOffer(Offer offer) async {
    Navigator.pop(context);

    // إظهار نتيجة التطبيق
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getOfferAppliedText()),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  List<Color> _getTierColors(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.bronze:
        return [AppColors.brown, AppColors.darkBrown];
      case CustomerTier.silver:
        return [Colors.grey[400]!, Colors.grey[600]!];
      case CustomerTier.gold:
        return [AppColors.primaryGold, AppColors.darkGold];
      case CustomerTier.platinum:
        return [Colors.purple[400]!, Colors.purple[700]!];
    }
  }

  IconData _getTierIcon(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.bronze:
        return Icons.looks_3;
      case CustomerTier.silver:
        return Icons.looks_two;
      case CustomerTier.gold:
        return Icons.looks_one;
      case CustomerTier.platinum:
        return Icons.diamond;
    }
  }

  // النصوص المترجمة
  String _getPageTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عروضي الخاصة';
      case 'tr':
        return 'Özel Tekliflerim';
      default:
        return 'My Special Offers';
    }
  }

  String _getPageSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عروض مخصصة لك';
      case 'tr':
        return 'Sizin için özel teklifler';
      default:
        return 'Personalized offers for you';
    }
  }

  String _getTierName(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.bronze:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'عميل جديد';
          case 'tr':
            return 'Yeni Müşteri';
          default:
            return 'New Customer';
        }
      case CustomerTier.silver:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'عميل فضي';
          case 'tr':
            return 'Gümüş Müşteri';
          default:
            return 'Silver Customer';
        }
      case CustomerTier.gold:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'عميل ذهبي';
          case 'tr':
            return 'Altın Müşteri';
          default:
            return 'Gold Customer';
        }
      case CustomerTier.platinum:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'عميل بلاتيني';
          case 'tr':
            return 'Platin Müşteri';
          default:
            return 'Platinum Customer';
        }
    }
  }

  String _getCustomerStats(CustomerProfile profile) {
    switch (widget.selectedLanguage) {
      case 'ar':
        return '${profile.totalOrders} طلب • ${profile.totalSpent.toStringAsFixed(0)} ₺ إجمالي';
      case 'tr':
        return '${profile.totalOrders} sipariş • ${profile.totalSpent.toStringAsFixed(0)} ₺ toplam';
      default:
        return '${profile.totalOrders} orders • ${profile.totalSpent.toStringAsFixed(0)} ₺ total';
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

  String _getTotalSpentText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إجمالي المبلغ';
      case 'tr':
        return 'Toplam Tutar';
      default:
        return 'Total Spent';
    }
  }

  String _getAvailableOffersText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'العروض المتاحة';
      case 'tr':
        return 'Mevcut Teklifler';
      default:
        return 'Available Offers';
    }
  }

  String _getLoadingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جاري تحميل عروضك الخاصة...';
      case 'tr':
        return 'Özel teklifleriniz yükleniyor...';
      default:
        return 'Loading your special offers...';
    }
  }

  String _getNoOffersTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد عروض متاحة';
      case 'tr':
        return 'Mevcut Teklif Yok';
      default:
        return 'No Offers Available';
    }
  }

  String _getNoOffersMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد عروض خاصة متاحة لك حالياً\nتحقق مرة أخرى قريباً!';
      case 'tr':
        return 'Şu anda sizin için özel teklif bulunmuyor\nYakında tekrar kontrol edin!';
      default:
        return 'No special offers available for you right now\nCheck back soon!';
    }
  }

  String _getErrorTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'خطأ في التحميل';
      case 'tr':
        return 'Yükleme Hatası';
      default:
        return 'Loading Error';
    }
  }

  String _getErrorMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حدث خطأ أثناء تحميل العروض\nحاول مرة أخرى';
      case 'tr':
        return 'Teklifler yüklenirken hata oluştu\nTekrar deneyin';
      default:
        return 'Error occurred while loading offers\nPlease try again';
    }
  }

  String _getRetryText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إعادة المحاولة';
      case 'tr':
        return 'Tekrar Dene';
      default:
        return 'Retry';
    }
  }

  String _getDiscountText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'نسبة الخصم:';
      case 'tr':
        return 'İndirim Oranı:';
      default:
        return 'Discount:';
    }
  }

  String _getOriginalPriceText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'السعر الأصلي:';
      case 'tr':
        return 'Orijinal Fiyat:';
      default:
        return 'Original Price:';
    }
  }

  String _getValidUntilText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'صالح حتى:';
      case 'tr':
        return 'Geçerlilik:';
      default:
        return 'Valid Until:';
    }
  }

  String _getApplyOfferText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تطبيق العرض';
      case 'tr':
        return 'Teklifi Uygula';
      default:
        return 'Apply Offer';
    }
  }

  String _getOfferExpiredText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'انتهت صلاحية العرض';
      case 'tr':
        return 'Teklif Süresi Doldu';
      default:
        return 'Offer Expired';
    }
  }

  String _getOfferAppliedText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم تطبيق العرض بنجاح!';
      case 'tr':
        return 'Teklif başarıyla uygulandı!';
      default:
        return 'Offer applied successfully!';
    }
  }
}

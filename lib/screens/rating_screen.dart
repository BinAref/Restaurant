import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../config/app_theme.dart';
import '../models/order.dart';
import '../services/rating_service.dart';
import 'home_screen.dart';

class RatingScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;
  final Order order;

  const RatingScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
    required this.order,
  }) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _starsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _selectedStars = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _showSuccess = false;

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

    _starsAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _starsAnimationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _showSuccess
                        ? _buildSuccessView(l10n, isRTL, isMobile)
                        : _buildRatingView(l10n, isRTL, isMobile),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingView(AppLocalizations l10n, bool isRTL, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        children: [
          // رأس الصفحة
          _buildHeader(l10n, isRTL, isMobile),

          SizedBox(height: isMobile ? 30 : 40),

          // معلومات الطلب
          _buildOrderInfo(l10n, isMobile),

          SizedBox(height: isMobile ? 40 : 50),

          // قسم التقييم بالنجوم
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildStarsRating(l10n, isMobile),
          ),

          SizedBox(height: isMobile ? 30 : 40),

          // حقل الملاحظات
          _buildFeedbackField(l10n, isMobile),

          SizedBox(height: isMobile ? 40 : 50),

          // زر الإرسال
          _buildSubmitButton(l10n, isMobile),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isRTL, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 3,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // أيقونة التقييم المتحركة
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 1500),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.1,
                child: Container(
                  width: isMobile ? 80 : 100,
                  height: isMobile ? 80 : 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryGold, AppColors.darkGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_rate,
                    color: Colors.white,
                    size: isMobile ? 40 : 50,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16),

          Text(
            l10n.rateYourExperience,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8),

          Text(
            l10n.rateOrderExperience,
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

  Widget _buildOrderInfo(AppLocalizations l10n, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primaryGreen,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                'رقم الطلب: ${widget.order.id}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: AppColors.primaryGold,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.order.getOrderSummary(widget.selectedLanguage),
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.payments,
                color: AppColors.primaryGold,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                '${widget.order.totalPrice.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarsRating(AppLocalizations l10n, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // النجوم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isSelected = starNumber <= _selectedStars;

              return GestureDetector(
                onTap: () => _selectStars(starNumber),
                child: AnimatedBuilder(
                  animation: _starsAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected
                          ? 1.0 + (_starsAnimationController.value * 0.2)
                          : 1.0,
                      child: Container(
                        width: isMobile ? 50 : 60,
                        height: isMobile ? 50 : 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGold.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primaryGold.withOpacity(0.3),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected
                              ? AppColors.primaryGold
                              : AppColors.textLight,
                          size: isMobile ? 30 : 36,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          SizedBox(height: 16),

          // وصف التقييم
          if (_selectedStars > 0) ...[
            Text(
              _getRatingDescription(_selectedStars, l10n),
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_selectedStars),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackField(AppLocalizations l10n, bool isMobile) {
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
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment,
                color: AppColors.primaryGreen,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                l10n.addNotes,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: l10n.enterFeedback,
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontSize: isMobile ? 14 : 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.lightGold.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.lightGold.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: AppColors.primaryGold,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: _selectedStars > 0
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: isMobile ? 55 : 60,
        child: ElevatedButton(
          onPressed:
              _selectedStars > 0 && !_isSubmitting ? _submitRating : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedStars > 0
                ? AppColors.primaryGreen
                : AppColors.textLight,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: _selectedStars > 0 ? 5 : 0,
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      l10n.submitRating,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n, bool isRTL, bool isMobile) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isMobile ? 20 : 32),
        padding: EdgeInsets.all(isMobile ? 32 : 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              spreadRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة النجاح
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: isMobile ? 100 : 120,
                    height: isMobile ? 100 : 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(isMobile ? 50 : 60),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isMobile ? 50 : 60,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            Text(
              l10n.ratingSubmitted,
              style: TextStyle(
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            Text(
              l10n.ratingSuccess,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: isMobile ? 50 : 55,
              child: ElevatedButton(
                onPressed: _navigateToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStars(int stars) {
    setState(() {
      _selectedStars = stars;
    });

    // تشغيل رسوم متحركة للنجوم
    _starsAnimationController.forward().then((_) {
      _starsAnimationController.reverse();
    });
  }

  Future<void> _submitRating() async {
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ratingRequired),
          backgroundColor: AppColors.traditionalRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await RatingService.submitRating(
        orderId: widget.order.id,
        customerPhone: widget.phoneNumber,
        stars: _selectedStars,
        feedback: _feedbackController.text.trim().isEmpty
            ? null
            : _feedbackController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });

      // الانتقال للرئيسية بعد 3 ثوان
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          _navigateToHome();
        }
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.traditionalRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          selectedLanguage: widget.selectedLanguage,
          phoneNumber: widget.phoneNumber,
        ),
      ),
      (route) => false,
    );
  }

  String _getRatingDescription(int stars, AppLocalizations l10n) {
    switch (stars) {
      case 1:
        return l10n.veryPoor;
      case 2:
        return l10n.poor;
      case 3:
        return l10n.average;
      case 4:
        return l10n.good;
      case 5:
        return l10n.excellent;
      default:
        return '';
    }
  }

  Color _getRatingColor(int stars) {
    switch (stars) {
      case 1:
      case 2:
        return AppColors.traditionalRed;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return AppColors.primaryGreen;
      default:
        return AppColors.textLight;
    }
  }
}

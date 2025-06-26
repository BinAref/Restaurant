import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/offer.dart';

class OfferCardWidget extends StatefulWidget {
  final Offer offer;
  final String selectedLanguage;
  final VoidCallback? onTap;

  const OfferCardWidget({
    Key? key,
    required this.offer,
    required this.selectedLanguage,
    this.onTap,
  }) : super(key: key);

  @override
  State<OfferCardWidget> createState() => _OfferCardWidgetState();
}

class _OfferCardWidgetState extends State<OfferCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _getCardGradient(),
            boxShadow: [
              BoxShadow(
                color: _getCardColor().withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // الخلفية المزخرفة
                _buildDecorativeBackground(),

                // المحتوى الرئيسي
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس البطاقة مع التاجات
                      _buildCardHeader(isMobile),

                      SizedBox(height: 12),

                      // محتوى العرض
                      Row(
                        children: [
                          // صورة العرض
                          _buildOfferImage(isMobile),

                          SizedBox(width: 16),

                          // تفاصيل العرض
                          Expanded(
                            child: _buildOfferDetails(isMobile),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // شريط التقدم والمعلومات السفلية
                      _buildOfferFooter(isMobile),
                    ],
                  ),
                ),

                // شريط الخصم
                _buildDiscountBadge(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: _getCardGradient(),
        ),
        child: CustomPaint(
          painter: _ArabicPatternPainter(),
        ),
      ),
    );
  }

  Widget _buildCardHeader(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.offer.getTitle(widget.selectedLanguage),
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),

        // العلامات/التاجات
        Row(
          children: widget.offer.tags.take(2).map((tag) {
            return Container(
              margin: EdgeInsets.only(left: 4),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: _getCardColor(),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOfferImage(bool isMobile) {
    return Container(
      width: isMobile ? 80 : 100,
      height: isMobile ? 80 : 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.offer.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.white.withOpacity(0.2),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white.withOpacity(0.2),
              child: Icon(
                _getOfferIcon(),
                size: isMobile ? 40 : 50,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfferDetails(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الوصف
        Text(
          widget.offer.getDescription(widget.selectedLanguage),
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: Colors.white.withOpacity(0.95),
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 8),

        // السعر إذا كان متاحاً
        if (widget.offer.originalPrice != null &&
            widget.offer.discountedPrice != null)
          Row(
            children: [
              Text(
                '${widget.offer.originalPrice!.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.white.withOpacity(0.7),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${widget.offer.discountedPrice!.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOfferFooter(bool isMobile) {
    return Column(
      children: [
        // شريط الاستخدام
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getUsageText(),
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: widget.offer.currentUses / widget.offer.maxUses,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    minHeight: 4,
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // الوقت المتبقي
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.8),
                      size: isMobile ? 14 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _getTimeLeftText(),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.offer.timeLeft,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountBadge(bool isMobile) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.traditionalRed,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.traditionalRed.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer,
              color: Colors.white,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: 4),
            Text(
              '-${widget.offer.discountPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCardGradient() {
    switch (widget.offer.type) {
      case OfferType.newCustomer:
        return LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case OfferType.loyalty:
        return LinearGradient(
          colors: [AppColors.primaryGold, AppColors.darkGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case OfferType.combo:
        return LinearGradient(
          colors: [AppColors.traditionalRed, AppColors.darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppColors.primaryGold, AppColors.darkGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getCardColor() {
    switch (widget.offer.type) {
      case OfferType.newCustomer:
        return AppColors.primaryGreen;
      case OfferType.loyalty:
        return AppColors.primaryGold;
      case OfferType.combo:
        return AppColors.traditionalRed;
      default:
        return AppColors.primaryGold;
    }
  }

  IconData _getOfferIcon() {
    switch (widget.offer.type) {
      case OfferType.newCustomer:
        return Icons.celebration;
      case OfferType.loyalty:
        return Icons.stars;
      case OfferType.combo:
        return Icons.restaurant;
      case OfferType.freeDelivery:
        return Icons.delivery_dining;
      case OfferType.buyOneGetOne:
        return Icons.add_circle;
      default:
        return Icons.local_offer;
    }
  }

  String _getUsageText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم الاستخدام ${widget.offer.currentUses} من ${widget.offer.maxUses}';
      case 'tr':
        return '${widget.offer.maxUses} üzerinden ${widget.offer.currentUses} kullanıldı';
      default:
        return 'Used ${widget.offer.currentUses} of ${widget.offer.maxUses}';
    }
  }

  String _getTimeLeftText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'متبقي:';
      case 'tr':
        return 'Kalan:';
      default:
        return 'Left:';
    }
  }
}

// رسام الأنماط العربية
class _ArabicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // رسم أنماط هندسية عربية بسيطة
    final path = Path();

    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 4; j++) {
        final x = (size.width / 6) * i;
        final y = (size.height / 4) * j;

        path.moveTo(x, y);
        path.lineTo(x + 20, y + 10);
        path.lineTo(x + 10, y + 20);
        path.lineTo(x - 10, y + 10);
        path.close();
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

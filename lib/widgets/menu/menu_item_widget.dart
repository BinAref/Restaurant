import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/menu_item.dart';
import '../../providers/cart_provider.dart';

class MenuItemWidget extends StatefulWidget {
  final MenuItem item;
  final String selectedLanguage;

  const MenuItemWidget({
    Key? key,
    required this.item,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
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
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
            // صورة الطبق مع المؤشرات
            _buildItemImage(isMobile),

            // معلومات الطبق
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الطبق والمؤشرات
                  _buildItemHeader(isMobile),

                  SizedBox(height: 8),

                  // الوصف
                  _buildItemDescription(isMobile),

                  SizedBox(height: 12),

                  // المكونات
                  _buildIngredients(isMobile),

                  SizedBox(height: 16),

                  // السعر وزر الإضافة
                  _buildPriceAndButton(isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(bool isMobile) {
    return Stack(
      children: [
        // الصورة
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            height: isMobile ? 180 : 200,
            child: Image.network(
              widget.item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.lightCream,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightCream,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 50,
                        color: AppColors.primaryGold,
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.item.getName(widget.selectedLanguage),
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // مؤشرات الطبق
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              if (widget.item.isPopular)
                _buildBadge(
                  _getPopularText(),
                  AppColors.primaryGold,
                  Icons.star,
                  isMobile,
                ),
              if (widget.item.isSpicy)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: _buildBadge(
                    _getSpicyText(),
                    AppColors.traditionalRed,
                    Icons.local_fire_department,
                    isMobile,
                  ),
                ),
              if (!widget.item.isAvailable)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: _buildBadge(
                    _getUnavailableText(),
                    Colors.grey,
                    Icons.block,
                    isMobile,
                  ),
                ),
            ],
          ),
        ),

        // وقت التحضير
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 10,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: isMobile ? 14 : 16,
                ),
                SizedBox(width: 4),
                Text(
                  '${widget.item.preparationTime} ${_getMinutesText()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 12 : 14,
          ),
          SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.item.getName(widget.selectedLanguage),
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (widget.item.isPopular)
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.star,
              color: AppColors.primaryGold,
              size: isMobile ? 18 : 20,
            ),
          ),
      ],
    );
  }

  Widget _buildItemDescription(bool isMobile) {
    return Text(
      widget.item.getDescription(widget.selectedLanguage),
      style: TextStyle(
        fontSize: isMobile ? 13 : 14,
        color: AppColors.textLight,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildIngredients(bool isMobile) {
    if (widget.item.ingredients.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getIngredientsText(),
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: widget.item.ingredients.take(4).map((ingredient) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                ),
              ),
              child: Text(
                ingredient,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceAndButton(bool isMobile) {
    return Row(
      children: [
        // السعر
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.item.price.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                _getPriceText(),
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),

        // زر الإضافة
        SizedBox(
          width: isMobile ? 100 : 120,
          height: isMobile ? 40 : 45,
          child: ElevatedButton(
            onPressed: widget.item.isAvailable ? _addToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.item.isAvailable
                  ? AppColors.primaryGreen
                  : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: widget.item.isAvailable ? 3 : 0,
            ),
            child: _isAdding
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        size: isMobile ? 16 : 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getAddToCartText(),
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _addToCart() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);

    // تأثير بصري
    await _animationController.forward();
    await _animationController.reverse();

    // إضافة للسلة باستخدام Provider
    Provider.of<CartProvider>(context, listen: false).addItem(widget.item);

    setState(() => _isAdding = false);

    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_getAddedToCartText()} ${widget.item.getName(widget.selectedLanguage)}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // النصوص المترجمة
  String _getPopularText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'شائع';
      case 'tr':
        return 'Popüler';
      default:
        return 'Popular';
    }
  }

  String _getSpicyText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حار';
      case 'tr':
        return 'Acı';
      default:
        return 'Spicy';
    }
  }

  String _getUnavailableText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'غير متوفر';
      case 'tr':
        return 'Mevcut Değil';
      default:
        return 'Unavailable';
    }
  }

  String _getMinutesText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'دقيقة';
      case 'tr':
        return 'dk';
      default:
        return 'min';
    }
  }

  String _getIngredientsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'المكونات:';
      case 'tr':
        return 'İçindekiler:';
      default:
        return 'Ingredients:';
    }
  }

  String _getPriceText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'شامل الضريبة';
      case 'tr':
        return 'KDV Dahil';
      default:
        return 'Tax Included';
    }
  }

  String _getAddToCartText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أضف';
      case 'tr':
        return 'Ekle';
      default:
        return 'Add';
    }
  }

  String _getAddedToCartText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم إضافة';
      case 'tr':
        return 'Eklendi:';
      default:
        return 'Added:';
    }
  }
}

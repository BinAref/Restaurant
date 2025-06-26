import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_ordering_app/screens/order_pending_screen.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import 'order_pending_screen.dart';

class CartScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;

  const CartScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    _addressController.dispose();
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
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.isEmpty) {
                  return _buildEmptyCart(isRTL, isMobile);
                }

                return AnimatedBuilder(
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

                            // محتوى السلة
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // عناصر السلة
                                    _buildCartItems(cartProvider, isMobile),

                                    SizedBox(height: 24),

                                    // ملاحظات الطلب
                                    _buildOrderNotes(isMobile),

                                    SizedBox(height: 24),

                                    // عنوان التسليم
                                    _buildDeliveryAddress(isMobile),

                                    SizedBox(height: 24),

                                    // ملخص الطلب
                                    _buildOrderSummary(cartProvider, isMobile),
                                  ],
                                ),
                              ),
                            ),

                            // زر تأكيد الطلب
                            _buildConfirmButton(cartProvider, isMobile),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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

          // أيقونة السلة
          Container(
            width: isMobile ? 40 : 45,
            height: isMobile ? 40 : 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.darkGreen],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 20 : 22.5),
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
          ),

          SizedBox(width: 12),

          // عنوان السلة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCartTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _getCartSubtitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // زر مسح السلة
          IconButton(
            onPressed: _showClearCartDialog,
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.traditionalRed,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isRTL, bool isMobile) {
    return Column(
      children: [
        _buildCustomAppBar(isRTL, isMobile),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isMobile ? 120 : 150,
                  height: isMobile ? 120 : 150,
                  decoration: BoxDecoration(
                    color: AppColors.lightGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isMobile ? 60 : 75),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: isMobile ? 60 : 80,
                    color: AppColors.primaryGold,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  _getEmptyCartTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _getEmptyCartMessage(),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _getBrowseMenuText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItems(CartProvider cartProvider, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getOrderItemsTitle(),
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: cartProvider.items.length,
          itemBuilder: (context, index) {
            final cartItem = cartProvider.items[index];
            return _buildCartItemCard(cartItem, cartProvider, isMobile);
          },
        ),
      ],
    );
  }

  Widget _buildCartItemCard(
    cartItem,
    CartProvider cartProvider,
    bool isMobile,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // صورة الطبق
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                child: Image.network(
                  cartItem.menuItem.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.lightCream,
                      child: Icon(
                        Icons.restaurant,
                        color: AppColors.primaryGold,
                        size: isMobile ? 30 : 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 12),

            // معلومات الطبق
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.menuItem.getName(widget.selectedLanguage),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${cartItem.menuItem.price.toStringAsFixed(0)} ₺',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (cartItem.notes != null && cartItem.notes!.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      '${_getNotesText()}: ${cartItem.notes}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // عناصر التحكم
            Column(
              children: [
                // أزرار الكمية
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightCream,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        Icons.remove,
                        () => _updateQuantity(
                            cartProvider, cartItem, cartItem.quantity - 1),
                        isMobile,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${cartItem.quantity}',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        Icons.add,
                        () => _updateQuantity(
                            cartProvider, cartItem, cartItem.quantity + 1),
                        isMobile,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),

                // زر الحذف
                TextButton(
                  onPressed: () => _removeItem(cartProvider, cartItem),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size(0, 30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: isMobile ? 16 : 18,
                        color: AppColors.traditionalRed,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getDeleteText(),
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: AppColors.traditionalRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
      IconData icon, VoidCallback onPressed, bool isMobile) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isMobile ? 28 : 32,
        height: isMobile ? 28 : 32,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isMobile ? 16 : 18,
        ),
      ),
    );
  }

  Widget _buildOrderNotes(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getOrderNotesTitle(),
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _getOrderNotesHint(),
              hintStyle: TextStyle(color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getDeliveryAddressTitle(),
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: _getDeliveryAddressHint(),
              hintStyle: TextStyle(color: AppColors.textLight),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryGold,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withOpacity(0.1),
            AppColors.lightGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primaryGold,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                _getOrderSummaryTitle(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSummaryRow(
            _getItemsCountText(),
            '${cartProvider.itemCount}',
            isMobile,
          ),
          _buildSummaryRow(
            _getEstimatedTimeText(),
            '${cartProvider.estimatedPreparationTime} ${_getMinutesText()}',
            isMobile,
          ),
          Divider(
            color: AppColors.primaryGold.withOpacity(0.3),
            thickness: 1,
            height: 24,
          ),
          _buildSummaryRow(
            _getTotalText(),
            '${cartProvider.totalPrice.toStringAsFixed(0)} ₺',
            isMobile,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isMobile,
      {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColors.primaryGreen : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(CartProvider cartProvider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: isMobile ? 50 : 56,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : () => _confirmOrder(cartProvider),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
          child: _isSubmitting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _getSubmittingText(),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getConfirmOrderText(),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _updateQuantity(CartProvider cartProvider, cartItem, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(cartProvider, cartItem);
    } else {
      cartProvider.updateQuantity(cartItem.menuItem.id, newQuantity);
    }
  }

  void _removeItem(CartProvider cartProvider, cartItem) {
    cartProvider.removeItem(cartItem.menuItem.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getItemRemovedText()),
        backgroundColor: AppColors.traditionalRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _getClearCartTitle(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            _getClearCartMessage(),
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
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).clearCart();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // العودة للمنيو
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.traditionalRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _getClearText(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmOrder(CartProvider cartProvider) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final orderSummary = cartProvider.getOrderSummary();

      final response = await OrderService.submitOrder(
        phoneNumber: widget.phoneNumber,
        orderData: orderSummary,
        deliveryAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        specialInstructions: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // مسح السلة بعد النجاح
      cartProvider.clearCart();

      // الانتقال لشاشة متابعة الطلب
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderPendingScreen(
            orderId: response.orderId,
            estimatedTime: response.estimatedDeliveryTime,
            selectedLanguage: widget.selectedLanguage,
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is OrderException ? e.message : _getOrderErrorText(),
          ),
          backgroundColor: AppColors.traditionalRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // النصوص المترجمة
  String _getCartTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'سلة التسوق';
      case 'tr':
        return 'Alışveriş Sepeti';
      default:
        return 'Shopping Cart';
    }
  }

  String _getCartSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'راجع طلبك وأكمل الشراء';
      case 'tr':
        return 'Siparişinizi gözden geçirin ve tamamlayın';
      default:
        return 'Review your order and complete purchase';
    }
  }

  String _getEmptyCartTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'السلة فارغة';
      case 'tr':
        return 'Sepet Boş';
      default:
        return 'Cart is Empty';
    }
  }

  String _getEmptyCartMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أضف بعض الأطباق اللذيذة\nإلى سلتك للمتابعة';
      case 'tr':
        return 'Devam etmek için sepetinize\nlezzetli yemekler ekleyin';
      default:
        return 'Add some delicious dishes\nto your cart to continue';
    }
  }

  String _getBrowseMenuText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تصفح المنيو';
      case 'tr':
        return 'Menüyü Gözat';
      default:
        return 'Browse Menu';
    }
  }

  String _getOrderItemsTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أصناف الطلب';
      case 'tr':
        return 'Sipariş Öğeleri';
      default:
        return 'Order Items';
    }
  }

  String _getNotesText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملاحظات';
      case 'tr':
        return 'Notlar';
      default:
        return 'Notes';
    }
  }

  String _getDeleteText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حذف';
      case 'tr':
        return 'Sil';
      default:
        return 'Delete';
    }
  }

  String _getOrderNotesTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملاحظات خاصة';
      case 'tr':
        return 'Özel Notlar';
      default:
        return 'Special Notes';
    }
  }

  String _getOrderNotesHint() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أي طلبات خاصة أو ملاحظات للمطبخ...';
      case 'tr':
        return 'Mutfak için özel istekler veya notlar...';
      default:
        return 'Any special requests or notes for the kitchen...';
    }
  }

  String _getDeliveryAddressTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عنوان التسليم';
      case 'tr':
        return 'Teslimat Adresi';
      default:
        return 'Delivery Address';
    }
  }

  String _getDeliveryAddressHint() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أدخل عنوان التسليم (اختياري)';
      case 'tr':
        return 'Teslimat adresini girin (isteğe bağlı)';
      default:
        return 'Enter delivery address (optional)';
    }
  }

  String _getOrderSummaryTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملخص الطلب';
      case 'tr':
        return 'Sipariş Özeti';
      default:
        return 'Order Summary';
    }
  }

  String _getItemsCountText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عدد الأصناف:';
      case 'tr':
        return 'Öğe Sayısı:';
      default:
        return 'Items Count:';
    }
  }

  String _getEstimatedTimeText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'وقت التحضير:';
      case 'tr':
        return 'Hazırlık Süresi:';
      default:
        return 'Preparation Time:';
    }
  }

  String _getMinutesText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'دقيقة';
      case 'tr':
        return 'dakika';
      default:
        return 'minutes';
    }
  }

  String _getTotalText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الإجمالي:';
      case 'tr':
        return 'Toplam:';
      default:
        return 'Total:';
    }
  }

  String _getConfirmOrderText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تأكيد الطلب';
      case 'tr':
        return 'Siparişi Onayla';
      default:
        return 'Confirm Order';
    }
  }

  String _getSubmittingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جاري الإرسال...';
      case 'tr':
        return 'Gönderiliyor...';
      default:
        return 'Submitting...';
    }
  }

  String _getItemRemovedText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم حذف الصنف من السلة';
      case 'tr':
        return 'Öğe sepetten kaldırıldı';
      default:
        return 'Item removed from cart';
    }
  }

  String _getClearCartTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'مسح السلة';
      case 'tr':
        return 'Sepeti Temizle';
      default:
        return 'Clear Cart';
    }
  }

  String _getClearCartMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'هل أنت متأكد من رغبتك في مسح جميع الأصناف من السلة؟';
      case 'tr':
        return 'Sepetteki tüm öğeleri temizlemek istediğinizden emin misiniz?';
      default:
        return 'Are you sure you want to clear all items from the cart?';
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

  String _getClearText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'مسح';
      case 'tr':
        return 'Temizle';
      default:
        return 'Clear';
    }
  }

  String _getOrderErrorText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حدث خطأ أثناء إرسال الطلب، حاول مرة أخرى';
      case 'tr':
        return 'Sipariş gönderilirken hata oluştu, tekrar deneyin';
      default:
        return 'Error occurred while submitting order, please try again';
    }
  }
}

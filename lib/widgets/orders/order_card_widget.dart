import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';

class OrderCardWidget extends StatefulWidget {
  final Order order;
  final String selectedLanguage;
  final VoidCallback? onReorder;
  final VoidCallback? onViewDetails;

  const OrderCardWidget({
    Key? key,
    required this.order,
    required this.selectedLanguage,
    this.onReorder,
    this.onViewDetails,
  }) : super(key: key);

  @override
  State<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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
        onTap: widget.onViewDetails,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor().withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor().withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // رأس البطاقة
              _buildCardHeader(isMobile),

              // محتوى الطلب
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الطلب الأساسية
                    _buildOrderInfo(isMobile),

                    SizedBox(height: 12),

                    // أصناف الطلب
                    _buildOrderItems(isMobile),

                    SizedBox(height: 16),

                    // الإجمالي والأزرار
                    _buildOrderFooter(isMobile),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor().withOpacity(0.1),
            _getStatusColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // أيقونة حالة الطلب
          Container(
            width: isMobile ? 40 : 45,
            height: isMobile ? 40 : 45,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(isMobile ? 20 : 22.5),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
          ),

          SizedBox(width: 12),

          // معلومات الطلب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.order.id,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: 8),
                    if (widget.order.rating != null)
                      _buildRatingStars(widget.order.rating!, isMobile),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  _formatDate(widget.order.orderTime),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // حالة الطلب
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: AppColors.primaryGold,
          size: isMobile ? 14 : 16,
        );
      }),
    );
  }

  Widget _buildOrderInfo(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getOrderSummaryText(),
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: AppColors.textLight,
                ),
              ),
              if (widget.order.deliveryAddress != null) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 14 : 16,
                      color: AppColors.primaryGold,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.order.deliveryAddress!,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // وقت التسليم إذا كان متاحاً
        if (widget.order.deliveredAt != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getDeliveredAtText(),
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                _formatTime(widget.order.deliveredAt!),
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOrderItems(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getOrderItemsText(),
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),

        // عرض الأصناف
        if (widget.order.items.length <= 3) ...[
          // عرض جميع الأصناف إذا كانت قليلة
          ...widget.order.items.map((item) => _buildOrderItem(item, isMobile)),
        ] else ...[
          // عرض أول صنفين + "والمزيد"
          ...widget.order.items
              .take(2)
              .map((item) => _buildOrderItem(item, isMobile)),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _getAndMoreText(widget.order.items.length - 2),
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // كمية
          Container(
            width: isMobile ? 20 : 24,
            height: isMobile ? 20 : 24,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ),

          SizedBox(width: 8),

          // اسم الصنف
          Expanded(
            child: Text(
              item.menuItem.getName(widget.selectedLanguage),
              style: TextStyle(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // السعر
          Text(
            '${item.totalPrice.toStringAsFixed(0)} ₺',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter(bool isMobile) {
    return Row(
      children: [
        // الإجمالي
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTotalText(),
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '${widget.order.totalPrice.toStringAsFixed(0)} ₺',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),

        // أزرار العمل
        Column(
          children: [
            // زر إعادة الطلب
            if (widget.order.canReorder)
              SizedBox(
                width: isMobile ? 100 : 120,
                height: isMobile ? 36 : 40,
                child: ElevatedButton(
                  onPressed: _isReordering ? null : _reorderOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isReordering
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
                              Icons.refresh,
                              size: isMobile ? 14 : 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _getReorderText(),
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

            // زر التفاصيل
            SizedBox(height: 8),
            SizedBox(
              width: isMobile ? 100 : 120,
              height: isMobile ? 32 : 36,
              child: OutlinedButton(
                onPressed: widget.onViewDetails,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryGold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getDetailsText(),
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _reorderOrder() async {
    if (_isReordering) return;

    setState(() => _isReordering = true);

    try {
      // إضافة جميع الأصناف للسلة
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      for (final item in widget.order.items) {
        for (int i = 0; i < item.quantity; i++) {
          cartProvider.addItem(item.menuItem, notes: item.notes);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getReorderSuccessText()),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (widget.onReorder != null) {
        widget.onReorder!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getReorderErrorText()),
          backgroundColor: AppColors.traditionalRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isReordering = false);
    }
  }

  Color _getStatusColor() {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return AppColors.primaryGold;
      case OrderStatus.confirmed:
        return AppColors.primaryGreen;
      case OrderStatus.preparing:
        return AppColors.traditionalRed;
      case OrderStatus.ready:
        return AppColors.primaryGreen;
      case OrderStatus.delivered:
        return AppColors.primaryGreen;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.done_all;
      case OrderStatus.delivered:
        return Icons.delivery_dining;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText() {
    switch (widget.order.status) {
      case OrderStatus.pending:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'قيد الانتظار';
          case 'tr':
            return 'Beklemede';
          default:
            return 'Pending';
        }
      case OrderStatus.confirmed:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'مؤكد';
          case 'tr':
            return 'Onaylandı';
          default:
            return 'Confirmed';
        }
      case OrderStatus.preparing:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'قيد التحضير';
          case 'tr':
            return 'Hazırlanıyor';
          default:
            return 'Preparing';
        }
      case OrderStatus.ready:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'جاهز';
          case 'tr':
            return 'Hazır';
          default:
            return 'Ready';
        }
      case OrderStatus.delivered:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'تم التسليم';
          case 'tr':
            return 'Teslim Edildi';
          default:
            return 'Delivered';
        }
      case OrderStatus.cancelled:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'ملغي';
          case 'tr':
            return 'İptal Edildi';
          default:
            return 'Cancelled';
        }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      switch (widget.selectedLanguage) {
        case 'ar':
          return 'اليوم';
        case 'tr':
          return 'Bugün';
        default:
          return 'Today';
      }
    } else if (difference.inDays == 1) {
      switch (widget.selectedLanguage) {
        case 'ar':
          return 'أمس';
        case 'tr':
          return 'Dün';
        default:
          return 'Yesterday';
      }
    } else if (difference.inDays < 7) {
      switch (widget.selectedLanguage) {
        case 'ar':
          return 'منذ ${difference.inDays} أيام';
        case 'tr':
          return '${difference.inDays} gün önce';
        default:
          return '${difference.inDays} days ago';
      }
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // النصوص المترجمة
  String _getOrderSummaryText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return '${widget.order.totalItems} صنف • ${widget.order.getOrderSummary(widget.selectedLanguage)}';
      case 'tr':
        return '${widget.order.totalItems} ürün • ${widget.order.getOrderSummary(widget.selectedLanguage)}';
      default:
        return '${widget.order.totalItems} items • ${widget.order.getOrderSummary(widget.selectedLanguage)}';
    }
  }

  String _getDeliveredAtText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم التسليم:';
      case 'tr':
        return 'Teslim:';
      default:
        return 'Delivered:';
    }
  }

  String _getOrderItemsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'الأصناف:';
      case 'tr':
        return 'Ürünler:';
      default:
        return 'Items:';
    }
  }

  String _getAndMoreText(int count) {
    switch (widget.selectedLanguage) {
      case 'ar':
        return '+ $count صنف آخر';
      case 'tr':
        return '+ $count ürün daha';
      default:
        return '+ $count more items';
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

  String _getReorderText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'إعادة طلب';
      case 'tr':
        return 'Tekrar';
      default:
        return 'Reorder';
    }
  }

  String _getDetailsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'التفاصيل';
      case 'tr':
        return 'Detaylar';
      default:
        return 'Details';
    }
  }

  String _getReorderSuccessText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تمت إضافة الأصناف للسلة بنجاح!';
      case 'tr':
        return 'Ürünler sepete başarıyla eklendi!';
      default:
        return 'Items added to cart successfully!';
    }
  }

  String _getReorderErrorText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'فشل في إعادة الطلب، حاول مرة أخرى';
      case 'tr':
        return 'Tekrar sipariş verilemedi, tekrar deneyin';
      default:
        return 'Failed to reorder, please try again';
    }
  }
}

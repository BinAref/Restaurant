import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'home_screen.dart';

class OrderPendingScreen extends StatefulWidget {
  final String orderId;
  final DateTime estimatedTime;
  final String selectedLanguage;
  final String phoneNumber;

  const OrderPendingScreen({
    Key? key,
    required this.orderId,
    required this.estimatedTime,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OrderPendingScreen> createState() => _OrderPendingScreenState();
}

class _OrderPendingScreenState extends State<OrderPendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  OrderStatus _currentStatus = OrderStatus.pending;
  Timer? _statusTimer;
  late DateTime _orderTime;

  @override
  void initState() {
    super.initState();
    _orderTime = DateTime.now();
    _setupAnimations();
    _startStatusSimulation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startStatusSimulation() {
    // محاكاة تطور حالة الطلب كل 30 ثانية
    _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          switch (_currentStatus) {
            case OrderStatus.pending:
              _currentStatus = OrderStatus.confirmed;
              break;
            case OrderStatus.confirmed:
              _currentStatus = OrderStatus.preparing;
              break;
            case OrderStatus.preparing:
              _currentStatus = OrderStatus.ready;
              break;
            case OrderStatus.ready:
              _currentStatus = OrderStatus.delivered;
              timer.cancel();
              break;
            default:
              timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _statusTimer?.cancel();
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // AppBar مخصص
                        _buildCustomAppBar(isRTL, isMobile),

                        // المحتوى الرئيسي
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            child: Column(
                              children: [
                                // أيقونة النجاح
                                _buildSuccessIcon(isMobile),

                                SizedBox(height: 24),

                                // رسالة النجاح
                                _buildSuccessMessage(isMobile),

                                SizedBox(height: 32),

                                // معلومات الطلب
                                _buildOrderInfo(isMobile),

                                SizedBox(height: 24),

                                // متتبع حالة الطلب
                                _buildOrderTracker(isMobile),

                                SizedBox(height: 32),

                                // معلومات إضافية
                                _buildAdditionalInfo(isMobile),
                              ],
                            ),
                          ),
                        ),

                        // أزرار العمل
                        _buildActionButtons(isMobile),
                      ],
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
          // أيقونة الطلب
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
              Icons.receipt_long,
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
                Text(
                  _getOrderTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  widget.orderId,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textLight,
                    fontFamily: 'monospace',
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
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
              ),
            ),
            child: Text(
              _getStatusText(_currentStatus),
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon(bool isMobile) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.darkGreen],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 50 : 60),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: isMobile ? 50 : 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage(bool isMobile) {
    return Column(
      children: [
        Text(
          _getSuccessTitle(),
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          _getSuccessMessage(),
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.textLight,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrderInfo(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryGold,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                _getOrderInfoTitle(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            _getOrderTimeText(),
            _formatTime(_orderTime),
            isMobile,
          ),
          _buildInfoRow(
            Icons.schedule,
            _getEstimatedDeliveryText(),
            _formatTime(widget.estimatedTime),
            isMobile,
          ),
          _buildInfoRow(
            Icons.phone,
            _getPhoneText(),
            '+90 ${widget.phoneNumber}',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            decoration: BoxDecoration(
              color: AppColors.lightGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGold,
              size: isMobile ? 16 : 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTracker(bool isMobile) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];

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
                Icons.track_changes,
                color: AppColors.primaryGold,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                _getOrderTrackerTitle(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Column(
            children: statuses
                .map((status) => _buildTrackerItem(
                      status,
                      statuses.indexOf(status) <=
                          statuses.indexOf(_currentStatus),
                      isMobile,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerItem(
      OrderStatus status, bool isCompleted, bool isMobile) {
    final isActive = status == _currentStatus;

    return Row(
      children: [
        // النقطة
        Container(
          width: isMobile ? 20 : 24,
          height: isMobile ? 20 : 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primaryGreen
                : AppColors.textLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            border: Border.all(
              color: isActive ? AppColors.primaryGold : Colors.transparent,
              width: 3,
            ),
          ),
          child: isCompleted
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: isMobile ? 12 : 14,
                )
              : null,
        ),

        SizedBox(width: 12),

        // النص
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isCompleted ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ),
        ),

        // وقت التحديث
        if (isCompleted)
          Text(
            _formatTime(DateTime.now()),
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: AppColors.textLight,
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalInfo(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primaryGold,
                size: isMobile ? 18 : 20,
              ),
              SizedBox(width: 8),
              Text(
                _getHelpfulTipsTitle(),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _getHelpfulTipsText(),
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
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
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      phoneNumber: widget.phoneNumber,
                      selectedLanguage: widget.selectedLanguage,
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getBackToHomeText(),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 52,
            child: OutlinedButton(
              onPressed: () {
                // TODO: الاتصال بالمطعم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_getCallRestaurantText()),
                    backgroundColor: AppColors.primaryGold,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: AppColors.primaryGold,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getContactRestaurantText(),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
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
      default:
        return AppColors.textLight;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // النصوص المترجمة
  String _getOrderTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'طلبك';
      case 'tr':
        return 'Siparişiniz';
      default:
        return 'Your Order';
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        switch (widget.selectedLanguage) {
          case 'ar':
            return 'في الانتظار';
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
      default:
        return '';
    }
  }

  String _getSuccessTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تم تأكيد طلبك!';
      case 'tr':
        return 'Siparişiniz Onaylandı!';
      default:
        return 'Order Confirmed!';
    }
  }

  String _getSuccessMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'شكراً لك! تم استلام طلبك بنجاح\nوسيتم تحضيره قريباً';
      case 'tr':
        return 'Teşekkürler! Siparişiniz başarıyla alındı\nve yakında hazırlanacak';
      default:
        return 'Thank you! Your order has been received\nand will be prepared soon';
    }
  }

  String _getOrderInfoTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تفاصيل الطلب';
      case 'tr':
        return 'Sipariş Detayları';
      default:
        return 'Order Details';
    }
  }

  String _getOrderTimeText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'وقت الطلب';
      case 'tr':
        return 'Sipariş Zamanı';
      default:
        return 'Order Time';
    }
  }

  String _getEstimatedDeliveryText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'التسليم المتوقع';
      case 'tr':
        return 'Tahmini Teslimat';
      default:
        return 'Estimated Delivery';
    }
  }

  String _getPhoneText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'رقم الهاتف';
      case 'tr':
        return 'Telefon';
      default:
        return 'Phone';
    }
  }

  String _getOrderTrackerTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تتبع الطلب';
      case 'tr':
        return 'Sipariş Takibi';
      default:
        return 'Order Tracking';
    }
  }

  String _getHelpfulTipsTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'نصائح مفيدة';
      case 'tr':
        return 'Faydalı İpuçları';
      default:
        return 'Helpful Tips';
    }
  }

  String _getHelpfulTipsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'سيتم إشعارك عبر الرسائل عند تغيير حالة طلبك. يمكنك التواصل معنا في أي وقت إذا كان لديك أي استفسار.';
      case 'tr':
        return 'Sipariş durumunuz değiştiğinde SMS ile bilgilendirileceksiniz. Herhangi bir sorunuz varsa istediğiniz zaman bizimle iletişime geçebilirsiniz.';
      default:
        return 'You will be notified via SMS when your order status changes. You can contact us anytime if you have any questions.';
    }
  }

  String _getBackToHomeText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'العودة للرئيسية';
      case 'tr':
        return 'Ana Sayfaya Dön';
      default:
        return 'Back to Home';
    }
  }

  String _getContactRestaurantText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'التواصل مع المطعم';
      case 'tr':
        return 'Restoran ile İletişim';
      default:
        return 'Contact Restaurant';
    }
  }

  String _getCallRestaurantText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'يمكنك الاتصال على: 0555 123 4567';
      case 'tr':
        return 'Arayabilirsiniz: 0555 123 4567';
      default:
        return 'You can call: 0555 123 4567';
    }
  }
}

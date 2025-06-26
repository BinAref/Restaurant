import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/order.dart';
import '../services/previous_orders_service.dart';
import '../widgets/orders/order_card_widget.dart';
import 'cart_screen.dart';

class PreviousOrdersScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;

  const PreviousOrdersScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PreviousOrdersScreen> createState() => _PreviousOrdersScreenState();
}

class _PreviousOrdersScreenState extends State<PreviousOrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerAnimation;

  List<Order> _orders = [];
  OrderStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadOrders();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 3000),
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

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final orders =
          await PreviousOrdersService.getOrderHistory(widget.phoneNumber);
      final statistics =
          await PreviousOrdersService.getOrderStatistics(widget.phoneNumber);

      setState(() {
        _orders = orders;
        _statistics = statistics;
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

  List<Order> get _filteredOrders {
    switch (_selectedFilter) {
      case 'delivered':
        return _orders.where((o) => o.status == OrderStatus.delivered).toList();
      case 'cancelled':
        return _orders.where((o) => o.status == OrderStatus.cancelled).toList();
      case 'recent':
        final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
        return _orders.where((o) => o.orderTime.isAfter(oneWeekAgo)).toList();
      default:
        return _orders;
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
                else if (_orders.isEmpty)
                  Expanded(child: _buildEmptyState(isMobile))
                else ...[
                  // إحصائيات سريعة
                  if (_statistics != null) _buildStatistics(isMobile),

                  // فلاتر الطلبات
                  _buildOrderFilters(isMobile),

                  // قائمة الطلبات
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildOrdersList(isMobile),
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

          // أيقونة الطلبات
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
                      colors: [AppColors.traditionalRed, AppColors.darkRed],
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 22.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.traditionalRed.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
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
            onPressed: _loadOrders,
            icon: Icon(
              Icons.refresh,
              color: AppColors.traditionalRed,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 8,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.traditionalRed.withOpacity(0.1),
            AppColors.darkRed.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.traditionalRed.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.traditionalRed,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 8),
              Text(
                _getStatisticsTitle(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                Icons.shopping_bag,
                '${_statistics!.totalOrders}',
                _getTotalOrdersText(),
                isMobile,
              ),
              _buildStatItem(
                Icons.attach_money,
                '${_statistics!.totalSpent.toStringAsFixed(0)} ₺',
                _getTotalSpentText(),
                isMobile,
              ),
              _buildStatItem(
                Icons.trending_up,
                '${_statistics!.averageOrderValue} ₺',
                _getAverageOrderText(),
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
            color: AppColors.traditionalRed,
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

  Widget _buildOrderFilters(bool isMobile) {
    final filters = [
      {'id': 'all', 'label': _getAllOrdersText(), 'icon': Icons.list_alt},
      {
        'id': 'delivered',
        'label': _getDeliveredText(),
        'icon': Icons.check_circle
      },
      {'id': 'recent', 'label': _getRecentText(), 'icon': Icons.access_time},
      {'id': 'cancelled', 'label': _getCancelledText(), 'icon': Icons.cancel},
    ];

    return Container(
      height: isMobile ? 50 : 60,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: isMobile ? 16 : 18,
                    color: isSelected ? Colors.white : AppColors.traditionalRed,
                  ),
                  SizedBox(width: 4),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.traditionalRed,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['id'] as String;
                });
              },
              selectedColor: AppColors.traditionalRed,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: AppColors.traditionalRed.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(bool isMobile) {
    final filteredOrders = _filteredOrders;

    if (filteredOrders.isEmpty) {
      return _buildEmptyFilterState(isMobile);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.traditionalRed,
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return OrderCardWidget(
            order: order,
            selectedLanguage: widget.selectedLanguage,
            onReorder: () => _showReorderSuccess(),
            onViewDetails: () => _showOrderDetails(order),
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
            Icons.receipt_long,
            size: isMobile ? 80 : 100,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            _getNoOrdersTitle(),
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getNoOrdersMessage(),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _getStartOrderingText(),
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

  Widget _buildEmptyFilterState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: isMobile ? 60 : 80,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            _getNoFilterResultsTitle(),
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getNoFilterResultsMessage(),
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
                colors: [AppColors.traditionalRed, AppColors.darkRed],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 40 : 50),
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: isMobile ? 40 : 50,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.traditionalRed),
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
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traditionalRed,
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

  void _showReorderSuccess() {
    // إظهار رسالة نجاح مع خيار الذهاب للسلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getReorderSuccessText()),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: _getViewCartText(),
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  selectedLanguage: widget.selectedLanguage,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsModal(order),
    );
  }

  Widget _buildOrderDetailsModal(Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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

          // محتوى الطلب
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس الطلب
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: AppColors.traditionalRed,
                        size: isMobile ? 24 : 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getOrderDetailsTitle(),
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              order.id,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: AppColors.textLight,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // تفاصيل الطلب
                  _buildDetailSection(
                    _getOrderInfoText(),
                    [
                      _buildDetailRow(_getOrderDateText(),
                          _formatOrderDate(order.orderTime)),
                      _buildDetailRow(_getOrderStatusLabel(),
                          _getOrderStatusText(order.status)),
                      if (order.deliveredAt != null)
                        _buildDetailRow(_getDeliveryTimeText(),
                            _formatOrderDate(order.deliveredAt!)),
                      if (order.deliveryAddress != null)
                        _buildDetailRow(
                            _getDeliveryAddressText(), order.deliveryAddress!),
                    ],
                    isMobile,
                  ),

                  SizedBox(height: 20),

                  // الأصناف
                  _buildDetailSection(
                    _getOrderItemsText(),
                    order.items
                        .map((item) => _buildItemDetailRow(item, isMobile))
                        .toList(),
                    isMobile,
                  ),

                  if (order.notes != null) ...[
                    SizedBox(height: 20),
                    _buildDetailSection(
                      _getOrderNotesText(),
                      [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightCream,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.notes!,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 15,
                              color: AppColors.textDark,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      isMobile,
                    ),
                  ],

                  if (order.feedback != null) ...[
                    SizedBox(height: 20),
                    _buildDetailSection(
                      _getFeedbackText(),
                      [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (order.rating != null)
                                Row(
                                  children: [
                                    Text(_getRatingText()),
                                    SizedBox(width: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < order.rating!
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: AppColors.primaryGold,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 8),
                              Text(
                                order.feedback!,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 15,
                                  color: AppColors.textDark,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      isMobile,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // الإجمالي وزر إعادة الطلب
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: AppColors.lightCream,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getTotalText(),
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${order.totalPrice.toStringAsFixed(0)} ₺',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                if (order.canReorder) ...[
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _reorderFromDetails(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            _getReorderText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      String title, List<Widget> children, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailRow(OrderItem item, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.traditionalRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.getName(widget.selectedLanguage),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (item.notes != null)
                  Text(
                    item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(0)} ₺',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _reorderFromDetails(Order order) {
    // نفس منطق إعادة الطلب من البطاقة
    _showReorderSuccess();
  }

  String _formatOrderDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getOrderStatusText(OrderStatus status) {
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

  // النصوص المترجمة
  String _getPageTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'طلباتي المفضلة';
      case 'tr':
        return 'Favori Siparişlerim';
      default:
        return 'My Favorite Orders';
    }
  }

  String _getPageSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تاريخ طلباتك وإعادة طلبها';
      case 'tr':
        return 'Sipariş geçmişiniz ve tekrar sipariş';
      default:
        return 'Your order history and reorder';
    }
  }

  String _getStatisticsTitle() {
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

  String _getAverageOrderText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'متوسط الطلب';
      case 'tr':
        return 'Ortalama Sipariş';
      default:
        return 'Average Order';
    }
  }

  String _getAllOrdersText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جميع الطلبات';
      case 'tr':
        return 'Tüm Siparişler';
      default:
        return 'All Orders';
    }
  }

  String _getDeliveredText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'مُسلم';
      case 'tr':
        return 'Teslim Edildi';
      default:
        return 'Delivered';
    }
  }

  String _getRecentText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حديث';
      case 'tr':
        return 'Yakın Zamanlı';
      default:
        return 'Recent';
    }
  }

  String _getCancelledText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملغي';
      case 'tr':
        return 'İptal Edildi';
      default:
        return 'Cancelled';
    }
  }

  String _getLoadingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جاري تحميل طلباتك...';
      case 'tr':
        return 'Siparişleriniz yükleniyor...';
      default:
        return 'Loading your orders...';
    }
  }

  String _getNoOrdersTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد طلبات سابقة';
      case 'tr':
        return 'Önceki Sipariş Yok';
      default:
        return 'No Previous Orders';
    }
  }

  String _getNoOrdersMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لم تقم بأي طلبات حتى الآن\nابدأ أول طلب لك الآن!';
      case 'tr':
        return 'Henüz hiç sipariş vermediniz\nİlk siparişinizi şimdi verin!';
      default:
        return 'You haven\'t placed any orders yet\nStart your first order now!';
    }
  }

  String _getStartOrderingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ابدأ الطلب';
      case 'tr':
        return 'Sipariş Vermeye Başla';
      default:
        return 'Start Ordering';
    }
  }

  String _getNoFilterResultsTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد نتائج';
      case 'tr':
        return 'Sonuç Bulunamadı';
      default:
        return 'No Results';
    }
  }

  String _getNoFilterResultsMessage() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد طلبات تطابق الفلتر المحدد';
      case 'tr':
        return 'Seçilen filtreyle eşleşen sipariş yok';
      default:
        return 'No orders match the selected filter';
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
        return 'حدث خطأ أثناء تحميل طلباتك\nحاول مرة أخرى';
      case 'tr':
        return 'Siparişleriniz yüklenirken hata oluştu\nTekrar deneyin';
      default:
        return 'Error occurred while loading your orders\nPlease try again';
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

  String _getReorderSuccessText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تمت إضافة الطلب للسلة بنجاح!';
      case 'tr':
        return 'Sipariş sepete başarıyla eklendi!';
      default:
        return 'Order added to cart successfully!';
    }
  }

  String _getViewCartText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عرض السلة';
      case 'tr':
        return 'Sepeti Görüntüle';
      default:
        return 'View Cart';
    }
  }

  String _getOrderDetailsTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تفاصيل الطلب';
      case 'tr':
        return 'Sipariş Detayları';
      default:
        return 'Order Details';
    }
  }

  String _getOrderInfoText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'معلومات الطلب';
      case 'tr':
        return 'Sipariş Bilgileri';
      default:
        return 'Order Information';
    }
  }

  String _getOrderDateText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تاريخ الطلب:';
      case 'tr':
        return 'Sipariş Tarihi:';
      default:
        return 'Order Date:';
    }
  }

  String _getOrderStatusLabel() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'حالة الطلب:';
      case 'tr':
        return 'Sipariş Durumu:';
      default:
        return 'Order Status:';
    }
  }

  String _getDeliveryTimeText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'وقت التسليم:';
      case 'tr':
        return 'Teslimat Zamanı:';
      default:
        return 'Delivery Time:';
    }
  }

  String _getDeliveryAddressText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'عنوان التسليم:';
      case 'tr':
        return 'Teslimat Adresi:';
      default:
        return 'Delivery Address:';
    }
  }

  String _getOrderItemsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'أصناف الطلب';
      case 'tr':
        return 'Sipariş Ürünleri';
      default:
        return 'Order Items';
    }
  }

  String _getOrderNotesText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ملاحظات الطلب';
      case 'tr':
        return 'Sipariş Notları';
      default:
        return 'Order Notes';
    }
  }

  String _getFeedbackText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'تقييمك';
      case 'tr':
        return 'Değerlendirmeniz';
      default:
        return 'Your Feedback';
    }
  }

  String _getRatingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'التقييم:';
      case 'tr':
        return 'Puan:';
      default:
        return 'Rating:';
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
        return 'إعادة طلب نفس الأصناف';
      case 'tr':
        return 'Aynı Ürünleri Tekrar Sipariş Et';
      default:
        return 'Reorder Same Items';
    }
  }
}

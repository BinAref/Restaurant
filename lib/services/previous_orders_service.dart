import 'dart:async';
import 'dart:math';
import '../models/order.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';

class PreviousOrdersService {
  // جلب الطلبات السابقة بناءً على رقم الهاتف
  static Future<List<Order>> getOrderHistory(String phoneNumber) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));

    // محاكاة احتمالية فشل قليلة (5%)
    if (Random().nextInt(100) < 5) {
      throw Exception('فشل في تحميل تاريخ الطلبات');
    }

    return _generateOrderHistory(phoneNumber);
  }

  // جلب إحصائيات الطلبات
  static Future<OrderStatistics> getOrderStatistics(String phoneNumber) async {
    await Future.delayed(Duration(milliseconds: 800));

    final orders = await getOrderHistory(phoneNumber);
    return _calculateStatistics(orders);
  }

  // إعادة طلب
  static Future<String> reorderOrder(String orderId, String phoneNumber) async {
    await Future.delayed(Duration(seconds: 1));

    // محاكاة نجاح إعادة الطلب (95% نجاح)
    if (Random().nextInt(100) < 95) {
      final newOrderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      return newOrderId;
    } else {
      throw Exception('فشل في إعادة الطلب، حاول مرة أخرى');
    }
  }

  // تقييم الطلب
  static Future<bool> rateOrder(
      String orderId, int rating, String? feedback) async {
    await Future.delayed(Duration(milliseconds: 500));
    return true; // نجاح التقييم دائماً
  }

  // إنشاء تاريخ طلبات وهمي
  static List<Order> _generateOrderHistory(String phoneNumber) {
    final random = Random(phoneNumber.hashCode);
    final orders = <Order>[];
    final menuItems = MenuService.getMenuItems();

    // عدد الطلبات بناءً على رقم الهاتف (3-15 طلب)
    final orderCount = 3 + random.nextInt(13);

    for (int i = 0; i < orderCount; i++) {
      final orderId = 'ORD${1000 + i + random.nextInt(9000)}';
      final orderDate =
          DateTime.now().subtract(Duration(days: random.nextInt(90) + 1));

      // عدد الأصناف في كل طلب (1-5 أصناف)
      final itemsCount = 1 + random.nextInt(5);
      final orderItems = <OrderItem>[];
      final selectedItems = <MenuItem>[];

      // اختيار أصناف عشوائية
      for (int j = 0; j < itemsCount; j++) {
        MenuItem item;
        do {
          item = menuItems[random.nextInt(menuItems.length)];
        } while (selectedItems.contains(item));

        selectedItems.add(item);

        final quantity = 1 + random.nextInt(3);
        orderItems.add(OrderItem(
          menuItem: item,
          quantity: quantity,
          unitPrice: item.price,
          notes: random.nextInt(4) == 0 ? _getRandomNote(random) : null,
        ));
      }

      final totalPrice =
          orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);

      // تحديد حالة الطلب (معظم الطلبات القديمة مسلمة)
      OrderStatus status;
      DateTime? deliveredAt;
      int? rating;
      String? feedback;

      if (i < orderCount - 2) {
        // الطلبات القديمة مسلمة
        status = OrderStatus.delivered;
        deliveredAt = orderDate.add(Duration(minutes: 30 + random.nextInt(60)));

        // إضافة تقييم لبعض الطلبات
        if (random.nextInt(3) == 0) {
          rating = 3 + random.nextInt(3); // تقييم من 3-5
          if (rating >= 4) {
            feedback = _getPositiveFeedback(random);
          }
        }
      } else if (i == orderCount - 1) {
        // الطلب الأخير قد يكون قيد التحضير
        final statuses = [
          OrderStatus.confirmed,
          OrderStatus.preparing,
          OrderStatus.ready,
          OrderStatus.delivered,
        ];
        status = statuses[random.nextInt(statuses.length)];

        if (status == OrderStatus.delivered) {
          deliveredAt =
              orderDate.add(Duration(minutes: 30 + random.nextInt(60)));
        }
      } else {
        // طلب متوسط
        status = random.nextInt(10) == 0
            ? OrderStatus.cancelled
            : OrderStatus.delivered;

        if (status == OrderStatus.delivered) {
          deliveredAt =
              orderDate.add(Duration(minutes: 30 + random.nextInt(60)));
        }
      }

      orders.add(Order(
        id: orderId,
        customerPhone: phoneNumber,
        items: orderItems,
        totalPrice: totalPrice,
        orderTime: orderDate,
        status: status,
        notes: random.nextInt(5) == 0 ? _getRandomOrderNote(random) : null,
        deliveryAddress:
            random.nextInt(3) == 0 ? _getRandomAddress(random) : null,
        deliveredAt: deliveredAt,
        rating: rating,
        feedback: feedback,
      ));
    }

    // ترتيب الطلبات من الأحدث للأقدم
    orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    return orders;
  }

  static OrderStatistics _calculateStatistics(List<Order> orders) {
    final deliveredOrders =
        orders.where((o) => o.status == OrderStatus.delivered).toList();
    final totalSpent =
        deliveredOrders.fold(0.0, (sum, order) => sum + order.totalPrice);
    final averageOrderValue = deliveredOrders.isNotEmpty
        ? (totalSpent / deliveredOrders.length).round()
        : 0;

    // حساب التصنيفات المفضلة
    final categoryCount = <String, int>{};
    final itemCount = <String, int>{};

    for (final order in deliveredOrders) {
      for (final item in order.items) {
        final categoryId = item.menuItem.categoryId;
        categoryCount[categoryId] =
            (categoryCount[categoryId] ?? 0) + item.quantity;
        itemCount[item.menuItem.id] =
            (itemCount[item.menuItem.id] ?? 0) + item.quantity;
      }
    }

    // أكثر 3 أصناف طلباً
    final favoriteItems = itemCount.entries.map((e) => e.key).take(3).toList();

    // طلبات هذا الشهر والشهر الماضي
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final ordersThisMonth =
        orders.where((o) => o.orderTime.isAfter(thisMonthStart)).length;

    final ordersLastMonth = orders
        .where((o) =>
            o.orderTime.isAfter(lastMonthStart) &&
            o.orderTime.isBefore(thisMonthStart))
        .length;

    return OrderStatistics(
      totalOrders: deliveredOrders.length,
      totalSpent: totalSpent,
      averageOrderValue: averageOrderValue,
      favoriteCategories: categoryCount,
      favoriteItems: favoriteItems,
      ordersThisMonth: ordersThisMonth,
      ordersLastMonth: ordersLastMonth,
    );
  }

  static String _getRandomNote(Random random) {
    final notes = [
      'بدون بصل',
      'بدون طماطم',
      'إضافة صلصة حارة',
      'طبخ جيد',
      'خفيف الملح',
      'إضافة ليمون',
    ];
    return notes[random.nextInt(notes.length)];
  }

  static String _getRandomOrderNote(Random random) {
    final notes = [
      'توصيل سريع من فضلك',
      'اتصل عند الوصول',
      'الطابق الثاني',
      'مبنى رقم 5',
      'طلب للمكتب',
    ];
    return notes[random.nextInt(notes.length)];
  }

  static String _getRandomAddress(Random random) {
    final addresses = [
      'شارع الاستقلال، رقم 15',
      'حي السلطان أحمد، مبنى 22',
      'شارع الفاتح، الطابق 3',
      'منطقة تقسيم، رقم 8',
      'شارع بشكتاش، مجمع الأعمال',
    ];
    return addresses[random.nextInt(addresses.length)];
  }

  static String _getPositiveFeedback(Random random) {
    final feedbacks = [
      'طعام لذيذ وتوصيل سريع!',
      'جودة ممتازة كالعادة',
      'المندي كان رائعاً',
      'خدمة ممتازة شكراً لكم',
      'أفضل مطعم في المنطقة',
    ];
    return feedbacks[random.nextInt(feedbacks.length)];
  }
}

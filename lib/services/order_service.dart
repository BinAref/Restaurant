import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/order.dart';
import '../providers/cart_provider.dart';

class OrderService {
  static int _orderCounter = 1000;

  // إرسال طلب جديد
  static Future<OrderResponse> submitOrder({
    required String phoneNumber,
    required Map<String, dynamic> orderData,
    String? deliveryAddress,
    String? specialInstructions,
  }) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(seconds: 2));

    // محاكاة احتمالية فشل قليلة (5%)
    if (Random().nextInt(100) < 5) {
      throw OrderException('فشل في معالجة الطلب، حاول مرة أخرى');
    }

    // إنشاء رقم طلب جديد
    final orderId = 'ORD${_orderCounter++}';

    // محاكاة إرسال البيانات إلى الخادم
    final requestBody = {
      'order_id': orderId,
      'customer_phone': phoneNumber,
      'order_data': orderData,
      'delivery_address': deliveryAddress,
      'special_instructions': specialInstructions,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    print('إرسال طلب إلى API: ${jsonEncode(requestBody)}');

    // محاكاة رد الخادم
    return OrderResponse(
      orderId: orderId,
      status: OrderStatus.pending,
      estimatedDeliveryTime: DateTime.now().add(
        Duration(minutes: 30 + Random().nextInt(30)),
      ),
      message: 'تم استلام طلبك بنجاح',
    );
  }

  // متابعة حالة الطلب
  static Future<OrderStatus> getOrderStatus(String orderId) async {
    await Future.delayed(Duration(seconds: 1));

    // محاكاة تطور حالة الطلب
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];

    // إرجاع حالة عشوائية لأغراض العرض
    return statuses[Random().nextInt(statuses.length)];
  }

  // إلغاء الطلب
  static Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(Duration(seconds: 1));

    // محاكاة نجاح الإلغاء (90% نجاح)
    return Random().nextInt(100) < 90;
  }

  // الحصول على تاريخ الطلبات
  static Future<List<OrderHistoryItem>> getOrderHistory(
      String phoneNumber) async {
    await Future.delayed(Duration(seconds: 1));

    // بيانات وهمية لتاريخ الطلبات
    return [
      OrderHistoryItem(
        orderId: 'ORD0998',
        date: DateTime.now().subtract(Duration(days: 2)),
        totalPrice: 85.0,
        status: OrderStatus.delivered,
        itemsCount: 3,
      ),
      OrderHistoryItem(
        orderId: 'ORD0997',
        date: DateTime.now().subtract(Duration(days: 5)),
        totalPrice: 42.0,
        status: OrderStatus.delivered,
        itemsCount: 2,
      ),
      OrderHistoryItem(
        orderId: 'ORD0996',
        date: DateTime.now().subtract(Duration(days: 8)),
        totalPrice: 67.0,
        status: OrderStatus.cancelled,
        itemsCount: 4,
      ),
    ];
  }
}

class OrderResponse {
  final String orderId;
  final OrderStatus status;
  final DateTime estimatedDeliveryTime;
  final String message;

  OrderResponse({
    required this.orderId,
    required this.status,
    required this.estimatedDeliveryTime,
    required this.message,
  });
}

class OrderHistoryItem {
  final String orderId;
  final DateTime date;
  final double totalPrice;
  final OrderStatus status;
  final int itemsCount;

  OrderHistoryItem({
    required this.orderId,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.itemsCount,
  });
}

class OrderException implements Exception {
  final String message;
  OrderException(this.message);

  @override
  String toString() => message;
}

import 'menu_item.dart';

enum OrderStatus {
  pending, // في الانتظار
  confirmed, // مؤكد
  preparing, // قيد التحضير
  ready, // جاهز
  delivered, // تم التسليم
  cancelled // ملغي
}

class Order {
  final String id;
  final String customerPhone;
  final List<OrderItem> items;
  final double totalPrice;
  final DateTime orderTime;
  final OrderStatus status;
  final String? notes;
  final String? deliveryAddress;
  final DateTime? deliveredAt;
  final int? rating; // تقييم من 1-5
  final String? feedback; // تعليق العميل

  Order({
    required this.id,
    required this.customerPhone,
    required this.items,
    required this.totalPrice,
    required this.orderTime,
    required this.status,
    this.notes,
    this.deliveryAddress,
    this.deliveredAt,
    this.rating,
    this.feedback,
  });

  // حساب عدد الأصناف الإجمالي
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // الحصول على الصنف الأكثر طلباً
  OrderItem? get mostOrderedItem {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.quantity > b.quantity ? a : b);
  }

  // التحقق من إمكانية إعادة الطلب
  bool get canReorder => status == OrderStatus.delivered;

  // الحصول على وصف مختصر للطلب
  String getOrderSummary(String language) {
    if (items.isEmpty) return '';

    if (items.length == 1) {
      final item = items.first;
      switch (language) {
        case 'ar':
          return '${item.menuItem.nameAr} × ${item.quantity}';
        case 'tr':
          return '${item.menuItem.nameTr} × ${item.quantity}';
        default:
          return '${item.menuItem.nameEn} × ${item.quantity}';
      }
    } else {
      switch (language) {
        case 'ar':
          return '${items.length} أصناف مختلفة';
        case 'tr':
          return '${items.length} farklı ürün';
        default:
          return '${items.length} different items';
      }
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerPhone: json['customer_phone'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalPrice: json['total_price'].toDouble(),
      orderTime: DateTime.parse(json['order_time']),
      status: OrderStatus.values[json['status']],
      notes: json['notes'],
      deliveryAddress: json['delivery_address'],
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      rating: json['rating'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_phone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
      'order_time': orderTime.toIso8601String(),
      'status': status.index,
      'notes': notes,
      'delivery_address': deliveryAddress,
      'delivered_at': deliveredAt?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
    };
  }
}

class OrderItem {
  final MenuItem menuItem;
  final int quantity;
  final double unitPrice;
  final String? notes;

  OrderItem({
    required this.menuItem,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItem: MenuItem.fromJson(json['menu_item']),
      quantity: json['quantity'],
      unitPrice: json['unit_price'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'notes': notes,
      'total_price': totalPrice,
    };
  }
}

// إحصائيات الطلبات
class OrderStatistics {
  final int totalOrders;
  final double totalSpent;
  final int averageOrderValue;
  final Map<String, int> favoriteCategories;
  final List<String> favoriteItems;
  final int ordersThisMonth;
  final int ordersLastMonth;

  OrderStatistics({
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    required this.favoriteCategories,
    required this.favoriteItems,
    required this.ordersThisMonth,
    required this.ordersLastMonth,
  });
}

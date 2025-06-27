class FavoriteItem {
  final String id;
  final String menuItemId;
  final DateTime addedAt;
  final int orderCount; // عدد مرات الطلب
  final DateTime lastOrderDate; // تاريخ آخر طلب
  final double averageRating; // متوسط التقييم

  FavoriteItem({
    required this.id,
    required this.menuItemId,
    required this.addedAt,
    this.orderCount = 0,
    required this.lastOrderDate,
    this.averageRating = 0.0,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      menuItemId: json['menu_item_id'],
      addedAt: DateTime.parse(json['added_at']),
      orderCount: json['order_count'] ?? 0,
      lastOrderDate: DateTime.parse(json['last_order_date']),
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'added_at': addedAt.toIso8601String(),
      'order_count': orderCount,
      'last_order_date': lastOrderDate.toIso8601String(),
      'average_rating': averageRating,
    };
  }
}

class FavoriteStatistics {
  final int totalFavorites;
  final String mostOrderedCategoryId;
  final String mostOrderedItemId;
  final double averageRating;
  final DateTime lastAddedDate;

  FavoriteStatistics({
    required this.totalFavorites,
    required this.mostOrderedCategoryId,
    required this.mostOrderedItemId,
    required this.averageRating,
    required this.lastAddedDate,
  });
}

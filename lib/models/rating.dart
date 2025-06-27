class Rating {
  final String id;
  final String orderId;
  final String customerPhone;
  final int stars; // 1-5
  final String? feedback;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Rating({
    required this.id,
    required this.orderId,
    required this.customerPhone,
    required this.stars,
    this.feedback,
    required this.createdAt,
    this.metadata,
  });

  // التحقق من صحة التقييم
  bool get isValid => stars >= 1 && stars <= 5;

  // نوع التقييم
  RatingType get ratingType {
    switch (stars) {
      case 1:
        return RatingType.veryPoor;
      case 2:
        return RatingType.poor;
      case 3:
        return RatingType.average;
      case 4:
        return RatingType.good;
      case 5:
        return RatingType.excellent;
      default:
        return RatingType.average;
    }
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_phone': customerPhone,
      'stars': stars,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // إنشاء من JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      orderId: json['order_id'],
      customerPhone: json['customer_phone'],
      stars: json['stars'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }
}

enum RatingType {
  veryPoor,
  poor,
  average,
  good,
  excellent,
}

// نموذج ملخص التقييمات
class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> starsCount;
  final List<Rating> recentRatings;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.starsCount,
    required this.recentRatings,
  });

  // حساب النسبة المئوية لكل تقييم
  double getPercentageForStars(int stars) {
    if (totalRatings == 0) return 0.0;
    return (starsCount[stars] ?? 0) / totalRatings * 100;
  }
}

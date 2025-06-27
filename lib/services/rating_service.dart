import 'dart:async';
import 'dart:math';
import '../models/rating.dart';

class RatingService {
  // إرسال التقييم لـ API وهمي
  static Future<bool> submitRating({
    required String orderId,
    required String customerPhone,
    required int stars,
    String? feedback,
  }) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));

    // محاكاة احتمالية فشل قليلة (5%)
    if (Random().nextInt(100) < 5) {
      throw Exception('فشل في إرسال التقييم، حاول مرة أخرى');
    }

    // إنشاء التقييم
    final rating = Rating(
      id: 'RAT${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      customerPhone: customerPhone,
      stars: stars,
      feedback: feedback?.trim().isEmpty == true ? null : feedback?.trim(),
      createdAt: DateTime.now(),
      metadata: {
        'platform': 'mobile',
        'version': '1.0.0',
        'submitted_from': 'rating_screen',
      },
    );

    // حفظ محلي وهمي
    await _saveRatingLocally(rating);

    // محاكاة إرسال للخادم
    await _sendToServer(rating);

    return true;
  }

  // جلب التقييمات للعميل
  static Future<List<Rating>> getUserRatings(String customerPhone) async {
    await Future.delayed(Duration(milliseconds: 800));
    return _generateUserRatings(customerPhone);
  }

  // جلب ملخص التقييمات للمطعم
  static Future<RatingSummary> getRatingSummary() async {
    await Future.delayed(Duration(seconds: 1));
    return _generateRatingSummary();
  }

  // حفظ محلي وهمي
  static Future<void> _saveRatingLocally(Rating rating) async {
    // محاكاة حفظ في قاعدة البيانات المحلية
    await Future.delayed(Duration(milliseconds: 200));
    print('تم حفظ التقييم محلياً: ${rating.toJson()}');
  }

  // إرسال للخادم وهمي
  static Future<void> _sendToServer(Rating rating) async {
    // محاكاة POST /api/rating
    await Future.delayed(Duration(milliseconds: 500));

    final response = {
      'success': true,
      'message': 'تم إرسال التقييم بنجاح',
      'rating_id': rating.id,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('API Response: $response');
  }

  // إنشاء تقييمات وهمية للمستخدم
  static List<Rating> _generateUserRatings(String customerPhone) {
    final random = Random(customerPhone.hashCode);
    final ratings = <Rating>[];

    // عدد التقييمات السابقة (0-8)
    final ratingsCount = random.nextInt(9);

    for (int i = 0; i < ratingsCount; i++) {
      final rating = Rating(
        id: 'RAT${1000 + i + random.nextInt(9000)}',
        orderId: 'ORD${2000 + i + random.nextInt(8000)}',
        customerPhone: customerPhone,
        stars: 1 + random.nextInt(5),
        feedback: random.nextInt(3) == 0 ? _getRandomFeedback(random) : null,
        createdAt: DateTime.now().subtract(
          Duration(days: random.nextInt(30) + 1),
        ),
        metadata: {
          'platform': 'mobile',
          'version': '1.0.0',
        },
      );

      ratings.add(rating);
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ratings;
  }

  // إنشاء ملخص تقييمات وهمي
  static RatingSummary _generateRatingSummary() {
    final random = Random();

    // توزيع عشوائي للتقييمات
    final starsCount = {
      5: 120 + random.nextInt(80),
      4: 85 + random.nextInt(60),
      3: 45 + random.nextInt(40),
      2: 15 + random.nextInt(25),
      1: 5 + random.nextInt(15),
    };

    final totalRatings = starsCount.values.reduce((a, b) => a + b);
    final averageRating = (starsCount[5]! * 5 +
            starsCount[4]! * 4 +
            starsCount[3]! * 3 +
            starsCount[2]! * 2 +
            starsCount[1]! * 1) /
        totalRatings;

    return RatingSummary(
      averageRating: averageRating,
      totalRatings: totalRatings,
      starsCount: starsCount,
      recentRatings: _generateRecentRatings(),
    );
  }

  // إنشاء تقييمات حديثة وهمية
  static List<Rating> _generateRecentRatings() {
    final random = Random();
    final ratings = <Rating>[];

    for (int i = 0; i < 5; i++) {
      final rating = Rating(
        id: 'RAT${9000 + i + random.nextInt(1000)}',
        orderId: 'ORD${8000 + i + random.nextInt(2000)}',
        customerPhone:
            '+905${random.nextInt(100000000).toString().padLeft(8, '0')}',
        stars: 3 + random.nextInt(3), // 3-5 نجوم للتقييمات الحديثة
        feedback: random.nextInt(2) == 0 ? _getRandomFeedback(random) : null,
        createdAt: DateTime.now().subtract(
          Duration(hours: random.nextInt(48) + 1),
        ),
        metadata: {'platform': 'mobile'},
      );

      ratings.add(rating);
    }

    return ratings;
  }

  // تعليقات عشوائية وهمية
  static String _getRandomFeedback(Random random) {
    final positiveFeedbacks = [
      'طعام لذيذ جداً وخدمة ممتازة',
      'أفضل مطعم جربته في المنطقة',
      'جودة عالية وأسعار معقولة',
      'طلب سريع وطازج',
      'سأطلب مرة أخرى بالتأكيد',
      'المندي رائع والخدمة سريعة',
      'نكهات أصيلة ومميزة',
      'تجربة رائعة، شكراً لكم',
    ];

    final neutralFeedbacks = [
      'جيد بشكل عام',
      'مقبول ولكن يمكن تحسينه',
      'خدمة عادية',
      'طعم جيد لكن التوصيل بطيء',
      'لا بأس به',
    ];

    final negativeFeedbacks = [
      'التوصيل تأخر كثيراً',
      'الطعام لم يكن ساخناً',
      'الطلب لم يكن كاملاً',
      'جودة أقل من المتوقع',
      'خدمة العملاء تحتاج تحسين',
    ];

    final allFeedbacks = [
      ...positiveFeedbacks,
      ...neutralFeedbacks,
      ...negativeFeedbacks,
    ];

    return allFeedbacks[random.nextInt(allFeedbacks.length)];
  }
}

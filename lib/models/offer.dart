class Offer {
  final String id;
  final String titleAr;
  final String titleEn;
  final String titleTr;
  final String descriptionAr;
  final String descriptionEn;
  final String descriptionTr;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double discountPercentage;
  final double? originalPrice;
  final double? discountedPrice;
  final OfferType type;
  final bool isActive;
  final List<String> applicableItems; // معرفات الأطباق المشمولة
  final int maxUses;
  final int currentUses;
  final List<String> tags; // مثل "جديد"، "محدود"، "شائع"

  Offer({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.titleTr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.descriptionTr,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.discountPercentage,
    this.originalPrice,
    this.discountedPrice,
    required this.type,
    this.isActive = true,
    required this.applicableItems,
    required this.maxUses,
    this.currentUses = 0,
    required this.tags,
  });

  String getTitle(String language) {
    switch (language) {
      case 'ar':
        return titleAr;
      case 'tr':
        return titleTr;
      default:
        return titleEn;
    }
  }

  String getDescription(String language) {
    switch (language) {
      case 'ar':
        return descriptionAr;
      case 'tr':
        return descriptionTr;
      default:
        return descriptionEn;
    }
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isStarted => DateTime.now().isAfter(startDate);
  bool get isValid =>
      isActive && isStarted && !isExpired && currentUses < maxUses;

  int get daysLeft {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  String get timeLeft {
    if (isExpired) return '';
    final duration = endDate.difference(DateTime.now());

    if (duration.inDays > 0) {
      return '${duration.inDays} أيام';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else {
      return '${duration.inMinutes} دقيقة';
    }
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      titleAr: json['title_ar'],
      titleEn: json['title_en'],
      titleTr: json['title_tr'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      descriptionTr: json['description_tr'],
      imageUrl: json['image_url'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      discountPercentage: json['discount_percentage'].toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      discountedPrice: json['discounted_price']?.toDouble(),
      type: OfferType.values[json['type']],
      isActive: json['is_active'] ?? true,
      applicableItems: List<String>.from(json['applicable_items'] ?? []),
      maxUses: json['max_uses'] ?? 1000,
      currentUses: json['current_uses'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'title_tr': titleTr,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'description_tr': descriptionTr,
      'image_url': imageUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'discount_percentage': discountPercentage,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'type': type.index,
      'is_active': isActive,
      'applicable_items': applicableItems,
      'max_uses': maxUses,
      'current_uses': currentUses,
      'tags': tags,
    };
  }
}

enum OfferType {
  percentage, // خصم بالنسبة المئوية
  fixedAmount, // خصم بمبلغ ثابت
  buyOneGetOne, // اشتري واحد واحصل على آخر
  freeDelivery, // توصيل مجاني
  combo, // عرض مجموعة
  newCustomer, // عرض العميل الجديد
  loyalty, // عرض الولاء
}

class PersonalizedOffers {
  final String customerPhone;
  final List<Offer> offers;
  final CustomerProfile profile;

  PersonalizedOffers({
    required this.customerPhone,
    required this.offers,
    required this.profile,
  });
}

class CustomerProfile {
  final String phone;
  final int totalOrders;
  final double totalSpent;
  final List<String> favoriteCategories;
  final List<String> favoriteItems;
  final DateTime lastOrderDate;
  final CustomerTier tier;

  CustomerProfile({
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    required this.favoriteCategories,
    required this.favoriteItems,
    required this.lastOrderDate,
    required this.tier,
  });
}

enum CustomerTier {
  bronze, // عميل جديد
  silver, // عميل منتظم
  gold, // عميل مميز
  platinum, // عميل VIP
}

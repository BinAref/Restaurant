import 'dart:async';
import 'dart:math';
import '../models/offer.dart';

class OffersService {
  // محاكاة جلب العروض المخصصة بناءً على رقم الهاتف
  static Future<PersonalizedOffers> getPersonalizedOffers(
      String phoneNumber) async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));

    // محاكاة ملف العميل
    final profile = _generateCustomerProfile(phoneNumber);

    // إنشاء عروض مخصصة بناءً على ملف العميل
    final offers = _generatePersonalizedOffers(profile);

    return PersonalizedOffers(
      customerPhone: phoneNumber,
      offers: offers,
      profile: profile,
    );
  }

  // محاكاة جلب جميع العروض المتاحة
  static Future<List<Offer>> getAllOffers() async {
    await Future.delayed(Duration(seconds: 1));
    return _getAllOffers();
  }

  // تطبيق عرض على الطلب
  static Future<bool> applyOffer(String offerId, String phoneNumber) async {
    await Future.delayed(Duration(milliseconds: 500));

    // محاكاة نجاح التطبيق (90% نجاح)
    return Random().nextInt(100) < 90;
  }

  // إنشاء ملف عميل وهمي
  static CustomerProfile _generateCustomerProfile(String phoneNumber) {
    final random = Random(phoneNumber.hashCode);

    // تحديد مستوى العميل بناءً على رقم الهاتف
    final totalOrders = 5 + random.nextInt(50);
    final totalSpent = 200.0 + random.nextDouble() * 2000;

    CustomerTier tier;
    if (totalSpent > 1500) {
      tier = CustomerTier.platinum;
    } else if (totalSpent > 800) {
      tier = CustomerTier.gold;
    } else if (totalSpent > 300) {
      tier = CustomerTier.silver;
    } else {
      tier = CustomerTier.bronze;
    }

    final categories = [
      'main_dishes',
      'grills',
      'appetizers',
      'salads',
      'beverages',
      'desserts'
    ];
    final favoriteCategories = categories.take(2 + random.nextInt(3)).toList();

    return CustomerProfile(
      phone: phoneNumber,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      favoriteCategories: favoriteCategories,
      favoriteItems: ['main_1', 'grill_1', 'app_1'], // عناصر مفضلة وهمية
      lastOrderDate:
          DateTime.now().subtract(Duration(days: random.nextInt(30))),
      tier: tier,
    );
  }

  // إنشاء عروض مخصصة بناءً على ملف العميل
  static List<Offer> _generatePersonalizedOffers(CustomerProfile profile) {
    final allOffers = _getAllOffers();
    final personalizedOffers = <Offer>[];

    // عروض خاصة بمستوى العميل
    personalizedOffers.addAll(allOffers
        .where((offer) => _isOfferSuitableForTier(offer, profile.tier)));

    // عروض بناءً على التفضيلات
    personalizedOffers.addAll(allOffers.where((offer) => offer.applicableItems
        .any((item) =>
            profile.favoriteCategories.any((cat) => item.startsWith(cat)))));

    // إزالة المكررات والحفاظ على أفضل 8 عروض
    final uniqueOffers = personalizedOffers.toSet().toList();
    uniqueOffers.shuffle();

    return uniqueOffers.take(8).toList();
  }

  static bool _isOfferSuitableForTier(Offer offer, CustomerTier tier) {
    switch (tier) {
      case CustomerTier.platinum:
        return offer.discountPercentage >= 15;
      case CustomerTier.gold:
        return offer.discountPercentage >= 10;
      case CustomerTier.silver:
        return offer.discountPercentage >= 5;
      case CustomerTier.bronze:
        return offer.type == OfferType.newCustomer ||
            offer.discountPercentage <= 15;
    }
  }

  // قائمة العروض الوهمية
  static List<Offer> _getAllOffers() {
    final now = DateTime.now();

    return [
      // عرض العميل الجديد
      Offer(
        id: 'offer_001',
        titleAr: 'ترحيب بالعميل الجديد',
        titleEn: 'Welcome New Customer',
        titleTr: 'Yeni Müşteri Karşılaması',
        descriptionAr:
            'احصل على خصم 25% على طلبك الأول معنا! مرحباً بك في عائلة مطعم الأصالة',
        descriptionEn:
            'Get 25% off your first order with us! Welcome to Authentic Restaurant family',
        descriptionTr:
            'İlk siparişinizde %25 indirim! Asalet Restaurant ailesine hoş geldiniz',
        imageUrl:
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400',
        startDate: now.subtract(Duration(days: 30)),
        endDate: now.add(Duration(days: 30)),
        discountPercentage: 25.0,
        type: OfferType.newCustomer,
        applicableItems: ['all'],
        maxUses: 1000,
        currentUses: 45,
        tags: ['جديد', 'محدود'],
      ),

      // عرض المندي الخاص
      Offer(
        id: 'offer_002',
        titleAr: 'عرض المندي الملكي',
        titleEn: 'Royal Mandi Special',
        titleTr: 'Kraliyet Mandi Özel',
        descriptionAr:
            'طبق المندي اليمني الأصيل بخصم 30%! تجربة طعم لا تُنسى مع الأرز المبهر واللحم الطري',
        descriptionEn:
            'Authentic Yemeni Mandi with 30% off! Unforgettable taste experience with spiced rice and tender meat',
        descriptionTr:
            'Özgün Yemen Mandisi %30 indirimle! Baharatli pilav ve yumuşak et ile unutulmaz lezzet deneyimi',
        imageUrl:
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',
        startDate: now.subtract(Duration(days: 10)),
        endDate: now.add(Duration(days: 20)),
        discountPercentage: 30.0,
        originalPrice: 45.0,
        discountedPrice: 31.5,
        type: OfferType.percentage,
        applicableItems: ['main_1'],
        maxUses: 500,
        currentUses: 123,
        tags: ['شائع', 'وقت محدود'],
      ),

      // عرض كومبو المشاوي
      Offer(
        id: 'offer_003',
        titleAr: 'كومبو المشاوي العائلي',
        titleEn: 'Family Grill Combo',
        titleTr: 'Aile Izgara Combo',
        descriptionAr:
            'وجبة عائلية مميزة: شاورما + كباب + دجاج مشوي + مقبلات + مشروبات بسعر خاص',
        descriptionEn:
            'Special family meal: Shawarma + Kebab + Grilled Chicken + Appetizers + Drinks at special price',
        descriptionTr:
            'Özel aile yemeği: Şavarma + Kebap + Izgara Tavuk + Mezeler + İçecekler özel fiyatla',
        imageUrl:
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
        startDate: now.subtract(Duration(days: 5)),
        endDate: now.add(Duration(days: 15)),
        discountPercentage: 40.0,
        originalPrice: 120.0,
        discountedPrice: 72.0,
        type: OfferType.combo,
        applicableItems: ['grill_1', 'grill_2', 'grill_3', 'app_1', 'bev_1'],
        maxUses: 200,
        currentUses: 67,
        tags: ['عائلي', 'وفير'],
      ),

      // عرض اشتري واحد واحصل على آخر
      Offer(
        id: 'offer_004',
        titleAr: 'اشتري حمص واحصل على بابا غنوج مجاناً',
        titleEn: 'Buy Hummus Get Baba Ghanoush Free',
        titleTr: 'Humus Al Baba Ganuş Bedava',
        descriptionAr:
            'عند طلب الحمص بالطحينة، احصل على بابا غنوج مجاناً! عرض محدود لعشاق المقبلات',
        descriptionEn:
            'Order Hummus with Tahini and get Baba Ghanoush free! Limited offer for appetizer lovers',
        descriptionTr:
            'Tahinli Humus sipariş edin ve Baba Ganuş bedava alın! Meze severler için sınırlı teklif',
        imageUrl:
            'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400',
        startDate: now.subtract(Duration(days: 3)),
        endDate: now.add(Duration(days: 12)),
        discountPercentage: 50.0,
        type: OfferType.buyOneGetOne,
        applicableItems: ['app_1', 'app_2'],
        maxUses: 300,
        currentUses: 89,
        tags: ['مقبلات', 'محدود'],
      ),

      // عرض التوصيل المجاني
      Offer(
        id: 'offer_005',
        titleAr: 'توصيل مجاني للطلبات فوق 50 ليرة',
        titleEn: 'Free Delivery for Orders Over 50 TL',
        titleTr: '50 TL Üzeri Siparişlerde Ücretsiz Teslimat',
        descriptionAr:
            'استمتع بالتوصيل المجاني عند طلب بقيمة 50 ليرة أو أكثر. صالح لجميع المناطق داخل المدينة',
        descriptionEn:
            'Enjoy free delivery when ordering 50 TL or more. Valid for all areas within the city',
        descriptionTr:
            '50 TL ve üzeri siparişlerde ücretsiz teslimatın keyfini çıkarın. Şehir içi tüm bölgeler için geçerli',
        imageUrl:
            'https://images.unsplash.com/photo-1566576912219-aee5b9894853?w=400',
        startDate: now.subtract(Duration(days: 20)),
        endDate: now.add(Duration(days: 40)),
        discountPercentage: 100.0,
        type: OfferType.freeDelivery,
        applicableItems: ['all'],
        maxUses: 1000,
        currentUses: 234,
        tags: ['توصيل', 'ساري دائماً'],
      ),

      // عرض الحلويات
      Offer(
        id: 'offer_006',
        titleAr: 'ليلة الحلويات الشرقية',
        titleEn: 'Eastern Sweets Night',
        titleTr: 'Doğu Tatlıları Gecesi',
        descriptionAr:
            'خصم 35% على جميع الحلويات الشرقية! بقلاوة، كنافة، ومعمول بأفضل الأسعار',
        descriptionEn:
            '35% off all Eastern sweets! Baklava, Kunafa, and Maamoul at the best prices',
        descriptionTr:
            'Tüm Doğu tatlılarında %35 indirim! Baklava, Künefe ve Maamoul en iyi fiyatlarla',
        imageUrl:
            'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400',
        startDate: now.subtract(Duration(days: 7)),
        endDate: now.add(Duration(days: 10)),
        discountPercentage: 35.0,
        type: OfferType.percentage,
        applicableItems: ['dessert_1', 'dessert_2'],
        maxUses: 400,
        currentUses: 156,
        tags: ['حلويات', 'شرقي'],
      ),

      // عرض العميل المميز
      Offer(
        id: 'offer_007',
        titleAr: 'عرض العميل الذهبي',
        titleEn: 'Gold Customer Offer',
        titleTr: 'Altın Müşteri Teklifi',
        descriptionAr:
            'مخصص للعملاء المميزين! خصم 20% + طبق حلوى مجاني مع كل طلب فوق 80 ليرة',
        descriptionEn:
            'Exclusive for VIP customers! 20% off + free dessert with every order over 80 TL',
        descriptionTr:
            'VIP müşteriler için özel! 80 TL üzeri her siparişte %20 indirim + bedava tatlı',
        imageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',
        startDate: now.subtract(Duration(days: 15)),
        endDate: now.add(Duration(days: 25)),
        discountPercentage: 20.0,
        type: OfferType.loyalty,
        applicableItems: ['all'],
        maxUses: 150,
        currentUses: 43,
        tags: ['VIP', 'ذهبي'],
      ),

      // عرض الإفطار المتأخر
      Offer(
        id: 'offer_008',
        titleAr: 'فطار الويكند المميز',
        titleEn: 'Special Weekend Breakfast',
        titleTr: 'Özel Hafta Sonu Kahvaltısı',
        descriptionAr:
            'استمتع بوجبة إفطار شرقية مميزة في عطلة نهاية الأسبوع بخصم 15% + شاي بالنعناع مجاناً',
        descriptionEn:
            'Enjoy a special Eastern breakfast on weekends with 15% off + free mint tea',
        descriptionTr:
            'Hafta sonları özel Doğu kahvaltısının keyfini %15 indirim + bedava naneli çayla çıkarın',
        imageUrl:
            'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400',
        startDate: now.subtract(Duration(days: 5)),
        endDate: now.add(Duration(days: 30)),
        discountPercentage: 15.0,
        type: OfferType.percentage,
        applicableItems: ['app_1', 'app_2', 'salad_1', 'bev_1'],
        maxUses: 250,
        currentUses: 78,
        tags: ['إفطار', 'نهاية الأسبوع'],
      ),
    ];
  }
}

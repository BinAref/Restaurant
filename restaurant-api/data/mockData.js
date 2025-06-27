// بيانات وهمية شاملة للمطعم العربي

const registeredPhones = new Set([
  '+905501234567',
  '+905509876543',
  '+905507654321',
  '+905503456789',
  '+905502345678'
]);

const menuCategories = [
  {
    id: 'main_dishes',
    nameAr: 'الأطباق الرئيسية',
    nameEn: 'Main Dishes',
    nameTr: 'Ana Yemekler',
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    iconName: 'restaurant'
  },
  {
    id: 'grills',
    nameAr: 'المشاوي',
    nameEn: 'Grills',
    nameTr: 'Izgara',
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
    iconName: 'outdoor_grill'
  },
  {
    id: 'appetizers',
    nameAr: 'المقبلات',
    nameEn: 'Appetizers',
    nameTr: 'Mezeler',
    imageUrl: 'https://images.unsplash.com/photo-1541833089466-4e9bcbf2b5c6?w=400',
    iconName: 'tapas'
  },
  {
    id: 'beverages',
    nameAr: 'المشروبات',
    nameEn: 'Beverages',
    nameTr: 'İçecekler',
    imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400',
    iconName: 'local_cafe'
  },
  {
    id: 'desserts',
    nameAr: 'الحلويات',
    nameEn: 'Desserts',
    nameTr: 'Tatlılar',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    iconName: 'cake'
  }
];

const menuItems = [
  // الأطباق الرئيسية
  {
    id: 'main_1',
    categoryId: 'main_dishes',
    nameAr: 'المندي اليمني',
    nameEn: 'Yemeni Mandi',
    nameTr: 'Yemen Mandisi',
    descriptionAr: 'لحم خروف طري مطبوخ على الطريقة اليمنية التقليدية مع الأرز البسمتي المُعطر بالتوابل',
    descriptionEn: 'Tender lamb cooked in traditional Yemeni style with fragrant basmati rice and spices',
    descriptionTr: 'Geleneksel Yemen usulü pişirilmiş yumuşak kuzu eti, baharatli basmati pilavı ile',
    price: 85,
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: false,
    preparationTime: 35,
    ingredients: ['لحم خروف', 'أرز بسمتي', 'لومي', 'هيل', 'قرفة', 'ورق غار']
  },
  {
    id: 'main_2',
    categoryId: 'main_dishes',
    nameAr: 'الكبسة السعودية',
    nameEn: 'Saudi Kabsa',
    nameTr: 'Suudi Kabsası',
    descriptionAr: 'طبق تقليدي سعودي من الأرز المُتبل مع قطع الدجاج أو اللحم والخضار المشكلة',
    descriptionEn: 'Traditional Saudi dish of spiced rice with chicken or meat pieces and mixed vegetables',
    descriptionTr: 'Tavuk veya et parçaları ve karışık sebzelerle baharatli pirinç, geleneksel Suudi yemeği',
    price: 75,
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: true,
    preparationTime: 30,
    ingredients: ['دجاج', 'أرز بسمتي', 'جزر', 'بازلاء', 'بهارات مشكلة', 'زبيب']
  },

  // المشاوي
  {
    id: 'grill_1',
    categoryId: 'grills',
    nameAr: 'شاورما الدجاج',
    nameEn: 'Chicken Shawarma',
    nameTr: 'Tavuk Döner',
    descriptionAr: 'شرائح الدجاج المتبلة والمشوية مع الخضار الطازجة والصوص الخاص في خبز التورتيلا',
    descriptionEn: 'Marinated grilled chicken strips with fresh vegetables and special sauce in tortilla bread',
    descriptionTr: 'Marine edilmiş ızgara tavuk şeritleri, taze sebzeler ve özel sos ile tortilla ekmeğinde',
    price: 35,
    imageUrl: 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: false,
    preparationTime: 15,
    ingredients: ['دجاج', 'خبز تورتيلا', 'خس', 'طماطم', 'ثوميه', 'مخلل']
  },
  {
    id: 'grill_2',
    categoryId: 'grills',
    nameAr: 'كباب حلبي',
    nameEn: 'Aleppo Kebab',
    nameTr: 'Halep Kebabı',
    descriptionAr: 'كباب لحم مفروم مُتبل بالتوابل الحلبية الأصيلة ومشوي على الفحم',
    descriptionEn: 'Minced meat kebab seasoned with authentic Aleppo spices and grilled over charcoal',
    descriptionTr: 'Özgün Halep baharatları ile marine edilmiş kıyma kebabı, kömürde ızgara',
    price: 45,
    imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
    isAvailable: true,
    isPopular: false,
    isSpicy: true,
    preparationTime: 20,
    ingredients: ['لحم مفروم', 'بقدونس', 'بصل', 'بهارات حلبية', 'فلفل أحمر']
  },

  // المقبلات
  {
    id: 'app_1',
    categoryId: 'appetizers',
    nameAr: 'حمص بالطحينة',
    nameEn: 'Hummus with Tahini',
    nameTr: 'Tahinli Humus',
    descriptionAr: 'حمص مهروس ناعم مع الطحينة وزيت الزيتون والكمون وحبات الصنوبر',
    descriptionEn: 'Smooth mashed chickpeas with tahini, olive oil, cumin and pine nuts',
    descriptionTr: 'Tahin, zeytinyağı, kimyon ve çam fıstığı ile ezilmiş yumuşak nohut',
    price: 18,
    imageUrl: 'https://images.unsplash.com/photo-1541833089466-4e9bcbf2b5c6?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: false,
    preparationTime: 5,
    ingredients: ['حمص', 'طحينة', 'زيت زيتون', 'ثوم', 'كمون', 'صنوبر']
  },
  {
    id: 'app_2',
    categoryId: 'appetizers',
    nameAr: 'بابا غنوج',
    nameEn: 'Baba Ganoush',
    nameTr: 'Baba Ganuş',
    descriptionAr: 'باذنجان مشوي مهروس مع الطحينة والثوم وعصير الليمون',
    descriptionEn: 'Grilled eggplant mashed with tahini, garlic and lemon juice',
    descriptionTr: 'Közlenmiş patlıcan, tahin, sarımsak ve limon suyu ile ezilmiş',
    price: 20,
    imageUrl: 'https://images.unsplash.com/photo-1541833089466-4e9bcbf2b5c6?w=500',
    isAvailable: true,
    isPopular: false,
    isSpicy: false,
    preparationTime: 10,
    ingredients: ['باذنجان', 'طحينة', 'ثوم', 'عصير ليمون', 'زيت زيتون']
  },

  // المشروبات
  {
    id: 'drink_1',
    categoryId: 'beverages',
    nameAr: 'شاي بالنعناع',
    nameEn: 'Mint Tea',
    nameTr: 'Naneli Çay',
    descriptionAr: 'شاي أحمر تركي أصيل مُحضر مع أوراق النعناع الطازج والسكر',
    descriptionEn: 'Authentic Turkish red tea prepared with fresh mint leaves and sugar',
    descriptionTr: 'Taze nane yaprakları ve şeker ile hazırlanmış özgün Türk kırmızı çayı',
    price: 8,
    imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: false,
    preparationTime: 5,
    ingredients: ['شاي أحمر', 'نعناع طازج', 'سكر']
  },
  {
    id: 'drink_2',
    categoryId: 'beverages',
    nameAr: 'قهوة عربية',
    nameEn: 'Arabic Coffee',
    nameTr: 'Arap Kahvesi',
    descriptionAr: 'قهوة عربية أصيلة محضرة بالهيل والزعفران وماء الورد',
    descriptionEn: 'Authentic Arabic coffee prepared with cardamom, saffron and rose water',
    descriptionTr: 'Kakule, safran ve gül suyu ile hazırlanmış özgün Arap kahvesi',
    price: 12,
    imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500',
    isAvailable: true,
    isPopular: false,
    isSpicy: false,
    preparationTime: 8,
    ingredients: ['قهوة عربية', 'هيل', 'زعفران', 'ماء ورد']
  },

  // الحلويات
  {
    id: 'dessert_1',
    categoryId: 'desserts',
    nameAr: 'بقلاوة تركية',
    nameEn: 'Turkish Baklava',
    nameTr: 'Türk Baklavası',
    descriptionAr: 'طبقات رقيقة من العجين المحشوة بالمكسرات والمُحلاة بالشيرة العسلية',
    descriptionEn: 'Thin layers of pastry filled with nuts and sweetened with honey syrup',
    descriptionTr: 'Ceviz dolu ince hamur katları, bal şurubu ile tatlandırılmış',
    price: 25,
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
    isAvailable: true,
    isPopular: true,
    isSpicy: false,
    preparationTime: 5,
    ingredients: ['عجين الفيلو', 'جوز', 'لوز', 'فستق', 'عسل', 'ماء الورد']
  }
];

const offers = [
  {
    id: 'welcome_25',
    titleAr: 'عرض الترحيب',
    titleEn: 'Welcome Offer',
    titleTr: 'Hoş Geldin Teklifi',
    descriptionAr: 'خصم 25% على طلبك الأول! مرحباً بك في عائلة مطعم الأصالة',
    descriptionEn: '25% off your first order! Welcome to Asalet Restaurant family',
    descriptionTr: 'İlk siparişinde %25 indirim! Asalet Restaurant ailesine hoş geldin',
    discountPercentage: 25,
    minOrderAmount: 30,
    maxDiscountAmount: 50,
    validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    imageUrl: 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    offerType: 'new_customer',
    isActive: true,
    customerTiers: ['bronze']
  },
  {
    id: 'family_combo',
    titleAr: 'كومبو العائلة',
    titleEn: 'Family Combo',
    titleTr: 'Aile Kombosı',
    descriptionAr: 'مندي + كبسة + مشروبين + حلوى = خصم 40%',
    descriptionEn: 'Mandi + Kabsa + 2 drinks + dessert = 40% off',
    descriptionTr: 'Mandi + Kabsa + 2 içecek + tatlı = %40 indirim',
    discountPercentage: 40,
    minOrderAmount: 150,
    maxDiscountAmount: 100,
    validUntil: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
    offerType: 'combo',
    isActive: true,
    customerTiers: ['silver', 'gold', 'platinum']
  },
  {
    id: 'golden_customer',
    titleAr: 'عرض العميل الذهبي',
    titleEn: 'Golden Customer Offer',
    titleTr: 'Altın Müşteri Teklifi',
    descriptionAr: 'خصم 20% + حلوى مجانية لعملائنا الذهبيين المميزين',
    descriptionEn: '20% discount + free dessert for our valued golden customers',
    descriptionTr: 'Değerli altın müşterilerimiz için %20 indirim + ücretsiz tatlı',
    discountPercentage: 20,
    minOrderAmount: 75,
    maxDiscountAmount: 60,
    validUntil: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    offerType: 'loyalty',
    isActive: true,
    customerTiers: ['gold', 'platinum']
  }
];

// مخزن الطلبات والتقييمات في الذاكرة
let orders = [];
let ratings = [];
let otpCodes = new Map();

module.exports = {
  registeredPhones,
  menuCategories,
  menuItems,
  offers,
  orders,
  ratings,
  otpCodes
};

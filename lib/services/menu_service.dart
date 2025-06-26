import 'package:restaurant_ordering_app/models/cart_item.dart';

import '../models/menu_item.dart';

class MenuService {
  static final Cart _cart = Cart();
  static Cart get cart => _cart;

  static List<MenuCategory> getCategories() {
    return [
      MenuCategory(
        id: 'main_dishes',
        nameAr: 'الأطباق الرئيسية',
        nameEn: 'Main Dishes',
        nameTr: 'Ana Yemekler',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
        iconName: 'restaurant',
      ),
      MenuCategory(
        id: 'grills',
        nameAr: 'المشاوي',
        nameEn: 'Grills',
        nameTr: 'Izgara',
        imageUrl:
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400',
        iconName: 'outdoor_grill',
      ),
      MenuCategory(
        id: 'appetizers',
        nameAr: 'المقبلات',
        nameEn: 'Appetizers',
        nameTr: 'Mezeler',
        imageUrl:
            'https://images.unsplash.com/photo-1541833089466-4e9bcbf2b5c6?w=400',
        iconName: 'tapas',
      ),
      MenuCategory(
        id: 'salads',
        nameAr: 'السلطات',
        nameEn: 'Salads',
        nameTr: 'Salatalar',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        iconName: 'eco',
      ),
      MenuCategory(
        id: 'beverages',
        nameAr: 'المشروبات',
        nameEn: 'Beverages',
        nameTr: 'İçecekler',
        imageUrl:
            'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400',
        iconName: 'local_cafe',
      ),
      MenuCategory(
        id: 'desserts',
        nameAr: 'الحلويات',
        nameEn: 'Desserts',
        nameTr: 'Tatlılar',
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
        iconName: 'cake',
      ),
    ];
  }

  static List<MenuItem> getMenuItems() {
    return [
      // الأطباق الرئيسية
      MenuItem(
        id: 'main_1',
        categoryId: 'main_dishes',
        nameAr: 'المندي اليمني',
        nameEn: 'Yemeni Mandi',
        nameTr: 'Yemen Mandisi',
        descriptionAr: 'لحم ضأن طري مطبوخ في الفرن مع الأرز المبهر والخضار',
        descriptionEn:
            'Tender lamb cooked in the oven with spiced rice and vegetables',
        descriptionTr:
            'Fırında pişirilmiş yumuşak kuzu eti, baharatli pilav ve sebzelerle',
        price: 45.0,
        imageUrl:
            'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',
        isPopular: true,
        ingredients: ['لحم ضأن', 'أرز بسمتي', 'بصل', 'طماطم', 'بهارات يمنية'],
        preparationTime: 45,
      ),
      MenuItem(
        id: 'main_2',
        categoryId: 'main_dishes',
        nameAr: 'الكبسة السعودية',
        nameEn: 'Saudi Kabsa',
        nameTr: 'Suudi Kabsa',
        descriptionAr: 'أرز أصفر بالزعفران مع لحم الدجاج والخضار المشكلة',
        descriptionEn: 'Saffron yellow rice with chicken and mixed vegetables',
        descriptionTr: 'Safranlı sarı pilav, tavuk ve karışık sebzelerle',
        price: 38.0,
        imageUrl:
            'https://images.unsplash.com/photo-1563379091339-03246963d96c?w=400',
        isPopular: true,
        ingredients: ['دجاج', 'أرز', 'زعفران', 'هيل', 'قرفة'],
        preparationTime: 35,
      ),
      MenuItem(
        id: 'main_3',
        categoryId: 'main_dishes',
        nameAr: 'الزربيان العدني',
        nameEn: 'Adeni Zurbian',
        nameTr: 'Aden Zurbiyani',
        descriptionAr: 'أرز بالزعفران مع لحم الغنم والبهارات الخاصة',
        descriptionEn: 'Saffron rice with mutton and special spices',
        descriptionTr: 'Safranlı pilav, koyun eti ve özel baharatlarla',
        price: 42.0,
        imageUrl:
            'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400',
        ingredients: ['لحم غنم', 'أرز بسمتي', 'زعفران', 'لوز', 'زبيب'],
        preparationTime: 50,
      ),

      // المشاوي
      MenuItem(
        id: 'grill_1',
        categoryId: 'grills',
        nameAr: 'شاورما اللحم',
        nameEn: 'Meat Shawarma',
        nameTr: 'Et Şavarma',
        descriptionAr: 'لحم مشوي متبل بالطحينة والخضار الطازجة',
        descriptionEn: 'Grilled seasoned meat with tahini and fresh vegetables',
        descriptionTr: 'Baharatli ızgara et, tahin ve taze sebzelerle',
        price: 25.0,
        imageUrl:
            'https://images.unsplash.com/photo-1529059997-1c9722750316?w=400',
        isPopular: true,
        isSpicy: true,
        ingredients: ['لحم بقري', 'طحينة', 'خيار', 'طماطم', 'بصل'],
        preparationTime: 15,
      ),
      MenuItem(
        id: 'grill_2',
        categoryId: 'grills',
        nameAr: 'كباب حلبي',
        nameEn: 'Aleppo Kebab',
        nameTr: 'Halep Kebabı',
        descriptionAr: 'لحم مفروم متبل مشوي على الفحم مع الأرز',
        descriptionEn: 'Seasoned ground meat grilled on charcoal with rice',
        descriptionTr: 'Baharatli kiyma kömürde ızgara, pilav ile',
        price: 32.0,
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        isSpicy: true,
        ingredients: ['لحم مفروم', 'بقدونس', 'بصل', 'بهارات', 'أرز'],
        preparationTime: 20,
      ),
      MenuItem(
        id: 'grill_3',
        categoryId: 'grills',
        nameAr: 'دجاج مشوي',
        nameEn: 'Grilled Chicken',
        nameTr: 'Izgara Tavuk',
        descriptionAr: 'نصف دجاجة مشوية بالتوابل العربية مع الخضار',
        descriptionEn: 'Half grilled chicken with Arabic spices and vegetables',
        descriptionTr: 'Arap baharatlarıyla yarım ızgara tavuk ve sebzeler',
        price: 28.0,
        imageUrl:
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400',
        ingredients: ['دجاج', 'ثوم', 'ليمون', 'زعتر', 'فلفل حار'],
        preparationTime: 25,
      ),

      // المقبلات
      MenuItem(
        id: 'app_1',
        categoryId: 'appetizers',
        nameAr: 'حمص بالطحينة',
        nameEn: 'Hummus with Tahini',
        nameTr: 'Tahinli Humus',
        descriptionAr: 'معجون الحمص الكريمي بالطحينة وزيت الزيتون',
        descriptionEn: 'Creamy chickpea paste with tahini and olive oil',
        descriptionTr: 'Tahin ve zeytinyağlı kremsi nohut ezmesi',
        price: 15.0,
        imageUrl:
            'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400',
        isPopular: true,
        ingredients: ['حمص', 'طحينة', 'ليمون', 'ثوم', 'زيت زيتون'],
        preparationTime: 10,
      ),
      MenuItem(
        id: 'app_2',
        categoryId: 'appetizers',
        nameAr: 'بابا غنوج',
        nameEn: 'Baba Ghanoush',
        nameTr: 'Baba Ganuş',
        descriptionAr: 'معجون الباذنجان المشوي بالطحينة والثوم',
        descriptionEn: 'Grilled eggplant paste with tahini and garlic',
        descriptionTr: 'Tahin ve sarımsaklı ızgara patlıcan ezmesi',
        price: 18.0,
        imageUrl:
            'https://images.unsplash.com/photo-1586998962369-48c7d5c4163e?w=400',
        ingredients: ['باذنجان', 'طحينة', 'ثوم', 'ليمون', 'زيت زيتون'],
        preparationTime: 15,
      ),
      MenuItem(
        id: 'app_3',
        categoryId: 'appetizers',
        nameAr: 'سمبوسة باللحم',
        nameEn: 'Meat Samosa',
        nameTr: 'Etli Börek',
        descriptionAr: 'معجنات محشوة باللحم المفروم والبصل المقلي',
        descriptionEn: 'Pastry filled with ground meat and fried onions',
        descriptionTr: 'Kıyma ve soğan doldurulmuş hamur işi',
        price: 12.0,
        imageUrl:
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
        isSpicy: true,
        ingredients: ['عجين', 'لحم مفروم', 'بصل', 'بهارات', 'زيت'],
        preparationTime: 20,
      ),

      // السلطات
      MenuItem(
        id: 'salad_1',
        categoryId: 'salads',
        nameAr: 'تبولة لبنانية',
        nameEn: 'Lebanese Tabbouleh',
        nameTr: 'Lübnan Tabulesi',
        descriptionAr: 'سلطة البقدونس والطماطم مع البرغل والليمون',
        descriptionEn: 'Parsley and tomato salad with bulgur and lemon',
        descriptionTr: 'Maydanoz ve domates salatası, bulgur ve limonlu',
        price: 16.0,
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
        isPopular: true,
        ingredients: ['بقدونس', 'طماطم', 'برغل', 'ليمون', 'زيت زيتون'],
        preparationTime: 10,
      ),
      MenuItem(
        id: 'salad_2',
        categoryId: 'salads',
        nameAr: 'فتوش شامي',
        nameEn: 'Syrian Fattoush',
        nameTr: 'Şam Fettuş',
        descriptionAr: 'سلطة الخضار المشكلة مع الخبز المحمص والسماق',
        descriptionEn: 'Mixed vegetable salad with toasted bread and sumac',
        descriptionTr: 'Kızarmış ekmek ve sumakla karışık sebze salatası',
        price: 18.0,
        imageUrl:
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
        ingredients: ['خس', 'طماطم', 'خيار', 'فجل', 'خبز محمص', 'سماق'],
        preparationTime: 12,
      ),

      // المشروبات
      MenuItem(
        id: 'bev_1',
        categoryId: 'beverages',
        nameAr: 'شاي أحمر بالنعناع',
        nameEn: 'Red Tea with Mint',
        nameTr: 'Naneli Kırmızı Çay',
        descriptionAr: 'شاي أسود ساخن مع أوراق النعناع الطازجة',
        descriptionEn: 'Hot black tea with fresh mint leaves',
        descriptionTr: 'Taze nane yaprakları ile sıcak siyah çay',
        price: 8.0,
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
        isPopular: true,
        ingredients: ['شاي أسود', 'نعناع طازج', 'سكر'],
        preparationTime: 5,
      ),
      MenuItem(
        id: 'bev_2',
        categoryId: 'beverages',
        nameAr: 'قهوة عربية',
        nameEn: 'Arabic Coffee',
        nameTr: 'Arap Kahvesi',
        descriptionAr: 'قهوة تقليدية بالهيل والزعفران',
        descriptionEn: 'Traditional coffee with cardamom and saffron',
        descriptionTr: 'Kakule ve safranlı geleneksel kahve',
        price: 12.0,
        imageUrl:
            'https://images.unsplash.com/photo-1521302200778-33500795e128?w=400',
        ingredients: ['قهوة عربية', 'هيل', 'زعفران'],
        preparationTime: 8,
      ),
      MenuItem(
        id: 'bev_3',
        categoryId: 'beverages',
        nameAr: 'عصير ليمون بالنعناع',
        nameEn: 'Lemon Mint Juice',
        nameTr: 'Naneli Limon Suyu',
        descriptionAr: 'عصير ليمون طازج مع النعناع والثلج',
        descriptionEn: 'Fresh lemon juice with mint and ice',
        descriptionTr: 'Taze limon suyu, nane ve buz ile',
        price: 10.0,
        imageUrl:
            'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400',
        ingredients: ['ليمون طازج', 'نعناع', 'ماء', 'سكر', 'ثلج'],
        preparationTime: 5,
      ),

      // الحلويات
      MenuItem(
        id: 'dessert_1',
        categoryId: 'desserts',
        nameAr: 'بقلاوة بالفستق',
        nameEn: 'Pistachio Baklava',
        nameTr: 'Antep Fıstıklı Baklava',
        descriptionAr: 'حلوى البقلاوة المقرمشة محشوة بالفستق الحلبي',
        descriptionEn: 'Crispy baklava filled with Aleppo pistachios',
        descriptionTr: 'Antep fıstığı doldurulmuş gevrek baklava',
        price: 22.0,
        imageUrl:
            'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400',
        isPopular: true,
        ingredients: ['عجين فيلو', 'فستق حلبي', 'سكر', 'زبدة', 'شربات'],
        preparationTime: 30,
      ),
      MenuItem(
        id: 'dessert_2',
        categoryId: 'desserts',
        nameAr: 'كنافة نابلسية',
        nameEn: 'Nablusi Kunafa',
        nameTr: 'Nablus Künefe',
        descriptionAr: 'حلوى الكنافة الساخنة بالجبن والشربات',
        descriptionEn: 'Hot kunafa with cheese and syrup',
        descriptionTr: 'Peynir ve şuruplu sıcak künefe',
        price: 20.0,
        imageUrl:
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
        ingredients: ['كنافة', 'جبن عكاوي', 'سمن', 'شربات', 'فستق'],
        preparationTime: 25,
      ),
    ];
  }

  static List<MenuItem> getMenuItemsByCategory(String categoryId) {
    return getMenuItems()
        .where((item) => item.categoryId == categoryId)
        .toList();
  }

  static List<MenuItem> getPopularItems() {
    return getMenuItems().where((item) => item.isPopular).toList();
  }

  static List<MenuItem> searchItems(String query) {
    if (query.isEmpty) return [];

    return getMenuItems().where((item) {
      return item.nameAr.toLowerCase().contains(query.toLowerCase()) ||
          item.nameEn.toLowerCase().contains(query.toLowerCase()) ||
          item.nameTr.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

class MenuCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String imageUrl;
  final String iconName;

  MenuCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.imageUrl,
    required this.iconName,
  });

  String getName(String language) {
    switch (language) {
      case 'ar':
        return nameAr;
      case 'tr':
        return nameTr;
      default:
        return nameEn;
    }
  }

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameTr: json['name_tr'],
      imageUrl: json['image_url'],
      iconName: json['icon_name'],
    );
  }
}

class MenuItem {
  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String descriptionAr;
  final String descriptionEn;
  final String descriptionTr;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final bool isPopular;
  final bool isSpicy;
  final List<String> ingredients;
  final int preparationTime; // بالدقائق

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.descriptionTr,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
    this.isPopular = false,
    this.isSpicy = false,
    required this.ingredients,
    required this.preparationTime,
  });

  String getName(String language) {
    switch (language) {
      case 'ar':
        return nameAr;
      case 'tr':
        return nameTr;
      default:
        return nameEn;
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

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      categoryId: json['category_id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameTr: json['name_tr'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      descriptionTr: json['description_tr'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      isPopular: json['is_popular'] ?? false,
      isSpicy: json['is_spicy'] ?? false,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      preparationTime: json['preparation_time'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_tr': nameTr,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'description_tr': descriptionTr,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'is_popular': isPopular,
      'is_spicy': isSpicy,
      'ingredients': ingredients,
      'preparation_time': preparationTime,
    };
  }
}

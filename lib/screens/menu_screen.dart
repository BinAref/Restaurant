import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/menu/menu_category_widget.dart';
import '../widgets/menu/menu_item_widget.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final String selectedLanguage;
  final String phoneNumber;

  const MenuScreen({
    Key? key,
    required this.selectedLanguage,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<MenuCategory> _categories = MenuService.getCategories();
  List<MenuItem> _currentItems = [];
  String _selectedCategoryId = '';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeMenu();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
  }

  Future<void> _initializeMenu() async {
    // محاكاة تحميل البيانات
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _selectedCategoryId = _categories.first.id;
      _currentItems = MenuService.getMenuItemsByCategory(_selectedCategoryId);
      _isLoading = false;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.selectedLanguage == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.lightCream,
                AppColors.background,
                AppColors.cream,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // AppBar مخصص
                _buildCustomAppBar(isRTL, isMobile),

                if (_isLoading)
                  Expanded(child: _buildLoadingWidget())
                else ...[
                  // شريط البحث
                  _buildSearchBar(isMobile),

                  // تصنيفات الطعام
                  _buildCategoriesSection(isMobile),

                  // قائمة الأطباق
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildItemsList(isMobile),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // زر عربة التسوق العائم
        floatingActionButton: _buildCartButton(),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isRTL, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              isRTL ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.primaryGreen,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),

          SizedBox(width: 12),

          // أيقونة المنيو
          Container(
            width: isMobile ? 40 : 45,
            height: isMobile ? 40 : 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold, AppColors.darkGold],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 20 : 22.5),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: isMobile ? 20 : 24,
            ),
          ),

          SizedBox(width: 12),

          // عنوان المنيو
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMenuTitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _getMenuSubtitle(),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // أيقونة القلب للمفضلة
          IconButton(
            onPressed: () {
              // TODO: إظهار المفضلة
            },
            icon: Icon(
              Icons.favorite_border,
              color: AppColors.traditionalRed,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 8,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _performSearch,
        decoration: InputDecoration(
          hintText: _getSearchHint(),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primaryGold,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textLight,
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.lightGold),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(bool isMobile) {
    return Container(
      height: isMobile ? 50 : 60,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return MenuCategoryWidget(
            category: category,
            selectedLanguage: widget.selectedLanguage,
            isSelected: _selectedCategoryId == category.id,
            onTap: () => _selectCategory(category.id),
          );
        },
      ),
    );
  }

  Widget _buildItemsList(bool isMobile) {
    if (_currentItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: _currentItems.length,
      itemBuilder: (context, index) {
        return MenuItemWidget(
          item: _currentItems[index],
          selectedLanguage: widget.selectedLanguage,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            _getNoResultsText(),
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getTryDifferentSearchText(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold, AppColors.darkGold],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryGold),
          ),
          SizedBox(height: 16),
          Text(
            _getLoadingText(),
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) return SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  selectedLanguage: widget.selectedLanguage,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            ),
            backgroundColor: AppColors.primaryGreen,
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cartProvider.itemCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  _getCartText(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _currentItems = MenuService.getMenuItemsByCategory(categoryId);
      _searchController.clear();
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _currentItems = MenuService.getMenuItemsByCategory(_selectedCategoryId);
      } else {
        _currentItems = MenuService.searchItems(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  // النصوص المترجمة
  String _getMenuTitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'قائمة الطعام';
      case 'tr':
        return 'Menü';
      default:
        return 'Menu';
    }
  }

  String _getMenuSubtitle() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'اختر من أشهى الأطباق';
      case 'tr':
        return 'En lezzetli yemekleri seçin';
      default:
        return 'Choose from our delicious dishes';
    }
  }

  String _getSearchHint() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'ابحث عن طبق...';
      case 'tr':
        return 'Yemek ara...';
      default:
        return 'Search for a dish...';
    }
  }

  String _getLoadingText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جاري تحميل المنيو...';
      case 'tr':
        return 'Menü yükleniyor...';
      default:
        return 'Loading menu...';
    }
  }

  String _getNoResultsText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'لا توجد نتائج';
      case 'tr':
        return 'Sonuç bulunamadı';
      default:
        return 'No results found';
    }
  }

  String _getTryDifferentSearchText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'جرب البحث بكلمات أخرى';
      case 'tr':
        return 'Farklı kelimelerle arayın';
      default:
        return 'Try searching with different words';
    }
  }

  String _getCartText() {
    switch (widget.selectedLanguage) {
      case 'ar':
        return 'السلة';
      case 'tr':
        return 'Sepet';
      default:
        return 'Cart';
    }
  }
}

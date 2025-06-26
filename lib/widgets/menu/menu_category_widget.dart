import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/menu_item.dart';

class MenuCategoryWidget extends StatelessWidget {
  final MenuCategory category;
  final String selectedLanguage;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuCategoryWidget({
    Key? key,
    required this.category,
    required this.selectedLanguage,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [AppColors.primaryGold, AppColors.darkGold],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.lightGold.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة التصنيف
                Container(
                  width: isMobile ? 30 : 35,
                  height: isMobile ? 30 : 35,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 15 : 17.5),
                  ),
                  child: Icon(
                    _getIconData(),
                    size: isMobile ? 16 : 18,
                    color: isSelected ? Colors.white : AppColors.primaryGold,
                  ),
                ),

                SizedBox(width: 8),

                // اسم التصنيف
                Text(
                  category.getName(selectedLanguage),
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (category.iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'tapas':
        return Icons.tapas;
      case 'eco':
        return Icons.eco;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }
}

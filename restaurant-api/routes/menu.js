const express = require('express');
const router = express.Router();

const { successResponse, errorResponse, notFoundResponse } = require('../../utils/responses');
const { verifyApiKey, optionalJWT } = require('../restaurant-api/middleware/auth');
const { menuCategories, menuItems } = require('../restaurant-api/data/mockData');

/**
 * GET /api/menu
 * جلب المنيو الكامل
 */
router.get('/', verifyApiKey, optionalJWT, (req, res) => {
  try {
    const { category, search, available_only } = req.query;
    
    let filteredItems = [...menuItems];
    
    // تصفية حسب التصنيف
    if (category) {
      filteredItems = filteredItems.filter(item => item.categoryId === category);
    }
    
    // تصفية حسب البحث
    if (search) {
      const searchTerm = search.toLowerCase();
      filteredItems = filteredItems.filter(item => 
        item.nameAr.toLowerCase().includes(searchTerm) ||
        item.nameEn.toLowerCase().includes(searchTerm) ||
        item.nameTr.toLowerCase().includes(searchTerm) ||
        item.descriptionAr.toLowerCase().includes(searchTerm) ||
        item.descriptionEn.toLowerCase().includes(searchTerm) ||
        item.descriptionTr.toLowerCase().includes(searchTerm)
      );
    }
    
    // تصفية المتاح فقط
    if (available_only === 'true') {
      filteredItems = filteredItems.filter(item => item.isAvailable);
    }
    
    // ترتيب حسب الشعبية
    filteredItems.sort((a, b) => {
      if (a.isPopular && !b.isPopular) return -1;
      if (!a.isPopular && b.isPopular) return 1;
      return 0;
    });

    const response = {
      categories: menuCategories,
      items: filteredItems,
      totalItems: filteredItems.length,
      totalCategories: menuCategories.length,
      filters: {
        category: category || null,
        search: search || null,
        availableOnly: available_only === 'true'
      }
    };

    return successResponse(res, response, 'تم جلب المنيو بنجاح');

  } catch (error) {
    console.error('خطأ في جلب المنيو:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب المنيو', 500);
  }
});

/**
 * GET /api/menu/categories
 * جلب التصنيفات فقط
 */
router.get('/categories', verifyApiKey, (req, res) => {
  try {
    return successResponse(res, {
      categories: menuCategories,
      totalCategories: menuCategories.length
    }, 'تم جلب التصنيفات بنجاح');
  } catch (error) {
    console.error('خطأ في جلب التصنيفات:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب التصنيفات', 500);
  }
});

/**
 * GET /api/menu/items/:id
 * جلب صنف واحد بالتفصيل
 */
router.get('/items/:id', verifyApiKey, (req, res) => {
  try {
    const { id } = req.params;
    const item = menuItems.find(item => item.id === id);
    
    if (!item) {
      return notFoundResponse(res, 'الصنف غير موجود');
    }
    
    // إضافة أصناف مشابهة
    const similarItems = menuItems
      .filter(i => i.categoryId === item.categoryId && i.id !== item.id)
      .slice(0, 4);
    
    return successResponse(res, {
      item,
      similarItems,
      category: menuCategories.find(c => c.id === item.categoryId)
    }, 'تم جلب تفاصيل الصنف بنجاح');

  } catch (error) {
    console.error('خطأ في جلب الصنف:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب الصنف', 500);
  }
});

/**
 * GET /api/menu/popular
 * جلب الأصناف الشعبية
 */
router.get('/popular', verifyApiKey, (req, res) => {
  try {
    const popularItems = menuItems
      .filter(item => item.isPopular && item.isAvailable)
      .slice(0, 8);
    
    return successResponse(res, {
      items: popularItems,
      totalItems: popularItems.length
    }, 'تم جلب الأصناف الشعبية بنجاح');

  } catch (error) {
    console.error('خطأ في جلب الأصناف الشعبية:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب الأصناف الشعبية', 500);
  }
});

module.exports = router;
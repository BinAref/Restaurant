const express = require('express');
const router = express.Router();
const { successResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../utils/responses');
const { generateUniqueId, formatTurkishPhone } = require('../utils/helpers');
const { ratings, orders } = require('../data/mockData');

// إرسال تقييم جديد
router.post('/rating', async (req, res) => {
  try {
    const { orderId, stars, feedback, phone: rawPhone } = req.body;

    // التحقق من البيانات الأساسية
    if (!orderId || !stars || !rawPhone) {
      return errorResponse(res, 'معرف الطلب والتقييم ورقم الهاتف مطلوبة', 400);
    }

    if (stars < 1 || stars > 5) {
      return errorResponse(res, 'التقييم يجب أن يكون بين 1 و 5 نجوم', 400);
    }

    const phone = formatTurkishPhone(rawPhone);

    // التحقق من وجود الطلب
    const order = orders.find(o => o.id === orderId);
    if (!order) {
      return notFoundResponse(res, 'الطلب غير موجود');
    }

    // التحقق من أن المستخدم يقيم طلبه الخاص
    if (order.customerPhone !== phone) {
      return errorResponse(res, 'لا يمكنك تقييم طلب مستخدم آخر', 403);
    }

    // التحقق من حالة الطلب
    if (order.status !== 'delivered') {
      return errorResponse(res, 'لا يمكن تقييم الطلب إلا بعد التسليم', 400);
    }

    // التحقق من عدم وجود تقييم سابق
    const existingRating = ratings.find(r => r.orderId === orderId && r.customerPhone === phone);
    if (existingRating) {
      return errorResponse(res, 'تم تقييم هذا الطلب مسبقاً', 400);
    }

    // محاكاة تأخير المعالجة
    await new Promise(resolve => setTimeout(resolve, 1000));

    // إنشاء التقييم
    const rating = {
      id: generateUniqueId('RAT'),
      orderId,
      customerPhone: phone,
      stars,
      feedback: feedback?.trim() || null,
      createdAt: new Date(),
      metadata: {
        platform: 'api',
        orderValue: order.totalPrice,
        orderItemsCount: order.items.length
      }
    };

    // حفظ التقييم
    ratings.push(rating);

    // تحديث الطلب بالتقييم
    order.rating = stars;
    order.feedback = rating.feedback;
    order.ratedAt = rating.createdAt;

    console.log('⭐ تقييم جديد:', {
      id: rating.id,
      orderId: rating.orderId,
      stars: rating.stars,
      phone: rating.customerPhone
    });

    return successResponse(res, {
      rating: {
        id: rating.id,
        stars: rating.stars,
        feedback: rating.feedback,
        createdAt: rating.createdAt
      },
      order: {
        id: order.id,
        rating: order.rating
      }
    }, 'تم إرسال التقييم بنجاح', 201);

  } catch (error) {
    console.error('خطأ في إرسال التقييم:', error);
    return errorResponse(res, 'حدث خطأ أثناء معالجة التقييم', 500);
  }
});

// جلب تقييم طلب محدد
router.get('/rating/order/:orderId', (req, res) => {
  try {
    const { orderId } = req.params;
    
    const rating = ratings.find(r => r.orderId === orderId);
    
    if (!rating) {
      return notFoundResponse(res, 'لا يوجد تقييم لهذا الطلب');
    }

    return successResponse(res, { rating }, 'تم جلب التقييم بنجاح');

  } catch (error) {
    console.error('خطأ في جلب التقييم:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب التقييم', 500);
  }
});

// جلب جميع تقييمات العميل
router.get('/ratings/:phone', (req, res) => {
  try {
    const phone = formatTurkishPhone(req.params.phone);
    const { limit = 10, offset = 0 } = req.query;

    let customerRatings = ratings.filter(r => r.customerPhone === phone);
    
    // إضافة تقييمات وهمية إذا لم توجد
    if (customerRatings.length === 0) {
      const dummyRatings = [
        {
          id: generateUniqueId('RAT'),
          orderId: 'ORD_DUMMY_1',
          customerPhone: phone,
          stars: 5,
          feedback: 'طعام ممتاز وخدمة سريعة!',
          createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
        },
        {
          id: generateUniqueId('RAT'),
          orderId: 'ORD_DUMMY_2',
          customerPhone: phone,
          stars: 4,
          feedback: 'جيد جداً، لكن التوصيل تأخر قليلاً',
          createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
        }
      ];
      
      ratings.push(...dummyRatings);
      customerRatings = dummyRatings;
    }
    
    // ترتيب حسب التاريخ (الأحدث أولاً)
    customerRatings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    const totalRatings = customerRatings.length;
    customerRatings = customerRatings.slice(offset, offset + parseInt(limit));

    // حساب الإحصائيات
    const allCustomerRatings = ratings.filter(r => r.customerPhone === phone);
    const stats = {
      totalRatings,
      averageRating: allCustomerRatings.length > 0 
        ? (allCustomerRatings.reduce((sum, r) => sum + r.stars, 0) / allCustomerRatings.length).toFixed(1)
        : 0,
      starsDistribution: {
        5: allCustomerRatings.filter(r => r.stars === 5).length,
        4: allCustomerRatings.filter(r => r.stars === 4).length,
        3: allCustomerRatings.filter(r => r.stars === 3).length,
        2: allCustomerRatings.filter(r => r.stars === 2).length,
        1: allCustomerRatings.filter(r => r.stars === 1).length
      }
    };

    return successResponse(res, {
      ratings: customerRatings,
      stats,
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset),
        total: totalRatings,
        hasMore: offset + parseInt(limit) < totalRatings
      }
    }, 'تم جلب التقييمات بنجاح');

  } catch (error) {
    console.error('خطأ في جلب تقييمات العميل:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب التقييمات', 500);
  }
});

module.exports = router;

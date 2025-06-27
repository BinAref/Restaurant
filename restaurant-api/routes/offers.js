const express = require('express');
const router = express.Router();

const { successResponse, errorResponse } = require('../../utils/responses');
const { verifyApiKey, optionalJWT } = require('../restaurant-api/middleware/auth');
const { formatTurkishPhone, getCustomerTier, generateCustomerStats } = require('../../utils/helpers');
const { offers } = require('../restaurant-api/data/mockData');

/**
 * GET /api/offers/:phone
 * جلب العروض المخصصة للعميل
 */
router.get('/:phone', verifyApiKey, optionalJWT, async (req, res) => {
  try {
    const phone = formatTurkishPhone(req.params.phone);
    const { active_only = 'true' } = req.query;

    // محاكاة تأخير تحميل البيانات
    await new Promise(resolve => setTimeout(resolve, 800));

    // تحديد مستوى العميل وإحصائياته
    const customerTier = getCustomerTier(phone);
    const customerStats = generateCustomerStats(phone);

    // تصفية العروض حسب مستوى العميل
    let customerOffers = offers.filter(offer => {
      // التحقق من تاريخ الانتهاء
      const isValid = new Date() < new Date(offer.validUntil);
      
      // التحقق من مستوى العميل
      const tierAllowed = offer.customerTiers.includes(customerTier);
      
      // التحقق من الحالة النشطة
      const isActiveCheck = active_only === 'true' ? offer.isActive : true;
      
      return isValid && tierAllowed && isActiveCheck;
    });

    // ترتيب العروض حسب الأولوية
    customerOffers.sort((a, b) => {
      // العروض المخصصة للعملاء الجدد أولاً
      if (a.offerType === 'new_customer' && b.offerType !== 'new_customer') return -1;
      if (a.offerType !== 'new_customer' && b.offerType === 'new_customer') return 1;
      
      // ثم العروض بأعلى خصم
      return b.discountPercentage - a.discountPercentage;
    });

    // إضافة معلومات إضافية لكل عرض
    customerOffers = customerOffers.map(offer => {
      const daysLeft = Math.ceil((new Date(offer.validUntil) - new Date()) / (1000 * 60 * 60 * 24));
      const isExpiringSoon = daysLeft <= 3;
      
      return {
        ...offer,
        daysLeft,
        isExpiringSoon,
        potentialSavings: Math.min(
          (customerStats.averageOrderValue * offer.discountPercentage / 100),
          offer.maxDiscountAmount
        )
      };
    });

    // ملف العميل الشخصي
    const customerProfile = {
      phone,
      tier: customerTier,
      stats: customerStats,
      tierName: {
        bronze: 'عميل جديد',
        silver: 'عميل فضي',
        gold: 'عميل ذهبي',
        platinum: 'عميل بلاتيني'
      }[customerTier],
      nextTierRequirement: _getNextTierRequirement(customerTier, customerStats)
    };

    return successResponse(res, {
      offers: customerOffers,
      profile: customerProfile,
      totalOffers: customerOffers.length,
      metadata: {
        generatedAt: new Date(),
        tierEvaluatedAt: new Date(),
        nextRefresh: new Date(Date.now() + 6 * 60 * 60 * 1000) // 6 ساعات
      }
    }, 'تم جلب العروض المخصصة بنجاح');

  } catch (error) {
    console.error('خطأ في جلب العروض:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب العروض', 500);
  }
});

/**
 * GET /api/offers/all/available
 * جلب جميع العروض المتاحة (للمدراء)
 */
router.get('/all/available', verifyApiKey, (req, res) => {
  try {
    const { include_expired = 'false' } = req.query;
    
    let allOffers = [...offers];
    
    if (include_expired === 'false') {
      allOffers = allOffers.filter(offer => new Date() < new Date(offer.validUntil));
    }
    
    // إضافة إحصائيات لكل عرض
    allOffers = allOffers.map(offer => {
      const usage = Math.floor(Math.random() * 100); // محاكاة عدد الاستخدامات
      const views = Math.floor(Math.random() * 500); // محاكاة عدد المشاهدات
      
      return {
        ...offer,
        stats: {
          views,
          usage,
          conversionRate: usage > 0 ? ((usage / views) * 100).toFixed(2) : 0
        }
      };
    });

    return successResponse(res, {
      offers: allOffers,
      totalOffers: allOffers.length,
      summary: {
        active: allOffers.filter(o => o.isActive).length,
        expired: allOffers.filter(o => new Date() >= new Date(o.validUntil)).length,
        byType: {
          welcome: allOffers.filter(o => o.offerType === 'new_customer').length,
          combo: allOffers.filter(o => o.offerType === 'combo').length,
          loyalty: allOffers.filter(o => o.offerType === 'loyalty').length
        }
      }
    }, 'تم جلب جميع العروض بنجاح');

  } catch (error) {
    console.error('خطأ في جلب جميع العروض:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب العروض', 500);
  }
});

/**
 * POST /api/offers/apply/:offerId
 * تطبيق عرض محدد
 */
router.post('/apply/:offerId', verifyApiKey, optionalJWT, (req, res) => {
  try {
    const { offerId } = req.params;
    const { phone, orderTotal } = req.body;

    if (!phone || !orderTotal) {
      return errorResponse(res, 'رقم الهاتف وإجمالي الطلب مطلوبان', 400);
    }

    const offer = offers.find(o => o.id === offerId);
    if (!offer) {
      return errorResponse(res, 'العرض غير موجود', 404);
    }

    // التحقق من صلاحية العرض
    if (new Date() >= new Date(offer.validUntil)) {
      return errorResponse(res, 'انتهت صلاحية هذا العرض', 400);
    }

    if (!offer.isActive) {
      return errorResponse(res, 'هذا العرض غير نشط حالياً', 400);
    }

    // التحقق من الحد الأدنى للطلب
    if (orderTotal < offer.minOrderAmount) {
      return errorResponse(res, `الحد الأدنى للطلب هو ${offer.minOrderAmount} ليرة`, 400);
    }

    // حساب قيمة الخصم
    const discountAmount = Math.min(
      (orderTotal * offer.discountPercentage / 100),
      offer.maxDiscountAmount
    );
    
    const finalTotal = orderTotal - discountAmount;

    return successResponse(res, {
      offer: {
        id: offer.id,
        title: offer.titleAr,
        discountPercentage: offer.discountPercentage
      },
      calculation: {
        originalTotal: orderTotal,
        discountAmount: Math.round(discountAmount * 100) / 100,
        finalTotal: Math.round(finalTotal * 100) / 100,
        savings: Math.round(discountAmount * 100) / 100
      },
      appliedAt: new Date()
    }, 'تم تطبيق العرض بنجاح');

  } catch (error) {
    console.error('خطأ في تطبيق العرض:', error);
    return errorResponse(res, 'حدث خطأ أثناء تطبيق العرض', 500);
  }
});

/**
 * دالة مساعدة لحساب متطلبات المستوى التالي
 */
function _getNextTierRequirement(currentTier, stats) {
  const requirements = {
    bronze: { nextTier: 'silver', ordersNeeded: Math.max(0, 5 - stats.totalOrders), spendingNeeded: Math.max(0, 200 - stats.totalSpent) },
    silver: { nextTier: 'gold', ordersNeeded: Math.max(0, 15 - stats.totalOrders), spendingNeeded: Math.max(0, 500 - stats.totalSpent) },
    gold: { nextTier: 'platinum', ordersNeeded: Math.max(0, 30 - stats.totalOrders), spendingNeeded: Math.max(0, 1000 - stats.totalSpent) },
    platinum: { nextTier: null, ordersNeeded: 0, spendingNeeded: 0 }
  };

  return requirements[currentTier] || null;
}

module.exports = router;
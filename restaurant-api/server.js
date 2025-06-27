const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// استيراد الأدوات المساعدة
const { successResponse, errorResponse } = require('./utils/responses');
const { generateOTP, formatTurkishPhone, isValidTurkishPhone, sendSMS, isExpired, getCustomerTier, generateCustomerStats } = require('./utils/helpers');

// استيراد البيانات
const { registeredPhones, menuCategories, menuItems, offers, orders, ratings, otpCodes } = require('./data/mockData');

// استيراد المسارات
const orderRoutes = require('./routes/orders');
const ratingRoutes = require('./routes/ratings');

// إنشاء التطبيق
const app = express();

// إعدادات الأمان والميدل وير
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-api-key']
}));

app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// middleware للتسجيل
app.use((req, res, next) => {
  req.requestTime = new Date().toISOString();
  req.requestId = Math.random().toString(36).substring(2, 15);
  console.log(`${req.method} ${req.path} - ${req.requestTime} [${req.requestId}]`);
  next();
});

// ========== المسارات الأساسية ==========

// الصفحة الرئيسية
app.get('/', (req, res) => {
  try {
    res.json({
      message: 'مرحباً بك في واجهة برمجة التطبيقات لمطعم الأصالة',
      version: '2.0.0',
      status: 'running',
      timestamp: new Date().toISOString(),
      endpoints: {
        health: '/api/health',
        docs: '/api/docs',
        menu: '/api/menu',
        verifyPhone: '/api/verify-phone',
        order: '/api/order',
        orders: '/api/orders/:phone',
        offers: '/api/offers/:phone',
        rating: '/api/rating'
      },
      server: {
        environment: process.env.NODE_ENV || 'development',
        port: process.env.PORT || 3000,
        uptime: Math.floor(process.uptime())
      },
      stats: {
        menuItems: menuItems.length,
        categories: menuCategories.length,
        offers: offers.length,
        totalOrders: orders.length,
        totalRatings: ratings.length
      }
    });
  } catch (error) {
    console.error('خطأ في الصفحة الرئيسية:', error);
    res.status(500).json({ error: 'خطأ في الخادم' });
  }
});

// صفحة الحالة الصحية
app.get('/api/health', (req, res) => {
  try {
    const healthCheck = {
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: Math.floor(process.uptime()),
      environment: process.env.NODE_ENV || 'development',
      version: '2.0.0',
      memory: {
        used: Math.round((process.memoryUsage().heapUsed / 1024 / 1024) * 100) / 100,
        total: Math.round((process.memoryUsage().heapTotal / 1024 / 1024) * 100) / 100
      },
      services: {
        database: 'mock',
        sms: 'mock',
        payment: 'mock'
      },
      counters: {
        menuItems: menuItems.length,
        activeOffers: offers.filter(o => o.isActive).length,
        totalOrders: orders.length,
        totalRatings: ratings.length,
        registeredPhones: registeredPhones.size
      }
    };

    res.json(healthCheck);
  } catch (error) {
    console.error('خطأ في فحص الحالة:', error);
    res.status(500).json({ 
      status: 'ERROR',
      message: 'خطأ في فحص حالة الخادم' 
    });
  }
});

// ========== مسارات API ==========

// التحقق من الهاتف مع OTP
app.post('/api/verify-phone', async (req, res) => {
  try {
    const { phone: rawPhone, action = 'send_otp', otp } = req.body;

    if (!rawPhone) {
      return errorResponse(res, 'رقم الهاتف مطلوب', 400);
    }

    const phone = formatTurkishPhone(rawPhone);
    
    if (!isValidTurkishPhone(phone)) {
      return errorResponse(res, 'رقم الهاتف التركي غير صحيح', 400);
    }

    if (action === 'send_otp') {
      // إرسال OTP
      const otpCode = generateOTP(6);
      const expiryTime = new Date(Date.now() + 5 * 60 * 1000);

      // حفظ OTP مؤقتاً
      otpCodes.set(phone, {
        code: otpCode,
        createdAt: new Date(),
        expiryTime: expiryTime,
        attempts: 0
      });

      // محاكاة إرسال SMS
      const smsMessage = `مطعم الأصالة: رمز التحقق ${otpCode}. صالح لمدة 5 دقائق.`;
      
      try {
        await sendSMS(phone, smsMessage);
        console.log(`📱 OTP Sent to ${phone}: ${otpCode}`);
      } catch (smsError) {
        return errorResponse(res, 'فشل في إرسال رسالة التحقق، حاول مرة أخرى', 500);
      }

      return successResponse(res, {
        phone,
        otpSent: true,
        expiryMinutes: 5,
        isRegistered: registeredPhones.has(phone),
        message: process.env.NODE_ENV === 'development' ? `رمز التطوير: ${otpCode}` : 'تم إرسال رمز التحقق'
      }, 'تم إرسال رمز التحقق بنجاح');

    } else if (action === 'verify_otp') {
      // التحقق من OTP
      if (!otp) {
        return errorResponse(res, 'رمز التحقق مطلوب', 400);
      }

      const storedOTP = otpCodes.get(phone);
      if (!storedOTP) {
        return errorResponse(res, 'لم يتم إرسال رمز تحقق لهذا الرقم', 400);
      }

      storedOTP.attempts += 1;

      if (isExpired(storedOTP.createdAt, 5)) {
        otpCodes.delete(phone);
        return errorResponse(res, 'انتهت صلاحية رمز التحقق، اطلب رمزاً جديداً', 400);
      }

      if (storedOTP.attempts > 3) {
        otpCodes.delete(phone);
        return errorResponse(res, 'تجاوزت عدد المحاولات المسموح، اطلب رمزاً جديداً', 400);
      }

      if (storedOTP.code !== otp) {
        return errorResponse(res, 'رمز التحقق غير صحيح', 400);
      }

      // نجح التحقق
      otpCodes.delete(phone);
      registeredPhones.add(phone);

      console.log(`✅ Phone verified: ${phone}`);

      return successResponse(res, {
        phone,
        verified: true,
        token: 'mock-jwt-token-' + Date.now(),
        isNewCustomer: !registeredPhones.has(phone)
      }, 'تم التحقق بنجاح');
    }

  } catch (error) {
    console.error('خطأ في التحقق من الهاتف:', error);
    return errorResponse(res, 'حدث خطأ أثناء التحقق', 500);
  }
});

// جلب المنيو الكامل
app.get('/api/menu', (req, res) => {
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

// جلب العروض المخصصة
app.get('/api/offers/:phone', async (req, res) => {
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
      const isValid = new Date() < new Date(offer.validUntil);
      const tierAllowed = offer.customerTiers.includes(customerTier);
      const isActiveCheck = active_only === 'true' ? offer.isActive : true;
      
      return isValid && tierAllowed && isActiveCheck;
    });

    // ترتيب العروض حسب الأولوية
    customerOffers.sort((a, b) => {
      if (a.offerType === 'new_customer' && b.offerType !== 'new_customer') return -1;
      if (a.offerType !== 'new_customer' && b.offerType === 'new_customer') return 1;
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
      }[customerTier]
    };

    return successResponse(res, {
      offers: customerOffers,
      profile: customerProfile,
      totalOffers: customerOffers.length,
      metadata: {
        generatedAt: new Date(),
        nextRefresh: new Date(Date.now() + 6 * 60 * 60 * 1000)
      }
    }, 'تم جلب العروض المخصصة بنجاح');

  } catch (error) {
    console.error('خطأ في جلب العروض:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب العروض', 500);
  }
});

// ربط مسارات الطلبات والتقييمات
app.use('/api', orderRoutes);
app.use('/api', ratingRoutes);

// توثيق تفاعلي
app.get('/api/docs', (req, res) => {
  try {
    res.json({
      title: 'مطعم الأصالة - توثيق API الكامل',
      version: '2.0.0',
      description: 'واجهة برمجة التطبيقات المتكاملة لتطبيق طلب الطعام',
      baseUrl: `${req.protocol}://${req.get('host')}/api`,
      authentication: {
        note: 'معظم endpoints تعمل بدون مصادقة في النظام الوهمي',
        development: 'في التطوير، جميع OTP codes تقبل 123456'
      },
      endpoints: [
        {
          path: '/health',
          method: 'GET',
          description: 'فحص حالة الخادم والإحصائيات'
        },
        {
          path: '/verify-phone',
          method: 'POST',
          description: 'التحقق من رقم الهاتف مع OTP',
          body: {
            phone: 'رقم الهاتف التركي (مثل +905501234567)',
            action: 'send_otp أو verify_otp',
            otp: 'رمز التحقق (للتحقق)'
          },
          example: {
            send: { phone: '+905501234567', action: 'send_otp' },
            verify: { phone: '+905501234567', action: 'verify_otp', otp: '123456' }
          }
        },
        {
          path: '/menu',
          method: 'GET',
          description: 'جلب المنيو مع تصفية وبحث',
          query: {
            category: 'معرف التصنيف (اختياري)',
            search: 'نص البحث (اختياري)',
            available_only: 'true/false (اختياري)'
          }
        },
        {
          path: '/order',
          method: 'POST',
          description: 'إرسال طلب جديد',
          body: {
            phone: 'رقم الهاتف',
            items: 'مصفوفة الأصناف [{id, quantity}]',
            notes: 'ملاحظات (اختياري)',
            deliveryAddress: 'عنوان التسليم (اختياري)'
          }
        },
        {
          path: '/orders/:phone',
          method: 'GET',
          description: 'جلب الطلبات السابقة للعميل'
        },
        {
          path: '/offers/:phone',
          method: 'GET',
          description: 'جلب العروض المخصصة للعميل'
        },
        {
          path: '/rating',
          method: 'POST',
          description: 'إرسال تقييم للطلب',
          body: {
            orderId: 'معرف الطلب',
            phone: 'رقم الهاتف',
            stars: 'التقييم 1-5',
            feedback: 'التعليق (اختياري)'
          }
        }
      ]
    });
  } catch (error) {
    console.error('خطأ في التوثيق:', error);
    res.status(500).json({ error: 'خطأ في جلب التوثيق' });
  }
});

// ========== معالجة الأخطاء ==========

app.use('*', (req, res) => {
  console.log(`❌ مسار غير موجود: ${req.method} ${req.originalUrl}`);
  errorResponse(res, `المسار ${req.originalUrl} غير موجود`, 404);
});

app.use((error, req, res, next) => {
  console.error(`❌ خطأ في الخادم [${req.requestId}]:`, error);
  
  if (res.headersSent) {
    return next(error);
  }
  
  return errorResponse(res, 'حدث خطأ داخلي في الخادم', 500);
});

// ========== بدء الخادم ==========

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`
🍽️  مطعم الأصالة - خادم API متكامل يعمل بنجاح
🚀 البيئة: ${process.env.NODE_ENV || 'development'}  
🌐 الرابط: http://localhost:${PORT}
📖 التوثيق الكامل: http://localhost:${PORT}/api/docs
❤️  الحالة الصحية: http://localhost:${PORT}/api/health
⏰ تم البدء: ${new Date().toLocaleString('ar-SA')}

📊 إحصائيات النظام:
   🍽️  أصناف المنيو: ${menuItems.length}
   🏷️  تصنيفات: ${menuCategories.length}
   🎁 العروض النشطة: ${offers.filter(o => o.isActive).length}
   📱 أرقام مسجلة: ${registeredPhones.size}

🧪 اختبارات سريعة:
   curl http://localhost:${PORT}/api/health
   curl http://localhost:${PORT}/api/menu
   curl -X POST http://localhost:${PORT}/api/verify-phone -H "Content-Type: application/json" -d '{"phone":"+905501234567","action":"send_otp"}'
   curl http://localhost:${PORT}/api/offers/+905501234567

🔗 ربط مع Flutter:
   const String baseUrl = 'http://localhost:${PORT}/api';
  `);
});

// إيقاف آمن
process.on('SIGTERM', () => {
  console.log('\n📴 جاري إيقاف الخادم...');
  server.close(() => {
    console.log('✅ تم إيقاف الخادم بنجاح');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n📴 جاري إيقاف الخادم...');
  server.close(() => {
    console.log('✅ تم إيقاف الخادم بنجاح'); 
    process.exit(0);
  });
});

module.exports = app;

const { orders, ratings, registeredPhones, otpCodes } = require('../restaurant-api/data/mockData');
const { generateUniqueId, generateCustomerStats } = require('../utils/helpers');

/**
 * إضافة بيانات تجريبية للتطوير
 */
function seedDatabase() {
  console.log('🌱 بدء إضافة البيانات التجريبية...\n');

  // إضافة أرقام هواتف إضافية
  const additionalPhones = [
    '+905551111111',
    '+905552222222',
    '+905553333333',
    '+905554444444',
    '+905555555555'
  ];

  additionalPhones.forEach(phone => {
    registeredPhones.add(phone);
  });

  console.log(`📱 تم إضافة ${additionalPhones.length} رقم هاتف جديد`);

  // إضافة طلبات تجريبية
  const sampleOrders = [
    {
      customerPhone: '+905501234567',
      items: [
        {
          menuItem: { id: 'main_1', nameAr: 'المندي اليمني', price: 85 },
          quantity: 1,
          unitPrice: 85,
          totalPrice: 85
        }
      ],
      totalPrice: 85,
      status: 'delivered',
      deliveredAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) // منذ يومين
    },
    {
      customerPhone: '+905501234567',
      items: [
        {
          menuItem: { id: 'grill_1', nameAr: 'شاورما الدجاج', price: 35 },
          quantity: 2,
          unitPrice: 35,
          totalPrice: 70
        },
        {
          menuItem: { id: 'drink_1', nameAr: 'شاي بالنعناع', price: 8 },
          quantity: 2,
          unitPrice: 8,
          totalPrice: 16
        }
      ],
      totalPrice: 86,
      status: 'delivered',
      deliveredAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) // منذ 5 أيام
    },
    {
      customerPhone: '+905509876543',
      items: [
        {
          menuItem: { id: 'main_2', nameAr: 'الكبسة السعودية', price: 75 },
          quantity: 1,
          unitPrice: 75,
          totalPrice: 75
        }
      ],
      totalPrice: 75,
      status: 'preparing',
      orderTime: new Date(Date.now() - 30 * 60 * 1000) // منذ 30 دقيقة
    }
  ];

  sampleOrders.forEach(orderData => {
    const order = {
      id: generateUniqueId('ORD'),
      orderTime: orderData.orderTime || new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000),
      ...orderData
    };
    orders.push(order);
  });

  console.log(`📦 تم إضافة ${sampleOrders.length} طلب تجريبي`);

  // إضافة تقييمات تجريبية
  const sampleRatings = [
    {
      orderId: orders[0].id,
      customerPhone: '+905501234567',
      stars: 5,
      feedback: 'طعام ممتاز وخدمة سريعة، أنصح به بشدة!'
    },
    {
      orderId: orders[1].id,
      customerPhone: '+905501234567',
      stars: 4,
      feedback: 'جودة جيدة لكن التوصيل تأخر قليلاً'
    }
  ];

  sampleRatings.forEach(ratingData => {
    const rating = {
      id: generateUniqueId('RAT'),
      createdAt: new Date(Date.now() - Math.random() * 3 * 24 * 60 * 60 * 1000),
      ...ratingData
    };
    ratings.push(rating);
  });

  console.log(`⭐ تم إضافة ${sampleRatings.length} تقييم تجريبي`);

  // إضافة OTP تجريبي للاختبار
  otpCodes.set('+905500000000', {
    code: '123456',
    createdAt: new Date(),
    expiryTime: new Date(Date.now() + 5 * 60 * 1000),
    attempts: 0
  });

  console.log('🔐 تم إضافة OTP تجريبي: +905500000000 → 123456');

  console.log('\n✅ تم الانتهاء من إضافة البيانات التجريبية بنجاح!');
  console.log('\n📊 إحصائيات البيانات:');
  console.log(`   📱 أرقام مسجلة: ${registeredPhones.size}`);
  console.log(`   📦 طلبات: ${orders.length}`);
  console.log(`   ⭐ تقييمات: ${ratings.length}`);
  console.log(`   🔐 رموز OTP نشطة: ${otpCodes.size}`);
}

// تشغيل البذر إذا تم استدعاء الملف مباشرة
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
EOF
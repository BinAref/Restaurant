const express = require('express');
const router = express.Router();
const { successResponse, errorResponse, validationErrorResponse, notFoundResponse } = require('../utils/responses');
const { generateUniqueId, formatTurkishPhone } = require('../utils/helpers');
const { orders, menuItems } = require('../data/mockData');

// إرسال طلب جديد
router.post('/order', async (req, res) => {
  try {
    const { items: orderItems, phone: rawPhone, notes, deliveryAddress } = req.body;

    // التحقق من البيانات الأساسية
    if (!rawPhone || !orderItems || !Array.isArray(orderItems) || orderItems.length === 0) {
      return errorResponse(res, 'رقم الهاتف والأصناف مطلوبة', 400);
    }

    const phone = formatTurkishPhone(rawPhone);

    // التحقق من صحة الأصناف وحساب السعر
    const validatedItems = [];
    let totalPrice = 0;

    for (const orderItem of orderItems) {
      if (!orderItem.id || !orderItem.quantity || orderItem.quantity < 1) {
        return errorResponse(res, 'معرف الصنف والكمية مطلوبان', 400);
      }

      const menuItem = menuItems.find(item => item.id === orderItem.id);
      
      if (!menuItem) {
        return errorResponse(res, `الصنف ${orderItem.id} غير موجود`, 400);
      }
      
      if (!menuItem.isAvailable) {
        return errorResponse(res, `الصنف ${menuItem.nameAr} غير متوفر حالياً`, 400);
      }

      const itemTotal = menuItem.price * orderItem.quantity;
      totalPrice += itemTotal;

      validatedItems.push({
        menuItem,
        quantity: orderItem.quantity,
        unitPrice: menuItem.price,
        totalPrice: itemTotal,
        notes: orderItem.notes || null
      });
    }

    // محاكاة تأخير المعالجة
    await new Promise(resolve => setTimeout(resolve, 1500));

    // إنشاء الطلب
    const order = {
      id: generateUniqueId('ORD'),
      customerPhone: phone,
      items: validatedItems,
      totalPrice: Math.round(totalPrice * 100) / 100,
      orderTime: new Date(),
      status: 'pending',
      notes: notes || null,
      deliveryAddress: deliveryAddress || null,
      estimatedPreparationTime: Math.max(...validatedItems.map(item => item.menuItem.preparationTime)),
      paymentStatus: 'pending'
    };

    // حفظ الطلب
    orders.push(order);

    console.log('📦 طلب جديد:', {
      id: order.id,
      phone: order.customerPhone,
      items: order.items.length,
      total: order.totalPrice
    });

    // محاكاة تحديث الحالة بعد 3 ثواني
    setTimeout(() => {
      const savedOrder = orders.find(o => o.id === order.id);
      if (savedOrder) {
        savedOrder.status = 'confirmed';
        savedOrder.confirmedAt = new Date();
        console.log(`✅ تم تأكيد الطلب: ${order.id}`);
      }
    }, 3000);

    return successResponse(res, {
      order: {
        id: order.id,
        totalPrice: order.totalPrice,
        estimatedPreparationTime: order.estimatedPreparationTime,
        status: order.status,
        orderTime: order.orderTime,
        itemsCount: validatedItems.length
      }
    }, 'تم إرسال الطلب بنجاح', 201);

  } catch (error) {
    console.error('خطأ في إنشاء الطلب:', error);
    return errorResponse(res, 'حدث خطأ أثناء معالجة الطلب', 500);
  }
});

// جلب الطلبات السابقة للعميل
router.get('/orders/:phone', (req, res) => {
  try {
    const phone = formatTurkishPhone(req.params.phone);
    const { status, limit = 20, offset = 0 } = req.query;

    let customerOrders = orders.filter(order => order.customerPhone === phone);

    // إضافة طلبات وهمية إذا لم توجد
    if (customerOrders.length === 0) {
      const dummyOrders = [
        {
          id: generateUniqueId('ORD'),
          customerPhone: phone,
          items: [
            {
              menuItem: { id: 'main_1', nameAr: 'المندي اليمني', price: 85 },
              quantity: 1,
              unitPrice: 85,
              totalPrice: 85
            }
          ],
          totalPrice: 85,
          orderTime: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
          status: 'delivered',
          estimatedPreparationTime: 35
        },
        {
          id: generateUniqueId('ORD'),
          customerPhone: phone,
          items: [
            {
              menuItem: { id: 'grill_1', nameAr: 'شاورما الدجاج', price: 35 },
              quantity: 2,
              unitPrice: 35,
              totalPrice: 70
            }
          ],
          totalPrice: 70,
          orderTime: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
          status: 'delivered',
          estimatedPreparationTime: 15
        }
      ];
      
      orders.push(...dummyOrders);
      customerOrders = dummyOrders;
    }

    // تصفية حسب الحالة
    if (status) {
      customerOrders = customerOrders.filter(order => order.status === status);
    }

    // ترتيب حسب التاريخ (الأحدث أولاً)
    customerOrders.sort((a, b) => new Date(b.orderTime) - new Date(a.orderTime));

    // تطبيق الحد والإزاحة
    const totalOrders = customerOrders.length;
    customerOrders = customerOrders.slice(offset, offset + parseInt(limit));

    // حساب الإحصائيات
    const allCustomerOrders = orders.filter(o => o.customerPhone === phone);
    const stats = {
      totalOrders,
      totalSpent: allCustomerOrders
        .filter(o => o.status === 'delivered')
        .reduce((sum, o) => sum + o.totalPrice, 0),
      pendingOrders: allCustomerOrders.filter(o => ['pending', 'confirmed', 'preparing'].includes(o.status)).length,
      lastOrderDate: customerOrders.length > 0 ? customerOrders[0].orderTime : null
    };

    return successResponse(res, {
      orders: customerOrders,
      stats,
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset),
        total: totalOrders,
        hasMore: offset + parseInt(limit) < totalOrders
      }
    }, 'تم جلب الطلبات بنجاح');

  } catch (error) {
    console.error('خطأ في جلب الطلبات:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب الطلبات', 500);
  }
});

// جلب تفاصيل طلب محدد
router.get('/order/:orderId', (req, res) => {
  try {
    const { orderId } = req.params;
    const order = orders.find(o => o.id === orderId);

    if (!order) {
      return notFoundResponse(res, 'الطلب غير موجود');
    }

    return successResponse(res, { order }, 'تم جلب تفاصيل الطلب بنجاح');

  } catch (error) {
    console.error('خطأ في جلب تفاصيل الطلب:', error);
    return errorResponse(res, 'حدث خطأ أثناء جلب تفاصيل الطلب', 500);
  }
});

module.exports = router;

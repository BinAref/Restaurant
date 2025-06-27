const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const router = express.Router();

const { successResponse, errorResponse, validationErrorResponse } = require('../utils/responses');
const { generateOTP, formatTurkishPhone, isValidTurkishPhone, sendSMS, isExpired } = require('../utils/helpers');
const { phoneVerificationLimiter } = require('../restaurant-api/middleware/rateLimiter');
const { registeredPhones, otpCodes } = require('../restaurant-api/data/mockData');

/**
 * POST /api/verify-phone
 * التحقق من رقم الهاتف وإرسال OTP
 */
router.post('/verify-phone',
  phoneVerificationLimiter,
  [
    body('phone')
      .notEmpty()
      .withMessage('رقم الهاتف مطلوب')
      .custom((value) => {
        const formatted = formatTurkishPhone(value);
        if (!isValidTurkishPhone(formatted)) {
          throw new Error('رقم الهاتف التركي غير صحيح');
        }
        return true;
      }),
    body('action')
      .optional()
      .isIn(['send_otp', 'verify_otp'])
      .withMessage('نوع العملية غير صحيح')
  ],
  async (req, res) => {
    try {
      // التحقق من الأخطاء
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return validationErrorResponse(res, errors.array());
      }

      const { phone: rawPhone, action = 'send_otp', otp } = req.body;
      const phone = formatTurkishPhone(rawPhone);

      if (action === 'send_otp') {
        // إرسال OTP
        const otpCode = generateOTP(6);
        const expiryTime = new Date(Date.now() + 5 * 60 * 1000); // 5 دقائق

        // حفظ OTP مؤقتاً
        otpCodes.set(phone, {
          code: otpCode,
          createdAt: new Date(),
          expiryTime: expiryTime,
          attempts: 0
        });

        // محاكاة إرسال SMS
        const smsMessage = `مطعم الأصالة: رمز التحقق ${otpCode}. صالح لمدة 5 دقائق. لا تشارك هذا الرمز مع أحد.`;
        
        try {
          await sendSMS(phone, smsMessage);
        } catch (smsError) {
          return errorResponse(res, 'فشل في إرسال رسالة التحقق، حاول مرة أخرى', 500);
        }

        return successResponse(res, {
          phone,
          otpSent: true,
          expiryMinutes: 5,
          isRegistered: registeredPhones.has(phone)
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

        // زيادة عدد المحاولات
        storedOTP.attempts += 1;

        // التحقق من انتهاء الصلاحية
        if (isExpired(storedOTP.createdAt, 5)) {
          otpCodes.delete(phone);
          return errorResponse(res, 'انتهت صلاحية رمز التحقق، اطلب رمزاً جديداً', 400);
        }

        // التحقق من عدد المحاولات
        if (storedOTP.attempts > 3) {
          otpCodes.delete(phone);
          return errorResponse(res, 'تجاوزت عدد المحاولات المسموح، اطلب رمزاً جديداً', 400);
        }

        // التحقق من صحة الرمز
        if (storedOTP.code !== otp) {
          return errorResponse(res, 'رمز التحقق غير صحيح', 400);
        }

        // نجح التحقق - حذف OTP
        otpCodes.delete(phone);

        // إضافة الرقم للمسجلين إذا لم يكن موجوداً
        if (!registeredPhones.has(phone)) {
          registeredPhones.add(phone);
        }

        // إنشاء JWT Token
        const token = jwt.sign(
          { 
            phone,
            verified: true,
            iat: Math.floor(Date.now() / 1000)
          },
          process.env.JWT_SECRET,
          { expiresIn: '30d' }
        );

        return successResponse(res, {
          phone,
          verified: true,
          token,
          isNewCustomer: !registeredPhones.has(phone)
        }, 'تم التحقق بنجاح');
      }

    } catch (error) {
      console.error('خطأ في التحقق من الهاتف:', error);
      return errorResponse(res, 'حدث خطأ أثناء التحقق', 500);
    }
  }
);

/**
 * POST /api/refresh-token
 * تجديد JWT Token
 */
router.post('/refresh-token',
  [
    body('token')
      .notEmpty()
      .withMessage('الرمز المميز مطلوب')
  ],
  (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return validationErrorResponse(res, errors.array());
      }

      const { token: oldToken } = req.body;

      // التحقق من الرمز القديم (حتى لو انتهت صلاحيته)
      let decoded;
      try {
        decoded = jwt.verify(oldToken, process.env.JWT_SECRET, { ignoreExpiration: true });
      } catch (error) {
        return errorResponse(res, 'الرمز المميز غير صحيح', 400);
      }

      // إنشاء رمز جديد
      const newToken = jwt.sign(
        { 
          phone: decoded.phone,
          verified: true,
          iat: Math.floor(Date.now() / 1000)
        },
        process.env.JWT_SECRET,
        { expiresIn: '30d' }
      );

      return successResponse(res, {
        token: newToken,
        phone: decoded.phone
      }, 'تم تجديد الرمز المميز بنجاح');

    } catch (error) {
      console.error('خطأ في تجديد الرمز:', error);
      return errorResponse(res, 'حدث خطأ أثناء تجديد الرمز', 500);
    }
  }
);

module.exports = router;
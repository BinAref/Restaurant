const rateLimit = require('express-rate-limit');
const { rateLimitResponse } = require('../../utils/responses');

// معدل عام للطلبات
const generalLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // دقيقة واحدة
  max: parseInt(process.env.MAX_REQUESTS_PER_MINUTE) || 100,
  message: 'تجاوزت عدد الطلبات المسموح',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    rateLimitResponse(res);
  }
});

// معدل صارم للتحقق من الهاتف
const phoneVerificationLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // دقيقة واحدة
  max: 3, // 3 محاولات فقط
  message: 'تجاوزت عدد محاولات التحقق، حاول بعد دقيقة',
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => {
    return req.ip + ':' + (req.body.phone || 'unknown');
  },
  handler: (req, res) => {
    rateLimitResponse(res);
  }
});

// معدل للطلبات
const orderLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 دقائق
  max: 10, // 10 طلبات كحد أقصى
  message: 'تجاوزت عدد الطلبات المسموح، حاول بعد 5 دقائق',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    rateLimitResponse(res);
  }
});

// معدل للتقييمات
const ratingLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 دقائق
  max: 5, // 5 تقييمات كحد أقصى
  message: 'تجاوزت عدد التقييمات المسموح، حاول بعد 10 دقائق',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    rateLimitResponse(res);
  }
});

module.exports = {
  generalLimiter,
  phoneVerificationLimiter,
  orderLimiter,
  ratingLimiter
};
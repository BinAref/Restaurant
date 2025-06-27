const jwt = require('jsonwebtoken');
const { unauthorizedResponse, errorResponse } = require('../../utils/responses');

/**
 * التحقق من صحة JWT Token
 */
function verifyJWT(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return unauthorizedResponse(res, 'يجب تقديم token صحيح');
  }
  
  const token = authHeader.substring(7);
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return unauthorizedResponse(res, 'انتهت صلاحية الجلسة، سجل دخولك مرة أخرى');
    } else if (error.name === 'JsonWebTokenError') {
      return unauthorizedResponse(res, 'رمز المصادقة غير صحيح');
    } else {
      return errorResponse(res, 'خطأ في التحقق من الهوية', 500);
    }
  }
}

/**
 * التحقق من مفتاح API
 */
function verifyApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'] || req.query.api_key;
  
  if (!apiKey) {
    return unauthorizedResponse(res, 'مفتاح API مطلوب');
  }
  
  if (apiKey !== process.env.API_KEY && apiKey !== process.env.ADMIN_API_KEY) {
    return unauthorizedResponse(res, 'مفتاح API غير صحيح');
  }
  
  // تحديد نوع المستخدم
  req.userType = apiKey === process.env.ADMIN_API_KEY ? 'admin' : 'user';
  next();
}

/**
 * التحقق من صلاحيات المدير
 */
function requireAdmin(req, res, next) {
  if (req.userType !== 'admin') {
    return unauthorizedResponse(res, 'صلاحيات المدير مطلوبة');
  }
  next();
}

/**
 * middleware اختياري للتحقق من JWT
 */
function optionalJWT(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7);
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
    } catch (error) {
      // تجاهل الأخطاء في النمط الاختياري
    }
  }
  
  next();
}

module.exports = {
  verifyJWT,
  verifyApiKey,
  requireAdmin,
  optionalJWT
};
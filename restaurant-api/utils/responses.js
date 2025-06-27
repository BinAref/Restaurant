function successResponse(res, data = null, message = 'تم بنجاح', statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString(),
    statusCode
  });
}

function errorResponse(res, message = 'حدث خطأ', statusCode = 400, errors = null) {
  return res.status(statusCode).json({
    success: false,
    message,
    errors,
    timestamp: new Date().toISOString(),
    statusCode
  });
}

function unauthorizedResponse(res, message = 'غير مسموح بالوصول') {
  return errorResponse(res, message, 401);
}

function notFoundResponse(res, message = 'المورد غير موجود') {
  return errorResponse(res, message, 404);
}

function validationErrorResponse(res, errors) {
  return errorResponse(res, 'خطأ في البيانات المُدخلة', 422, errors);
}

module.exports = {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  notFoundResponse,
  validationErrorResponse
};

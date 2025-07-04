# 🍽️ مطعم الأصالة - واجهة برمجة التطبيقات

واجهة REST API متكاملة لتطبيق طلب الطعام من المطعم العربي. مبنية باستخدام Node.js و Express مع أمان عالي ودعم متعدد اللغات.

## 🌟 المميزات

- ✅ **تحقق من الهاتف**: نظام OTP آمن للتحقق من أرقام الهواتف التركية
- 🍽️ **إدارة المنيو**: عرض تصنيفات وأصناف الطعام مع البحث والتصفية
- 📦 **إدارة الطلبات**: إرسال وتتبع الطلبات مع حفظ التاريخ
- 🎁 **العروض المخصصة**: عروض ذكية مبنية على سلوك العميل
- ⭐ **نظام التقييم**: تقييم الطلبات مع التعليقات
- 🔒 **أمان متقدم**: JWT، معدل محدود للطلبات، تشفير
- 🌍 **متعدد اللغات**: دعم العربية والتركية والإنجليزية
- 📱 **متجاوب**: يعمل على جميع المنصات والأجهزة

## 🚀 التثبيت والتشغيل

### المتطلبات الأساسية
- Node.js 16.0.0 أو أحدث
- npm 8.0.0 أو أحدث

### خطوات التثبيت

```bash
# استنساخ المشروع
git clone https://github.com/restaurant/api.git
cd restaurant-api

# تثبيت المكتبات
npm install

# نسخ ملف البيئة
cp .env.example .env

# تشغيل الخادم في بيئة التطوير
npm run dev

# أو التشغيل العادي
npm start
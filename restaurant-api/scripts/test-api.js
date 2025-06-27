const https = require('https');
const http = require('http');

const BASE_URL = process.env.API_URL || 'http://localhost:3000';
const API_KEY = process.env.API_KEY || 'restaurant-api-key-2024';

class APITester {
  constructor() {
    this.results = [];
    this.currentToken = null;
  }

  async makeRequest(method, path, data = null, headers = {}) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, BASE_URL);
      const options = {
        method,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': API_KEY,
          ...headers
        }
      };

      const client = url.protocol === 'https:' ? https : http;
      
      const req = client.request(url, options, (res) => {
        let responseData = '';
        
        res.on('data', (chunk) => {
          responseData += chunk;
        });
        
        res.on('end', () => {
          try {
            const parsed = JSON.parse(responseData);
            resolve({
              status: res.statusCode,
              headers: res.headers,
              data: parsed
            });
          } catch (error) {
            resolve({
              status: res.statusCode,
              headers: res.headers,
              data: responseData
            });
          }
        });
      });

      req.on('error', reject);

      if (data) {
        req.write(JSON.stringify(data));
      }

      req.end();
    });
  }

  async test(name, testFunc) {
    console.log(`\n🧪 اختبار: ${name}`);
    try {
      const startTime = Date.now();
      const result = await testFunc();
      const duration = Date.now() - startTime;
      
      console.log(`✅ نجح في ${duration}ms`);
      this.results.push({ name, status: 'passed', duration, result });
    } catch (error) {
      console.log(`❌ فشل: ${error.message}`);
      this.results.push({ name, status: 'failed', error: error.message });
    }
  }

  async runAllTests() {
    console.log('🚀 بدء اختبار API مطعم الأصالة\n');

    // اختبار الصفحة الرئيسية
    await this.test('الصفحة الرئيسية', async () => {
      const response = await this.makeRequest('GET', '/');
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      return response.data;
    });

    // اختبار الحالة الصحية
    await this.test('الحالة الصحية', async () => {
      const response = await this.makeRequest('GET', '/api/health');
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (response.data.status !== 'OK') throw new Error('الحالة ليست OK');
      return response.data;
    });

    // اختبار إرسال OTP
    await this.test('إرسال رمز التحقق', async () => {
      const response = await this.makeRequest('POST', '/api/verify-phone', {
        phone: '+905501234567',
        action: 'send_otp'
      });
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (!response.data.data.otpSent) throw new Error('لم يتم إرسال OTP');
      return response.data;
    });

    // اختبار التحقق من OTP
    await this.test('التحقق من رمز OTP', async () => {
      const response = await this.makeRequest('POST', '/api/verify-phone', {
        phone: '+905501234567',
        action: 'verify_otp',
        otp: '123456' // أي رمز سيعمل في النظام الوهمي
      });
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (!response.data.data.token) throw new Error('لم يتم إرجاع Token');
      
      this.currentToken = response.data.data.token;
      return response.data;
    });

    // اختبار جلب المنيو
    await this.test('جلب المنيو', async () => {
      const response = await this.makeRequest('GET', '/api/menu');
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (!response.data.data.categories) throw new Error('لا توجد تصنيفات');
      if (!response.data.data.items) throw new Error('لا توجد أصناف');
      return response.data;
    });

    // اختبار إرسال طلب
    await this.test('إرسال طلب جديد', async () => {
      if (!this.currentToken) throw new Error('لا يوجد token للمصادقة');
      
      const response = await this.makeRequest('POST', '/api/order', {
        phone: '+905501234567',
        items: [
          { id: 'main_1', quantity: 1 },
          { id: 'drink_1', quantity: 2 }
        ],
        notes: 'طلب تجريبي للاختبار'
      }, {
        'Authorization': `Bearer ${this.currentToken}`
      });
      
      if (response.status !== 201) throw new Error(`كود خطأ: ${response.status}`);
      if (!response.data.data.order.id) throw new Error('لم يتم إرجاع معرف الطلب');
      
      this.testOrderId = response.data.data.order.id;
      return response.data;
    });

    // اختبار جلب الطلبات السابقة
    await this.test('جلب الطلبات السابقة', async () => {
      if (!this.currentToken) throw new Error('لا يوجد token للمصادقة');
      
      const response = await this.makeRequest('GET', '/api/orders/+905501234567', null, {
        'Authorization': `Bearer ${this.currentToken}`
      });
      
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (!Array.isArray(response.data.data.orders)) throw new Error('الطلبات ليست مصفوفة');
      return response.data;
    });

    // اختبار جلب العروض
    await this.test('جلب العروض المخصصة', async () => {
      const response = await this.makeRequest('GET', '/api/offers/+905501234567');
      if (response.status !== 200) throw new Error(`كود خطأ: ${response.status}`);
      if (!Array.isArray(response.data.data.offers)) throw new Error('العروض ليست مصفوفة');
      return response.data;
    });

    // عرض النتائج النهائية
    this.showResults();
  }

  showResults() {
    console.log('\n📊 نتائج الاختبارات:');
    console.log('='.repeat(50));
    
    const passed = this.results.filter(r => r.status === 'passed').length;
    const failed = this.results.filter(r => r.status === 'failed').length;
    const total = this.results.length;
    
    this.results.forEach(result => {
      const status = result.status === 'passed' ? '✅' : '❌';
      const duration = result.duration ? ` (${result.duration}ms)` : '';
      console.log(`${status} ${result.name}${duration}`);
      
      if (result.status === 'failed') {
        console.log(`    خطأ: ${result.error}`);
      }
    });
    
    console.log('='.repeat(50));
    console.log(`📈 إجمالي: ${total} | ✅ نجح: ${passed} | ❌ فشل: ${failed}`);
    console.log(`🎯 معدل النجاح: ${((passed / total) * 100).toFixed(1)}%`);
    
    if (failed === 0) {
      console.log('\n🎉 جميع الاختبارات نجحت! API يعمل بشكل صحيح.');
    } else {
      console.log('\n⚠️  بعض الاختبارات فشلت، تحقق من الأخطاء أعلاه.');
      process.exit(1);
    }
  }
}

// تشغيل الاختبارات
if (require.main === module) {
  const tester = new APITester();
  tester.runAllTests().catch(console.error);
}

module.exports = APITester;
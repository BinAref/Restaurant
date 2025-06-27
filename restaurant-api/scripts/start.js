const { spawn } = require('child_process');
const { seedDatabase } = require('./seed-data');

console.log('🚀 تشغيل خادم مطعم الأصالة...\n');

// إضافة البيانات التجريبية في بيئة التطوير
if (process.env.NODE_ENV === 'development' || !process.env.NODE_ENV) {
  console.log('🌱 إضافة البيانات التجريبية...');
  seedDatabase();
  console.log('');
}

// بدء الخادم
const server = spawn('node', ['server.js'], {
  stdio: 'inherit',
  env: { ...process.env }
});

server.on('error', (error) => {
  console.error('❌ خطأ في بدء الخادم:', error);
  process.exit(1);
});

server.on('close', (code) => {
  if (code !== 0) {
    console.error(`❌ توقف الخادم بكود خطأ: ${code}`);
    process.exit(code);
  }
});

// معالجة إشارات الإيقاف
process.on('SIGINT', () => {
  console.log('\n📴 إيقاف الخادم...');
  server.kill('SIGINT');
});

process.on('SIGTERM', () => {
  console.log('\n📴 إيقاف الخادم...');
  server.kill('SIGTERM');
});
const crypto = require('crypto');

function generateOTP(length = 6) {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * digits.length)];
  }
  return otp;
}

function generateUniqueId(prefix = '') {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2);
  return `${prefix}${timestamp}_${random}`;
}

function formatTurkishPhone(phone) {
  const cleaned = phone.replace(/\D/g, '');
  
  if (cleaned.startsWith('90')) {
    return `+${cleaned}`;
  } else if (cleaned.startsWith('5') && cleaned.length === 10) {
    return `+90${cleaned}`;
  } else if (cleaned.startsWith('0') && cleaned.length === 11) {
    return `+90${cleaned.substring(1)}`;
  }
  
  return phone;
}

function isValidTurkishPhone(phone) {
  const turkishPhoneRegex = /^\+90[5][0-9]{9}$/;
  return turkishPhoneRegex.test(phone);
}

function getCustomerTier(phone) {
  const hash = crypto.createHash('md5').update(phone).digest('hex');
  const num = parseInt(hash.substring(0, 2), 16);
  
  if (num < 64) return 'bronze';
  if (num < 128) return 'silver';
  if (num < 192) return 'gold';
  return 'platinum';
}

function generateCustomerStats(phone) {
  const hash = crypto.createHash('md5').update(phone).digest('hex');
  const seed = parseInt(hash.substring(0, 8), 16);
  const random = (seed % 1000) / 1000;
  
  const tier = getCustomerTier(phone);
  let baseOrders, baseSpent;
  
  switch (tier) {
    case 'bronze':
      baseOrders = 1 + Math.floor(random * 5);
      baseSpent = baseOrders * (25 + random * 35);
      break;
    case 'silver':
      baseOrders = 5 + Math.floor(random * 15);
      baseSpent = baseOrders * (35 + random * 45);
      break;
    case 'gold':
      baseOrders = 15 + Math.floor(random * 25);
      baseSpent = baseOrders * (45 + random * 55);
      break;
    case 'platinum':
      baseOrders = 30 + Math.floor(random * 50);
      baseSpent = baseOrders * (55 + random * 75);
      break;
  }
  
  return {
    totalOrders: baseOrders,
    totalSpent: Math.round(baseSpent),
    averageOrderValue: Math.round(baseSpent / baseOrders)
  };
}

async function sendSMS(phone, message) {
  await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 2000));
  
  if (Math.random() < 0.05) {
    throw new Error('فشل في إرسال SMS');
  }
  
  console.log(`📱 SMS Sent to ${phone}: ${message}`);
  return true;
}

function isExpired(timestamp, expiryMinutes = 5) {
  const now = new Date();
  const expiryTime = new Date(timestamp.getTime() + expiryMinutes * 60 * 1000);
  return now > expiryTime;
}

module.exports = {
  generateOTP,
  generateUniqueId,
  formatTurkishPhone,
  isValidTurkishPhone,
  getCustomerTier,
  generateCustomerStats,
  sendSMS,
  isExpired
};

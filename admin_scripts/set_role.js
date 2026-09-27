/**
 * set_role.js — منح صلاحية دور (بما فيها owner/admin) عبر Custom Claims (بند 3-ب، 12-أ).
 *
 * ⚠️ هذا السكربت يُشغَّل حصراً من جهاز شخصي موثوق، خارج التطبيق نفسه.
 * هذا هو الطريقة الوحيدة والآمنة لمنح صلاحية owner — لا تُمنح أبداً عبر أي
 * شاشة داخل التطبيق (بند 3-ب).
 *
 * ------------------------------------------------------------------------
 * الإعداد المطلوب قبل أول استخدام (خطوة بشرية — بند 6-9):
 * 1. من Firebase Console → Project Settings → Service Accounts →
 *    "Generate new private key" لمشروع mada-prod (أو mada-dev للتجربة).
 * 2. احفظ الملف الناتج باسم service_account.json داخل هذا المجلد
 *    (admin_scripts/) — هذا الملف حساس جداً، لا تشاركه ولا ترفعه لأي
 *    مستودع كود عام (أضِفه إلى .gitignore بالجذر — موجود مسبقاً).
 * 3. shell: cd admin_scripts && npm install
 * ------------------------------------------------------------------------
 *
 * الاستخدام:
 *   node set_role.js <email> <role>
 * مثال منح صلاحية المالك:
 *   node set_role.js owner@mmtech.example owner
 * الأدوار المسموحة هنا: owner, admin, officeAdmin, driver, customer
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const ALLOWED_ROLES = ['owner', 'admin', 'officeAdmin', 'driver', 'customer'];

function fail(message) {
  console.error(`\n❌ ${message}\n`);
  process.exit(1);
}

const [, , emailArg, roleArg] = process.argv;

if (!emailArg || !roleArg) {
  fail('الاستخدام الصحيح: node set_role.js <email> <role>\nالأدوار المسموحة: ' + ALLOWED_ROLES.join(', '));
}

if (!ALLOWED_ROLES.includes(roleArg)) {
  fail(`دور غير معروف: "${roleArg}". الأدوار المسموحة: ${ALLOWED_ROLES.join(', ')}`);
}

const serviceAccountPath = path.join(__dirname, 'service_account.json');
if (!fs.existsSync(serviceAccountPath)) {
  fail(
    'ملف service_account.json غير موجود ضمن admin_scripts/.\n' +
      '  اذهب إلى Firebase Console → Project Settings → Service Accounts →\n' +
      '  "Generate new private key" واحفظ الملف هنا بهذا الاسم بالضبط.'
  );
}

admin.initializeApp({ credential: admin.credential.cert(require(serviceAccountPath)) });

async function main() {
  try {
    const user = await admin.auth().getUserByEmail(emailArg);

    // owner/admin: بلا pendingReview. driver/officeAdmin: يبقى pendingReview=true
    // حتى يعتمده المالك يدوياً من لوحته لاحقاً (بند 3-أ، 8-المرحلة 4).
    const needsReview = roleArg === 'driver' || roleArg === 'officeAdmin';

    await admin.auth().setCustomUserClaims(user.uid, {
      role: roleArg,
      pendingReview: needsReview,
    });

    console.log(`\n✅ تم منح الدور "${roleArg}" للحساب ${emailArg} (uid: ${user.uid})`);
    if (needsReview) {
      console.log('   ملاحظة: pendingReview=true — سيُنقَل تلقائياً لحالة "قيد المراجعة" حتى الاعتماد.');
    }
    console.log('\n⚠️  يجب على المستخدم تسجيل الخروج والدخول مجدداً (أو إعادة تشغيل التطبيق)\n' +
      '    ليقرأ التطبيق الـCustom Claims الجديدة (Firebase يخزّنها مؤقتاً بالتوكن المحلي).\n');
    process.exit(0);
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      fail(`لا يوجد حساب مسجَّل بهذا البريد بعد: ${emailArg}\n  يجب أن يسجّل المستخدم دخوله أولاً عبر التطبيق (Email Link) قبل تشغيل هذا السكربت.`);
    }
    fail(`خطأ غير متوقع: ${err.message}`);
  }
}

main();

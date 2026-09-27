# admin_scripts — سكربتات إدارية (بند 3-ب، 12-أ)

هذا المجلد **لا يُنشر أبداً ضمن APK التطبيق** — يُشغَّل فقط يدوياً من جهاز
شخصي (Node.js مطلوب على الجهاز).

## set_role.js — منح الأدوار (بما فيها owner)

انظر التعليق العلوي داخل `set_role.js` للتفاصيل الكاملة. باختصار:

```bash
cd admin_scripts
npm install
# ضع service_account.json (من Firebase Console) بهذا المجلد أولاً
node set_role.js owner@mmtech.example owner
```

**تحذير أمني**: `service_account.json` يمنح تحكماً كاملاً بمشروع Firebase —
لا تشاركه، ولا يُرفع لأي Git عام (مُضاف مسبقاً إلى `.gitignore` بالجذر).

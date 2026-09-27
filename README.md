# MADA | مدى — الإصدار 1.0.0 الكامل

مشروع Flutter واحد بأربعة أدوار تشغيلية (عميل/سائق/مكتب تأجير) وطبقتَي
إشراف (owner/admin) — محافظة درعا. راجع `PROJECT_STATE.md` لسجل الإنجاز
الكامل مرحلة بمرحلة، `SECURITY_REVIEW.md` للمراجعة الأمنية النهائية، و
`OWNERSHIP.md` للملكية.

## 0) المتطلبات على جهازك
- Flutter SDK مثبَّت (channel stable) — تحقق: `flutter doctor`
- Android SDK (عبر Android Studio أو VS Code) — API 28+ (بند 5)
- VS Code + إضافة Flutter الرسمية

## 1) فك ضغط المشروع وفتحه
افتح مجلد `mada_app/` كمجلد جذر في VS Code.

## 2) توليد مجلدات المنصّات (مرة واحدة فقط أول مرة)
```bash
cd mada_app
flutter create . --project-name mada_app --org com.mada
```
هذا يُنشئ `android/` و`ios/` تلقائياً استناداً لملف `pubspec.yaml` الموجود
مسبقاً — **لا يحذف أي كود Dart موجود بـ lib/**.

## 3) تفعيل Android Product Flavors (خطوة يدوية إلزامية — مرة واحدة)
افتح `android/app/build.gradle` وطبّق المحتوى الموجود بالضبط في:
```
build_config_reference/android_build_gradle_app_snippet.txt
```
(نسخ/لصق الأجزاء المطلوبة كما هو موضَّح بالتعليقات داخل ذلك الملف).

## 4) وضع ملفات google-services.json بمكانها الصحيح
```
android/app/src/dev/google-services.json    ← انسخ ملف mada-dev-5ca8e هنا
android/app/src/prod/google-services.json   ← انسخ ملف mada-prod هنا
```
> ملاحظتان أرسلتهما سابقاً بأسماء مختلفة — تأكد فقط من المطابقة الصحيحة
> بين المشروع (dev/prod) والمسار (src/dev/ أو src/prod/).

## 5) تثبيت الحزم
```bash
flutter pub get
```
هذا يُشغّل أيضاً `flutter gen-l10n` تلقائياً (بفضل `generate: true` في
pubspec.yaml) فيُنشئ `lib/core/localization/gen/app_localizations.dart`.

## 6) التشغيل أثناء التطوير (بيئة dev)
```bash
flutter run -t lib/main_dev.dart --flavor dev
```

## 7) بناء APK
**نسخة تطوير (Debug، بيئة dev):**
```bash
flutter build apk --debug -t lib/main_dev.dart --flavor dev
```

**نسخة الإنتاج النهائية (Release، بيئة prod):**
```bash
flutter build apk --release -t lib/main_prod.dart --flavor prod
```
الناتج: `build/app/outputs/flutter-apk/app-prod-release.apk`

## 8) تشغيل الاختبارات
```bash
flutter test
```

## 9) الأدوار الإدارية (owner/admin)
راجع `admin_scripts/README.md` — لا تُمنح هذه الأدوار أبداً من داخل
التطبيق، فقط عبر `admin_scripts/set_role.js` من جهازك الشخصي.

---

## ⚠️ ملاحظات ختامية للإصدار 1.0.0

**ما زلت غير قادر على تشغيل Flutter SDK فعلياً في بيئتي** (لا يزال Flutter
غير مثبَّت في حاوية التنفيذ التي أكتب منها الكود) — كل الكود مكتوب يدوياً
بعناية عبر خمس مراحل متتالية ومراجَع للتناسق المنطقي والبنيوي (توازن
الأقواس، تطابق الاستيرادات، تطابق حقول القواعد مع النماذج)، لكن **التحقق
النهائي من نجاح `flutter pub get`/`flutter build` يقع على عاتقك** في
VS Code — هذا قيد ثابت لم يتغيّر منذ المرحلة 0.

**قبل إطلاق فعلي لمستخدمين حقيقيين** (وليس شرطاً لبناء APK للاختبار):
- أكِّد تفعيل واختبار Email Link Sign-in على مشروع **mada-prod** تحديداً
  (اختُبِر على mada-dev فقط خلال هذا المشروع).
- راجع النص المؤقت للشروط والأحكام (`terms_screen.dart`) واستبدله بالنص
  القانوني النهائي المعتمَد إن لم يكن قد تم ذلك بعد.

**قرارات مؤجَّلة تتطلب موافقتك الصريحة (ميزانية/حساب مدفوع) — انظر آخر
رسالة للتفاصيل الكاملة**: الترقية لباقة Firebase Blaze (لتفعيل Cloud
Functions وإشعارات Push حقيقية)، مفاتيح Sham Cash الفعلية، Google Maps
كبديل مدفوع لـOSM.


# 🚀 دليل تشغيل مشروع Khuta (لشادي)

المشروع متظبط بالكامل على Firebase (مشروع `khuta-1febc`). كل الإعدادات موجودة في الريبو — **مش محتاج تظبط Firebase من الأول**. اتبع الخطوات بالترتيب.

---

## 1) المتطلبات

| الأداة | للتأكد |
|--------|--------|
| **Flutter SDK** (stable) | `flutter --version` |
| **Android Studio** (بيجيب Android SDK + JDK) أو JDK 17+ | `java -version` |
| **Git** | `git --version` |
| جهاز أندرويد (USB debugging) أو emulator أو Chrome | `flutter devices` |

بعد التثبيت شغّل ده وتأكد إن مفيش مشاكل:
```bash
flutter doctor
```

---

## 2) تحميل المشروع

```bash
git clone https://github.com/shadysaeed13112002-cloud/KHUTA_TESTING.git
cd KHUTA_TESTING/KhutaTeam
flutter pub get
```

> ملاحظة: لو لسه نسخة قديمة عندك، اعمل `git pull` بدل الـ clone عشان تاخد آخر تحديثات (Firebase + إصلاحات).

---

## 3) التشغيل (Debug — العادي)

```bash
flutter run
```

- بصمتك (debug SHA) **متسجّلة بالفعل** في Firebase، فـ **Google Sign-In هيشتغل** على جهازك.
- مش محتاج أي ملفات إضافية للتشغيل العادي.

---

## 4) بناء نسخة Release (اختياري)

نسخة الـ release بتتوقّع بمفتاح مشترك. الملفين دول **مش في الريبو** (متعمدين، للأمان) — وصلوك على تيليجرام. حطهم في مكانهم:

```
KHUTA_TESTING/KhutaTeam/android/key.properties            ← ملف الإعدادات
KHUTA_TESTING/KhutaTeam/android/app/release-keystore.jks  ← ملف التوقيع
```

وبعدها:
```bash
flutter build apk --release
```

> 🔴 **مهم:** الملفين دول سريين — **متعملهمش commit** أبدًا (هم أصلاً متستثنيين في `.gitignore`).

---

## 5) حل المشاكل الشائعة

| المشكلة | الحل |
|---------|------|
| `flutter` مش متعرّف | ضيف مجلد `flutter\bin` للـ PATH (ويندوز: Environment Variables → Path) |
| `No devices found` | شغّل emulator، أو وصّل موبايل بـ USB debugging، أو جرّب `flutter run -d chrome` |
| Gradle بطيء أول مرة | طبيعي — بيحمّل dependencies، استنى |
| Google Sign-In مش شغّال | لازم تكون على نفس الجهاز اللي بصمته اترفعت. لو على جهاز جديد، طلّع الـ SHA (شوف `GET_SHA_WINDOWS.md`) وابعتها تتسجّل |
| خطأ `permission-denied` من Firestore | اتأكد إنك سحبت آخر نسخة (`git pull`) — فيها قواعد Firestore الصحيحة |
| `keytool` مش متعرّف وقت طلب الـ SHA | شوف ملف `GET_SHA_WINDOWS.md` في الريبو، فيه كل الحلول |

---

## 6) معلومات سريعة عن المشروع

- **مشروع Firebase:** `khuta-1febc`
- **Package name:** `com.example.khuta`
- **طرق الدخول المفعّلة:** Google + Email/Password
- التطبيق Flutter لإدارة تقييم ADHD (مقياس Conners) + توصيات AI + دليل أطباء + لعبة إدراكية.
- مجلد العمل الأساسي: `KhutaTeam/` (شغّل كل أوامر flutter من جواه).

---

أي مشكلة، ابعت **screenshot للخطأ** كامل.

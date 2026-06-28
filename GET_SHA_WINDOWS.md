# 🔑 دليل استخراج SHA على ويندوز — مشروع Khuta

دليل كامل خطوة بخطوة لاستخراج بصمات **SHA-1** و **SHA-256** (Debug و Release) عشان Google Sign-In و Firebase يشتغلوا. كل أوامر الدليل دي لـ **PowerShell** على ويندوز.

---

## 📌 الأول افهم الموضوع (مهم)

- بصمة الـ **SHA** هي "بصمة" مفتاح التوقيع بتاع التطبيق. Firebase بيستخدمها عشان يتأكد إن التطبيق ده فعلاً بتاعك (خصوصًا لـ Google Sign-In).
- في نوعين:
  | النوع | بيتعمل منين | مين يعمله |
  |------|------------|----------|
  | **Debug** | مفتاح تلقائي بيتعمل على كل جهاز لوحده | **كل مطوّر يعمل بتاعه** ويبعته |
  | **Release** | مفتاح واحد بنوقّع بيه نسخة النشر | **مفتاح واحد للتطبيق كله** (مش لكل شخص) |
- ➡️ **انت بصفتك مطوّر تاني محتاج تطلّع الـ Debug SHA بتاع جهازك وتبعته** عشان يتضاف في Firebase. أما الـ Release فمشترك (هنتكلم عنه في الآخر).

---

## ✅ المتطلبات

1. **Flutter SDK** متنصّب وشغّال (`flutter --version`).
2. **JDK** (بييجي مع Android Studio أو مع Flutter). محتاجينه عشان أمر `keytool`.

اتأكد إن فلاتر شغّال:
```powershell
flutter --version
```
لو طلع خطأ، روح لقسم [الفشل #2](#فشل-2-flutter-مش-متعرّف).

---

## 🟢 الجزء الأول: استخراج Debug SHA

### الخطوة 1 — شغّل المشروع مرة واحدة
ده بيعمل ملف الـ debug keystore تلقائيًا لو مش موجود. من جوّه مجلد `KhutaTeam`:
```powershell
flutter run
```
> ممكن توقف التطبيق بعد ما يفتح (Ctrl+C). الهدف بس إن الـ keystore يتعمل.

### الخطوة 2 — اطلع البصمة بأمر keytool
انسخ ده بالظبط:
```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

### الخطوة 3 — انسخ النتيجة
هتلاقي سطور كده:
```
SHA1: 75:0B:C4:13:...:FF:3F
SHA256: D9:54:E3:7C:...:2F:F7
```
انسخ سطر **SHA1** و **SHA256** وابعتهم. خلاص كده! ✅

---

## 🔵 الجزء الثاني: استخراج Release SHA

> ⚠️ الـ Release key **واحد للتطبيق كله** — مش بيتعمل لكل مطوّر. غالبًا مش هتحتاج تعمله، صاحب المشروع عنده الملف. بس لو محتاج تطلّع البصمة منه:

### لو معاك ملف `release-keystore.jks` + الباسورد:
```powershell
keytool -list -v -alias khuta -keystore "C:\path\to\release-keystore.jks" -storepass "الباسورد_هنا"
```
> غيّر المسار والـ alias والباسورد حسب اللي صاحب المشروع باعتهولك. (في مشروع Khuta: الـ alias اسمه `khuta`).

### لو هتنشر على Google Play (Play App Signing):
الـ SHA المهم للإنتاج بييجي من Google نفسه:
**Play Console → تطبيقك → Test and release → Setup → App signing → "App signing key certificate"** — انسخ الـ SHA-1 و SHA-256 من هناك.

---

## 🧰 إزاي تشغّل keytool لو مش موجود (مسارات شائعة)

لو `keytool` مش متعرّف، استخدم المسار الكامل بتاعه. جرّب واحد من دول حسب اللي متنصّب عندك:

**JDK اللي مع Flutter / Android Studio:**
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

**عشان تعرف مسار الـ Java/JDK اللي فلاتر شايفه:**
```powershell
flutter doctor -v
```
دوّر على سطر `Java binary at: ...\bin\java` — استخدم نفس المجلد بس بدّل `java` بـ `keytool`.

---

# 🚨 كل سيناريوهات الفشل وحلولها

### فشل #1: `'keytool' is not recognized as an internal or external command`
**السبب:** الـ JDK مش مضاف للـ PATH.
**الحل (مؤقت للجلسة دي):**
```powershell
$env:Path += ";$env:JAVA_HOME\bin"
```
بعدها جرّب أمر keytool تاني. ولو `JAVA_HOME` فاضي، استخدم المسار الكامل من قسم [المسارات الشائعة](#-إزاي-تشغّل-keytool-لو-مش-موجود-مسارات-شائعة) فوق.

---

### فشل #2: `flutter` مش متعرّف
**السبب:** Flutter مش في الـ PATH.
**الحل:** ضيف مجلد `flutter\bin` للـ PATH:
```powershell
$env:Path += ";C:\src\flutter\bin"   # غيّر المسار لمكان فلاتر عندك
flutter --version
```
للإضافة الدائمة: ابحث في ويندوز عن "Environment Variables" → Path → New → ضيف مسار `flutter\bin`.

---

### فشل #3: `keytool error: java.lang.Exception: Keystore file does not exist`
**السبب:** الـ debug keystore لسه ماتعملش (يعني ماعملتش build لسه).
**الحل أ:** شغّل `flutter run` مرة (الخطوة 1).
**الحل ب:** اعمل الـ keystore يدوي:
```powershell
keytool -genkeypair -v -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
```
بعدها أعد أمر الـ list.

---

### فشل #4: `keytool error: ... Keystore was tampered with, or password was incorrect`
**السبب:** الباسورد غلط.
**الحل:** للـ **debug** الباسورد دايمًا `android` (للـ store والـ key). للـ **release** استخدم الباسورد الصح اللي صاحب المشروع باعتهولك.

---

### فشل #5: `Alias <androiddebugkey> does not exist`
**السبب:** اسم الـ alias غلط.
**الحل:** 
- للـ debug: الـ alias لازم يكون `androiddebugkey`.
- لو مش متأكد، اعرض كل الـ aliases في الملف:
```powershell
keytool -list -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android
```
واستخدم الاسم اللي ظهر.

---

### فشل #6: الأمر اشتغل بس **مفيش SHA ظاهر** / طلع سطور قليلة بس
**السبب:** نسيت `-v` (verbose) — من غيرها مابيطبعش البصمات.
**الحل:** اتأكد إن `-v` موجودة في الأمر:
```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

---

### فشل #7: `java` / JDK مش متنصّب أصلًا
**السبب:** مفيش JDK على الجهاز.
**الحل:** نصّب **Android Studio** (بيجيب JDK معاه) أو نصّب **JDK 17** لوحده، وبعدها أعد المحاولة. اتأكد:
```powershell
java -version
```

---

### فشل #8: المسار فيه مسافات وبيدّي خطأ
**السبب:** المسار فيه مسافات من غير علامات تنصيص.
**الحل:** حط المسار كله بين `" "` (زي ما في كل الأوامر فوق).

---

### فشل #9: نسخت الأمر في **CMD** مش PowerShell وبيدّي خطأ في `$env:`
**السبب:** `$env:USERPROFILE` ده شكل PowerShell.
**الحل:** 
- إما تفتح **PowerShell** (مش CMD) وتستخدم الأوامر زي ما هي.
- أو في CMD استخدم `%USERPROFILE%` بدل `$env:USERPROFILE`:
```cmd
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android
```

---

### فشل #10: `gradlew` / `signingReport` مش شغّال
**ملاحظة:** مشروع Khuta حاليًا **مفيهوش** ملف `gradlew` wrapper، فطريقة `cd android && ./gradlew signingReport` مش هتشتغل. **استخدم طريقة `keytool`** اللي في الدليل ده بدلها.

---

## 📤 إزاي تبعت النتيجة

ابعت السطرين دول لصاحب المشروع (نسخ نص عادي):
```
Debug SHA-1:   ...
Debug SHA-256: ...
```
وهو هيضيفهم في:
**Firebase Console → khuta-1febc → Project Settings → تطبيق Android → Add fingerprint**

---

## ⚡ ملخّص سريع (لو مستعجل)
```powershell
# 1) (مرة واحدة) عشان الـ keystore يتعمل
flutter run

# 2) اطلع الـ SHA
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```
انسخ `SHA1` و `SHA256` وابعتهم. تمام! ✅

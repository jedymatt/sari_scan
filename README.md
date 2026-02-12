# 📱 Sari Scan - Your Sari-Sari Store's Digital Helper! 🏪

> *"Magkano ito?"* (How much is this?) - Never ask again! Just scan! 🎯

Built with ❤️ using Flutter for Android mobile devices.

Transform your sari-sari store into a high-tech operation! This app turns your phone's camera into a powerful price scanner. No more flipping through notebooks or guessing prices - just point, scan, and know! Perfect for busy sari-sari store owners who want to keep track of hundreds of products without the headache.

## ✨ What Can It Do?

- 📸 **Barcode Magic** - Point your camera, get instant prices! Real-time scanning that actually works
- ➕ **Easy Product Registration** - New item? No problem! Add it in seconds with name, price, and barcode
- 📝 **Full Product Management** - View, edit, delete - you're the boss of your inventory!
- 🔍 **Lightning Fast Search** - Find products by name or barcode faster than you can say "tindahan"
- 🌓 **Your Eyes Will Thank You** - Switch between light, dark, or auto theme modes
- 🇵🇭 **Bisaya? English? Both!** - Supports English and Cebuano (Bisaya) languages
- 💰 **Pesos Perfect** - Automatically formats prices in Philippine Peso (₱) - no more decimal confusion!

## 🚀 Coming Soon (We Promise!)

- 💾 **Backup & Restore** - Export and import your data so you'll never lose your precious inventory (even if your phone takes a tumble!)
- 🌐 **Desktop Companion Website** - Manage your products on a big screen! Edit on your computer, import to your phone. No server needed, just pure offline awesomeness!

## 🏗️ How It's Built (For the Curious Devs)

**Tech Stack:** Flutter + Drift (SQLite) with good old StatefulWidget (keeping it simple!)

**The Secret Sauce:** Direct database calls from pages to `lib/db.dart` - no fancy state management needed. Sometimes simple is better! 🎯

**Cool Tech Inside:**
- 🗄️ **Drift** - Type-safe SQLite that doesn't let you mess up queries
- 📷 **mobile_scanner** - Barcode scanning that's faster than you can say "beep!"
- 💾 **shared_preferences** - Remembers your theme and language preferences
- 💵 **intl** - Makes those pesos look pretty (₱123.45)

**Code Tour:**
- `lib/main.dart` — Where the magic begins ✨ (Material 3 theme included!)
- `lib/models.dart` — Product data structure (simple but effective)
- `lib/database.dart` — Drift table schema (modify here, regenerate there!)
- `lib/db.dart` — Your database BFF (all CRUD operations live here)
- `lib/pages/camera_page.dart` — The scanning screen 📸
- `lib/pages/product_management/` — Where products get managed like a boss
- `lib/l10n/` — English & Cebuano living in harmony 🇵🇭

## 🚀 Let's Get This Running!

### What You Need
- Flutter SDK (your ticket to mobile dev paradise)
- An Android device or emulator (we're Android-only, pero powerful!)

### Quick Start (3... 2... 1... 🏃‍♂️)

```bash
# Step 1: Grab those dependencies
flutter pub get

# Step 2: Generate the database magic ✨
# (Do this every time you modify lib/database.dart!)
dart run build_runner build

# Step 3: Fire it up! 🔥
flutter run

# Want an APK? Easy!
flutter build apk --release
```

### Developer Goodies 🛠️

```bash
# Auto-regenerate code when files change (so handy!)
dart run build_runner watch

# Make sure everything works 🧪
flutter test

# Check for code issues (before they check you!)
flutter analyze

# Make your code pretty ✨
dart format lib/
```

## ⚠️ The Fine Print (But Honest!)

This app is powered by barcodes, so it won't help with:
- 🥚 Eggs (unless you sticker each one, which... please don't)
- 🧅 Onions (they make you cry enough already)
- 🧄 Garlic (keeps vampires away, keeps barcodes away too)
- 🥬 Other fresh produce without packaging

**TL;DR:** If it doesn't have a barcode, this app can't scan it. But hey, that's what chalkboards are for! 🤪

## 📸 See It In Action!

<div align="center">
  <img src="https://github.com/user-attachments/assets/e1b5e16d-59ab-4f72-a4a1-2199c36283e0" alt="Home Screen" width="250"/>
  <img src="https://github.com/user-attachments/assets/43d5f815-6364-4684-afd5-2a42b5830010" alt="Scanner Ready" width="250"/>
  <img src="https://github.com/user-attachments/assets/8543069e-6225-41db-8dfb-f19afdf5fd07" alt="Price Display" width="250"/>
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/fabccc92-c635-4706-8926-6afbff687d0e" alt="Product List" width="250"/>
  <img src="https://github.com/user-attachments/assets/252e1b6d-8642-4706-84f2-f4d6998ea429" alt="Product Management" width="250"/>
</div>


# Ay Khedma - Flutter App

تطبيق موبايل يربط العملاء بمقدمي الخدمات (سباك - كهربائي - دليفري)

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point + routes
├── theme/
│   ├── app_colors.dart                # Color palette
│   └── app_text_styles.dart           # Text styles
├── models/
│   ├── user_model.dart                # User data model
│   ├── provider_model.dart            # Provider data model + sample data
│   └── app_state.dart                 # Global state (Provider)
├── widgets/
│   └── common_widgets.dart            # Reusable: PrimaryButton, AppInput, AppHeader...
└── screens/
    ├── splash_screen.dart             # Splash with animation
    ├── login_screen.dart              # Login
    ├── register_step1_screen.dart     # Register: choose Client or Provider
    ├── register_step2_screen.dart     # Register: basic info
    ├── register_step3_screen.dart     # Register: location (client) / service type (provider)
    ├── home_user_screen.dart          # Home for clients
    ├── home_provider_screen.dart      # Home for providers (requests + earnings)
    └── other_screens.dart             # ServiceDetails, Request, Payment, Tracking, Rating
```

## 🚀 Setup Steps

### 1. Copy files
انسخ كل الفايلات دي جوا مشروعك بنفس الـ structure

### 2. Add Cairo font
- حمل Cairo font من Google Fonts: https://fonts.google.com/specimen/Cairo
- حط الفايلات في `fonts/` folder جوا المشروع

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run
```bash
flutter run
```

## 🎨 Color Palette
| Color  | Hex       |
|--------|-----------|
| Black  | #000611   |
| Navy   | #001F54   |
| Blue   | #034078   |
| Teal   | #1282A2   |
| White  | #FEFCFB   |
| Red    | #E11414   |

## 📱 Screens & Flow

### Client Flow:
Splash → Login → Register (3 steps) → Home → Service Details → Book → Payment → Tracking → Rating

### Provider Flow:
Splash → Login → Register (3 steps) → Home Provider (requests + earnings + online toggle)

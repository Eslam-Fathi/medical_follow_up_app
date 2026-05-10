<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
<img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
<img src="https://img.shields.io/badge/State-Riverpod-00C1D4?style=for-the-badge" alt="Riverpod"/>
<img src="https://img.shields.io/badge/AI-Google_Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI"/>
<img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge" alt="Platforms"/>

# 🏥 AuraMed — Medical Follow-up App

**A premium cross-platform healthcare application connecting patients and doctors through smart appointments, real-time chat, AI health assistance, and comprehensive medical records.**

[Getting Started](#-getting-started) · [Architecture](#-architecture) · [Features](#-features) · [Tech Stack](#-tech-stack) · [Contributing](#-contributing)

</div>

---

## 📖 Overview

AuraMed (internally `MedME`) is a full-stack **Flutter** application that serves as a complete healthcare management platform. It supports three distinct user roles — **Patient**, **Doctor**, and **Admin** — each with a tailored dashboard and feature set.

The app runs on **Android**, **iOS**, and **Web** from a single codebase, with platform-adaptive UI that switches between a mobile bottom-navigation layout and a desktop sidebar layout automatically.

---

## ✨ Features

### 👤 For Patients
| Feature | Description |
|---------|-------------|
| 🏠 **Home Dashboard** | Personalized greeting, health insights card, appointment filter chips, and next follow-up countdown |
| 📅 **Smart Appointments** | View, filter (All / Upcoming / Missed / Completed), and book appointments with doctors |
| 💬 **Real-time Chat** | Instant messaging with the care team and treating doctors |
| 🤖 **AI Health Chatbot** | Google Gemini-powered assistant for health queries, symptom checks, and medication questions |
| 📂 **Medical Records** | Centralized view of diagnoses, prescriptions, lab results, and clinical history |
| 👨‍⚕️ **Care Team** | Dedicated panel listing all assigned doctors (mobile: slide-out drawer, desktop: right column) |
| 🔔 **Smart Reminders** | OS-level local notifications at T-15, T-10, T-5, and T+0 minutes before each appointment |
| 👤 **Profile Management** | View and edit personal, medical, and contact information |

### 👨‍⚕️ For Doctors
| Feature | Description |
|---------|-------------|
| 🏠 **Doctor Dashboard** | Patient appointment list, status summaries, and today's schedule |
| 📅 **Appointment Management** | Accept, reject, and update appointment statuses |
| 💬 **Patient Messaging** | Direct chat with patients from the appointment detail view |
| 🤖 **AI Assistant** | Same Gemini chatbot available for clinical reference queries |

### 🛡️ For Admins (Super Admin)
| Feature | Description |
|---------|-------------|
| 📊 **Admin Dashboard** | System-wide statistics, user counts, and appointment metrics |
| ✅ **Doctor Approval** | Review, approve, or reject pending doctor registration requests |
| 📈 **Specialty Analytics** | Charts showing the distribution of doctor specializations |

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | [Flutter 3.10+](https://flutter.dev) | Cross-platform rendering |
| **Language** | Dart 3.10+ | Null-safe, strongly typed |
| **State Management** | [Riverpod 3.x](https://riverpod.dev) | Reactive, testable state |
| **Networking** | [Dio 5.x](https://pub.dev/packages/dio) | HTTP client with interceptors |
| **AI / Chatbot** | [Google Generative AI](https://pub.dev/packages/google_generative_ai) | Gemini 1.5 Flash chatbot |
| **Local Storage** | [Shared Preferences](https://pub.dev/packages/shared_preferences) | JWT + user session persistence |
| **Secure Storage** | [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) | Sensitive data encryption |
| **Notifications** | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) | Scheduled appointment reminders |
| **Charts** | [FL Chart](https://pub.dev/packages/fl_chart) | Admin analytics visualizations |
| **Typography** | [Google Fonts — Inter](https://pub.dev/packages/google_fonts) | Consistent cross-platform fonts |
| **Markdown Rendering** | [Flutter Markdown](https://pub.dev/packages/flutter_markdown) | AI chat response formatting |
| **Icons** | [Feather Icons](https://pub.dev/packages/flutter_feather_icons) | Clean, consistent icon set |
| **Environment Vars** | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | API key management via `.env` |
| **Timezone** | [timezone](https://pub.dev/packages/timezone) + [flutter_timezone](https://pub.dev/packages/flutter_timezone) | Accurate scheduled notifications |

---

## 📐 Architecture

The project follows **Feature-Driven Clean Architecture**, separating concerns into three clear layers inside each feature module.

### Folder Structure

```
lib/
├── core/                          # Shared infrastructure (used by all features)
│   ├── consts/                    # Global design tokens (spacing, colors)
│   ├── errors/                    # Failure model + DioException mapper
│   ├── models/                    # Shared data models (DoctorSpecialization enum)
│   ├── network/                   # ApiClient (Dio singleton) + provider registrations
│   ├── platform/                  # Platform detection (AppPlatform)
│   ├── services/                  # NotificationService (local alarm scheduling)
│   ├── theme/                     # Light & dark ThemeData, AppIcons, ThemeNotifier
│   ├── utils/                     # Responsive, ResponsiveWrapper, colors, scroll behavior
│   └── widgets/                   # App-wide shared widgets (SplashScreen, NotFoundScreen)
│
└── features/                      # One folder per business domain
    ├── auth/                      # Login, Register, Session management
    │   ├── data/models/           # UserDto, LoginResponse, AuthApi (HTTP layer)
    │   └── presentation/
    │       ├── manager/state/     # AuthState + AuthNotifier (Riverpod StateNotifier)
    │       └── view/              # AuthSwitcher, LoginScreen, RegisterScreen
    │
    ├── home/                      # Main dashboard for patients and doctors
    │   └── presentation/view/
    │       └── widgets/           # HomeHeader, InsightsCard, NextFollowUpCard, etc.
    │
    ├── appointments/              # Appointment booking, list, and detail screens
    ├── chat/                      # Real-time patient↔doctor messaging
    ├── chatbot/                   # Google Gemini AI health assistant
    ├── doctors/                   # Doctor search, list, profile, care team
    ├── medical_record/            # Patient medical history and records
    ├── notifications/             # In-app notification center
    ├── profile/                   # User profile view and editing
    └── admin/                     # Super admin dashboard and doctor approvals
```

### Layered Architecture (per feature)

```
Feature
  ├── data/
  │   ├── models/         → DTOs (parsed from JSON) and API service classes
  │   └── api/            → HTTP methods using ApiClient (Dio)
  └── presentation/
      ├── manager/        → Riverpod providers and StateNotifier business logic
      └── view/           → Flutter widgets (screens + reusable widget components)
```

### Data Flow

```
User Action (Widget)
    │
    ▼
Riverpod Provider (StateNotifier)   ← watches auth, profile, etc.
    │
    ▼
API Service (e.g. AuthApi)          ← calls Dio through ApiClient
    │
    ▼
Backend REST API                    ← https://medical-app-seven-kappa.vercel.app
    │
    ▼
JSON Response → Dart Model (DTO)
    │
    ▼
State update → UI rebuilds reactively
```

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Riverpod over Provider/BLoC** | Type-safe, compile-time checked, no `BuildContext` needed in logic |
| **`StateNotifier` for auth/profile** | Immutable state with `copyWith` enables predictable, testable updates |
| **Singleton `ApiClient`** | One Dio instance + one auth interceptor across the entire app |
| **Named routes** | Decoupled navigation — screens push `'/home'` by string, not by importing widgets |
| **`GlobalKey<NavigatorState>`** | Allows navigation from services and Riverpod listeners outside the widget tree |
| **Feature-first, then layer** | Keeps related code colocated; easier to add/remove entire features |

---

## 🎨 Design System

AuraMed uses a custom design system called **Aurora UI** implemented via Flutter's `ThemeData`.

### Color Palette

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| Primary | `#6366F1` (Indigo) | `#6366F1` (Indigo) |
| Background | `#F3E8FF` (Soft Lavender) | `#0F172A` (Deep Navy) |
| Surface | `#FAFAFA` | `#1E293B` (Slate) |
| Accent | `#FCD34D` (Amber) | `#FCD34D` (Amber) |
| Text Primary | `#111827` | `#F1F5F9` |

### Typography
Google Fonts **Inter** — used across all text styles for a clean, modern medical-grade look.

### Responsive Breakpoints
| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 600 px | Bottom navigation bar + slide-out drawer |
| Tablet | 600 – 1023 px | Mobile layout (wider constraints) |
| Desktop | ≥ 1024 px | Left sidebar + center content + right care-team panel |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.10 ([install guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** ≥ 3.10 (bundled with Flutter)
- **Android Studio** or **VS Code** with the Flutter plugin
- A valid **Google Gemini API Key** (for the AI chatbot feature)

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/Eslam-Fathi/medical_follow_up_app.git
cd medical_follow_up_app
```

**2. Install Flutter dependencies**
```bash
flutter pub get
```

**3. Set up environment variables**

Create a `.env` file in the project root:
```env
GEMINI_API_KEY=your_google_gemini_api_key_here
```

> ⚠️ **Never commit the `.env` file.** It is already in `.gitignore`.

**4. Run the app**

```bash
# Mobile (Android/iOS)
flutter run

# Web (development server)
flutter run -d chrome

# Specific device
flutter run -d <device-id>
```

List available devices with:
```bash
flutter devices
```

### Platform-specific Notes

<details>
<summary><strong>Android</strong> — Notification Permissions</summary>

Android 13+ (API 33+) requires runtime permission for notifications. The app requests this automatically on first launch via `NotificationService`. Exact alarm permission is also requested for precise appointment reminders.

If reminders don't fire, check **Settings → Apps → AuraMed → Permissions → Notifications**.

</details>

<details>
<summary><strong>iOS</strong> — Permissions</summary>

The app requests notification permissions on first launch. Accept the system prompt to receive appointment reminders. No additional configuration is needed for development builds.

</details>

<details>
<summary><strong>Web</strong> — Deployment</summary>

The app is pre-configured for **Vercel** deployment. See `vercel.json` in the project root. Build with:

```bash
flutter build web --release
```

Then deploy the `build/web/` output to any static hosting provider.

</details>

---

## 🔑 User Roles & Test Accounts

| Role | Access | Route after login |
|------|--------|------------------|
| `PATIENT` | Home dashboard, appointments, chat, chatbot, medical records, profile | `/home` |
| `DOCTOR` | Doctor dashboard, patient appointments, messaging | `/home` |
| `SUPER_ADMIN` | Admin analytics dashboard, doctor approval | `/admin_dashboard` |

> Create accounts via the **Sign up** tab on the login screen. Doctor accounts require admin approval before they become active.

---

## 🔌 Backend API

The app communicates with a hosted REST API:

**Base URL:** `https://medical-app-seven-kappa.vercel.app`

### Key Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/auth/login` | Authenticate user, returns JWT |
| `POST` | `/api/auth/register` | Create new account, returns JWT |
| `GET` | `/api/profile` | Fetch authenticated user's profile |
| `GET` | `/api/appointments` | List user's appointments |
| `POST` | `/api/appointments` | Book a new appointment |
| `GET` | `/api/doctors` | Search and list doctors |
| `GET` | `/api/medical-records` | Fetch patient medical history |

### Authentication
All authenticated endpoints require a `Bearer` token in the `Authorization` header. This is automatically injected by `ApiClient`'s request interceptor — API service classes never add it manually.

---

## 🗂️ Core Concepts Explained

### State Management with Riverpod

```dart
// 1. Define a StateNotifier (business logic)
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true); // Immutable update
    // ... call API ...
    state = state.copyWith(isLoading: false, loginResponse: res);
  }
}

// 2. Expose it as a Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authApiProvider));
});

// 3. Consume in a Widget
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    // ...
  }
}
```

### Error Handling Pipeline

Every network error flows through a consistent pipeline:

```
DioException (raw HTTP error)
    │
    ▼
mapDioError()              ← inspects status code + response body
    │
    ▼
Failure object             ← typed: Failure.network() | .auth() | .server() | ...
    │
    ▼
StateNotifier.state.error  ← user-friendly message string
    │
    ▼
Widget shows error banner  ← no raw exceptions ever reach the UI
```

### Responsive Layout Strategy

```dart
// The home screen switches layout based on screen width
final isDesktop = Responsive.isDesktop(context); // ≥ 1024 px

return isDesktop
    ? _buildDesktopLayout(...)   // Row: Sidebar | Content | CareTeam
    : _buildMobileLayout(...);   // SingleChildScrollView + BottomNavBar
```

### Platform-Adaptive Icons

```dart
// AppIcons automatically returns the right icon per platform
Icon(AppIcons.home)         // Feather on mobile, Material on web
Icon(AppIcons.homeFilled)   // Active/selected state variant
```

---

## 📦 Project Scripts

Some utility scripts are included in the `scripts/` directory for development and testing.

| Script | Purpose |
|--------|---------|
| `test_appointment.dart` | Quick appointment booking smoke test |
| `test_script.dart` | General feature integration checks |
| `test_script_admin.dart` | Admin flow validation |

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before submitting a pull request.

### Quick Contribution Guide

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Follow the architecture**: New features go in `lib/features/<feature_name>/` with `data/` and `presentation/` subdirectories
4. **Document your code**: Add Dart doc comments (`///`) to all public classes and methods
5. **Analyze before committing**: Run `flutter analyze` — no new warnings allowed
6. **Format your code**: Run `dart format lib/` before committing
7. **Commit with clear messages**: `feat: add doctor rating widget`
8. **Open a Pull Request** against the `main` branch

### Coding Standards
- Use `HealthCareColors` and `ThemeData` — no hard-coded color hex values in widgets
- All new providers must be documented and placed in the feature's `manager/` folder
- Error handling must use `mapError()` — never expose raw exceptions to the UI
- Use `AppIcons` for all icons — never reference `FeatherIcons` or `Icons.*` directly in screens

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ using Flutter · Powered by Google Gemini AI

</div>

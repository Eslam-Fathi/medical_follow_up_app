# Aurora Health: Medical Follow-up App

[![Flutter](https://img.shields.io/badge/Flutter-v3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-00C1D4?logo=riverpod&logoColor=white)](https://riverpod.dev)
[![Design](https://img.shields.io/badge/Design-Aurora_UI-0891B2)](https://github.com/Eslam-Fathi/medical_follow_up_app/blob/main/design-system/medical-follow-up-app/MASTER.md)

Aurora Health is a premium, feature-rich medical follow-up application designed to bridge the gap between patients and healthcare providers. Built with a focus on accessibility, premium aesthetics, and real-time health insights, it provides a seamless experience for managing medical journeys.

---

## ✨ Key Features

- **🏥 Health Insights Dashboard**: Personalized daily health overview with dynamic charts and metrics.
- **📅 Smart Appointments**: Advanced scheduling system with conflict resolution and automated reminders.
- **💬 Real-time Chat**: Secure, instant communication between patients and medical care teams.
- **🤖 AI Health Assistant**: Integrated Google Gemini-powered chatbot for instant health-related queries.
- **📂 Medical Records**: Centralized management of health history and clinical data.
- **🛡️ Admin Ecosystem**: Specialized dashboard for medical companies and user management.
- **🔔 Intelligent Notifications**: Proactive alerts for upcoming check-ups and follow-ups.

---

## 🛠️ Tech Stack

- **Core**: [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management**: [Riverpod](https://riverpod.dev) (Functional & Type-safe)
- **Networking**: [Dio](https://pub.dev/packages/dio) with interceptors
- **AI Integration**: [Google Generative AI](https://pub.dev/packages/google_generative_ai) (Gemini)
- **Database/Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences) & [Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Icons**: [Feather Icons](https://pub.dev/packages/flutter_feather_icons)

---

## 📐 Architecture

The project strictly follows **Clean Architecture** principles combined with **Feature-Driven** organization to ensure scalability, testability, and maintainability.

```text
lib/
├── core/             # Shared logic, themes, widgets, and utilities
│   ├── network/      # API clients and error handling
│   ├── theme/        # Aurora UI Design System implementation
│   └── shared/       # Cross-cutting concerns
└── features/         # Modular feature-specific code
    ├── auth/         # Login, Sign up, Onboarding
    ├── home/         # Dashboard & Insights
    ├── appointments/ # Booking and management
    └── ...           # Other domain-specific features
```

For more details, see [ARCHITECTURE.md](./docs/ARCHITECTURE.md).

---

## 🎨 Design System: Aurora UI

The application implements a custom design system called **Aurora UI**, focusing on:
- **Color Palette**: Calm Cyan (`#0891B2`) & Health Green (`#059669`)
- **Typography**: Figtree (Headings) & Noto Sans (Body)
- **Philosophy**: Accessible, Ethical, and Professional.

Check the [Design System Master](./design-system/medical-follow-up-app/MASTER.md) for detailed specifications.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10 or higher)
- Android Studio / VS Code
- A valid Google AI API Key (for the chatbot)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Eslam-Fathi/medical_follow_up_app.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Create a `.env` file in the root directory and add your keys:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](./CONTRIBUTING.md) to get started.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

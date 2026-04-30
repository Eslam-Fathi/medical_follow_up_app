# Technical Architecture Guide

This document provides a deep dive into the technical design and architectural principles of the Aurora Health application.

## Clean Architecture

The project is structured according to Clean Architecture principles, ensuring a separation of concerns and making the codebase highly testable and maintainable.

### 1. Data Layer
- **Repositories**: Implementation of domain-layer repository interfaces. Handles data fetching from remote (API) or local sources.
- **Models**: Data Transfer Objects (DTOs) used for serialization/deserialization (JSON).
- **Data Sources**: Low-level drivers for API communication (Dio) or local storage (Secure Storage).

### 2. Domain Layer
- **Entities**: Simple Dart objects representing the business logic and core data structures.
- **Repositories (Interfaces)**: Abstract definitions of data operations.
- **Use Cases**: Encapsulate specific business rules (e.g., `ScheduleAppointment`, `FetchHealthMetrics`).

### 3. Presentation Layer
- **Views (Screens)**: Flutter widgets representing the user interface.
- **Widgets**: Reusable UI components.
- **Providers (Riverpod)**: Manage the UI state and bridge the gap between domain logic and the view.

---

## State Management: Riverpod

The application uses **Riverpod** for state management, following a modern, functional approach.

### Key Patterns used:
- **AsyncNotifierProvider**: For complex states requiring asynchronous initialization and side effects (e.g., `ChatNotifier`).
- **StateProvider**: For simple, atomic state variables.
- **FutureProvider**: For one-off asynchronous data fetching.
- **StreamProvider**: For real-time updates (e.g., chat messages).

### Example Structure:
```dart
// State Definition
final appointmentsProvider = AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
  AppointmentsNotifier.new,
);

// Notifier Implementation
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    return ref.read(appointmentRepositoryProvider).getUpcomingAppointments();
  }
  
  Future<void> addAppointment(Appointment appointment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(appointmentRepositoryProvider).create(appointment);
      return ref.read(appointmentRepositoryProvider).getUpcomingAppointments();
    });
  }
}
```

---

## Networking & API

- **Client**: [Dio](https://pub.dev/packages/dio) is the primary HTTP client.
- **Interceptors**: Used for adding Auth tokens, logging, and global error handling.
- **Error Handling**: Custom `Failure` classes in `core/errors` map exceptions to user-friendly messages.

---

## Dependency Injection

Riverpod acts as the dependency injection framework. Providers are used to inject repositories and services into notifiers, ensuring that components are loosely coupled and easy to mock for testing.

```dart
// Repository Injection
final chatRepositoryProvider = Provider((ref) => ChatRepository(
  networkClient: ref.read(dioProvider),
));
```

---

## Folder Structure

```text
lib/
├── core/
│   ├── consts/        # Global constants and strings
│   ├── errors/        # Exception and Failure definitions
│   ├── network/       # Dio client and API endpoints
│   ├── theme/         # AppTheme and Aurora UI styling
│   └── utils/         # Extensions and helper functions
└── features/
    └── [feature_name]/
        ├── data/      # Models, repositories, sources
        ├── domain/    # Entities, usecases, repo interfaces
        └── presentation/
            ├── view/       # Screens
            ├── widgets/    # Feature-specific components
            └── providers/  # Riverpod state management
```

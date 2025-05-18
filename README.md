# RTM SAT: Route-to-Market Sales Automation Tracker

A robust, **offline-first** Flutter application built to streamline and digitize field sales operations. It embraces **Clean Architecture**, strong **state management** with BLoC/Cubit, **local-first data strategy**, and modern **CI/CD** practices for maintainability, scalability, and testability.

---

## 📱 Screenshots

<div align="center">
<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
    <img src="readme_files/Simulator Screenshot - iPhone 16 Pro Max - 2025-05-19 at 00.23.24.png" alt="Dashboard Screen" width="200"/>
    <img src="readme_files/Simulator Screenshot - iPhone 16 Pro Max - 2025-05-19 at 00.23.39.png" alt="Customer Details" width="200"/>
    <img src="readme_files/Simulator Screenshot - iPhone 16 Pro Max - 2025-05-19 at 00.23.45.png" alt="Visit Tracking" width="200"/>
    <img src="readme_files/Simulator Screenshot - iPhone 16 Pro Max - 2025-05-19 at 00.23.58.png" alt="Activity Log" width="200"/>
    <img src="readme_files/Simulator Screenshot - iPhone 16 Pro Max - 2025-05-19 at 00.24.00.png" alt="Settings Screen" width="200"/>
</div>

</div>

---

## 🧱 Architecture and Design

### 🧼 Clean Architecture

This application adopts **Clean Architecture** for modular, testable, and scalable code.

* **Presentation Layer**
  Manages UI and state using `Cubit` for streamlined state transitions.

* **Domain Layer**
  Contains core business logic, including `Entities` and `Use Cases`.

* **Data Layer**
  Handles interaction with local (Hive) and remote (REST API) data sources.

``` bash
lib/
├── core/                 # Shared app infrastructure (DI, routes, utils)
├── features/             # Modular feature-based structure
│   ├── visits_tracker/   # Visit tracking
│   ├── customers/        # Customer management
│   └── activities/       # Activity tracking
├── app.dart              # Root application widget
└── main.dart             # App entry point
```

---

## 🔁 State Management with BLoC/Cubit

The app uses **Cubit**, a simplified version of BLoC, to manage state with a unidirectional data flow and testable architecture.

```dart
class VisitsCubit extends Cubit<VisitsState> {
  final GetVisitsUseCase getVisitsUseCase;
  final CreateVisitUseCase createVisitUseCase;

  Future<void> getVisits() async {
    emit(VisitsLoading());
    try {
      final visits = await getVisitsUseCase();
      emit(VisitsLoaded(visits: visits));
    } catch (e) {
      emit(VisitsError(message: e.toString()));
    }
  }
}
```

✅ Predictable state transitions
✅ Clear separation of concerns
✅ Simplified unit testing

---

## 🧪 Dependency Injection with GetIt

A **service locator** pattern via `GetIt` decouples dependencies and supports mock injection in tests.

```dart
List<SingleChildWidget> getProviders() {
  return [
    BlocProvider(create: (_) => sl<DashboardCubit>()..loadDashboardItems()),
    BlocProvider(create: (_) => sl<VisitsCubit>()..getVisits()),
    // Additional cubits...
  ];
}
```

---

## 📦 Offline-First Support

### 🗃️ Local-First Strategy

* **Hive** is used to persist all core data locally.
* **TypeAdapters** are implemented for seamless serialization.
* The app reads/writes to local data first, ensuring instant responsiveness.

```dart
final localVisit = await localDataSource.getVisitById(id);
if (localVisit != null) return localVisit;

if (await networkInfo.isConnected) {
  // Fetch from remote...
}
```

---

### 🔄 Intelligent Sync & Temporary IDs

* **Temporary IDs** (e.g., -1, -2) are assigned for offline-created records.
* A sync routine automatically uploads these once the connection is restored.

```dart
Future<void> syncVisits() async {
  final unsyncedVisits = await localDataSource.getUnsyncedVisits();

  for (final visit in unsyncedVisits) {
    if (visit.id! < 0) {
      await remoteDataSource.createVisit(visit);
    } else {
      await remoteDataSource.updateVisit(visit);
    }
  }

  // Refresh with server data
  await localDataSource.clearAllVisits();
  final remoteVisits = await remoteDataSource.getVisits();
  await localDataSource.saveAllVisits(remoteVisits);
}
```

---

## 🚀 Setup Instructions

### 🔧 Prerequisites

* Flutter SDK: `>=3.29.2`
* Dart SDK: `>=3.7.2`
* IDE: Android Studio / VS Code

### 🛠️ Installation

```bash
git clone https://github.com/yourusername/rtm_sat.git
cd rtm_sat
```

Create a `.env` file:

``` bash
API_URL=your_api_url_here
API_KEY=your_api_key_here
```

Install dependencies:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## ✅ Testing Strategy

### 🧪 Unit & Cubit Tests

* **Use Case Tests**: Validate core business logic.
* **Cubit Tests**: Simulate state transitions.
* **Repository Tests**: Validate local/remote logic separation.

### 🧰 Mocking with Mockito

```dart
@GenerateNiceMocks([
  MockSpec<GetVisitsUseCase>(),
  MockSpec<CreateVisitUseCase>(),
  // ...
])
```

---

## 🔄 CI/CD Pipeline

### ⚙️ GitHub Actions Workflow

```yaml
- name: Run unit tests
  run: flutter test --coverage test/features/visits_tracker/presentation/cubit/visits_cubit_test.dart
```

### 🏗️ Build Automation

* Automatically builds APKs for release branches.
* Stores build artifacts for download and distribution.

### 🔍 Code Quality

* **Lefthook**: Enforces pre-commit checks.
* **Flutter Analyze**: Static code analysis to prevent regressions.

---

## 💭 Assumptions and Limitations

### ✅ Assumptions

* API follows REST standards
* Intermittent connectivity is expected
* User experience is prioritized

### ⚠️ Limitations

* Server wins in conflict resolution
* No real-time sync (uses polling)
* Offline mode lacks support for complex operations

### 🔁 Design Trade-offs

* Offline-first UX over strict consistency
* Lightweight Hive chosen over heavier local DBs
* Simplified logic for broader compatibility

---

## 👤 Author

**James Opondo**
Flutter Consultant Candidate – [Solutech](https://solutech.co.ke)
🔗 [GitHub](https://github.com/hamezksm)

---

## 📄 License

This project is part of a technical assessment and is not licensed for production use.

---

Let me know if you want this exported as a `README.md` file or further customized (e.g. badges, live demo links, etc.).

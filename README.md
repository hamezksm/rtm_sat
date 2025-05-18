# RTM SAT: Route-to-Market Sales Automation Tracker

A Flutter application tailored for field sales operations, emphasizing offline-first functionality, clean architecture, comprehensive testing, and continuous integration/deployment (CI/CD) practices.

---

## 🧱 Architecture and Design

### 🧼 Clean Architecture

The application is structured following the principles of Clean Architecture, promoting separation of concerns and scalability:

- **Presentation Layer**: Handles UI and state management using BLoC/Cubit.
- **Domain Layer**: Contains business logic, including use cases and entities.
- **Data Layer**: Manages data sources, including local (Hive) and remote (API) interactions.

This layered approach ensures that each component has a single responsibility, facilitating maintainability and testability.

### 🔁 BLoC Pattern for State Management

Utilizes the BLoC (Business Logic Component) pattern to manage state across the application, ensuring a unidirectional data flow and separation between UI and business logic.

### 🧪 Dependency Injection with GetIt

Employs the `get_it` package as a service locator for dependency injection, allowing for loose coupling between classes and easier testing.

---

## 📦 Offline Support Implementation

### 🗃️ Local-First Data Strategy with Hive

- **Data Storage**: All core entities—visits, customers, and activities—are stored locally using Hive boxes.
- **Type Adapters**: Custom Hive TypeAdapters are implemented for each data model to facilitate serialization and deserialization.
- **Immediate Access**: Enables users to access and modify data instantly, even without internet connectivity.

```dart
// Attempt to retrieve visit from local storage first
final localVisit = await localDataSource.getVisitById(id);
if (localVisit != null) {
  return localVisit;
}

// Fallback to remote fetch if connected
if (await networkInfo.isConnected) {
  // Remote data fetching logic...
}
```

### 🔄 Intelligent Data Fetching and Temporary IDs

**\*Connectivity Check**: Before attempting remote operations, the app checks for network availability.
**\*Offline Creation**: If offline, new records are assigned temporary negative IDs to distinguish them from server-assigned IDs.

```dart
// Create a visit locally with a temporary ID in offline mode
log('📱 Creating visit locally (offline mode)');
final localId = await localDataSource.createVisitFromLocal(visitModel);
```

### 🔁 Two-Way Synchronization

Upon regaining connectivity, the application:

1. Identifies locally created or modified records.
2. Pushes these changes to the server.
3. Refreshes the local database with the latest server data.
4. Maintains a `synced` status flag to track synchronization state.

```dart
Future<void> syncVisits() async {
  final unsyncedVisits = await localDataSource.getUnsyncedVisits();

  for (final visit in unsyncedVisits) {
    if (visit.id != null && visit.id! < 0) {
      // Push new local visit to server
      await remoteDataSource.createVisit(visit);
    } else if (visit.id != null) {
      // Update existing visit on server
      await remoteDataSource.updateVisit(visit);
    }
  }

  // Refresh local database with server data
  await localDataSource.clearAllVisits();
  final remoteVisits = await remoteDataSource.getVisits();
  await localDataSource.saveAllVisits(remoteVisits);
}
```

---

## ✅ Testing Strategy

### 🧪 Unit Tests for Business Logic

**\*Cubit Tests**: Validate state management logic with mocked use cases.
**\*Repository Tests**: Ensure correct data flow between local and remote data sources.
**\*Use Case Tests**: Verify business logic and rules are correctly implemented.

### 🧰 Mock Implementations

Utilizes `mockito` for creating mock classes:

```dart
@GenerateNiceMocks([
  MockSpec<GetVisitsUseCase>(),
  MockSpec<CreateVisitUseCase>(),
  // Additional use cases...
])
```

### 🔁 Continuous Testing

**_ Tests are automatically executed on each code change.
_** Coverage reports are generated to identify untested code paths.

---

## 🚀 CI/CD Pipeline

Implemented using GitHub Actions to automate testing and build processes.

### ⚙️ Automated Testing Workflow

```yaml
- name: Run unit tests
  run: flutter test --coverage test/features/visits_tracker/presentation/cubit/visits_cubit_test.dart
```

### 🏗️ Build Automation

- Automatically builds APKs for release branches.
- Stores build artifacts for easy access and distribution.

---

## 📂 Project Structure

``` bash
lib/
├── core/
├── features/
│   ├── customers/
│   ├── visits_tracker/
│   └── activities/
├── main.dart
```

---

## 👤 Author

**Your Name**
Flutter Consultant Candidate – Solutech
LinkedIn/GitHub: \[your-link]

---

## 📄 License

This project is part of a technical assessment and is not licensed for production use.

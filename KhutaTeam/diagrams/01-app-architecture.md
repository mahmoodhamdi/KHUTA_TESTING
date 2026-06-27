# App Architecture Diagram

## High-Level Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Screens]
        Widgets[Widgets]
    end

    subgraph "State Management Layer"
        AuthCubit[AuthCubit]
        ChildCubit[ChildCubit]
        AssessmentCubit[AssessmentCubit]
        ThemeCubit[ThemeCubit]
        OnboardingCubit[OnboardingCubit]
    end

    subgraph "Service Layer"
        AssessmentService[AssessmentService]
        SdqScoringService[SdqScoringService]
        AiRecommendationsService[AiRecommendationsService]
        ErrorHandlerService[ErrorHandlerService]
        ConnectivityService[ConnectivityService]
        OfflineQueueService[OfflineQueueService]
    end

    subgraph "Repository Layer"
        ChildRepository[ChildRepository]
        TestResultRepository[TestResultRepository]
    end

    subgraph "Data Layer"
        Firebase[(Firebase)]
        Firestore[(Cloud Firestore)]
        FirebaseAuth[Firebase Auth]
        FirebaseAI[Firebase AI/Gemini]
        SharedPrefs[(SharedPreferences)]
    end

    UI --> Widgets
    Widgets --> AuthCubit
    Widgets --> ChildCubit
    Widgets --> AssessmentCubit
    Widgets --> ThemeCubit
    Widgets --> OnboardingCubit

    AuthCubit --> FirebaseAuth
    ChildCubit --> ChildRepository
    AssessmentCubit --> AssessmentService
    ThemeCubit --> SharedPrefs
    OnboardingCubit --> SharedPrefs

    AssessmentService --> SdqScoringService
    AssessmentService --> AiRecommendationsService
    AssessmentService --> TestResultRepository

    AiRecommendationsService --> FirebaseAI

    ChildRepository --> Firestore
    TestResultRepository --> Firestore

    ErrorHandlerService -.-> AssessmentService
    ConnectivityService -.-> OfflineQueueService
```

## Layered Architecture

```mermaid
graph LR
    subgraph "UI Layer"
        A1[Screens]
        A2[Widgets]
        A3[Themes]
    end

    subgraph "Business Logic Layer"
        B1[Cubits]
        B2[States]
        B3[Services]
    end

    subgraph "Data Access Layer"
        C1[Repositories]
        C2[Models]
        C3[DTOs]
    end

    subgraph "Infrastructure Layer"
        D1[Firebase]
        D2[Local Storage]
        D3[Network]
    end

    A1 --> B1
    A2 --> B1
    B1 --> B2
    B1 --> B3
    B3 --> C1
    C1 --> C2
    C1 --> D1
    C1 --> D2
```

## Folder Structure

```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── constants/        # Constants & questions
│   ├── di/               # Dependency injection
│   ├── exceptions/       # Custom exceptions
│   ├── repositories/     # Repository interfaces
│   ├── services/         # Business services
│   ├── theme/            # App theming
│   ├── utils/            # Utilities
│   └── widgets/          # Shared widgets
├── cubit/
│   ├── auth/             # Authentication state
│   ├── assessment/       # Assessment state
│   ├── child/            # Child management state
│   ├── onboarding/       # Onboarding state
│   └── theme/            # Theme state
├── data/
│   └── repositories/     # Repository implementations
├── models/               # Data models
├── screens/              # UI screens
│   ├── auth/             # Auth screens
│   ├── child/            # Child screens
│   ├── home/             # Home screen
│   ├── legal/            # Legal screens
│   ├── onboarding/       # Onboarding screens
│   ├── settings/         # Settings screen
│   └── splash/           # Splash screen
└── widgets/              # Shared widgets
```

## Technology Stack

```mermaid
graph TB
    subgraph "Frontend"
        Flutter[Flutter 3.x]
        Dart[Dart 3.x]
    end

    subgraph "State Management"
        BLoC[flutter_bloc]
        Cubit[Cubit Pattern]
    end

    subgraph "Backend Services"
        FirebaseCore[Firebase Core]
        FirebaseAuth[Firebase Auth]
        Firestore[Cloud Firestore]
        FirebaseAI[Firebase AI - Gemini 2.0]
        AppCheck[Firebase App Check]
    end

    subgraph "Local Storage"
        SharedPrefs[SharedPreferences]
        PDFStorage[PDF Documents]
    end

    subgraph "UI/UX"
        Localization[easy_localization]
        Animations[flutter_animate]
        Shimmer[shimmer]
        PDF[pdf/printing]
    end

    Flutter --> Dart
    Flutter --> BLoC
    BLoC --> Cubit
    Flutter --> FirebaseCore
    FirebaseCore --> FirebaseAuth
    FirebaseCore --> Firestore
    FirebaseCore --> FirebaseAI
    FirebaseCore --> AppCheck
    Flutter --> SharedPrefs
    Flutter --> Localization
    Flutter --> Animations
```

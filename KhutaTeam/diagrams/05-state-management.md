# State Management Diagrams

## BLoC Architecture Overview

```mermaid
flowchart TB
    subgraph "UI Layer"
        Screen[Screen Widget]
        BlocBuilder[BlocBuilder]
        BlocListener[BlocListener]
        BlocConsumer[BlocConsumer]
    end

    subgraph "State Management"
        Cubit[Cubit]
        State[State]
        Event[Event/Method]
    end

    subgraph "Data Layer"
        Repository[Repository]
        Service[Service]
    end

    Screen --> BlocBuilder
    Screen --> BlocListener
    Screen --> BlocConsumer

    BlocBuilder -->|reads| State
    BlocListener -->|reacts to| State
    BlocConsumer -->|both| State

    Screen -->|calls| Event
    Event --> Cubit
    Cubit -->|emits| State
    Cubit --> Repository
    Cubit --> Service
```

## AuthCubit State Flow

```mermaid
stateDiagram-v2
    direction LR

    [*] --> AuthInitial

    AuthInitial --> AuthLoading: login()
    AuthInitial --> AuthLoading: register()
    AuthInitial --> AuthLoading: checkLoginStatus()

    AuthLoading --> AuthSuccess: Valid User + Verified
    AuthLoading --> AuthEmailNotVerified: Valid User + Not Verified
    AuthLoading --> AuthFailure: Error

    AuthEmailNotVerified --> AuthLoading: resendVerificationEmail()
    AuthEmailNotVerified --> AuthSuccess: Email Verified

    AuthFailure --> AuthInitial: clearError()

    AuthSuccess --> AuthInitial: logout()

    AuthSuccess --> [*]
```

## ChildCubit State Flow

```mermaid
stateDiagram-v2
    direction LR

    [*] --> Initial

    Initial --> Loading: loadChildren()

    Loading --> Loaded: Success
    Loading --> Error: Failure

    Loaded --> Adding: addChild()
    Adding --> Loaded: Success
    Adding --> Error: Failure

    Loaded --> Deleting: deleteChild()
    Deleting --> Loaded: Success
    Deleting --> Error: Failure

    Error --> Loaded: clearError()
    Error --> Loading: retry()
```

## AssessmentCubit State Flow

```mermaid
stateDiagram-v2
    direction TB

    [*] --> Initial: Create Cubit

    Initial --> InProgress: Start

    state InProgress {
        [*] --> Q1
        Q1 --> Q2: selectAnswer + next
        Q2 --> Q3: selectAnswer + next
        Q3 --> Q_N: ...
        Q_N --> Q_Last: selectAnswer + next

        Q2 --> Q1: previous
        Q3 --> Q2: previous
    }

    InProgress --> Submitting: submitAssessment()

    Submitting --> Success: Complete
    Submitting --> Error: Failed

    Error --> InProgress: clearError()

    Success --> [*]: Navigate Away
```

## State Classes

```mermaid
classDiagram
    class AuthState {
        <<abstract>>
    }
    class AuthInitial
    class AuthLoading
    class AuthSuccess {
        +User user
    }
    class AuthEmailNotVerified {
        +User user
    }
    class AuthFailure {
        +String message
    }

    AuthState <|-- AuthInitial
    AuthState <|-- AuthLoading
    AuthState <|-- AuthSuccess
    AuthState <|-- AuthEmailNotVerified
    AuthState <|-- AuthFailure

    class ChildState {
        +ChildStatus status
        +List~Child~ children
        +String? errorMessage
        +bool isEmpty
    }

    class ChildStatus {
        <<enumeration>>
        initial
        loading
        loaded
        adding
        deleting
        error
    }

    ChildState --> ChildStatus

    class AssessmentState {
        +AssessmentStatus status
        +int currentIndex
        +Map~int,int~ answers
        +double? finalScore
        +String? interpretation
        +List~String~? recommendations
        +String? errorMessage
        +bool isFirstQuestion
    }

    class AssessmentStatus {
        <<enumeration>>
        initial
        inProgress
        submitting
        success
        error
    }

    AssessmentState --> AssessmentStatus
```

## Cubit Dependencies

```mermaid
graph TB
    subgraph "Cubits"
        AuthCubit[AuthCubit]
        ChildCubit[ChildCubit]
        AssessmentCubit[AssessmentCubit]
        ThemeCubit[ThemeCubit]
        OnboardingCubit[OnboardingCubit]
    end

    subgraph "Dependencies"
        FirebaseAuth[Firebase Auth]
        ChildRepo[ChildRepository]
        AssessmentService[AssessmentService]
        SharedPrefs[SharedPreferences]
    end

    AuthCubit --> FirebaseAuth
    ChildCubit --> ChildRepo
    AssessmentCubit --> AssessmentService
    ThemeCubit --> SharedPrefs
    OnboardingCubit --> SharedPrefs
```

## MultiBlocProvider Setup

```mermaid
flowchart TD
    subgraph "main.dart"
        App[runApp]
    end

    subgraph "MultiBlocProvider"
        BP1[BlocProvider<br/>AuthCubit]
        BP2[BlocProvider<br/>ThemeCubit]
        BP3[BlocProvider<br/>OnboardingCubit]
    end

    subgraph "Child Widgets"
        KhutaApp[KhutaApp]
        MaterialApp[MaterialApp]
        Screens[All Screens]
    end

    App --> BP1
    BP1 --> BP2
    BP2 --> BP3
    BP3 --> KhutaApp
    KhutaApp --> MaterialApp
    MaterialApp --> Screens

    note1[Cubits available<br/>via context.read]
    Screens -.-> note1
```

## State Updates Example

```mermaid
sequenceDiagram
    participant UI as Screen
    participant Cubit as ChildCubit
    participant Repo as ChildRepository
    participant FB as Firestore

    UI->>Cubit: addChild(child)
    Cubit->>Cubit: emit(ChildState(status: adding))
    UI->>UI: Show Loading Indicator

    Cubit->>Repo: addChild(child)
    Repo->>FB: collection.add(child)
    FB->>Repo: Document Reference
    Repo->>Cubit: Success

    Cubit->>Cubit: emit(ChildState(status: loaded, children: [...]))
    UI->>UI: Update UI with new child
```

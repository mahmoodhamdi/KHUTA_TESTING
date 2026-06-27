# Database Schema Diagrams

## Firestore Collections Structure

```mermaid
erDiagram
    USERS ||--o{ CHILDREN : has
    CHILDREN ||--o{ TEST_RESULTS : has

    USERS {
        string id PK
        string email
        string displayName
        timestamp createdAt
        timestamp lastLogin
    }

    CHILDREN {
        string id PK
        string userId FK
        string name
        int age
        string gender
        timestamp createdAt
        timestamp updatedAt
        boolean isDeleted
    }

    TEST_RESULTS {
        string id PK
        string childId FK
        string testType
        double score
        string interpretation
        array answers
        array recommendations
        timestamp date
        string notes
    }
```

## Detailed Collection Schemas

### Users Collection
```mermaid
classDiagram
    class User {
        +String id
        +String email
        +String? displayName
        +DateTime createdAt
        +DateTime? lastLogin
        +bool emailVerified
    }

    note for User "Path: /users/{userId}"
```

### Children Collection
```mermaid
classDiagram
    class Child {
        +String id
        +String name
        +int age
        +String gender
        +List~TestResult~ testResults
        +DateTime createdAt
        +DateTime? updatedAt
        +bool isDeleted
    }

    note for Child "Path: /users/{userId}/children/{childId}"
```

### Test Results Collection
```mermaid
classDiagram
    class TestResult {
        +String id
        +String testType
        +double score
        +String interpretation
        +List~int~ answers
        +List~String~ recommendations
        +DateTime date
        +String notes
    }

    note for TestResult "Path: /users/{userId}/children/{childId}/testResults/{testId}"
```

## Data Flow

```mermaid
flowchart TB
    subgraph "Client (Flutter App)"
        Model[Data Models]
        Repo[Repositories]
    end

    subgraph "Cloud Firestore"
        Users[(users)]
        Children[(children)]
        Results[(testResults)]
    end

    Model <--> Repo
    Repo <--> Users
    Repo <--> Children
    Repo <--> Results

    Users -->|subcollection| Children
    Children -->|subcollection| Results
```

## Security Rules Structure

```mermaid
flowchart TD
    Request[Firestore Request] --> AuthCheck{Authenticated?}

    AuthCheck -->|No| Deny[❌ Deny]
    AuthCheck -->|Yes| OwnerCheck{Owner of Data?}

    OwnerCheck -->|No| Deny
    OwnerCheck -->|Yes| OperationCheck{Valid Operation?}

    OperationCheck -->|Read| AllowRead[✅ Allow Read]
    OperationCheck -->|Create| ValidateCreate{Valid Data?}
    OperationCheck -->|Update| ValidateUpdate{Valid Update?}
    OperationCheck -->|Delete| AllowDelete[✅ Allow Delete]

    ValidateCreate -->|Yes| AllowCreate[✅ Allow Create]
    ValidateCreate -->|No| Deny

    ValidateUpdate -->|Yes| AllowUpdate[✅ Allow Update]
    ValidateUpdate -->|No| Deny
```

## Local Storage Structure

```mermaid
graph TB
    subgraph "SharedPreferences"
        Theme[theme_mode<br/>light/dark]
        Language[language<br/>en/ar]
        Onboarding[onboarding_complete<br/>true/false]
        OfflineQueue[offline_queue<br/>JSON array]
    end

    subgraph "App Documents Directory"
        PDFs[/reports/<br/>PDF files]
    end

    subgraph "Firestore Cache"
        FirestoreCache[Local Cache<br/>Automatic]
    end
```

## Data Models (Dart Classes)

```mermaid
classDiagram
    class Child {
        +String id
        +String name
        +int age
        +String gender
        +List~TestResult~ testResults
        +DateTime createdAt
        +DateTime? updatedAt
        +bool isDeleted
        +toJson() Map
        +fromJson(Map) Child$
        +copyWith() Child
        +copyWithDeleted() Child
    }

    class TestResult {
        +String id
        +String testType
        +double score
        +String interpretation
        +List~int~ answers
        +List~String~ recommendations
        +DateTime date
        +String notes
        +toJson() Map
        +fromJson(Map) TestResult$
    }

    class Question {
        +String id
        +String questionText
        +String questionType
        +String? imageUrl
    }

    Child "1" --> "*" TestResult : contains
```

## Offline Sync Strategy

```mermaid
sequenceDiagram
    participant App
    participant Cache as Local Cache
    participant Queue as Offline Queue
    participant Firestore

    Note over App,Firestore: Online Mode
    App->>Firestore: Write Data
    Firestore->>Cache: Sync to Cache
    Firestore->>App: Confirm

    Note over App,Firestore: Offline Mode
    App->>Cache: Read from Cache
    App->>Queue: Queue Write Operation
    Queue->>Queue: Store Pending Operations

    Note over App,Firestore: Back Online
    Queue->>Firestore: Sync Pending Operations
    Firestore->>Cache: Update Cache
    Queue->>Queue: Clear Synced Operations
```

## Index Requirements

```mermaid
graph LR
    subgraph "Composite Indexes"
        I1[children<br/>userId ASC, createdAt DESC]
        I2[children<br/>userId ASC, isDeleted ASC]
        I3[testResults<br/>childId ASC, date DESC]
    end

    subgraph "Single Field Indexes"
        S1[userId]
        S2[createdAt]
        S3[isDeleted]
    end
```

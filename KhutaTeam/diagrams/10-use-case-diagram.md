# Use Case Diagrams

## System Use Cases

```mermaid
graph TB
    subgraph "Khuta ADHD Assessment System"
        subgraph "Authentication"
            UC1((Register))
            UC2((Login))
            UC3((Logout))
            UC4((Reset Password))
            UC5((Verify Email))
        end

        subgraph "Child Management"
            UC6((Add Child))
            UC7((View Children))
            UC8((View Child Details))
            UC9((Delete Child))
        end

        subgraph "Assessment"
            UC10((Start Assessment))
            UC11((Answer Questions))
            UC12((Submit Assessment))
            UC13((View Results))
            UC14((View Recommendations))
        end

        subgraph "Reports"
            UC15((Generate PDF))
            UC16((Share Report))
            UC17((View History))
        end

        subgraph "Settings"
            UC18((Change Theme))
            UC19((Change Language))
            UC20((View Privacy Policy))
        end
    end

    User((User/Parent))

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    User --> UC16
    User --> UC17
    User --> UC18
    User --> UC19
    User --> UC20
```

## Detailed Use Cases

### Authentication Use Cases

```mermaid
graph LR
    User((User))

    subgraph "Authentication"
        Register((Register<br/>New Account))
        Login((Login))
        Logout((Logout))
        ResetPwd((Reset<br/>Password))
        VerifyEmail((Verify<br/>Email))
    end

    subgraph "External Systems"
        Firebase[(Firebase Auth)]
        EmailService[Email Service]
    end

    User --> Register
    User --> Login
    User --> Logout
    User --> ResetPwd

    Register --> Firebase
    Register --> EmailService
    Login --> Firebase
    Logout --> Firebase
    ResetPwd --> EmailService
    VerifyEmail --> EmailService
```

### Child Management Use Cases

```mermaid
graph LR
    User((Parent))

    subgraph "Child Management"
        AddChild((Add Child))
        ViewChildren((View All<br/>Children))
        ViewDetails((View Child<br/>Details))
        DeleteChild((Delete Child))
        EditChild((Edit Child))
    end

    subgraph "Data Storage"
        Firestore[(Cloud Firestore)]
    end

    User --> AddChild
    User --> ViewChildren
    User --> ViewDetails
    User --> DeleteChild
    User --> EditChild

    AddChild --> Firestore
    ViewChildren --> Firestore
    ViewDetails --> Firestore
    DeleteChild --> Firestore
    EditChild --> Firestore
```

### Assessment Use Cases

```mermaid
graph TB
    User((Parent/Teacher))

    subgraph "Assessment Process"
        SelectType((Select<br/>Assessment Type))
        AnswerQ((Answer<br/>Questions))
        Navigate((Navigate<br/>Questions))
        Submit((Submit<br/>Assessment))
    end

    subgraph "Processing"
        CalcScore((Calculate<br/>T-Score))
        GetRecs((Get AI<br/>Recommendations))
        SaveResult((Save<br/>Results))
    end

    subgraph "View Results"
        ViewScore((View<br/>Score))
        ViewInterp((View<br/>Interpretation))
        ViewRecs((View<br/>Recommendations))
    end

    subgraph "External"
        GeminiAI[Gemini AI]
        Firestore[(Firestore)]
    end

    User --> SelectType
    SelectType --> AnswerQ
    AnswerQ --> Navigate
    Navigate --> Submit

    Submit --> CalcScore
    CalcScore --> GetRecs
    GetRecs --> GeminiAI
    GetRecs --> SaveResult
    SaveResult --> Firestore

    SaveResult --> ViewScore
    ViewScore --> ViewInterp
    ViewInterp --> ViewRecs

    ViewRecs --> User
```

### Report Use Cases

```mermaid
graph LR
    User((User))

    subgraph "Report Generation"
        GenPDF((Generate<br/>PDF Report))
        ShareReport((Share<br/>Report))
        ViewHistory((View Test<br/>History))
    end

    subgraph "Storage"
        LocalFS[Local<br/>File System]
        Firestore[(Firestore)]
    end

    subgraph "External"
        SharePlugin[Share<br/>Plugin]
    end

    User --> GenPDF
    User --> ShareReport
    User --> ViewHistory

    GenPDF --> LocalFS
    ShareReport --> SharePlugin
    ViewHistory --> Firestore
```

## Actor Descriptions

| Actor | Description |
|-------|-------------|
| **Parent** | Primary user who registers, adds children, and conducts parent assessments |
| **Teacher** | Secondary user who can conduct teacher assessments (using parent's account) |
| **Firebase Auth** | External authentication service |
| **Firestore** | Cloud database for storing user data |
| **Gemini AI** | AI service for generating recommendations |
| **Email Service** | Email verification and password reset |

## Use Case Specifications

### UC1: Register New Account
| Field | Description |
|-------|-------------|
| **Actor** | User (Parent) |
| **Precondition** | User has valid email address |
| **Main Flow** | 1. User enters name, email, password<br/>2. System validates input<br/>3. System creates account<br/>4. System sends verification email<br/>5. User verifies email |
| **Postcondition** | Account created and verified |
| **Extensions** | Email already in use, Weak password |

### UC10: Start Assessment
| Field | Description |
|-------|-------------|
| **Actor** | User (Parent/Teacher) |
| **Precondition** | User logged in, Child exists |
| **Main Flow** | 1. User selects child<br/>2. User selects assessment type<br/>3. System loads questions<br/>4. User answers 27 questions<br/>5. System calculates score<br/>6. System gets AI recommendations<br/>7. System saves results |
| **Postcondition** | Assessment completed and saved |
| **Extensions** | Network error, AI unavailable |

### UC15: Generate PDF Report
| Field | Description |
|-------|-------------|
| **Actor** | User |
| **Precondition** | Assessment completed |
| **Main Flow** | 1. User taps Generate PDF<br/>2. System creates PDF document<br/>3. System saves to local storage<br/>4. System offers share options |
| **Postcondition** | PDF saved and shareable |
| **Extensions** | Storage full |

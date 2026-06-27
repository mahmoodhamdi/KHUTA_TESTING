# Sequence Diagrams

## User Registration Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as RegisterScreen
    participant Cubit as AuthCubit
    participant Auth as Firebase Auth
    participant Email as Email Service

    User->>UI: Enter name, email, password
    User->>UI: Tap Register
    UI->>Cubit: register(email, password, name)
    Cubit->>Cubit: emit(AuthLoading)
    UI->>UI: Show loading indicator

    Cubit->>Auth: createUserWithEmailAndPassword()
    Auth->>Auth: Create user account
    Auth->>Cubit: UserCredential

    Cubit->>Auth: updateDisplayName(name)
    Cubit->>Auth: sendEmailVerification()
    Auth->>Email: Send verification email
    Email->>User: Verification email

    Cubit->>Cubit: emit(AuthEmailNotVerified)
    UI->>UI: Navigate to verification screen
    UI->>User: Show "Check your email"
```

## Login Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as LoginScreen
    participant Cubit as AuthCubit
    participant Auth as Firebase Auth

    User->>UI: Enter email, password
    User->>UI: Tap Login
    UI->>Cubit: login(email, password)
    Cubit->>Cubit: emit(AuthLoading)
    UI->>UI: Show loading

    Cubit->>Auth: signInWithEmailAndPassword()

    alt Valid Credentials
        Auth->>Cubit: UserCredential
        Cubit->>Cubit: Check emailVerified

        alt Email Verified
            Cubit->>Cubit: emit(AuthSuccess)
            UI->>UI: Navigate to HomeScreen
        else Email Not Verified
            Cubit->>Cubit: emit(AuthEmailNotVerified)
            UI->>UI: Navigate to VerifyScreen
        end
    else Invalid Credentials
        Auth->>Cubit: FirebaseAuthException
        Cubit->>Cubit: emit(AuthFailure)
        UI->>User: Show error message
    end
```

## Load Children Sequence

```mermaid
sequenceDiagram
    participant UI as HomeScreen
    participant Cubit as ChildCubit
    participant Repo as ChildRepository
    participant FS as Firestore

    UI->>Cubit: loadChildren()
    Cubit->>Cubit: emit(status: loading)
    UI->>UI: Show shimmer skeleton

    Cubit->>Repo: getChildren()
    Repo->>FS: Query children collection
    FS->>Repo: Stream<List<Child>>
    Repo->>Cubit: Children list

    Cubit->>Cubit: emit(status: loaded, children)

    alt No Children
        UI->>UI: Show empty state
    else Has Children
        UI->>UI: Show children list
    end
```

## Complete Assessment Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as AssessmentScreen
    participant Cubit as AssessmentCubit
    participant Service as AssessmentService
    participant Scoring as SdqScoringService
    participant AI as AiRecommendationsService
    participant Repo as TestResultRepository
    participant FS as Firestore

    User->>UI: Start Assessment
    UI->>Cubit: Create with child & questions

    loop For each question
        UI->>User: Display question
        User->>UI: Select answer
        UI->>Cubit: selectAnswer(index, value)
        Cubit->>Cubit: Update answers map
        User->>UI: Tap Next
        UI->>Cubit: nextQuestion()
    end

    User->>UI: Tap Submit
    UI->>Cubit: submitAssessment()
    Cubit->>Cubit: emit(status: submitting)
    UI->>UI: Show loading overlay

    Cubit->>Service: submitAssessment(child, questions, answers)

    Service->>Scoring: calculateTScore(answers, age, gender)
    Scoring->>Scoring: Sum raw scores
    Scoring->>Scoring: Lookup T-Score from norms
    Scoring->>Service: T-Score (e.g., 65.0)

    Service->>Scoring: getInterpretation(tScore)
    Scoring->>Service: "Elevated"

    Service->>AI: getRecommendations(answers, questions, score)
    AI->>AI: Detect language
    AI->>AI: Build prompt

    alt AI Success
        AI->>AI: Call Gemini API
        AI->>AI: Parse response
        AI->>Service: List<String> recommendations
    else AI Failure
        AI->>AI: Get fallback recommendations
        AI->>Service: Fallback recommendations
    end

    Service->>Repo: addTestResult(childId, result)
    Repo->>FS: Add document
    FS->>Repo: Success

    Service->>Cubit: AssessmentResult
    Cubit->>Cubit: emit(status: success, score, recommendations)
    UI->>UI: Navigate to ResultsScreen
    UI->>User: Show results
```

## Generate PDF Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as ResultsScreen
    participant PDFService as PDF Service
    participant FileSystem as File System
    participant Share as Share Plugin

    User->>UI: Tap Generate PDF
    UI->>PDFService: generateReport(child, score, recommendations)

    PDFService->>PDFService: Create PDF document
    PDFService->>PDFService: Add header with child info
    PDFService->>PDFService: Add score section
    PDFService->>PDFService: Add recommendations
    PDFService->>PDFService: Add footer with date

    PDFService->>FileSystem: Get documents directory
    FileSystem->>PDFService: Path
    PDFService->>FileSystem: Save PDF file

    PDFService->>PDFService: Cleanup old reports (>24h)

    PDFService->>UI: File path

    UI->>Share: Share file
    Share->>User: Share sheet
```

## Offline Sync Sequence

```mermaid
sequenceDiagram
    participant App
    participant Queue as OfflineQueueService
    participant Connectivity as ConnectivityService
    participant FS as Firestore

    Note over App,FS: App goes offline

    App->>Queue: queueOperation(addChild, data)
    Queue->>Queue: Store in SharedPreferences

    App->>Queue: queueOperation(addTestResult, data)
    Queue->>Queue: Append to queue

    Note over App,FS: App comes back online

    Connectivity->>App: Connection restored
    App->>Queue: syncQueue(processor)

    loop For each queued operation
        Queue->>FS: Execute operation
        FS->>Queue: Success
        Queue->>Queue: Remove from queue
    end

    Queue->>App: Sync complete (count)
```

## Theme Toggle Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as SettingsScreen
    participant Cubit as ThemeCubit
    participant Prefs as SharedPreferences
    participant App as MaterialApp

    User->>UI: Toggle dark mode switch
    UI->>Cubit: toggleTheme()
    Cubit->>Cubit: Determine new theme
    Cubit->>Prefs: Save theme preference
    Cubit->>Cubit: emit(ThemeDark/ThemeLight)

    App->>App: BlocBuilder rebuilds
    App->>App: Apply new ThemeMode
    UI->>User: Theme changes instantly
```

## Language Change Sequence

```mermaid
sequenceDiagram
    actor User
    participant UI as SettingsScreen
    participant Prefs as SharedPreferences
    participant Localization as EasyLocalization
    participant App as MaterialApp

    User->>UI: Select language (AR/EN)
    UI->>Prefs: Save language preference
    UI->>Localization: setLocale(Locale)

    Localization->>App: Notify locale change
    App->>App: Rebuild with new locale

    alt Arabic Selected
        App->>App: Set RTL direction
        App->>App: Load ar.json translations
    else English Selected
        App->>App: Set LTR direction
        App->>App: Load en.json translations
    end

    UI->>User: UI updates in new language
```

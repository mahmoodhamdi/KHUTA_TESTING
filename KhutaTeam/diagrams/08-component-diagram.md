# Component Diagrams

## Screen Components Overview

```mermaid
graph TB
    subgraph "App Entry"
        Main[main.dart]
        KhutaApp[KhutaApp]
    end

    subgraph "Navigation"
        MainScreen[MainScreen<br/>Bottom Navigation]
    end

    subgraph "Auth Screens"
        Splash[SplashScreen]
        Login[LoginScreen]
        Register[RegisterScreen]
        VerifyEmail[VerifyEmailScreen]
        ForgotPassword[ForgotPasswordScreen]
    end

    subgraph "Onboarding"
        Onboarding[OnboardingScreen]
    end

    subgraph "Main Screens"
        Home[HomeScreen]
        Settings[SettingsScreen]
    end

    subgraph "Child Screens"
        AddChild[AddChildScreen]
        ChildDetails[ChildDetailsScreen]
    end

    subgraph "Assessment Screens"
        Assessment[AssessmentScreen]
        Results[ResultsScreen]
    end

    subgraph "Legal Screens"
        Privacy[PrivacyPolicyScreen]
        Terms[TermsScreen]
        MarkdownView[MarkdownViewScreen]
    end

    Main --> KhutaApp
    KhutaApp --> Splash
    Splash --> Onboarding
    Splash --> Login
    Onboarding --> Login
    Login --> Register
    Login --> ForgotPassword
    Login --> MainScreen
    Register --> VerifyEmail
    VerifyEmail --> Login

    MainScreen --> Home
    MainScreen --> Settings

    Home --> AddChild
    Home --> ChildDetails
    ChildDetails --> Assessment
    Assessment --> Results
    Results --> ChildDetails

    Settings --> Privacy
    Settings --> Terms
```

## HomeScreen Components

```mermaid
graph TB
    subgraph "HomeScreen"
        AppBar[AppBar<br/>Title: My Children]
        Body[Body Content]
        FAB[FloatingActionButton<br/>Add Child]
    end

    subgraph "Body States"
        Loading[ChildListSkeleton<br/>Shimmer Loading]
        Error[ErrorWidget<br/>Retry Button]
        Empty[EmptyState<br/>Add First Child]
        List[ChildrenList]
    end

    subgraph "ChildCard"
        Avatar[Avatar Icon<br/>Boy/Girl]
        Name[Child Name]
        Age[Age Display]
        TestResults[Test Results Section]
    end

    subgraph "TestResultsSection"
        LastTest[Last Test Date]
        Score[Score Badge<br/>Color Coded]
        Severity[Severity Text]
    end

    Body --> Loading
    Body --> Error
    Body --> Empty
    Body --> List

    List --> ChildCard
    ChildCard --> Avatar
    ChildCard --> Name
    ChildCard --> Age
    ChildCard --> TestResults

    TestResults --> LastTest
    TestResults --> Score
    TestResults --> Severity
```

## AssessmentScreen Components

```mermaid
graph TB
    subgraph "AssessmentScreen"
        AAppBar[AppBar<br/>Assessment Type]
        Progress[AssessmentProgressBar]
        Content[Question Content]
        Navigation[NavigationButtons]
    end

    subgraph "Progress Bar"
        ProgressIndicator[Linear Progress]
        QuestionCounter[Question X of Y]
    end

    subgraph "Question Content"
        QImage[QuestionImage<br/>Optional]
        QText[QuestionText]
        Answers[AnswerOptionsList]
    end

    subgraph "Answer Options"
        Opt0[Not at All - 0]
        Opt1[Just a Little - 1]
        Opt2[Pretty Much - 2]
        Opt3[Very Much - 3]
    end

    subgraph "Navigation"
        PrevBtn[Previous Button]
        NextBtn[Next/Submit Button]
    end

    AAppBar --> Progress
    Progress --> Content
    Content --> Navigation

    Progress --> ProgressIndicator
    Progress --> QuestionCounter

    Content --> QImage
    Content --> QText
    Content --> Answers

    Answers --> Opt0
    Answers --> Opt1
    Answers --> Opt2
    Answers --> Opt3

    Navigation --> PrevBtn
    Navigation --> NextBtn
```

## ResultsScreen Components

```mermaid
graph TB
    subgraph "ResultsScreen"
        RAppBar[AppBar<br/>Results]
        ScoreSection[Score Display]
        InterpSection[Interpretation]
        RecsSection[Recommendations]
        ActionsSection[Action Buttons]
    end

    subgraph "Score Display"
        ScoreCircle[Animated Circle]
        ScoreValue[T-Score Value]
        ScoreColor[Color Indicator]
    end

    subgraph "Interpretation"
        SeverityBadge[Severity Badge]
        Description[Description Text]
    end

    subgraph "Recommendations"
        RecsList[Numbered List]
        RecItem1[Recommendation 1]
        RecItem2[Recommendation 2]
        RecItemN[Recommendation N]
    end

    subgraph "Actions"
        PDFBtn[Generate PDF]
        ShareBtn[Share]
        HomeBtn[Back to Home]
    end

    RAppBar --> ScoreSection
    ScoreSection --> InterpSection
    InterpSection --> RecsSection
    RecsSection --> ActionsSection

    ScoreSection --> ScoreCircle
    ScoreSection --> ScoreValue
    ScoreSection --> ScoreColor

    InterpSection --> SeverityBadge
    InterpSection --> Description

    RecsSection --> RecsList
    RecsList --> RecItem1
    RecsList --> RecItem2
    RecsList --> RecItemN

    ActionsSection --> PDFBtn
    ActionsSection --> ShareBtn
    ActionsSection --> HomeBtn
```

## Shared Widgets

```mermaid
graph TB
    subgraph "Loading Widgets"
        ShimmerBox[ShimmerBox]
        ChildCardSkeleton[ChildCardSkeleton]
        ChildListSkeleton[ChildListSkeleton]
        QuestionSkeleton[QuestionSkeleton]
        ResultsSkeleton[ResultsSkeleton]
        LoadingOverlay[LoadingOverlay]
    end

    subgraph "Error Widgets"
        ErrorBoundary[ErrorBoundary]
        ErrorDisplay[ErrorDisplay]
        NoConnectionWidget[NoConnectionWidget]
    end

    subgraph "Offline Widgets"
        OfflineBanner[OfflineBanner]
        OfflineIndicator[OfflineIndicator]
        OfflineAwareScaffold[OfflineAwareScaffold]
    end

    subgraph "Navigation Widgets"
        FadePageRoute[FadePageRoute]
        SlidePageRoute[SlidePageRoute]
        SlideUpPageRoute[SlideUpPageRoute]
        ScaleFadePageRoute[ScaleFadePageRoute]
    end
```

## Theme Components

```mermaid
graph LR
    subgraph "Theme System"
        AppTheme[AppTheme]
        HomeScreenTheme[HomeScreenTheme]
        InputThemes[InputThemes]
    end

    subgraph "AppTheme"
        LightTheme[lightTheme]
        DarkTheme[darkTheme]
    end

    subgraph "HomeScreenTheme"
        BGColor[backgroundColor]
        CardBG[cardBackground]
        TextColors[primaryText/secondaryText]
        AccentColors[accentBlue/Pink/Green/Red]
        ScoreColor[getScoreColor]
    end

    AppTheme --> LightTheme
    AppTheme --> DarkTheme
    HomeScreenTheme --> BGColor
    HomeScreenTheme --> CardBG
    HomeScreenTheme --> TextColors
    HomeScreenTheme --> AccentColors
    HomeScreenTheme --> ScoreColor
```

## Widget Interactions

```mermaid
sequenceDiagram
    participant User
    participant ChildCard
    participant HapticUtils
    participant Navigator
    participant ChildDetails

    User->>ChildCard: Tap
    ChildCard->>HapticUtils: cardTap()
    HapticUtils->>HapticUtils: Light Impact
    ChildCard->>Navigator: push(SlidePageRoute)
    Navigator->>ChildDetails: Navigate with Animation
    ChildDetails->>User: Show Child Details
```

# Assessment Flow Diagrams

## Complete Assessment Flow

```mermaid
flowchart TD
    Start([Child Details Screen]) --> SelectType{Select Assessment Type}

    SelectType -->|Parent| ParentQuestions[Load Parent Questions<br/>27 questions]
    SelectType -->|Teacher| TeacherQuestions[Load Teacher Questions<br/>27 questions]

    ParentQuestions --> AssessmentScreen[Assessment Screen]
    TeacherQuestions --> AssessmentScreen

    AssessmentScreen --> ShowQuestion[Display Question]
    ShowQuestion --> SelectAnswer{Select Answer}

    SelectAnswer -->|Not at All| Score0[Score: 0]
    SelectAnswer -->|Just a Little| Score1[Score: 1]
    SelectAnswer -->|Pretty Much| Score2[Score: 2]
    SelectAnswer -->|Very Much| Score3[Score: 3]

    Score0 --> SaveAnswer[Save Answer]
    Score1 --> SaveAnswer
    Score2 --> SaveAnswer
    Score3 --> SaveAnswer

    SaveAnswer --> CheckProgress{Last Question?}

    CheckProgress -->|No| NextQuestion[Next Question]
    NextQuestion --> ShowQuestion

    CheckProgress -->|Yes| ValidateAnswers{All Answered?}

    ValidateAnswers -->|No| ShowError[Show Error Message]
    ShowError --> ShowQuestion

    ValidateAnswers -->|Yes| ShowLoading[Show Loading]
    ShowLoading --> CalculateRaw[Calculate Raw Score]
    CalculateRaw --> GetAgeGroup[Determine Age Group]
    GetAgeGroup --> GetGender[Get Gender]
    GetGender --> LookupTScore[Lookup T-Score from Norms Table]

    LookupTScore --> GetInterpretation[Get Score Interpretation]
    GetInterpretation --> CallAI[Call AI for Recommendations]

    CallAI --> AIResult{AI Success?}
    AIResult -->|Yes| ParseRecommendations[Parse AI Recommendations]
    AIResult -->|No| UseFallback[Use Fallback Recommendations]

    ParseRecommendations --> SaveResults[Save to Firestore]
    UseFallback --> SaveResults

    SaveResults --> ResultsScreen([Results Screen])
```

## T-Score Calculation Process

```mermaid
flowchart LR
    subgraph "Input"
        Answers[27 Answers<br/>0-3 each]
        Age[Child Age]
        Gender[Child Gender]
    end

    subgraph "Processing"
        FilterValid[Filter Valid Answers<br/>Remove -1 values]
        SumScores[Sum All Scores]
        DetermineAgeGroup[Determine Age Group<br/>6-8, 9-11, 12-14, 15-17]
        LookupTable[Lookup Norms Table<br/>by Age + Gender]
        FindTScore[Find T-Score<br/>from Raw Score]
    end

    subgraph "Output"
        TScore[T-Score<br/>40-90 range]
        Interpretation[Interpretation<br/>Average/Elevated/High/Very High]
    end

    Answers --> FilterValid
    FilterValid --> SumScores
    Age --> DetermineAgeGroup
    Gender --> LookupTable
    DetermineAgeGroup --> LookupTable
    SumScores --> LookupTable
    LookupTable --> FindTScore
    FindTScore --> TScore
    TScore --> Interpretation
```

## Score Interpretation

```mermaid
graph LR
    subgraph "T-Score Ranges"
        A[T < 45] -->|Green| Avg[Average<br/>Low Concern]
        B[45 ≤ T ≤ 55] -->|Yellow| Mild[Slightly Elevated<br/>Monitor]
        C[55 < T ≤ 65] -->|Orange| Mod[Elevated<br/>Concern]
        D[T > 65] -->|Red| High[Very Elevated<br/>High Concern]
    end
```

## AI Recommendations Flow

```mermaid
sequenceDiagram
    participant App as App
    participant Service as AiRecommendationsService
    participant Gemini as Firebase AI (Gemini)

    App->>Service: getRecommendations(answers, questions, score)
    Service->>Service: Detect Language (AR/EN)
    Service->>Service: Build Prompt with Context
    Service->>Service: Add Retry Logic

    loop Max 3 Retries
        Service->>Gemini: Generate Content
        alt Success
            Gemini->>Service: AI Response
            Service->>Service: Parse Numbered List
            Service->>App: List<String> Recommendations
        else Failure
            Service->>Service: Wait with Exponential Backoff
            Service->>Gemini: Retry
        end
    end

    alt All Retries Failed
        Service->>Service: Get Fallback Recommendations
        Service->>App: Fallback Recommendations
    end
```

## Assessment State Machine

```mermaid
stateDiagram-v2
    [*] --> Initial: Load Questions

    Initial --> InProgress: Start Assessment

    InProgress --> InProgress: Answer Question
    InProgress --> InProgress: Navigate Next/Previous

    InProgress --> Submitting: Submit (All Answered)
    InProgress --> InProgress: Validation Error

    Submitting --> Success: Calculation Complete
    Submitting --> Error: API/Calculation Error

    Error --> InProgress: Retry

    Success --> [*]: Navigate to Results
```

## Question Types

```mermaid
classDiagram
    class Question {
        +String id
        +String questionText
        +String questionType
        +String? imageUrl
    }

    class ParentQuestion {
        +questionType = "parent_assessment"
        +27 questions
    }

    class TeacherQuestion {
        +questionType = "teacher_assessment"
        +27 questions
    }

    class AnswerOption {
        +int value
        +String label
    }

    Question <|-- ParentQuestion
    Question <|-- TeacherQuestion

    Question "1" --> "4" AnswerOption : has options

    note for AnswerOption "0: Not at All\n1: Just a Little\n2: Pretty Much\n3: Very Much"
```

## Results Display

```mermaid
flowchart TB
    subgraph "Results Screen"
        Score[Score Circle<br/>with Animation]
        Interpretation[Score Interpretation<br/>with Color]
        Recommendations[AI Recommendations<br/>Numbered List]
        Actions[Action Buttons]
    end

    subgraph "Actions"
        Actions --> PDF[Generate PDF]
        Actions --> Share[Share Results]
        Actions --> Home[Back to Home]
    end

    subgraph "PDF Report"
        PDF --> ChildInfo[Child Information]
        PDF --> ScoreDetails[Score & Interpretation]
        PDF --> AllRecommendations[All Recommendations]
        PDF --> DateTime[Date & Time]
    end
```

# Khuta App - Diagrams

This folder contains all system diagrams for the Khuta ADHD Assessment App.

## Diagrams Overview

| Diagram | File | Description |
|---------|------|-------------|
| App Architecture | [01-app-architecture.md](01-app-architecture.md) | Overall system architecture |
| User Flow | [02-user-flow.md](02-user-flow.md) | Complete user journey |
| Authentication Flow | [03-authentication-flow.md](03-authentication-flow.md) | Login, register, verification |
| Assessment Flow | [04-assessment-flow.md](04-assessment-flow.md) | Assessment process and scoring |
| State Management | [05-state-management.md](05-state-management.md) | BLoC/Cubit patterns |
| Database Schema | [06-database-schema.md](06-database-schema.md) | Firestore data structure |
| Class Diagram | [07-class-diagram.md](07-class-diagram.md) | Key classes and relationships |
| Component Diagram | [08-component-diagram.md](08-component-diagram.md) | UI components hierarchy |
| Sequence Diagrams | [09-sequence-diagrams.md](09-sequence-diagrams.md) | Key interactions |
| Use Case Diagram | [10-use-case-diagram.md](10-use-case-diagram.md) | System use cases |

## How to View Diagrams

These diagrams are written in **Mermaid** markdown format. You can view them:

1. **GitHub**: GitHub automatically renders Mermaid diagrams
2. **VS Code**: Install "Markdown Preview Mermaid Support" extension
3. **Online**: Use [Mermaid Live Editor](https://mermaid.live/)
4. **Export to PNG/SVG**: Use Mermaid CLI or online tools

## Quick Links

- [App Architecture](#app-architecture)
- [User Flow](#user-flow)
- [Assessment Flow](#assessment-flow)

---

## App Overview

**Khuta** is a Flutter-based mobile application for ADHD assessment using the Conners' Rating Scale with AI-powered recommendations.

### Key Features
- Multi-language support (English/Arabic)
- Parent and Teacher assessment forms
- T-Score calculation with age/gender norms
- AI-generated personalized recommendations
- Offline support with data sync
- PDF report generation

### Technology Stack
- **Frontend**: Flutter (Dart)
- **State Management**: BLoC/Cubit
- **Backend**: Firebase (Auth, Firestore, AI)
- **AI**: Google Gemini 2.0 Flash
- **Localization**: easy_localization

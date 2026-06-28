# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

The Flutter application lives in the [KhutaTeam/](KhutaTeam/) directory — run all `flutter`/`dart` commands from there, and see [KhutaTeam/CLAUDE.md](KhutaTeam/CLAUDE.md) for full architecture and command documentation.

**Khuta** is a Flutter app for ADHD assessment (Conners' Rating Scale) with AI-powered recommendations, a doctor directory with appointment booking, and a cognitive mini-game.

## Layout

- [KhutaTeam/](KhutaTeam/) — the main Flutter app. **Work here.**
- [KhutaTeam/mobile_preview/](KhutaTeam/mobile_preview/) — a separate standalone Flutter copy for UI preview only. It does **not** share code with the main app; changes must be ported manually.
- [KhutaTeam/diagrams/](KhutaTeam/diagrams/) — architecture/flow/sequence diagrams (Mermaid markdown).
- [KhutaTeam/.code-review/](KhutaTeam/.code-review/) — phased improvement plan, checklists, and prompts.

## Quick Start

```bash
cd KhutaTeam
flutter pub get
flutter run
flutter test
flutter analyze
```

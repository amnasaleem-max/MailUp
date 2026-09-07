# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Generate Riverpod providers and other generated code (required after modifying @riverpod annotations)
flutter pub run build_runner build

# Watch mode for code generation
flutter pub run build_runner watch

# Firebase Cloud Functions (from /functions directory)
cd functions && npm install
cd functions && npm run build
cd functions && npm run lint
firebase deploy --only functions
```

## Architecture

**Mail-Up** is a Gmail client with AI features, built on a **feature-based clean architecture**.

### Structure

```
lib/
├── core/                    # Shared infrastructure
│   ├── providers/           # Global state (theme)
│   ├── router/              # Go Router config & route definitions
│   ├── services/            # Push notifications (FCM)
│   └── theme/               # Material 3 light/dark themes (Poppins/Inter fonts)
└── features/                # Feature modules, each with:
    ├── data/                # Models, repositories, API calls
    └── presentation/
        ├── pages/           # Screens
        ├── providers/       # Riverpod state (+ generated .g.dart files)
        └── widgets/         # Feature-specific widgets
```

Features: `auth`, `home` (inbox), `splash`, `onboarding`, `setup`, `settings`, `summary`, `ai`.

### State Management: Riverpod with code generation

All providers use `@riverpod` / `@Riverpod(keepAlive: true)` annotations. After modifying any provider, run `build_runner build` to regenerate the corresponding `.g.dart` file. Never edit `.g.dart` files directly.

### Routing: Go Router

Routes are defined in `lib/core/router/router_definitions.dart` and wired in `lib/core/router/router.dart`. Add new routes to both files.

### Backend

Firebase Cloud Functions (TypeScript, in `/functions/`) handle secure server-side operations — primarily the OAuth token exchange flow. The Flutter app calls these via `cloud_functions` package callable functions.

### Key data flows

- **Auth**: Google Sign-In → Firebase Auth → Cloud Function exchanges auth code for Gmail refresh token → stored in Firestore
- **Email**: Gmail API (`googleapis` package) fetches emails with pagination (50/page); bodies are Base64-decoded HTML or plain text
- **AI**: Google Generative AI (Gemini) used in `lib/features/ai/`
- **Notifications**: FCM token synced to Firestore on login; background handler uses `@pragma('vm:entry-point')`

### Firebase project

Project ID: `mailup-7ff3d` (see `firebase.json` / `.firebaserc`).

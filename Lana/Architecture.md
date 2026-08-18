# Lana Architecture

This project follows MVVM with a thin service layer and local persistence.

- Models: Plain Swift data types (Codable) for quizzes, words, movies, grammar, listening, and progress.
- ViewModels: State holders for each screen, injected with repositories/services.
- Services:
  - `JSONContentService` loads teacher-managed content from bundled JSON files.
  - `SQLiteService` stores user data locally (saved words, quiz results, streak).
  - `NotificationService` schedules local reminders (Word of the Day, Quiz).
- Views: SwiftUI screens built from smaller Components.

To connect an API later, replace `JSONContentService` with a network-backed repository without changing the UI or ViewModels.

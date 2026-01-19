# Amharic Bible App (የአማርኛ መጽሐፍ ቅዱስ)

A modern, fast, and offline-first Amharic Bible app built with Flutter.

## Features

- **Beautiful Typography**: Optimized for Amharic text using Noto Sans Ethiopic.
- **Offline Reading**: Works 100% offline once installed.
- **Clean Navigation**: Simple Old/New Testament book selection, chapter grid, and verse lists.
- **Smart Search**: Find any verse by Amharic words instantly.
- **Bookmarks**: Save your favorite verses for easy access.
- **Material 3 Design**: Supports Light and Dark modes with adjustable font sizes.

## 🧱 Tech Stack

- **Framework**: Flutter
- **Design**: Material 3
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Persistence**: SharedPreferences (for settings)

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/example/amharicbible.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## 📂 Project Structure

- `lib/core`: Theme and constants.
- `lib/data`: Models, SQLite helper, and repositories.
- `lib/providers`: State management logic.
- `lib/screens`: All UI screens.
- `lib/widgets`: Reusable UI components.

## 📖 Bible Data

The app initializes its local SQLite database from `assets/data/bible.json` on the first launch. This ensures all content is available offline immediately.

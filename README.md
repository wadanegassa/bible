# Holy Bible (Amharic & English)

A comprehensive, premium Flutter application designed for reading and studying the Bible in Amharic and English. Optimized for all devices with a focus on buttery-smooth performance and luxury aesthetics.

## Features

*   **Bilingual Support**: Access the Bible in both Amharic and English (KJV & 1962 Amharic).
*   **Fully Responsive**: Adaptive layouts that look stunning on phones, tablets, and desktops.
*   **Premium Highlighting**: Highlight verses with a vibrant, translucent color palette (Rose, Amethyst, Sky, Emerald, etc.) and smart contrast detection.
*   **Performance Optimized**: 
    *   Background data processing using Isolates.
    *   Asynchronous database population for a lag-free experience.
*   **Easy Navigation**: New "Navigator Hub" with dynamic grid layouts for seamless book and chapter selection.
*   **Search Functionality**: Quickly find specific verses or keywords.
*   **Bookmarks**: Save your favorite verses for quick access later.
*   **Customizable Theme**:
    *   **Dark/Light Mode**: Fully themed UI that respects light/dark settings.
    *   **Font Size Adjustment**: Adjustable text sizes for optimal readability.
*   **Clean Architecture**: Built with a maintainable and scalable code structure (UI → Logic → Data).

## Tech Stack & Tools

*   **Framework**: [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications.
*   **Language**: [Dart](https://dart.dev/) - Modern language with Isolate support for high performance.
*   **State Management**: [Provider](https://pub.dev/packages/provider) - For reactive state transitions.
*   **Local Database**: [Sqflite](https://pub.dev/packages/sqflite) - High-performance local storage for offline reading.
*   **Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences) - For persisting user settings and session state.

## Project Structure

The project follows a clean architecture pattern to separate concerns and ensure maintainability:

```
lib/
├── core/           # Services (Storage, Theme), Constants
├── data/           # Repositories, API, Models, Local DB (SQL)
├── providers/      # State Management (BibleProvider, ThemeProvider)
├── screens/        # UI Layers (Home, Search, Bookmarks, Settings)
└── widgets/        # Reusable UI Components (VerseTile, Toolbars)
```

## Setup Instructions

To get up and running with the project locally:

1.  **Prerequisites**:
    *   Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
    *   Ensure setup for your target device (Android Studio/Xcode).

2.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd amharicbible
    ```

3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the App**:
    ```bash
    flutter run
    ```

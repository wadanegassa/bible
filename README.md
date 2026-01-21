# Holy Bible (Amharic & English)

A comprehensive Flutter application designed for reading and studying the Bible in Amharic and English. This app offers a clean, user-friendly interface with features for reading chapters, searching for verses, managing bookmarks, and customizing the reading experience.

## Features

*   **Bilingual Support**: Access the Bible in both Amharic and English.
*   **Easy Navigation**: Browse books, chapters, and verses seamlessly.
*   **Search Functionality**: Quickly find specific verses or keywords.
*   **Bookmarks**: Save your favorite verses for quick access later.
*   **Customizable Theme**:
    *   **Dark/Light Mode**: Toggle between themes for comfortable reading in any environment.
    *   **Font Size Adjustment**: Increase or decrease text size to suit your preference.
*   **Clean Architecture**: Built with a maintainable and scalable code structure.

## Tech Stack & Tools

*   **Framework**: [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications.
*   **Language**: [Dart](https://dart.dev/) - The programming language used for Flutter.
*   **State Management**: [Provider](https://pub.dev/packages/provider) - For managing application state effectively.
*   **Local Database**: [Sqflite](https://pub.dev/packages/sqflite) - For storing bookmarks locally on the device.
*   **Networking**: [http](https://pub.dev/packages/http) - For making API requests to fetch Bible content.
*   **UI Components**: Material Design widgets for a native Android/iOS feel.

## Project Structure

The project follows a clean architecture pattern to separate concerns and ensure maintainability:

```
lib/
├── core/           # Core utilities, constants, and theme configurations
├── data/           # Data layer: API services, local DB, models, and repositories
├── providers/      # State management logic
├── screens/        # UI screens and pages
└── widgets/        # Reusable UI components
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

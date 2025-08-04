# QuizScape Project Report

This document provides a comprehensive overview of the QuizScape Flutter application, detailing its architecture, features, and implementation specifics.

## 1. Project Overview

**Project Name:** QuizScape
**Description:** A colorful animated quiz application.
**Purpose:** To provide an interactive and engaging platform for users to test their knowledge across various categories and difficulties.

## 2. Technology Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** Provider
*   **Local Storage:** `shared_preferences` (for user authentication and quiz results)
*   **JSON Serialization:** `json_annotation` and `json_serializable` (for data models)
*   **Date Formatting:** `intl`

## 3. Project Structure

The project follows a modular structure, with clear separation of concerns:

```
/lib
├───main.dart             # Main application entry point and route definitions
├───models/               # Data models (e.g., Question, QuizResult, User)
├───screens/              # User interface screens (e.g., Login, Category, Question, Result, Profile, Registration)
├───services/             # Business logic and data handling (e.g., AuthService, QuizService)
├───utils/                # Utility functions, constants, and theme definitions
└───widgets/              # Reusable UI components (e.g., AnimatedButton, CategoryCard, GradientBackground, QuestionCard)
```

## 4. Core Features

### 4.1. User Authentication

*   **Login:** Users can log in with their username/email and password.
*   **Registration:** New users can create an account with a username, full name, email, and password.
*   **Logout:** Users can securely log out from their profile screen.
*   **Persistence:** User session and data are managed using `shared_preferences`.

**Relevant Files:**
*   `lib/screens/login_screen.dart`
*   `lib/screens/registration_screen.dart`
*   `lib/services/auth_service.dart`
*   `lib/models/user.dart`

### 4.2. Quiz Functionality

*   **Category Selection:** Users can choose from various quiz categories (e.g., General Knowledge, Science & Nature, Technology).
*   **Difficulty Selection:** For each category, users can select a difficulty level (easy, medium, hard).
*   **Question Display:** Questions are presented one by one with multiple-choice options.
*   **Timer:** Each question has a 10-second timer. If the timer runs out, the question is automatically answered (incorrectly).
*   **Score Tracking:** The application tracks the user's score during the quiz.
*   **Quiz Results:** After completing a quiz, users see their score and can choose to play the same quiz again, go to their profile, or return to the home screen.
*   **Quiz History:** Completed quiz results are saved to the user's profile.

**Relevant Files:**
*   `lib/screens/category_screen.dart`
*   `lib/screens/question_screen.dart`
*   `lib/screens/result_screen.dart`
*   `lib/services/quiz_service.dart`
*   `lib/models/question.dart`
*   `lib/models/quiz_result.dart`
*   `assets/data/quiz_questions.json` (data source for questions)

### 4.3. User Profile Management

*   **Profile View:** Users can view their username, full name, email, and quiz history.
*   **Edit Profile:** Users can update their full name and email address.
*   **Quiz History Display:** A list of past quiz attempts, including category, score, and date, is displayed.

**Relevant Files:**
*   `lib/screens/profile_screen.dart`
*   `lib/services/auth_service.dart`
*   `lib/models/user.dart`
*   `lib/models/quiz_result.dart`

### 4.4. Theming and UI/UX

*   **Dynamic Theming:** The application supports light and dark themes, which can be toggled by the user.
*   **Gradient Backgrounds:** Many screens feature visually appealing gradient backgrounds.
*   **Animated UI Elements:** Buttons and category cards incorporate subtle animations for a more engaging user experience.
*   **Responsive Design:** The UI is designed to adapt to different screen sizes.
*   **Consistent Styling:** Utilizes `constants.dart` for consistent color schemes and `theme.dart` for overall application themes.

**Relevant Files:**
*   `lib/utils/theme.dart`
*   `lib/utils/theme_notifier.dart`
*   `lib/utils/constants.dart`
*   `lib/widgets/gradient_background.dart`
*   `lib/widgets/animated_button.dart`
*   `lib/widgets/category_card.dart`

## 5. Data Models

*   **`Question` (`lib/models/question.dart`):** Represents a single quiz question with its text, options, correct answer, and difficulty. Uses `json_annotation` for serialization.
*   **`QuizResult` (`lib/models/quiz_result.dart`):** Stores the outcome of a completed quiz, including category, score, total questions, and date. Uses `json_annotation` for serialization.
*   **`User` (`lib/models/user.dart`):** Represents a user with username, password (note: in a real app, passwords should be hashed), quiz history, full name, and email. Uses `json_annotation` for serialization.

## 6. Services

*   **`AuthService` (`lib/services/auth_service.dart`):** Handles user registration, login, logout, current user management, and saving/retrieving quiz results for the current user using `shared_preferences`.
*   **`QuizService` (`lib/services/quiz_service.dart`):** Responsible for loading quiz questions from `assets/data/quiz_questions.json`, filtering them by category and difficulty, and providing random subsets of questions.

## 7. Utilities

*   **`constants.dart` (`lib/utils/constants.dart`):** Defines application-wide constants such as color palettes and category-specific colors.
*   **`theme.dart` (`lib/utils/theme.dart`):** Contains functions to define the light and dark themes for the application.
*   **`theme_notifier.dart` (`lib/utils/theme_notifier.dart`):** A `ChangeNotifier` that manages the application's theme mode (light, dark, system) and persists the user's preference using `shared_preferences`.

## 8. Widgets

*   **`AnimatedButton` (`lib/widgets/animated_button.dart`):** A customizable button with press animations, loading states, and optional icons. Includes `PulseButton` and `GradientButton` variations.
*   **`CategoryCard` (`lib/widgets/category_card.dart`):** A visually appealing card for displaying quiz categories, with animations, icons, and optional details like question count and best score. Includes `AnimatedCategoryCard` for staggered animations.
*   **`GradientBackground` (`lib/widgets/gradient_background.dart`):** A simple widget to apply a consistent gradient background across screens.
*   **`QuestionCard` (`lib/widgets/question_card.dart`):** A card specifically designed to display quiz questions.

## 9. Assets

*   **`assets/data/quiz_questions.json`:** Contains the structured data for all quiz questions, categorized by topic and including difficulty levels.

## 10. Development Dependencies

*   **`flutter_test`:** For unit and widget testing.
*   **`flutter_lints`:** For enforcing Dart best practices and code style.
*   **`build_runner`:** Code generation tool, used with `json_serializable`.
*   **`json_serializable`:** Automatically generates `fromJson` and `toJson` methods for data models.

## 11. Getting Started (for Developers)

1.  **Clone the repository:**
    ```bash
    git clone [repository_url]
    cd quiz_app
    ```
2.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run code generation (for JSON models):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## 12. Future Enhancements (Potential Report Sections)

*   **Backend Integration:** Currently, user data and quiz questions are stored locally using `shared_preferences` and a local JSON file. A future enhancement would involve integrating with a backend service (e.g., Firebase, Node.js, Python FastAPI) for persistent user data, real-time quiz updates, and more robust authentication.
*   **Advanced Quiz Features:**
    *   Leaderboards
    *   User-generated quizzes
    *   Different question types (e.g., true/false, fill-in-the-blanks)
    *   Detailed quiz analytics for users
*   **Improved UI/UX:**
    *   More complex animations and transitions
    *   Customizable user avatars
    *   Sound effects and haptic feedback
*   **Error Handling and Robustness:**
    *   More comprehensive error handling for network requests (if a backend is integrated).
    *   Offline mode support.
*   **Testing:** Expanding unit, widget, and integration tests to cover more application logic and UI components.
*   **Internationalization:** Adding support for multiple languages.

This report provides a solid foundation for understanding the QuizScape project.

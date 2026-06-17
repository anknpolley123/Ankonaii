# AnkonAI - Offline Android AI Assistant

An Android application with a built-in, offline AI engine using TensorFlow Lite. It features a Gemini-inspired chat interface, image support, and optional Firebase cloud sync.

## Features

- 🧠 **Offline AI**: Runs locally using a TFLite model (`SmolLM-135M-Instruct`).
- 💬 **Chat Interface**: Clean, Gemini-style UI with smooth scrolling.
- 📝 **Chat History**: Persists messages locally using Room database.
- 📷 **Image Support**: Upload and display images within the chat.
- ☁️ **Firebase Sync (Optional)**: Synchronizes chat history across devices with Firebase.
- 🔒 **Anonymous Authentication**: Secure, frictionless login.

## Project Structure


## Getting Started

### Prerequisites
- **Android Studio** or **Project IDX**
- **JDK 17**
- **Android SDK 34**

### Firebase Setup (Optional for Cloud Sync)
1.  Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
2.  Enable **Anonymous Authentication**.
3.  Enable **Cloud Firestore**.
4.  Download the `google-services.json` file and place it in the `AnkonAI/app/` directory.

### Model File
Place your TFLite model file at: AnkonAI/app/src/main/assets/model.bin


### Building the Project
1.  Navigate to the project directory:
    ```bash
    cd AnkonAI
    ```
2.  Build the project:
    ```bash
    ./gradlew build
    ```
3.  Install on a connected device or emulator:
    ```bash
    ./gradlew installDebug
    ```

## Built With

- **Kotlin** - Primary language
- **TensorFlow Lite** - On-device AI inference
- **Room** - Local data persistence
- **Firebase** - Authentication, Firestore, Storage
- **Dagger Hilt** - Dependency injection
- **Coroutines** - Asynchronous programming
- **Markwon** - Markdown rendering for AI responses

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
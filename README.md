# 🤖 AnkonAI - Offline Android AI Assistant

<div align="center">

[![Release](https://img.shields.io/github/v/release/anknpolley123/Ankonaii?style=for-the-badge&logo=github&color=blue&label=Latest%20Release)](https://github.com/anknpolley123/Ankonaii/releases/latest)
[![Stars](https://img.shields.io/github/stars/anknpolley123/Ankonaii?style=for-the-badge&logo=github&color=yellow)](https://github.com/anknpolley123/Ankonaii/stargazers)
[![License](https://img.shields.io/github/license/anknpolley123/Ankonaii?style=for-the-badge&logo=gnu&color=red)](LICENSE)
[![GitHub Downloads](https://img.shields.io/github/downloads/anknpolley123/Ankonaii/total?style=for-the-badge&logo=github&color=green)](https://github.com/anknpolley123/Ankonaii/releases)
[![Build Status](https://img.shields.io/badge/Build-Passing-success?style=for-the-badge&logo=android)](https://github.com/anknpolley123/Ankonaii)

</div>

An Android application with a built-in, offline AI engine using TensorFlow Lite. Featuring a Gemini-inspired chat interface, image support, and optional Firebase cloud sync.

<div align="center">
  <img src="AnkonAI/app/src/main/res/drawable/ic_launcher.png" alt="AnkonAI Logo" width="120" height="120">
</div>

---

## 📦 Download APK

<div align="center">
  <a href="https://github.com/anknpolley123/Ankonaii/releases/latest">
    <img src="https://img.shields.io/badge/📱 Download Latest APK-424 MB-blue?style=for-the-badge&logo=android&logoColor=white&color=3DDC84" alt="Download APK" />
  </a>
</div>

> **Latest Version:** [v18](https://github.com/anknpolley123/Ankonaii/releases/latest) (424 MB)

---

## ✨ Features

- 🧠 **Offline AI** - Runs locally using a TFLite model (`SmolLM-135M-Instruct`)
- 💬 **Chat Interface** - Clean, Gemini-style UI with smooth scrolling
- 📝 **Chat History** - Persists messages locally using Room database
- 📷 **Image Support** - Upload and display images within the chat
- ☁️ **Firebase Sync** - Synchronize chat history across devices
- 🔒 **Anonymous Authentication** - Secure, frictionless login

---

## 🚀 Quick Start

### Prerequisites
- **Android Studio** or **Project IDX**
- **JDK 17**
- **Android SDK 34**

### Clone with Git LFS (for model.bin)

```bash
git lfs install
git clone https://github.com/anknpolley123/Ankonaii.git
cd Ankonaii/AnkonAI
```

## Build The Project

```bash
./gradlew build
./gradlew installDebug
```
or 

```bash
./gradlew assembleDebug 
```

## Firebase Setup (Optional)

1. Create a Firebase project at console.firebase.google.com or idx.google.com 

2. Enable Anonymous Authentication and Cloud Firestore

3. Download google-services.json and place it in AnkonAI/app/

## Project Status
```bash
Component       Status
APK Build       ✅ Successful
Custom Icon     ✅ Applied
Firebase 
Integration     ✅ Configured
Offline
 AI Model       ✅ Included (146 MB)
```

## Build With
```bash
Technology             Purpose

  Kotlin            Primary language

TensorFlow       On-device AI inference         Lite   

  Room           Local data persistence

Firebase             Authentication,
                    Firestore,Storage

Dagger Hilt       Dependency injection

Coroutines     Asynchronous programming

Markwon            Markdown rendering
                    for AIresponses

```

## License 

This project is licensed under the **GNU General Public License v3.0** - see the LICENSE file for details
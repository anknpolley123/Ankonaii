#!/bin/bash

echo "🔥 Building AnkonAI with Firebase Support"
echo "========================================="
echo "Project ID: $(pwd)"

# Step 1: Navigate to Android project
cd ~/Ankonaii/AnkonAI

# Step 2: Create local.properties
echo "sdk.dir=$ANDROID_HOME" > local.properties
echo "✅ SDK configured"

# Step 3: Make gradlew executable
chmod +x gradlew

# Step 4: Verify google-services.json exists
if [ ! -f "app/google-services.json" ]; then
    echo "⚠️ WARNING: google-services.json not found!"
    echo "Firebase features may not work properly."
    echo "Download it from Firebase Console and place in app/"
fi

# Step 5: Verify model.bin exists
if [ ! -f "app/src/main/assets/model.bin" ]; then
    echo "❌ Error: model.bin not found!"
    echo "Please place your TFLite model in app/src/main/assets/"
    exit 1
fi
echo "✅ model.bin found ($(du -h app/src/main/assets/model.bin | cut -f1))"

# Step 6: Clean previous builds
echo "🧹 Cleaning previous builds..."
./gradlew clean

# Step 7: Build debug APK
echo "🔨 Building debug APK with Firebase..."
./gradlew assembleDebug

# Step 8: Check build result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo "📱 APK location: app/build/outputs/apk/debug/app-debug.apk"
    echo ""
    echo "📊 APK Details:"
    ls -lh app/build/outputs/apk/debug/
    
    echo ""
    echo "📥 To download the APK:"
    echo "1. In the Explorer panel, navigate to:"
    echo "   AnkonAI/app/build/outputs/apk/debug/"
    echo "2. Right-click app-debug.apk"
    echo "3. Select Download"
    echo ""
    echo "📲 To install on your phone:"
    echo "1. Transfer the APK to your phone"
    echo "2. Open the APK file"
    echo "3. Tap 'Install'"
    
else
    echo ""
    echo "❌ BUILD FAILED"
    echo "Check the error messages above."
    echo ""
    echo "Common fixes:"
    echo "1. Java not found: Install JDK 17"
    echo "2. SDK issues: Run sdkmanager 'platforms;android-34'"
    echo "3. Network issues: Check your internet connection"
    echo "4. Memory issues: Increase memory in gradle.properties"
fi

echo "========================================="
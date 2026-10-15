#!/usr/bin/env bash
# Generates the Android project around lib/ and applies the settings flutter_gemma needs.
set -e
flutter create --platforms=android --project-name gemma_chat --org com.example .
G=$(ls android/app/build.gradle.kts android/app/build.gradle 2>/dev/null | head -1)
sed -i -E 's/minSdk(Version)?[ =]+flutter\.minSdkVersion/minSdk = 26/' "$G"
M=android/app/src/main/AndroidManifest.xml
grep -q 'permission.INTERNET' $M || sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' $M
grep -q libOpenCL $M || sed -i 's#</application>#    <uses-native-library android:name="libOpenCL.so" android:required="false"/>\n    </application>#' $M
flutter pub get

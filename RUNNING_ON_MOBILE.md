# Running on Mobile (Android)

**YES!** This app is actually designed to run best on mobile.

## Why Mobile is Better
1.  **No Security Errors**: The "CORS" error you saw on Chrome simply **does not exist** on Android/iOS. The API calls just work.
2.  **Better Camera**: You can use the real phone camera to scan your room.

## How to Run on Android
Since you are on Windows, you can easily run on Android.

### Option 1: Physical Android Phone (Best)
1.  Enable **Developer Mode** on your phone (Settings -> About Phone -> Tap "Build Number" 7 times).
2.  Enable **USB Debugging** in Developer Options.
3.  Connect your phone to your PC via USB.
4.  Run:
    ```bash
    flutter run
    ```

### Option 2: Android Emulator
1.  Open **Android Studio**.
2.  Go to **Virtual Device Manager**.
3.  Start a device (e.g., Pixel 6).
4.  Run:
    ```bash
    flutter run
    ```

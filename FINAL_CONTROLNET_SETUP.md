# FINAL SETUP: Replicate ControlNet

Great choice! Your app is now configured to use **Stable Diffusion + ControlNet** via the Replicate API.

## 1. What This Does
1.  **Captures**: Your room photo.
2.  **Keeps Structure**: Uses ControlNet (Canny Edge Detection) to lock walls/windows in place.
3.  **Redesigns**: Applies your prompt ("Modern Living Room") inside those lines.
4.  **Result**: Returns a high-quality, photorealistic imageURL.

## 2. API Key Requirement (CRITICAL)
Before you run the app, you **MUST** add your API Key.
1.  Get a key from [replicate.com/account/api-tokens](https://replicate.com/account/api-tokens).
2.  Open `lib/services/ai_service.dart`.
3.  Replace `YOUR_REPLICATE_API_KEY_HERE` with your key (starts with `r8_...`).

## 3. Dependencies Added
I have just added the `http` package to your project so the API calls will work.

## 4. Run It!
Now verify everything works:
1.  `flutter pub get` (done automatically).
2.  `flutter run`.
3.  Go to Scan -> Take Photo -> Add Prompt -> Generate.

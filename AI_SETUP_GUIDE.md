# AI Tech: Structure-Preserving Room Redesign

You correctly identified that DALL-E creates *new* images. To **edit your existing room** while keeping the walls, windows, and furniture layout, you must use **ControlNet**.

## The Technology: **Stable Diffusion + ControlNet**

### What is ControlNet?
ControlNet is an AI adapter that lets you give the AI an extra "hint" image.
1.  **Input**: Your photo of the room.
2.  **Process**: The AI detects the "Edges" (lines of walls, sofa shape, window frames).
3.  **Generation**: It paints the new style (e.g., "Modern") *inside* those detected lines.

**Result:** The room looks exactly like yours, but re-decorated.

---

## How to Implement (Step-by-Step)

Since you cannot run this heavy AI on a phone, use the **Replicate API**.

### 1. Get a Replicate Account
1.  Go to [Replicate.com](https://replicate.com/).
2.  Sign in with GitHub.
3.  Go to **API Tokens** and copy your token.
4.  Paste this token into `lib/services/ai_service.dart` where it says `_replicateApiKey`.

### 2. Choose a Model
The `ai_service.dart` file is pre-configured to use a popular ControlNet model (`jagilley/controlnet-canny`).
*   **Canny**: Detects hard edges (good for keeping furniture shapes).
*   **MLSD**: Detects straight lines (best for keeping just walls/windows but changing furniture).

### 3. Usage
The code in `ai_service.dart` now handles:
1.  Converting your image to Base64.
2.  Sending it to Replicate.
3.  Waiting for the result (Polling).
4.  Returning the new Image URL.

### 4. Code Change
I have already updated `lib/services/ai_service.dart` to use this new logic.
Now, ensuring `http` is in your `pubspec.yaml` is the only setup step left.

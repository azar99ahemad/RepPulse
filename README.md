# RepPulse 💪

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![MediaPipe](https://img.shields.io/badge/MediaPipe-PoseLandmarker-4285F4?logo=google)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

**RepPulse** is a real-time, AI-powered mobile exercise rep counter built with Flutter. It uses on-device ML (MediaPipe Pose Landmarker) and the device camera to automatically detect and count repetitions for squats, push-ups, and pull-ups — no wearables required.

---

## 🏗️ System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter UI Layer                          │
│   HomeScreen  ──►  WorkoutScreen  ──►  WorkoutSummaryScreen      │
│   HistoryScreen ──► SessionDetailScreen                          │
└───────────────────────────┬──────────────────────────────────────┘
                            │ Riverpod StateNotifier
┌───────────────────────────▼──────────────────────────────────────┐
│                    Business Logic Layer                          │
│   WorkoutNotifier  ──►  RepCounter  ──►  AngleCalculator         │
│   ExerciseConfig (squat / push-up / pull-up thresholds)          │
└───────────────────────────┬──────────────────────────────────────┘
                            │ EventChannel / MethodChannel
┌───────────────────────────▼──────────────────────────────────────┐
│                    Native Android Layer (Kotlin)                  │
│   MainActivity (FlutterActivity)                                  │
│   PoseAnalyzer (CameraX ImageAnalysis.Analyzer)                  │
│        └──►  MediaPipe PoseLandmarker  (tasks-vision AAR)        │
└───────────────────────────┬──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                      Data / Storage Layer                        │
│   AppDatabase (Drift/SQLite)                                     │
│        ├── workout_sessions table                                │
│        ├── rep_logs table                                        │
│        └── exercise_configs table                                │
│   WorkoutRepository (abstract interface)                         │
│   Firebase Firestore (cloud sync – optional)                     │
└──────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- 🎥 **Real-time pose detection** via MediaPipe Pose Landmarker (on-device, no cloud)
- 🔢 **Automatic rep counting** for 3 exercises: Squat, Push-Up, Pull-Up
- 📐 **Joint angle calculation** with exponential moving average smoothing
- 🦴 **Skeleton overlay** rendered with `CustomPainter` for live visual feedback
- 📊 **Workout history** with per-session stats and rep-by-rep breakdown
- 📈 **Angle progression chart** using fl_chart
- ☁️ **Firebase sync** ready (Firestore + Auth + Google Sign-In scaffold)
- 🌙 **Material 3 dark theme** with cyan (`#00E5FF`) accent

---

## 📁 Folder Structure

```
RepPulse/
├── pubspec.yaml
├── README.md
├── analysis_options.yaml
├── android/
│   └── app/src/main/kotlin/com/reppulse/app/
│       ├── MainActivity.kt
│       └── PoseAnalyzer.kt
├── assets/
│   └── models/
│       └── .gitkeep               ← placeholder for pose_landmarker_lite.task
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── angle_calculator.dart
│   │   ├── rep_counter.dart
│   │   └── exercise_config.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── pose_data.dart
│   │   │   ├── workout_session.dart
│   │   │   └── rep_log.dart
│   │   ├── database/
│   │   │   └── app_database.dart
│   │   └── repositories/
│   │       └── workout_repository.dart
│   ├── features/
│   │   ├── home/
│   │   │   └── screens/
│   │   │       └── home_screen.dart
│   │   ├── workout/
│   │   │   ├── screens/
│   │   │   │   ├── exercise_select_screen.dart
│   │   │   │   ├── workout_screen.dart
│   │   │   │   └── workout_summary_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── skeleton_overlay.dart
│   │   │   │   └── rep_counter_hud.dart
│   │   │   └── providers/
│   │   │       └── workout_provider.dart
│   │   └── history/
│   │       ├── screens/
│   │       │   ├── history_screen.dart
│   │       │   └── session_detail_screen.dart
│   │       └── providers/
│   │           └── history_provider.dart
│   └── services/
│       ├── pose_service.dart
│       └── frame_throttle.dart
```

---

## 🚀 Installation

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android Studio / Xcode
- Java 11+
- A physical Android device (camera required for pose detection)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/azar99ahemad/RepPulse.git
cd RepPulse

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# 4. Add the MediaPipe model (see Android Setup below)
```

### Android Setup

1. **Add MediaPipe dependency** to `android/app/build.gradle`:
   ```groovy
   implementation 'com.google.mediapipe:tasks-vision:0.10.9'
   ```

2. **Download the model** from [MediaPipe Models](https://developers.google.com/mediapipe/solutions/vision/pose_landmarker#models) and place `pose_landmarker_lite.task` in `assets/models/`.

3. **Add permissions** to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-feature android:name="android.hardware.camera" />
   ```

4. **CameraX** is used in `PoseAnalyzer.kt`. Add to `build.gradle`:
   ```groovy
   def camerax_version = "1.3.1"
   implementation "androidx.camera:camera-core:${camerax_version}"
   implementation "androidx.camera:camera-camera2:${camerax_version}"
   implementation "androidx.camera:camera-lifecycle:${camerax_version}"
   ```

5. **Firebase** (optional): Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview/) and add `google-services.json` to `android/app/`.

---

## 🗺️ Roadmap

| Phase | Features | Status |
|-------|----------|--------|
| **MVP (Week 1–2)** | Scaffold, rep counting, squat/push-up/pull-up, local history | ✅ Done |
| **V2 (Week 3–4)** | Real MediaPipe integration, form correction feedback, calories tracking | 🔜 Planned |
| **V3 (Week 5–6)** | AI trainer suggestions, Firebase sync, Google Sign-In, social sharing | 🔜 Planned |

---

## 📄 License

MIT © 2026 azar99ahemad
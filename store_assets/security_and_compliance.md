# GoViral — Security Review & Google Play Compliance Declaration

## 1. Google Play Data Safety Form Responses

When publishing GoViral on the Google Play Console, use the following declarations:

### Data Collection & Sharing Summary
| Question | Response | Technical Architecture Rationale |
| :--- | :--- | :--- |
| **Does your app collect or share user data?** | **Yes (Minimal)** | Only account email for optional authentication (Firebase Auth). |
| **Is all data encrypted in transit?** | **Yes** | All network traffic uses TLS 1.3 / HTTPS / Secure WebSockets. |
| **Do you provide a way for users to request data deletion?** | **Yes** | Users can sign out or request Firebase account deletion. |
| **Does your app collect or store audio recordings?** | **NO** | Speech-to-text is evaluated in volatile memory with zero audio recording (`ZeroPersistenceService`). |
| **Does your app collect or store video or images?** | **NO** | Camera frames are sampled in transient RAM only for motion delta and never saved to disk. |

### Data Types Breakdown
- **User IDs / Email**: Collected for Firebase Authentication (optional guest mode available).
- **Audio / Voice**: **NOT COLLECTED**. No audio stored, no audio uploaded to cloud servers.
- **Photos / Videos**: **NOT COLLECTED**. Livestreams are strictly broadcast live and never archived.
- **Device Identifiers**: None collected.

---

## 2. Runtime Permissions & Justifications

| Permission | Android Name | Policy Purpose |
| :--- | :--- | :--- |
| **Camera** | `android.permission.CAMERA` | Required to provide live video capture for host broadcasting. Handled via `permission_handler` with runtime rationale dialogs. |
| **Microphone** | `android.permission.RECORD_AUDIO` | Required to enable real-time speech interaction and AI audience audio comprehension. |
| **Internet** | `android.permission.INTERNET` | Required for live streaming transmission, Firebase authentication, and chat connectivity. |

---

## 3. R8 / ProGuard Obfuscation Verification

- File: `android/app/proguard-rules.pro`
- Enabled in: `android/app/build.gradle.kts`
- Preserves native Flutter engine symbols, JNI bridges, Firebase Authentication callbacks, camera frame consumers, and speech recognition channels while stripping unreferenced classes and shrinking APK/AAB size.

---

## 4. Keystore & Release Signing Template

For production signing of release `.aab` bundles:

1. Generate release keystore:
   ```bash
   keytool -genkey -v -keystore goviral-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias goviral
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=<PASSWORD>
   keyPassword=<PASSWORD>
   keyAlias=goviral
   storeFile=../goviral-release.jks
   ```

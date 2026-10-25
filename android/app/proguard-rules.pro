# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Play Core / Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Firebase & Google Services
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Camera & Speech
-keep class io.flutter.plugins.camera.** { *; }
-keep class com.csdcorp.speech_to_text.** { *; }

# Preserve JNI and native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Everyday Christian ProGuard Rules

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep database models
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.paging.**

# Keep SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep cryptography
-keep class javax.crypto.** { *; }
-dontwarn javax.crypto.**

# Keep notifications
-keep class androidx.core.app.NotificationCompat** { *; }

# Keep JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# ONNX Runtime
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

# ========================================
# GSON - Required by flutter_local_notifications and other plugins
# ========================================
-dontwarn sun.misc.**

# Gson specific classes
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data fields annotated with @SerializedName
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# TypeToken retention (CRITICAL for SharedPreferences and other plugins)
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# ========================================
# SharedPreferences Fix - Prevents R8 full mode crash
# ========================================
-keep class com.google.common.reflect.TypeToken
-keep class * extends com.google.common.reflect.TypeToken

# ========================================
# Flutter Secure Storage
# ========================================
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ========================================
# Google Generative AI (HTTP-based)
# Preserve API models and serialization
# ========================================
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# ========================================
# WorkManager - Required for background tasks
# ========================================
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keepclassmembers class * extends androidx.work.Worker {
  public <init>(android.content.Context,androidx.work.WorkerParameters);
}

# ========================================
# In-App Purchase
# ========================================
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }

# ========================================
# Preserve all @pragma('vm:entry-point') annotated functions
# Critical for Flutter plugin callbacks
# ========================================
-keepattributes RuntimeVisibleAnnotations
-keep @pragma class * { *; }

# ========================================
# Play Core Library (Deferred Components)
# Suppress warnings for optional Flutter Play Store features
# These are not used in this app but referenced by Flutter framework
# ========================================
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

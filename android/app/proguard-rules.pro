# Keep Sceneform classes
-keep class com.google.ar.sceneform.** { *; }
-keep class com.google.ar.sceneform.rendering.** { *; }
-keep class com.google.ar.sceneform.assets.** { *; }
-keep class com.google.ar.sceneform.animation.** { *; }
-keep class com.google.ar.sceneform.utilities.** { *; }

# Keep anything used via reflection
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# ARCore related
-dontwarn com.google.ar.**
-keep class com.google.ar.** { *; }

# Prevent R8 from removing unused methods/classes aggressively
-dontshrink

# Play Core (para evitar errores en build release)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Desugar runtime
-dontwarn com.google.devtools.build.android.desugar.runtime.**

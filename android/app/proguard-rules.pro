# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Riverpod / State Management
-keep class com.google.common.reflect.TypeToken { *; }
-keep class * extends com.google.common.reflect.TypeToken
-keepnames class * implements java.io.Serializable

# Dio / Networking
-keepattributes Signature, InnerClasses, AnnotationDefault, EnclosingMethod
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Fix for R8 missing classes from com.google.android.play.core (used internally by Flutter engine for deferred components)
-dontwarn com.google.android.play.core.**

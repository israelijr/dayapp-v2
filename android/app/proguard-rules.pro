# Gson uses generic type information stored in a class file when working with fields.
# Proguard removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Preserve classes used by flutter_local_notifications for serialization
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep public class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep public class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter Secure Storage - Regras Absolutas
-keep class com.it_nomads.** { *; }
-keep interface com.it_nomads.** { *; }
-keep class plugins.it_nomads.** { *; }
-keep class **.FlutterSecureStoragePlugin { *; }
-dontwarn com.it_nomads.**

# Garantir que as classes de registro de plugins não sejam removidas (Crucial para Play Store)
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin
-keep public class * extends io.flutter.plugin.common.MethodChannel.MethodCallHandler

# Preservar recursos (Previne erros de permissão de notificação)
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Manter métodos de serialização e canais
-keepclassmembers class * {
    @org.json.JSONObject *;
}

# Necessário para a biblioteca de criptografia que o plugin usa (Android 10+)
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# Garantir que o registro do plugin pelo Flutter não seja removido
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep public class * extends io.flutter.plugin.common.MethodChannel.MethodCallHandler

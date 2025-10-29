# Flutter frameworks visibility
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class androidx.** { <fields>; <methods>; }
-keep public class * extends androidx.versionedparcelable.VersionedParcelable

# Do not shrink any Flutter specific classes. This is required for reflection.
-keep class **.R$* {
    *;
}

# ===================================================================
# === [ምሉእ መፍትሒ] ን Google Play Services and Play Core Library ===
# እዚ ን "Missing class com.google.android.play.core..." ይፈትሖ
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# እዚ ነቲ ሓድሽ "Missing class com.google.android.gms..." error ይፈትሖ
-keep class com.google.android.gms.** { *; }
-keep interface com.google.android.gms.** { *; }
# ===================================================================

# For any public class that extends a class from the Android support libraries,
# keep the public members of the class.
-keep public class * extends android.app.Service
-keep public class * extends android.app.backup.BackupAgent
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class com.google.vending.licensing.ILicensingService

# ነቲ ናይ MainActivity ClassNotFoundException ዝፈትሕ
-keep public class com.meaditsega.BHLabs.MainActivity { *; }
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}


android {
    namespace = "com.BHLabs.catholicapp"
    compileSdk = 36
    
    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.BHLabs.catholicapp"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
    
    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    buildTypes {
        getByName("release") {
            // 1. ናይ ምፍራም (Signing) ምድላው
            signingConfig = signingConfigs.getByName("release")

            // 2. ናይ ኮድ ምጽቃጥ (R8/ProGuard)
            isMinifyEnabled = false
            isShrinkResources = false
            
            // 3. ናይ ProGuard ሕግታት ዝሕዝ ፋይል
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // እዚ መስመር እዚ ኣብቲ ቀንዲ ናይ ፕሮጀክት gradle ፋይል (android/build.gradle.kts)
    // ስለ ዝግለጽ፡ ኣብዚ ምውሳኹ ኣየድልን እዩ። እንተደኣ ጸገም ኣምጺኡ ግን ክትመልሶ ትኽእል ኢኻ።
    // implementation(kotlin("stdlib-jdk8"))
}

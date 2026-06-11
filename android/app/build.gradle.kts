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
    ndkVersion = "28.2.13676358"
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

        // [ወሰኽ 1]፦ MultiDex ንናይ ቀደም ስልኪታት ኣገዳሲ እዩ (ከይዕጾ ይከላኸል)
        multiDexEnabled = true

        // [ወሰኽ 2]፦ ንኹሉ ኣርክቴክቸር ዝድግፍ (ARM32, ARM64, x86) ንምግባር
        // እዚ ኮድ እዩ እቲ ኣፕሊኬሽንካ ብዘንደር ክለኣኽ ከሎ ኣብ ዝኾነት ሞባይል ንክሰርሕ ዝገብሮ።
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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
    // [ወሰኽ 3]፦ MultiDex ንምድጋፍ ዝተወሰኸ ላይብረሪ
    implementation("androidx.multidex:multidex:2.0.1")

    // እዚ መስመር እዚ ኣብቲ ቀንዲ ናይ ፕሮጀክት gradle ፋይል (android/build.gradle.kts)
    // ስለ ዝግለጽ፡ ኣብዚ ምውሳኹ ኣየድልን እዩ። እንተደኣ ጸገም ኣምጺኡ ግን ክትመልሶ ትኽእል ኢኻ።
    // implementation(kotlin("stdlib-jdk8"))
}
plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
}

android {
    namespace = "com.example.despertador"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true // ✅ Desugaring enabled
    }

    kotlinOptions {
        jvmTarget = "1.8" // ✅ Keep it compatible with Java 8 for most plugins
    }

    defaultConfig {
        applicationId = "com.example.despertador"

        // ✅ Use assignment syntax for Kotlin DSL (no function call)
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Required for Java 8+ API support on lower Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}                       
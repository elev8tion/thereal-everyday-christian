plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.everydaychristian.app"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.everydaychristian.app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        manifestPlaceholders["appName"] = "Everyday Christian"
    }

    buildTypes {
        release {
            // Production release configuration
            minifyEnabled = true
            shrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // Add signing config for production release
            // signingConfig = signingConfigs.getByName("release")
        }
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }

    // Signing configurations (to be filled with production keys)
    // signingConfigs {
    //     release {
    //         storeFile = file("release-keystore.jks")
    //         storePassword = System.getenv("KEYSTORE_PASSWORD")
    //         keyAlias = System.getenv("KEY_ALIAS")
    //         keyPassword = System.getenv("KEY_PASSWORD")
    //     }
    // }
}

flutter {
    source = "../.."
}

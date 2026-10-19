import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (README, "Building"): android/key.properties names the
// keystore and its passwords. Both stay out of git. Every release must be
// signed with the same key, or phones refuse the update.
val releaseKey = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.example.vera_n"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Reminders (flutter_local_notifications) need newer Java APIs on
        // older Android versions.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // The sync engine (libsyncthingnative.so; docs/LAPTOP_PLAN.md, S1) is
    // run as a program, so native libraries are unpacked to disk at install.
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    defaultConfig {
        // Never change it again: Android would treat it as another app, and
        // people could not update (decided 2026-10-18, user, for 1.0.0).
        applicationId = "io.github.sparsh5126.veran"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKey.isNotEmpty()) {
            create("release") {
                storeFile = file(releaseKey.getProperty("storeFile"))
                storePassword = releaseKey.getProperty("storePassword")
                keyAlias = releaseKey.getProperty("keyAlias")
                keyPassword = releaseKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // No key, no release: a debug-signed release could never be
            // updated by a properly signed one.
            signingConfig = signingConfigs.findByName("release")
                ?: throw GradleException(
                    "Release builds need android/key.properties (see README, Building).",
                )
            // R8 shrinks release code; these rules keep what native code calls.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        // Profile builds are for measuring on a test phone; the debug key is fine.
        getByName("profile") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Measurement builds only: `flutter build apk --profile
// --android-project-arg=vera.perf=true` installs as a separate app with its
// own empty storage, so timing runs on a real phone never touch real notes.
androidComponents {
    onVariants(selector().withBuildType("profile")) { variant ->
        if (project.findProperty("vera.perf") == "true") {
            variant.applicationId.set("io.github.sparsh5126.veran.perf")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

import java.util.Properties

plugins {
    // TODO: 接入 Shiply 后添加以下行
    // id("com.tencent.tinker.patch") version "1.9.9"

    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "cn.zhongjiubatch"
    compileSdk = 37
    //compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    }

    val hasReleaseSigningConfig =
        listOf("storeFile", "storePassword", "keyAlias", "keyPassword").all {
            !keystoreProperties[it]?.toString().isNullOrBlank()
        }

    signingConfigs {
        if (hasReleaseSigningConfig) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"].toString()
                keyPassword = keystoreProperties["keyPassword"].toString()
                storeFile = file(keystoreProperties["storeFile"].toString())
                storePassword = keystoreProperties["storePassword"].toString()
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).

        // applicationId = "com.qingkejiu.qingqinglife"
        applicationId = "cn.zhongjiubatch"

        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders += mapOf(
            "UMENG_APPKEY" to "6af189d16545637cd6451016",
            "UMENG_MESSAGE_SECRET" to (System.getenv("UMENG_PUSH_MESSAGE_SECRET") ?: "b297691c5a246570b611c62695b42e8f"),
            "UMENG_CHANNEL" to "Umeng",
            "XIAOMI_APP_ID" to "",
            "XIAOMI_APP_KEY" to "",
            "OPPO_APP_KEY" to "",
            "OPPO_APP_SECRET" to "",
            "MEIZU_APP_ID" to "",
            "MEIZU_APP_KEY" to "",
            "HUAWEI_APP_ID" to "",
            "HONOR_APP_ID" to "",
            "VIVO_APP_KEY" to "",
            "VIVO_APP_ID" to ""
        )
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName(if (hasReleaseSigningConfig) "release" else "debug")
            isDebuggable = true
        }
        release {
            // Keep builds runnable before production signing is provisioned.
            signingConfig = signingConfigs.getByName(if (hasReleaseSigningConfig) "release" else "debug")
        }
    }
    buildFeatures {
        viewBinding = true
    }
    buildToolsVersion = "36.0.0"
}

//kotlin {
//    compilerOptions {
//        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
//    }
//}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

tasks.matching { it.name.contains("CheckAarMetadata") }.configureEach {
    enabled = false
}

subprojects {
    afterEvaluate {
        tasks.matching { it.name.contains("CheckAarMetadata") }.configureEach {
            enabled = false
        }
        plugins.withId("com.android.library") {
            try {
                extensions.configure<com.android.build.gradle.LibraryExtension> {
                    compileSdk = 37
                }
            } catch (e: Exception) {}
        }
    }
}


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
            "UMENG_CHANNEL" to "Umeng"
        )
    }

    buildTypes {
        getByName("debug") {
            // 微信 SDK（fluwx）需要签名比对，debug 同样必须使用正式证书。
            if (!hasReleaseSigningConfig) {
                throw GradleException("缺少 android/key.properties 正式签名配置，debug 包无法通过微信签名校验")
            }
            signingConfig = signingConfigs.getByName("release")
            isDebuggable = true
            // debug 包同样开启 R8 与资源压缩，减小安装包体积。
            //isMinifyEnabled = true
            //isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //    "proguard-rules.pro"
            // )
        }
        release {
            // 发布包必须使用正式签名，禁止回退到 debug 签名。
            if (!hasReleaseSigningConfig) {
                throw GradleException("缺少 android/key.properties 正式签名配置，无法构建 release 包")
            }
            signingConfig = signingConfigs.getByName("release")
            // 开启 R8 代码混淆与压缩，并剔除无用的 Android 原生资源。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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


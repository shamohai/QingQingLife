import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        // TODO: 接入 Shiply 后添加以下行
        // maven { url "https://shiply-cdn.tds.qq.com/release" }

        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
        options.compilerArgs.add("-Xlint:-options")
    }

    // 这里手动配置 Kotlin 编译选项以解决插件的 Java 8 警告
    tasks.configureEach {
        if (this.name.contains("KotlinCompile")) {
            try {
                (this as KotlinCompile).compilerOptions {
                    jvmTarget.set(JvmTarget.JVM_17)
                }
            } catch (e: Exception) {
                // Ignore if not a KotlinCompile task
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

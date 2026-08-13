allprojects {
    repositories {
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

// reactive_ble_mobile 5.5.0 declares compileSdk 33, while its AndroidX
// dependencies require API 34 or newer. Register this callback before the BLE
// project is evaluated so the override runs after its build script sets 33 but
// before the Android plugin reads the final value.
project(":reactive_ble_mobile").afterEvaluate {
    extensions.configure<com.android.build.api.dsl.LibraryExtension> {
        compileSdk = 36
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

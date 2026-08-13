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
subprojects {
    project.evaluationDependsOn(":app")
}

// reactive_ble_mobile 5.5.0 still declares compileSdk 33, while its AndroidX
// dependencies require API 34 or newer. Apply the compatibility override only
// after every project has finished evaluation so Flutter's evaluation order is
// not changed.
gradle.projectsEvaluated {
    project(":reactive_ble_mobile")
        .extensions
        .configure<com.android.build.api.dsl.LibraryExtension> {
            compileSdk = 36
        }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// telephony 0.2.0 has no `namespace` (required by AGP 8+). Match AndroidManifest package.
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "telephony") {
            extensions.configure<LibraryExtension>("android") {
                namespace = "com.shounakmulay.telephony"
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

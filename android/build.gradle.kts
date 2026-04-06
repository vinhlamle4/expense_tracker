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

// ── AGP 8.x namespace patch ──────────────────────────────────────────────────
// isar_flutter_libs 3.x omits the `namespace` field required by AGP 8.x.
// plugins.withId fires at plugin-application time, before project evaluation,
// so it avoids the "already evaluated" error from afterEvaluate.
subprojects {
    plugins.withId("com.android.library") {
        the<com.android.build.gradle.LibraryExtension>().apply {
            if (namespace.isNullOrEmpty()) {
                namespace = project.group
                    .toString()
                    .ifEmpty { "com.placeholder.${project.name.replace("-", "_")}" }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

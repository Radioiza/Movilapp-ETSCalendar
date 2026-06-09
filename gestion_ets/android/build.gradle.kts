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
    // Algunos plugins de pub.dev (p. ej. add_2_calendar) fijan un compileSdk
    // antiguo (33) que sus dependencias AndroidX ya no aceptan (exigen 34+).
    // Forzamos a todo subproyecto Android (excepto :app, que ya usa 35) con
    // compileSdk < 35 a usar 35, sin importar tipos de AGP (acceso dinámico
    // vía withGroovyBuilder). Se registra ANTES de evaluationDependsOn para
    // evitar el error "project is already evaluated".
    if (project.name != "app") {
        afterEvaluate {
            val androidExtension = project.extensions.findByName("android")
            if (androidExtension != null) {
                androidExtension.withGroovyBuilder {
                    val actual = ("getCompileSdkVersion"() as String?)
                        ?.removePrefix("android-")
                        ?.toIntOrNull() ?: 0
                    if (actual in 1..34) {
                        "compileSdkVersion"(35)
                    }
                }
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

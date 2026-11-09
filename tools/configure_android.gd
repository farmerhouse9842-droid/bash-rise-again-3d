extends SceneTree

func _initialize() -> void:
    # This script deliberately does not open or modify the Godot editor.
    # Android editor settings are configured by GitHub Actions instead.
    var sdk := OS.get_environment("ANDROID_HOME")
    var jdk := OS.get_environment("JAVA_HOME")
    var key := OS.get_environment("BASH_KEY")
    if sdk.is_empty() or jdk.is_empty() or key.is_empty():
        push_error("Missing ANDROID_HOME, JAVA_HOME or BASH_KEY")
        quit(1)
        return
    if not DirAccess.dir_exists_absolute(sdk) or not DirAccess.dir_exists_absolute(jdk):
        push_error("Android SDK or Java SDK directory missing")
        quit(1)
        return
    if not FileAccess.file_exists(key):
        push_error("Debug keystore missing")
        quit(1)
        return
    print("Android SDK, Java SDK, and keystore paths exist")
    quit(0)

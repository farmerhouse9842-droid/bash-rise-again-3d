extends SceneTree

func _initialize() -> void:
    print("=== BASH Android editor settings ===")
    var settings: EditorSettings = EditorInterface.get_editor_settings()
    for key in ["export/android/android_sdk_path", "export/android/java_sdk_path", "export/android/debug_keystore", "export/android/debug_keystore_user"]:
        var value = str(settings.get_setting(key)) if settings.has_setting(key) else "MISSING"
        print(key, " = ", value)
        if key.ends_with("_path") or key.ends_with("keystore"):
            print("exists = ", DirAccess.dir_exists_absolute(value) or FileAccess.file_exists(value))
    print("ANDROID_HOME = ", OS.get_environment("ANDROID_HOME"))
    print("JAVA_HOME = ", OS.get_environment("JAVA_HOME"))
    quit()

extends SceneTree

func _initialize() -> void:
    var settings = EditorInterface.get_editor_settings()
    var sdk = OS.get_environment("ANDROID_HOME")
    var jdk = OS.get_environment("JAVA_HOME")
    var key = OS.get_environment("BASH_KEY")
    if sdk.is_empty() or jdk.is_empty() or key.is_empty():
        push_error("Missing ANDROID_HOME, JAVA_HOME or BASH_KEY")
        quit(1)
        return
    settings.set_setting("export/android/android_sdk_path", sdk)
    settings.set_setting("export/android/java_sdk_path", jdk)
    settings.set_setting("export/android/debug_keystore", key)
    settings.set_setting("export/android/debug_keystore_user", "androiddebugkey")
    settings.set_setting("export/android/debug_keystore_pass", "android")
    settings.save()
    print("ANDROID SDK: ", settings.get_setting("export/android/android_sdk_path"))
    print("JAVA SDK: ", settings.get_setting("export/android/java_sdk_path"))
    print("KEY FILE EXISTS: ", FileAccess.file_exists(key))
    quit(0)

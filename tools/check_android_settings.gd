extends SceneTree

func _initialize() -> void:
    print("=== GODOT ANDROID EDITOR SETTINGS CHECK ===")
    var settings = EditorInterface.get_editor_settings()
    if settings == null:
        push_error("EditorInterface has no EditorSettings")
        quit(2)
        return
    var keys = ["export/android/android_sdk_path", "export/android/java_sdk_path", "export/android/debug_keystore", "export/android/debug_keystore_user"]
    var failed = false
    for key in keys:
        if not settings.has_setting(key):
            print("MISSING SETTING: ", key)
            failed = true
            continue
        var value = str(settings.get_setting(key))
        if key == "export/android/debug_keystore_user":
            print(key, ": ", value)
        else:
            print(key, ": ", value, " | exists=", DirAccess.dir_exists_absolute(value) if key != "export/android/debug_keystore" else FileAccess.file_exists(value))
        if value.is_empty():
            failed = true
    print("=== END CHECK ===")
    quit(2 if failed else 0)

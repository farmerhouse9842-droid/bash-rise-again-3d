extends SceneTree

func _initialize() -> void:
    print("=== BASH GODOT 4.3 DIAGNOSTICS ===")
    print("Godot version: ", Engine.get_version_info())
    print("EditorExport registered: ", ClassDB.class_exists("EditorExport"))
    print("EditorExportPlatform registered: ", ClassDB.class_exists("EditorExportPlatform"))
    print("Export preset exists: ", FileAccess.file_exists("res://export_presets.cfg"))
    print("Main scene exists: ", FileAccess.file_exists("res://main.tscn"))
    print("App icon exists: ", FileAccess.file_exists("res://assets/app_icon.png"))
    print("JAVA_HOME: ", OS.get_environment("JAVA_HOME"))
    print("ANDROID_HOME: ", OS.get_environment("ANDROID_HOME"))
    print("ANDROID_SDK_ROOT: ", OS.get_environment("ANDROID_SDK_ROOT"))
    print("=== END DIAGNOSTICS ===")
    quit()

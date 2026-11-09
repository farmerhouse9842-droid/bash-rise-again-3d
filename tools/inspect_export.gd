extends SceneTree

func _initialize() -> void:
    print("=== BASH GODOT 4.3 EXPORT API INSPECTION ===")
    print("Godot: ", Engine.get_version_info().get("string", "unknown"))
    for class_name in ["EditorExport", "EditorExportPlatform", "EditorExportPreset", "EditorInterface"]:
        print("\nCLASS: ", class_name)
        if not ClassDB.class_exists(class_name):
            print("NOT REGISTERED")
            continue
        for method in ClassDB.class_get_method_list(class_name, true):
            var method_name: String = str(method.get("name", ""))
            if "export" in method_name.to_lower() or "configuration" in method_name.to_lower() or "preset" in method_name.to_lower() or "platform" in method_name.to_lower() or "singleton" in method_name.to_lower():
                print("METHOD: ", method_name, " | flags=", method.get("flags", 0), " | args=", method.get("args", []))
    for singleton_name in ["EditorExport", "EditorInterface"]:
        print("ENGINE SINGLETON ", singleton_name, ": ", Engine.has_singleton(singleton_name))
    print("Preset file: ", FileAccess.file_exists("res://export_presets.cfg"))
    print("JAVA_HOME set: ", not OS.get_environment("JAVA_HOME").is_empty())
    print("ANDROID_HOME set: ", not OS.get_environment("ANDROID_HOME").is_empty())
    print("=== END INSPECTION ===")
    quit()

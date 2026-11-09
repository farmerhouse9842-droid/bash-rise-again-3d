extends SceneTree

func _initialize() -> void:
    print("=== GODOT EXPORT INSPECTION ===")
    print("EditorExport available: ", ClassDB.class_exists("EditorExport"))
    var editor_export = EditorExport
    print("Export presets: ", editor_export.get_export_preset_count())
    for i in range(editor_export.get_export_preset_count()):
        var preset = editor_export.get_export_preset(i)
        var platform = preset.get_platform()
        print("PRESET: ", preset.get_name(), " PLATFORM: ", platform.get_name())
        print("PLATFORM METHODS RELATED TO VALIDATION:")
        for method in platform.get_method_list():
            var n = str(method["name"])
            if "export" in n or "valid" in n or "warning" in n:
                print(JSON.stringify(method))
        for option in preset.get_property_list():
            var n = str(option["name"])
            if "keystore" in n or "package" in n or "architectures" in n:
                print(n, " = ", preset.get(n))
    print("=== END INSPECTION ===")
    quit()

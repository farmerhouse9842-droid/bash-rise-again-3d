# BASH: Rise Again 3D — V4

Offline Godot 4.3 Android prototype. Black-jacket hero, 3D platforms, villain bamboo encounter, recovery/fall animation, bamboo bridge, checkpoints, local score/level save, 10 chapters and a 500-level progression counter. Level geometry is generated from a small set of variations: **500 unique levels are not included**. The character is a static GLB mesh with procedural bounce/tumble, **not** a rigged physics ragdoll. Face likeness is a prototype and should not be considered a precise 3D scan.

## GitHub upload

Upload **the contents of this folder** to the root of your repository. Preserve the hidden `.github/workflows/android.yml` path. On mobile GitHub, uploading directories can be awkward; using GitHub's web editor or a Git client that preserves paths is recommended. Do not upload the ZIP itself as the project.

Go to Actions → Build BASH Android APK → Run workflow. Once the job finishes, download the `BASH-Rise-Again-V4-APK` artifact, unzip and install the APK. Enable installation from the browser/files app when Android asks. This workflow creates a debug APK, not a Play Store signed release.

## Controls

LEFT/RIGHT/UP/DOWN, JUMP, USE BAMBOO, RETRY and HOME. After the first villain collision, go to the middle platform and tap USE BAMBOO. Cross the bridge to reach the gold tile.

## Testing status

Source code packaged and checked for expected files; Android build and device gameplay **not verified** in this environment. If Actions fails, send the first red error line from the log for a targeted fix.

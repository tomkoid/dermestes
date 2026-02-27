# Copilot Instructions

## Project

**dermestes** is a Godot 4.6 game project (Forward Plus renderer). The entry point is `scenes/main.tscn`.

## Engine & Config

- **Godot version:** 4.6
- **Physics:** Jolt Physics (3D)
- **Renderer:** Forward Plus (D3D12 on Windows)
- `project.godot` is the engine config — prefer editing it through the Godot editor, not by hand.

## Conventions

- **Line endings:** LF for all text files (`* text=auto eol=lf` in `.gitattributes`)
- **Encoding:** UTF-8
- **Binary assets** (`.jpg`, `.png`, `.mp3`, `.wav`, `.so`, `.dll`, `.dylib`) are tracked via Git LFS — do not commit them without LFS configured.
- GDScript files live in `scripts/`.

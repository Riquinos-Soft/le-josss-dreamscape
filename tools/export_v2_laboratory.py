"""Export the isolated V2 laboratory without changing the production project."""

import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = root / "build" / "v2-laboratory"
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="project-", dir=output) as temporary:
        project = Path(temporary)
        shutil.copytree(
            root / "game", project, dirs_exist_ok=True,
            ignore=shutil.ignore_patterns(".godot"),
        )
        config = project / "project.godot"
        text, count = re.subn(
            r"^run/main_scene=.*$",
            'run/main_scene="res://v2/validation/laboratory.tscn"',
            config.read_text(), count=1, flags=re.MULTILINE,
        )
        if count != 1:
            raise RuntimeError("Expected exactly one production main scene setting")
        config.write_text(text)
        for command in [
            [args.godot, "--headless", "--path", str(project), "--import", "--quit"],
            [args.godot, "--headless", "--path", str(project), "--export-release",
             "Web", str(output / "index.html")],
        ]:
            result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT)
            print(result.stdout, end="", flush=True)
            if result.returncode or re.search(r"^(?:SCRIPT ERROR|ERROR):", result.stdout, re.MULTILINE):
                raise RuntimeError("Godot laboratory export failed; see output above")
    for filename in ("index.html", "index.wasm", "index.pck"):
        if not (output / filename).is_file():
            raise RuntimeError("Missing exported file: " + filename)
    print("Laboratory Web export:", output)


if __name__ == "__main__":
    main()

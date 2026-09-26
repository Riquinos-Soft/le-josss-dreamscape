"""Check document IDs, spec metadata, registry coverage and relative file links.

English prose still needs editorial review; this does not infer its language.
Run from any directory: python tools/check_docs.py.
"""

from datetime import date
from pathlib import Path
import re
import sys
from urllib.parse import unquote


def check_docs(root: Path) -> list[str]:
    errors = []
    statuses = {"draft", "approved", "in-progress", "implemented", "accepted", "superseded"}
    for folder, label in (("specs", "Spec"), ("plans", "Plan")):
        directory = root / "docs" / folder
        registry = (directory / "README.md").read_text(encoding="utf-8")
        seen = {}
        for path in sorted(directory.glob("*.md")):
            if path.name in {"README.md", "template.md", "task-template.md"}:
                continue
            match = re.fullmatch(r"(\d{3})-[a-z0-9]+(?:-[a-z0-9]+)*\.md", path.name)
            if not match:
                errors.append(f"{path.name}: expected NNN-english-slug.md")
                continue
            identifier = match[1]
            if identifier in seen:
                errors.append(f"{folder}: duplicate ID {identifier}: {seen[identifier]}, {path.name}")
            seen[identifier] = path.name
            text = path.read_text(encoding="utf-8")
            if not text.startswith(f"# {label} {identifier} — "):
                errors.append(f"{path.name}: title must match {label} {identifier}")
            if f"]({path.name})" not in registry:
                errors.append(f"{path.name}: missing registry link")
            if folder != "specs":
                continue
            status = re.search(r"^Status: (.+)$", text, re.MULTILINE)
            if not status or status[1] not in statuses:
                errors.append(f"{path.name}: missing/invalid Status")
            if "\nLanguage: en\n" not in text:
                errors.append(f"{path.name}: declare Language: en and review English prose")
            updated = re.search(r"^Updated: (\d{4}-\d{2}-\d{2})$", text, re.MULTILINE)
            try:
                date.fromisoformat(updated[1] if updated else "")
            except ValueError:
                errors.append(f"{path.name}: missing/invalid Updated date")

    documents = list((root / "docs").rglob("*.md"))
    documents += [root / "README.md", root / "AGENTS.md", root / "deploy/ovh/README.md"]
    for path in documents:
        text = path.read_text(encoding="utf-8")
        for link in re.findall(r"\[[^\]\n]*\]\(([^)\n]+)\)", text):
            target = link.strip().split("#", 1)[0]
            if not target or re.match(r"[a-zA-Z][a-zA-Z0-9+.-]*:", target):
                continue
            target = unquote(target.strip("<>"))
            if not (path.parent / target).is_file():
                errors.append(f"{path.relative_to(root)}: broken file link {target}")
    return errors


if __name__ == "__main__":
    problems = check_docs(Path(__file__).resolve().parents[1])
    for problem in problems:
        print(problem)
    print(f"Documentation checks: {len(problems)} errors")
    sys.exit(bool(problems))

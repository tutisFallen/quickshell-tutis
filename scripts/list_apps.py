#!/usr/bin/env python3
import configparser
import json
from pathlib import Path

APP_DIRS = [
    Path.home() / ".local/share/applications",
    Path("/usr/local/share/applications"),
    Path("/usr/share/applications"),
    Path("/var/lib/flatpak/exports/share/applications"),
    Path.home() / ".local/share/flatpak/exports/share/applications",
]


def clean_exec(raw: str) -> str:
    if not raw:
        return ""
    tokens = raw.strip().split()
    cleaned = [t for t in tokens if not t.startswith("%")]
    return " ".join(cleaned)


def read_desktop(path: Path):
    cp = configparser.ConfigParser(interpolation=None, strict=False)
    try:
        cp.read(path, encoding="utf-8")
    except Exception:
        return None

    if "Desktop Entry" not in cp:
        return None

    e = cp["Desktop Entry"]
    if e.get("Type", "Application") != "Application":
        return None
    if e.get("NoDisplay", "false").lower() == "true":
        return None
    if e.get("Hidden", "false").lower() == "true":
        return None

    name = e.get("Name", "").strip()
    exec_cmd = clean_exec(e.get("Exec", ""))
    if not name or not exec_cmd:
        return None

    return {
        "name": name,
        "genericName": e.get("GenericName", "").strip(),
        "comment": e.get("Comment", "").strip(),
        "icon": e.get("Icon", "").strip(),
        "exec": exec_cmd,
        "desktopId": path.name,
        "desktopFile": str(path),
    }


def main():
    apps_by_id = {}

    for d in APP_DIRS:
        if not d.exists():
            continue
        for entry in d.glob("*.desktop"):
            app = read_desktop(entry)
            if app:
                # first wins (user/local paths come first in APP_DIRS)
                apps_by_id.setdefault(app["desktopId"], app)

    apps = sorted(apps_by_id.values(), key=lambda a: a["name"].lower())
    print(json.dumps(apps, ensure_ascii=False))


if __name__ == "__main__":
    main()

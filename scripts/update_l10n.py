#!/usr/bin/env python3
"""Update ARB localization keys and regenerate Flutter localizations.

Examples:
  python3 scripts/update_l10n.py --key backup --value "Backup" --locale pt_BR
  python3 scripts/update_l10n.py --key backup --value "Cópia" --locale pt pt_BR
    python3 scripts/update_l10n.py --key backup --value "Backup" --description "Rótulo de backup"
  python3 scripts/update_l10n.py --key backup --value "Backup" --locale all --dry-run
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Iterable


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Update one localization key in ARB files and run flutter gen-l10n."
    )
    parser.add_argument("--key", required=True, help="Localization key, e.g. appTitle")
    parser.add_argument("--value", required=True, help="New localized text for the key")
    parser.add_argument(
        "--description",
        help="Optional description to store under @<key>.description in ARB files.",
    )
    parser.add_argument(
        "--locale",
        nargs="+",
        default=["pt_BR"],
        help="One or more locales (pt, pt_BR, en). Use 'all' for all intl_*.arb files.",
    )
    parser.add_argument(
        "--skip-gen",
        action="store_true",
        help="Skip flutter gen-l10n after updating ARB files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show intended changes without writing files or generating l10n.",
    )
    return parser.parse_args()


def resolve_project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def resolve_arb_files(project_root: Path, locales: Iterable[str]) -> list[Path]:
    l10n_dir = project_root / "lib" / "l10n"

    if any(locale.lower() == "all" for locale in locales):
        files = sorted(l10n_dir.glob("intl_*.arb"))
        if not files:
            raise FileNotFoundError("No ARB files were found in lib/l10n.")
        return files

    files: list[Path] = []
    for locale in locales:
        arb_file = l10n_dir / f"intl_{locale}.arb"
        if not arb_file.exists():
            raise FileNotFoundError(f"ARB file not found for locale '{locale}': {arb_file}")
        files.append(arb_file)
    return files


def update_arb_file(
    file_path: Path,
    key: str,
    value: str,
    description: str | None,
    dry_run: bool,
) -> tuple[bool, str | None, bool, str | None]:
    data = json.loads(file_path.read_text(encoding="utf-8"))

    meta_key = f"@{key}"
    old_value = data.get(key)
    old_description = None
    had_meta_change = False

    if isinstance(data.get(meta_key), dict):
        old_description = data[meta_key].get("description")

    changed = old_value != value
    if description is not None and old_description != description:
        had_meta_change = True
        changed = True

    if dry_run:
        return changed, old_value, had_meta_change, old_description

    data[key] = value

    if description is not None:
        meta_obj = data.get(meta_key)
        if not isinstance(meta_obj, dict):
            meta_obj = {}
        meta_obj["description"] = description
        data[meta_key] = meta_obj

    file_path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return changed, old_value, had_meta_change, old_description


def run_flutter_gen_l10n(project_root: Path) -> int:
    command = ["flutter", "gen-l10n"]
    completed = subprocess.run(command, cwd=project_root)
    return completed.returncode


def main() -> int:
    args = parse_args()
    project_root = resolve_project_root()

    try:
        arb_files = resolve_arb_files(project_root, args.locale)
    except FileNotFoundError as exc:
        print(f"[ERROR] {exc}")
        return 1

    print(f"[INFO] Key: {args.key}")
    print(f"[INFO] Value: {args.value}")
    if args.description is not None:
        print(f"[INFO] Description: {args.description}")
    print(f"[INFO] Target files: {len(arb_files)}")

    changed_any = False

    for arb_file in arb_files:
        changed, old_value, meta_changed, old_description = update_arb_file(
            arb_file,
            args.key,
            args.value,
            args.description,
            args.dry_run,
        )
        status = "CHANGED" if changed else "UNCHANGED"

        if old_value is None:
            print(f"[{status}] {arb_file.name}: key did not exist and will be created")
        else:
            print(f"[{status}] {arb_file.name}: '{old_value}' -> '{args.value}'")

        if args.description is not None:
            if old_description is None:
                print(f"[{status}] {arb_file.name}: @description will be created")
            elif meta_changed:
                print(
                    f"[{status}] {arb_file.name}: @description '{old_description}' -> '{args.description}'"
                )
            else:
                print(f"[{status}] {arb_file.name}: @description unchanged")

        changed_any = changed_any or changed

    if args.dry_run:
        print("[INFO] Dry-run mode: no files were written and gen-l10n was not executed.")
        return 0

    if args.skip_gen:
        print("[INFO] --skip-gen enabled: flutter gen-l10n was not executed.")
        return 0

    if not changed_any:
        print("[INFO] No changes detected in ARB files. Running gen-l10n anyway to keep generated files in sync.")

    print("[INFO] Running: flutter gen-l10n")
    result = run_flutter_gen_l10n(project_root)
    if result != 0:
        print("[ERROR] flutter gen-l10n failed.")
        return result

    print("[INFO] Localization files generated successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

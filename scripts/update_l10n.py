#!/usr/bin/env python3
"""Update ARB localization keys and regenerate Flutter localizations.

Examples:
  python3 scripts/update_l10n.py --key backup --value "Backup" --locale pt_BR
  python3 scripts/update_l10n.py --key backup --value "Cópia" --locale pt pt_BR
    python3 scripts/update_l10n.py --key backup --value "Backup" --description "Rótulo de backup"
    python3 scripts/update_l10n.py --key backup --value "Backup" --propagate-from-pt
    python3 scripts/update_l10n.py --key backup --value "Backup" --translate-from-pt-br
  python3 scripts/update_l10n.py --key backup --value "Backup" --locale all --dry-run
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import urlopen
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
        default=["pt"],
        help="One or more locales (pt, pt_BR, en). Use 'all' for all intl_*.arb files.",
    )
    parser.add_argument(
        "--propagate-from-pt",
        action="store_true",
        help=(
            "Update intl_pt.arb and propagate the same value to all other intl_*.arb files. "
            "Useful when Portuguese is your source text."
        ),
    )
    parser.add_argument(
        "--translate-from-pt-br",
        action="store_true",
        help=(
            "Use --value as Portuguese (Brazil) source text, then auto-translate "
            "and update all intl_*.arb files."
        ),
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


def resolve_arb_files_propagate_from_pt(project_root: Path) -> list[Path]:
    l10n_dir = project_root / "lib" / "l10n"
    pt_file = l10n_dir / "intl_pt.arb"

    if not pt_file.exists():
        raise FileNotFoundError(f"Required file not found: {pt_file}")

    all_files = sorted(l10n_dir.glob("intl_*.arb"))
    if not all_files:
        raise FileNotFoundError("No ARB files were found in lib/l10n.")

    # Ensure pt is processed first, then all remaining locales.
    return [pt_file] + [file for file in all_files if file != pt_file]


def extract_locale_from_arb_file(file_path: Path) -> str:
    stem = file_path.stem
    if not stem.startswith("intl_"):
        raise ValueError(f"Invalid ARB filename format: {file_path.name}")
    return stem.replace("intl_", "", 1)


def language_code_from_locale(locale: str) -> str:
    return locale.split("_", 1)[0].lower()


def translate_text(text: str, source_lang: str, target_lang: str) -> str:
    if source_lang == target_lang:
        return text

    params = urlencode(
        {
            "client": "gtx",
            "sl": source_lang,
            "tl": target_lang,
            "dt": "t",
            "q": text,
        }
    )
    url = f"https://translate.googleapis.com/translate_a/single?{params}"

    with urlopen(url, timeout=15) as response:
        payload = response.read().decode("utf-8")

    data = json.loads(payload)
    translated_chunks = data[0]
    translated_text = "".join(chunk[0] for chunk in translated_chunks if chunk and chunk[0])

    if not translated_text:
        raise RuntimeError("Translation service returned empty text.")

    return translated_text


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

    if args.propagate_from_pt and args.translate_from_pt_br:
        print("[ERROR] Use either --propagate-from-pt or --translate-from-pt-br, not both.")
        return 1

    if args.propagate_from_pt and args.locale != ["pt"]:
        print("[ERROR] Do not combine --propagate-from-pt with custom --locale values.")
        print("[ERROR] Use either --propagate-from-pt or --locale, not both.")
        return 1

    if args.translate_from_pt_br and args.locale != ["pt"]:
        print("[ERROR] Do not combine --translate-from-pt-br with custom --locale values.")
        print("[ERROR] Use either --translate-from-pt-br or --locale, not both.")
        return 1

    try:
        if args.propagate_from_pt:
            arb_files = resolve_arb_files_propagate_from_pt(project_root)
        elif args.translate_from_pt_br:
            arb_files = resolve_arb_files(project_root, ["all"])
        else:
            arb_files = resolve_arb_files(project_root, args.locale)
    except FileNotFoundError as exc:
        print(f"[ERROR] {exc}")
        return 1

    print(f"[INFO] Key: {args.key}")
    print(f"[INFO] Value: {args.value}")
    if args.description is not None:
        print(f"[INFO] Description: {args.description}")
    if args.propagate_from_pt:
        print("[INFO] Mode: propagate from pt -> all locales")
    if args.translate_from_pt_br:
        print("[INFO] Mode: translate from pt_BR -> all locales")
    print(f"[INFO] Target files: {len(arb_files)}")

    changed_any = False

    translated_values_by_locale: dict[str, str] = {}
    if args.translate_from_pt_br:
        source_lang = "pt"
        for arb_file in arb_files:
            locale = extract_locale_from_arb_file(arb_file)
            if locale == "pt_BR":
                translated_values_by_locale[locale] = args.value
                continue

            target_lang = language_code_from_locale(locale)
            try:
                translated_values_by_locale[locale] = translate_text(
                    args.value,
                    source_lang,
                    target_lang,
                )
            except Exception as exc:  # noqa: BLE001 - keep user-friendly error handling
                print(f"[ERROR] Failed to translate for locale '{locale}': {exc}")
                return 1

    for arb_file in arb_files:
        locale = extract_locale_from_arb_file(arb_file)
        localized_value = (
            translated_values_by_locale[locale]
            if args.translate_from_pt_br
            else args.value
        )

        changed, old_value, meta_changed, old_description = update_arb_file(
            arb_file,
            args.key,
            localized_value,
            args.description,
            args.dry_run,
        )
        status = "CHANGED" if changed else "UNCHANGED"

        if old_value is None:
            print(f"[{status}] {arb_file.name}: key did not exist and will be created")
        else:
            print(f"[{status}] {arb_file.name}: '{old_value}' -> '{localized_value}'")

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

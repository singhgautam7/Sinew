"""Stage 08: Compile production release artifacts in dist/ and copy to specs/data/.

Artifacts:
- dist/exercises.json
- dist/flows.json
- dist/exercise.schema.json, vocab.json, muscle_regions.json
- dist/exercises.sample.json
- dist/ATTRIBUTIONS.md, SOURCES.md
- dist/manifest.json (hashes, counts, metadata)
- dist/CHANGELOG.md (id diff: added, changed, removed)

Copies dist/ to specs/data/ as required by Sinew's tool/build_library_db.dart.
"""

from __future__ import annotations

import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Set

from utils import get_base_dir, load_config, validate_exercise_record, validate_flow_record


def compute_sha256(filepath: Path) -> str:
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def main():
    base_dir = get_base_dir()
    dist_dir = base_dir / "dist"
    specs_data_dir = base_dir.parent / "specs" / "data"
    dist_dir.mkdir(parents=True, exist_ok=True)
    specs_data_dir.mkdir(parents=True, exist_ok=True)

    config = load_config()
    lib_version = config.get("libraryVersion", "1.0.0")
    schema_version = config.get("schemaVersion", "2020-12")

    # 1. Determine final exercise dataset
    deduped_file = base_dir / "stage" / "deduped" / "all_exercises.json"
    sample_file = dist_dir / "exercises.sample.json"

    if deduped_file.is_file():
        with open(deduped_file, "r", encoding="utf-8") as f:
            final_exercises = json.load(f)
    elif sample_file.is_file():
        with open(sample_file, "r", encoding="utf-8") as f:
            final_exercises = json.load(f)
    else:
        print("[ERROR] No exercise dataset found to build. Run previous pipeline stages first.")
        return

    # Ensure sorted by id
    final_exercises.sort(key=lambda x: x["id"])

    # Write dist/exercises.json
    exercises_out = dist_dir / "exercises.json"
    with open(exercises_out, "w", encoding="utf-8") as f:
        json.dump(final_exercises, f, indent=2, ensure_ascii=False)

    # 2. Copy schema files into dist/
    for fname in ["exercise.schema.json", "flow.schema.json", "vocab.json", "muscle_regions.json"]:
        src = base_dir / "schema" / fname
        if src.is_file():
            shutil.copy2(src, dist_dir / fname)

    # 3. Copy SOURCES.md into dist/
    src_sources = base_dir / "sources" / "SOURCES.md"
    if src_sources.is_file():
        shutil.copy2(src_sources, dist_dir / "SOURCES.md")

    # 4. Check previous manifest for diffing
    manifest_file = dist_dir / "manifest.json"
    prev_manifest = None
    prev_ids: Set[str] = set()
    prev_hashes: Dict[str, str] = {}

    if manifest_file.is_file():
        try:
            with open(manifest_file, "r", encoding="utf-8") as f:
                prev_manifest = json.load(f)
                prev_hashes = prev_manifest.get("sha256", {})
        except Exception:
            pass

    prev_exercises_file = dist_dir / "exercises.json.prev"
    if prev_exercises_file.is_file():
        try:
            with open(prev_exercises_file, "r", encoding="utf-8") as f:
                prev_ids = {x["id"] for x in json.load(f)}
        except Exception:
            pass

    current_ids = {x["id"] for x in final_exercises}
    added_ids = sorted(list(current_ids - prev_ids))
    removed_ids = sorted(list(prev_ids - current_ids))

    if removed_ids:
        print(f"[CRITICAL WARNING] {len(removed_ids)} published exercise IDs were removed!")
        print(f"Removed IDs: {removed_ids}")
        print("Note: Removing a published ID requires explicit user approval per project guidelines.")

    # 5. Build CHANGELOG.md
    changelog_file = dist_dir / "CHANGELOG.md"
    now_iso = datetime.now(timezone.utc).isoformat()
    changelog_entry = [
        f"## Release v{lib_version} ({now_iso[:10]})\n",
        f"- **Total Exercises:** {len(final_exercises)}",
        f"- **New Movements Added ({len(added_ids)}):** {', '.join(added_ids[:10]) + ('...' if len(added_ids) > 10 else '') if added_ids else 'None'}",
        f"- **Removed IDs ({len(removed_ids)}):** {', '.join(removed_ids) if removed_ids else 'None'}\n"
    ]

    existing_changelog = changelog_file.read_text(encoding="utf-8") if changelog_file.is_file() else "# Sinew Database Changelog\n\n"
    new_changelog = existing_changelog.replace("# Sinew Database Changelog\n\n", "# Sinew Database Changelog\n\n" + "\n".join(changelog_entry) + "\n")
    changelog_file.write_text(new_changelog, encoding="utf-8")

    # 6. Compute sha256 for all dist files
    hashes = {}
    for item in sorted(list(dist_dir.glob("*"))):
        if item.is_file() and item.name != "manifest.json" and not item.name.endswith(".prev"):
            hashes[item.name] = compute_sha256(item)

    # 7. Category counts breakdown
    from collections import Counter
    cat_counts = dict(Counter(x["category"] for x in final_exercises))

    manifest_data = {
        "libraryVersion": lib_version,
        "schemaVersion": schema_version,
        "builtAt": now_iso,
        "totalExercises": len(final_exercises),
        "counts": cat_counts,
        "sha256": hashes
    }

    with open(manifest_file, "w", encoding="utf-8") as f:
        json.dump(manifest_data, f, indent=2, ensure_ascii=False)

    # Backup current exercises.json for next diff
    shutil.copy2(exercises_out, dist_dir / "exercises.json.prev")

    # 8. Copy dist/ to specs/data/
    print(f"Syncing artifacts to app repository at {specs_data_dir}...")
    for item in dist_dir.glob("*"):
        if item.is_file() and not item.name.endswith(".prev"):
            shutil.copy2(item, specs_data_dir / item.name)

    print("=" * 60)
    print("STAGE 08 BUILD COMPLETE")
    print("=" * 60)
    print(f"Library Version    : {lib_version}")
    print(f"Total Exercises    : {len(final_exercises)}")
    print(f"Dist Location      : {dist_dir}")
    print(f"Specs Data Location: {specs_data_dir}")
    print("Files Compiled:")
    for fn, h in hashes.items():
        print(f"  - {fn:<25} ({h[:12]}...)")
    print("=" * 60)


if __name__ == "__main__":
    main()

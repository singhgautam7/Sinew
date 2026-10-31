"""Stage 06: Normalised-name and alias matching plus deduplication.

Merges true duplicates (keeps the better text, unions aliases).
Keeps real variations separate and links them via variationOf.
Outputs -> stage/deduped/all_exercises.json
"""

from __future__ import annotations

import json
import re
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any, Dict, List, Set, Tuple

from utils import get_base_dir


def clean_name(name: str) -> str:
    name = name.lower().strip()
    name = re.sub(r"[^a-z0-9\s]", "", name)
    return " ".join(name.split())


def similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, clean_name(a), clean_name(b)).ratio()


def pick_better_record(a: Dict[str, Any], b: Dict[str, Any]) -> Tuple[Dict[str, Any], Dict[str, Any]]:
    """Returns (winner, loser) based on completeness, step detail, and passes."""
    score_a = len(" ".join(a.get("steps", []))) + len(a.get("tips", [])) * 20 + a.get("verification", {}).get("passes", 0) * 50
    score_b = len(" ".join(b.get("steps", []))) + len(b.get("tips", [])) * 20 + b.get("verification", {}).get("passes", 0) * 50
    if score_a >= score_b:
        return (a, b)
    return (b, a)


def merge_records(primary: Dict[str, Any], secondary: Dict[str, Any]) -> Dict[str, Any]:
    merged = dict(primary)
    # Union aliases
    aliases = set(merged.get("aliases", []))
    aliases.add(secondary.get("name"))
    for al in secondary.get("aliases", []):
        aliases.add(al)
    # Remove own primary name from aliases
    aliases.discard(merged.get("name"))
    merged["aliases"] = sorted(list(aliases))

    # Union tags
    tags = set(merged.get("tags", []))
    for t in secondary.get("tags", []):
        tags.add(t)
    merged["tags"] = sorted(list(tags))

    # Union secondary muscles if not primary
    primaries = set(merged.get("primaryMuscles", []))
    secondaries = set(merged.get("secondaryMuscles", []))
    for sm in secondary.get("secondaryMuscles", []):
        if sm not in primaries:
            secondaries.add(sm)
    merged["secondaryMuscles"] = sorted(list(secondaries))

    return merged


def link_variations(records: List[Dict[str, Any]]) -> int:
    """Finds natural variation chains and links variationOf."""
    linked_count = 0
    id_map = {r["id"]: r for r in records}
    names_to_id = {clean_name(r["name"]): r["id"] for r in records}

    # Common variation patterns -> base patterns
    variation_patterns = [
        (r"incline (.*)", r"\1"),
        (r"decline (.*)", r"\1"),
        (r"seated (.*)", r"\1"),
        (r"standing (.*)", r"\1"),
        (r"close-grip (.*)", r"\1"),
        (r"wide-grip (.*)", r"\1"),
        (r"single-leg (.*)", r"\1"),
        (r"single-arm (.*)", r"\1"),
        (r"(.*) on bench", r"\1"),
        (r"(.*) with bands?", r"\1"),
    ]

    for r in records:
        if r.get("variationOf"):
            continue
        cname = clean_name(r["name"])
        for pattern, replacement in variation_patterns:
            base_cand = re.sub(pattern, replacement, cname).strip()
            if base_cand != cname and base_cand in names_to_id:
                base_id = names_to_id[base_cand]
                if base_id != r["id"]:
                    r["variationOf"] = base_id
                    linked_count += 1
                    break

    return linked_count


def main():
    base_dir = get_base_dir()
    ver_dir = base_dir / "stage" / "verified"
    dedupe_dir = base_dir / "stage" / "deduped"
    dedupe_dir.mkdir(parents=True, exist_ok=True)
    out_file = dedupe_dir / "all_exercises.json"

    ver_files = sorted(list(ver_dir.glob("*.json"))) if ver_dir.is_dir() else []
    print(f"Loading verified records from {len(ver_files)} category files...")

    all_records: List[Dict[str, Any]] = []
    for vf in ver_files:
        with open(vf, "r", encoding="utf-8") as f:
            all_records.extend(json.load(f))

    print(f"Total raw verified input records: {len(all_records)}")

    # 1. Exact ID Deduplication
    by_id: Dict[str, Dict[str, Any]] = {}
    merged_ids = 0
    for r in all_records:
        rid = r["id"]
        if rid in by_id:
            winner, loser = pick_better_record(by_id[rid], r)
            by_id[rid] = merge_records(winner, loser)
            merged_ids += 1
        else:
            by_id[rid] = r

    unique_list = list(by_id.values())

    # 2. Normalized Name Deduplication
    by_clean_name: Dict[str, Dict[str, Any]] = {}
    merged_names = 0
    for r in unique_list:
        cname = clean_name(r["name"])
        # Check if equipment differs significantly
        if cname in by_clean_name:
            existing = by_clean_name[cname]
            eq_a = set(existing.get("equipment", []))
            eq_b = set(r.get("equipment", []))
            # If same equipment and same category, they are true duplicates
            if eq_a == eq_b and existing.get("category") == r.get("category"):
                winner, loser = pick_better_record(existing, r)
                by_clean_name[cname] = merge_records(winner, loser)
                merged_names += 1
            else:
                # Distinguish variation ID
                by_clean_name[f"{cname}_{r['id']}"] = r
        else:
            by_clean_name[cname] = r

    final_records = list(by_clean_name.values())

    # 3. Link variations
    linked_variations = link_variations(final_records)

    # Sort deterministically
    final_records.sort(key=lambda x: x["id"])

    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(final_records, f, indent=2, ensure_ascii=False)

    print("=" * 60)
    print("STAGE 06 DEDUPLICATION COMPLETE")
    print(f"Input records          : {len(all_records)}")
    print(f"Merged identical IDs   : {merged_ids}")
    print(f"Merged duplicate names : {merged_names}")
    print(f"Variations linked      : {linked_variations}")
    print(f"Final unique records   : {len(final_records)}")
    print(f"Output saved to        : {out_file}")
    print("=" * 60)


if __name__ == "__main__":
    main()

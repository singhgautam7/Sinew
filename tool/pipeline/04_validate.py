"""Stage 04: Validate records against exercise.schema.json and strict quality rules.

Validates schema, closed enums, word count constraints, tracking type requirements,
unilateral notes, and em dash prohibition.
Passing records -> stage/validated/<category>.json
Failing records after retries -> stage/rejects/<category>_rejects.json
"""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Tuple

from utils import get_base_dir, get_dist_dir, validate_exercise_record


def main():
    base_dir = get_base_dir()
    gen_dir = base_dir / "stage" / "generated"
    val_dir = base_dir / "stage" / "validated"
    rej_dir = base_dir / "stage" / "rejects"
    val_dir.mkdir(parents=True, exist_ok=True)
    rej_dir.mkdir(parents=True, exist_ok=True)

    gen_files = sorted(list(gen_dir.glob("*.json"))) if gen_dir.is_dir() else []
    print(f"Found {len(gen_files)} generated batch files to validate.")

    validated_by_category: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    rejected_by_category: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    error_summary: Dict[str, int] = defaultdict(int)

    total_records = 0
    total_valid = 0
    total_rejected = 0

    # Also include exercises.sample.json if available
    sample_file = get_dist_dir() / "exercises.sample.json"
    if sample_file.is_file():
        with open(sample_file, "r", encoding="utf-8") as f:
            sample_recs = json.load(f)
            for r in sample_recs:
                total_records += 1
                is_valid, errors = validate_exercise_record(r)
                cat = r.get("category", "general")
                if is_valid:
                    validated_by_category[cat].append(r)
                    total_valid += 1
                else:
                    r["_validationErrors"] = errors
                    rejected_by_category[cat].append(r)
                    total_rejected += 1
                    for err in errors:
                        error_summary[err.split(":")[0]] += 1

    for fpath in gen_files:
        try:
            with open(fpath, "r", encoding="utf-8") as f:
                recs = json.load(f)
        except Exception as e:
            print(f"Error reading {fpath}: {e}")
            continue

        if not isinstance(recs, list):
            continue

        for r in recs:
            total_records += 1
            cat = r.get("category", "general")
            is_valid, errors = validate_exercise_record(r)
            if is_valid:
                validated_by_category[cat].append(r)
                total_valid += 1
            else:
                r["_validationErrors"] = errors
                rejected_by_category[cat].append(r)
                total_rejected += 1
                for err in errors:
                    prefix = err.split(":")[0] if ":" in err else err[:40]
                    error_summary[prefix] += 1

    # Write validated
    for cat, recs in validated_by_category.items():
        # Deduplicate within category
        unique_recs = {r["id"]: r for r in recs}.values()
        out_file = val_dir / f"{cat}.json"
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(sorted(list(unique_recs), key=lambda x: x["id"]), f, indent=2, ensure_ascii=False)

    # Write rejects
    for cat, recs in rejected_by_category.items():
        out_file = rej_dir / f"{cat}_rejects.json"
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(recs, f, indent=2, ensure_ascii=False)

    print("=" * 60)
    print("STAGE 04 VALIDATION REPORT")
    print("=" * 60)
    print(f"Total Records Evaluated : {total_records}")
    print(f"Total Validated         : {total_valid}")
    print(f"Total Rejected          : {total_rejected}")
    if total_records > 0:
        pass_rate = (total_valid / total_records) * 100
        print(f"Validation Pass Rate    : {pass_rate:.1f}%")
    print("-" * 60)
    print("Validated Counts by Category:")
    for cat, recs in sorted(validated_by_category.items()):
        unique_cnt = len({r["id"]: r for r in recs})
        print(f"  - {cat:<20}: {unique_cnt}")

    if error_summary:
        print("-" * 60)
        print("Top Validation Errors:")
        for err, count in sorted(error_summary.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  [{count}x] {err}")
    print("=" * 60)


if __name__ == "__main__":
    main()

"""Stage 01: Import and normalize seed data from approved permissive sources.

Sources:
1. yuhonas/free-exercise-db (The Unlicense - Public Domain)
2. hasaneyldrm/exercises-dataset (MIT License for exercise data, zero media)

Outputs:
- stage/seed/seeded_exercises.json
- stage/seed/unmapped.log
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Set
import requests

from utils import get_base_dir, load_vocab


# Mapping from raw seed strings to closed vocabulary
MUSCLE_MAP: Dict[str, str] = {
    "chest": "chest",
    "pectorals": "chest",
    "shoulders": "shoulders",
    "delts": "shoulders",
    "anterior deltoid": "shoulders",
    "lateral deltoid": "shoulders",
    "rear delts": "rearDeltoids",
    "posterior deltoid": "rearDeltoids",
    "rear shoulders": "rearDeltoids",
    "biceps": "biceps",
    "triceps": "triceps",
    "forearms": "forearms",
    "traps": "trapezius",
    "trapezius": "trapezius",
    "lats": "lats",
    "latissimus dorsi": "lats",
    "middle back": "rhomboids",
    "rhomboids": "rhomboids",
    "upper back": "rhomboids",
    "lower back": "lowerBack",
    "erector spinae": "lowerBack",
    "abdominals": "core",
    "abs": "core",
    "core": "core",
    "obliques": "obliques",
    "hip flexors": "hipFlexors",
    "iliopsoas": "hipFlexors",
    "glutes": "glutes",
    "gluteus maximus": "glutes",
    "quadriceps": "quadriceps",
    "quads": "quadriceps",
    "hamstrings": "hamstrings",
    "adductors": "adductors",
    "inner thighs": "adductors",
    "abductors": "abductors",
    "outer hips": "abductors",
    "calves": "calves",
    "soleus": "calves",
    "gastrocnemius": "calves",
    "tibialis": "tibialis",
    "shins": "tibialis",
    "neck": "neck",
    "levator scapulae": "neck",
    "spine": "lowerBack",
    "serratus anterior": "core",
    "cardiovascular system": "fullBody",
    "full body": "fullBody"
}

EQUIPMENT_MAP: Dict[str, str] = {
    "barbell": "barbell",
    "olympic barbell": "barbell",
    "dumbbell": "dumbbell",
    "kettlebell": "kettlebell",
    "kettlebells": "kettlebell",
    "cable": "cable",
    "cables": "cable",
    "machine": "machine",
    "leverage machine": "machine",
    "sled machine": "machine",
    "smith machine": "smithMachine",
    "body only": "bodyweight",
    "bodyweight": "bodyweight",
    "none": "bodyweight",
    "body weight": "bodyweight",
    "assisted": "machine",
    "bands": "resistanceBand",
    "band": "resistanceBand",
    "resistance band": "resistanceBand",
    "mini band": "miniBand",
    "foam roll": "foamRoller",
    "foam roller": "foamRoller",
    "roller": "foamRoller",
    "exercise ball": "stabilityBall",
    "stability ball": "stabilityBall",
    "bosu ball": "stabilityBall",
    "medicine ball": "medicineBall",
    "slam ball": "slamBall",
    "e-z curl bar": "ezBar",
    "ez bar": "ezBar",
    "ez barbell": "ezBar",
    "trap bar": "trapBar",
    "hex bar": "trapBar",
    "pull-up bar": "pullupBar",
    "pullup bar": "pullupBar",
    "dip station": "dipStation",
    "bench": "bench",
    "incline bench": "inclineBench",
    "decline bench": "declineBench",
    "rings": "gymnasticRings",
    "jump rope": "jumpRope",
    "rope": "jumpRope",
    "box": "plyoBox",
    "landmine": "landmine",
    "wheel roller": "abWheel",
    "stationary bike": "stationaryBike",
    "elliptical machine": "elliptical",
    "stepmill machine": "stairClimber",
    "skierg machine": "skiErg",
    "weighted": "weightPlate"
}

CATEGORY_MAP: Dict[str, str] = {
    "strength": "strength",
    "powerlifting": "strength",
    "olympic weightlifting": "strength",
    "strongman": "strength",
    "plyometrics": "hiit",
    "stretching": "mobility",
    "cardio": "cardio",
    "calisthenics": "calisthenics"
}


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    return text.strip("-")


def map_muscle(name: str, unmapped: Set[str]) -> str | None:
    norm = name.strip().lower()
    if norm in MUSCLE_MAP:
        return MUSCLE_MAP[norm]
    unmapped.add(f"muscle: {name}")
    return None


def map_equipment(name: str, unmapped: Set[str]) -> str | None:
    norm = name.strip().lower()
    if norm in EQUIPMENT_MAP:
        return EQUIPMENT_MAP[norm]
    unmapped.add(f"equipment: {name}")
    return None


def fetch_yuhonas_dataset() -> List[Dict[str, Any]]:
    url = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
    print(f"Fetching yuhonas dataset from {url}...")
    try:
        resp = requests.get(url, timeout=30)
        if resp.status_code == 200:
            return resp.json()
        print(f"Failed to fetch yuhonas: HTTP {resp.status_code}")
    except Exception as e:
        print(f"Error fetching yuhonas: {e}")
    return []


def fetch_hasan_dataset() -> List[Dict[str, Any]]:
    url = "https://raw.githubusercontent.com/hasaneyldrm/exercises-dataset/main/data/exercises.json"
    print(f"Fetching hasaneyldrm dataset from {url}...")
    try:
        resp = requests.get(url, timeout=60)
        if resp.status_code == 200:
            return resp.json()
        print(f"Failed to fetch hasaneyldrm: HTTP {resp.status_code}")
    except Exception as e:
        print(f"Error fetching hasaneyldrm: {e}")
    return []


def main():
    base_dir = get_base_dir()
    seed_dir = base_dir / "stage" / "seed"
    seed_dir.mkdir(parents=True, exist_ok=True)
    out_file = seed_dir / "seeded_exercises.json"
    log_file = seed_dir / "unmapped.log"

    force = "--force" in sys.argv
    if out_file.is_file() and not force:
        print(f"Seed file already exists at {out_file}. Use --force to re-run. Skipping.")
        return

    unmapped: Set[str] = set()
    seeded: Dict[str, Dict[str, Any]] = {}

    # 1. Process yuhonas
    yuhonas_data = fetch_yuhonas_dataset()
    print(f"Processing {len(yuhonas_data)} raw records from yuhonas/free-exercise-db...")
    for item in yuhonas_data:
        raw_name = item.get("name", "").strip()
        if not raw_name:
            continue
        ex_id = slugify(raw_name)
        cat_raw = item.get("category", "strength").lower()
        category = CATEGORY_MAP.get(cat_raw, "strength")

        primary = []
        for m in item.get("primaryMuscles", []):
            mapped_m = map_muscle(m, unmapped)
            if mapped_m and mapped_m not in primary:
                primary.append(mapped_m)
        if not primary:
            primary = ["fullBody"]

        secondary = []
        for m in item.get("secondaryMuscles", []):
            mapped_m = map_muscle(m, unmapped)
            if mapped_m and mapped_m not in primary and mapped_m not in secondary:
                secondary.append(mapped_m)

        eq = []
        eq_raw = item.get("equipment")
        if eq_raw:
            mapped_eq = map_equipment(eq_raw, unmapped)
            if mapped_eq:
                eq.append(mapped_eq)
        if not eq:
            eq = ["bodyweight"]

        force_val = item.get("force")
        if force_val not in ["push", "pull", "static", "hinge"]:
            force_val = None

        mechanic_val = item.get("mechanic")
        if mechanic_val not in ["compound", "isolation"]:
            mechanic_val = None

        seeded[ex_id] = {
            "id": ex_id,
            "name": raw_name,
            "aliases": [],
            "category": category,
            "primaryMuscles": primary,
            "secondaryMuscles": secondary,
            "equipment": eq,
            "mechanic": mechanic_val,
            "force": force_val,
            "source": "seed",
            "sourceRef": "yuhonas/free-exercise-db",
            "license": "Unlicense"
        }

    # 2. Process hasaneyldrm
    hasan_data = fetch_hasan_dataset()
    print(f"Processing {len(hasan_data)} raw records from hasaneyldrm/exercises-dataset...")
    for item in hasan_data:
        raw_name = item.get("name", "").strip()
        if not raw_name:
            continue
        ex_id = slugify(raw_name)

        # Merge or add
        if ex_id in seeded:
            # Add raw name as alias if different casing or slight variant
            existing = seeded[ex_id]
            if raw_name.lower() != existing["name"].lower() and raw_name not in existing["aliases"]:
                existing["aliases"].append(raw_name)
            continue

        cat_raw = item.get("category", "strength").lower()
        category = CATEGORY_MAP.get(cat_raw, "strength")

        primary = []
        p_raw = item.get("target") or item.get("primaryMuscle")
        if p_raw:
            mapped_m = map_muscle(p_raw, unmapped)
            if mapped_m:
                primary.append(mapped_m)
        if not primary:
            primary = ["fullBody"]

        secondary = []
        for s in item.get("secondaryMuscles", []):
            mapped_m = map_muscle(s, unmapped)
            if mapped_m and mapped_m not in primary and mapped_m not in secondary:
                secondary.append(mapped_m)

        eq = []
        eq_raw = item.get("equipment")
        if eq_raw:
            mapped_eq = map_equipment(eq_raw, unmapped)
            if mapped_eq:
                eq.append(mapped_eq)
        if not eq:
            eq = ["bodyweight"]

        seeded[ex_id] = {
            "id": ex_id,
            "name": raw_name,
            "aliases": [],
            "category": category,
            "primaryMuscles": primary,
            "secondaryMuscles": secondary,
            "equipment": eq,
            "mechanic": None,
            "force": None,
            "source": "seed",
            "sourceRef": "hasaneyldrm/exercises-dataset",
            "license": "MIT"
        }

    seeded_list = sorted(list(seeded.values()), key=lambda x: x["id"])
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(seeded_list, f, indent=2, ensure_ascii=False)

    with open(log_file, "w", encoding="utf-8") as f:
        for u in sorted(list(unmapped)):
            f.write(f"{u}\n")

    print(f"[SUCCESS] Seeded {len(seeded_list)} distinct movement skeletons into {out_file}")
    print(f"Logged {len(unmapped)} unmapped terms to {log_file}")


if __name__ == "__main__":
    main()

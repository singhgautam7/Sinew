"""Generates canonical flow templates for Sinew's flow and timer mode."""

import json
from pathlib import Path
from utils import get_base_dir, get_dist_dir, validate_flow_record

FLOWS = [
    {
        "id": "surya-namaskar-a-sequence",
        "name": "Sun Salutation A (Surya Namaskar A)",
        "category": "yoga",
        "difficulty": "beginner",
        "description": "Classical foundational vinyasa sequence linking breath with dynamic standing and forward bend transitions.",
        "totalDurationSec": 180,
        "rounds": 3,
        "items": [
            {"exerciseId": "tadasana", "durationSec": 15, "transitionSec": 3, "notes": "Ground through feet and lengthen spine."},
            {"exerciseId": "uttanasana", "durationSec": 15, "transitionSec": 3, "notes": "Hinge forward from hips on exhale."},
            {"exerciseId": "ardha-uttanasana", "durationSec": 10, "transitionSec": 3, "notes": "Inhale, flat back, gaze forward."},
            {"exerciseId": "urdhva-mukha-svanasana", "durationSec": 15, "transitionSec": 3, "notes": "Inhale, open chest into upward dog."},
            {"exerciseId": "adho-mukha-svanasana", "durationSec": 30, "transitionSec": 5, "notes": "Exhale, push hips up and hold downward dog."},
            {"exerciseId": "ardha-uttanasana", "durationSec": 10, "transitionSec": 3, "notes": "Step forward to flat back on inhale."},
            {"exerciseId": "uttanasana", "durationSec": 15, "transitionSec": 3, "notes": "Exhale and fold deeply."},
            {"exerciseId": "tadasana", "durationSec": 15, "transitionSec": 3, "notes": "Inhale, sweep tall to standing mountain."}
        ],
        "tags": ["yoga", "vinyasa", "flow", "morning", "sunSalutation"]
    },
    {
        "id": "boxing-shadowboxing-fundamentals",
        "name": "Boxing Fundamentals: Punches and Guard Flow",
        "category": "boxing",
        "difficulty": "beginner",
        "description": "Rhythmic shadowboxing round emphasizing stance stability, 1-2 straight punch mechanics, and defensive slipping.",
        "totalDurationSec": 300,
        "rounds": 2,
        "items": [
            {"exerciseId": "orthodox-boxing-stance", "durationSec": 30, "transitionSec": 5, "notes": "Establish active balance and guard."},
            {"exerciseId": "boxing-lead-jab", "durationSec": 45, "transitionSec": 5, "notes": "Double and single 1 jabs from stance."},
            {"exerciseId": "boxing-rear-cross", "durationSec": 45, "transitionSec": 5, "notes": "Full rear hip rotation on 2 cross."},
            {"exerciseId": "one-two-lead-hook-combo", "durationSec": 60, "transitionSec": 5, "notes": "Fluid 1-2-3 combination cycles."},
            {"exerciseId": "orthodox-boxing-stance", "durationSec": 30, "transitionSec": 5, "notes": "Active recovery in tight guard."}
        ],
        "tags": ["boxing", "shadowboxing", "rounds", "technique"]
    },
    {
        "id": "full-body-dynamic-mobility-warmup",
        "name": "Full Body Joint Mobility & Activation Warmup",
        "category": "mobility",
        "difficulty": "beginner",
        "description": "Comprehensive pre-workout sequence targeting thoracic mobility, hip capsule expansion, and shoulder ranges.",
        "totalDurationSec": 240,
        "rounds": 1,
        "items": [
            {"exerciseId": "cat-cow-stretch", "durationSec": 45, "transitionSec": 5, "notes": "Segmental spinal articulation."},
            {"exerciseId": "thoracic-foam-roll-extension", "durationSec": 45, "transitionSec": 5, "notes": "Mid-back tissue opening."},
            {"exerciseId": "worlds-greatest-stretch", "durationSec": 60, "transitionSec": 5, "notes": "Hip flexor and thoracic rotation."},
            {"exerciseId": "ninety-ninety-hip-switch", "durationSec": 45, "transitionSec": 5, "notes": "Internal and external hip rotation."},
            {"exerciseId": "shoulder-pass-through", "durationSec": 30, "transitionSec": 5, "notes": "Shoulder girdle mobilization."}
        ],
        "tags": ["mobility", "warmup", "fullBody", "recovery"]
    },
    {
        "id": "hiit-bodyweight-tabata-circuit",
        "name": "High-Intensity Bodyweight Tabata Flow",
        "category": "hiit",
        "difficulty": "intermediate",
        "description": "Short burst high-cadence interval sequence targeting cardiorespiratory endurance and muscular power.",
        "totalDurationSec": 240,
        "rounds": 2,
        "items": [
            {"exerciseId": "standard-burpee", "durationSec": 20, "transitionSec": 10, "notes": "Maximum effort chest-to-floor burpees."},
            {"exerciseId": "mountain-climber", "durationSec": 20, "transitionSec": 10, "notes": "Rapid knee cadence in plank."},
            {"exerciseId": "jumping-lunge", "durationSec": 20, "transitionSec": 10, "notes": "Explosive split switch jumps."},
            {"exerciseId": "hollow-body-hold", "durationSec": 20, "transitionSec": 10, "notes": "Isometric core tension hold."}
        ],
        "tags": ["hiit", "tabata", "conditioning", "fatBurn"]
    },
    {
        "id": "classic-pilates-core-mat-series",
        "name": "Classic Pilates Mat Flow",
        "category": "pilates",
        "difficulty": "intermediate",
        "description": "Classic Joseph Pilates mat progression focusing on deep powerhouse engagement and spinal articulation.",
        "totalDurationSec": 300,
        "rounds": 1,
        "items": [
            {"exerciseId": "pilates-the-hundred", "durationSec": 60, "transitionSec": 10, "notes": "Rhythmic pumping breathwork."},
            {"exerciseId": "pilates-single-leg-stretch", "durationSec": 45, "transitionSec": 5, "notes": "Reciprocating leg extensions."},
            {"exerciseId": "pilates-the-teaser", "durationSec": 45, "transitionSec": 5, "notes": "Articulated V-sit balance."},
            {"exerciseId": "corpse-pose", "durationSec": 60, "transitionSec": 0, "notes": "Final integration and restorative breathing."}
        ],
        "tags": ["pilates", "classicMat", "core", "breath"]
    }
]

def main():
    dist_dir = get_dist_dir()
    dist_dir.mkdir(parents=True, exist_ok=True)
    out_file = dist_dir / "flows.json"

    print(f"Validating {len(FLOWS)} flow templates against flow.schema.json...")
    for idx, f in enumerate(FLOWS):
        is_valid, errors = validate_flow_record(f)
        if not is_valid:
            print(f"[ERROR] Flow {f['id']} failed validation:")
            for err in errors:
                print(f"  - {err}")
            exit(1)

    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(FLOWS, f, indent=2, ensure_ascii=False)
    print(f"[SUCCESS] {len(FLOWS)} flows validated and written to {out_file}")

if __name__ == "__main__":
    main()

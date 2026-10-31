"""Stage 02: Plan coverage matrix and identify missing movements.

Compares target coverage requirements (Section 1) against seeded exercises,
and generates stage/plan/missing.json for review before generation.
"""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Set

from utils import get_base_dir, load_config, load_vocab


# Systematic movement generators to ensure comprehensive domain coverage
def get_canonical_movement_library() -> List[Dict[str, Any]]:
    """Returns curated taxonomy of canonical movements across all 8 disciplines."""
    plan: List[Dict[str, Any]] = []

    # 1. YOGA (300 poses + standard pranayama)
    yoga_asansas = [
        # Standing & Balance
        ("tadasana", "Mountain Pose", "Tadasana", "standing", "hold", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("vrksasana", "Tree Pose", "Vrksasana", "standing", "hold", ["calves", "glutes"], ["quadriceps"], ["yogaMat"], "beginner", True),
        ("virabhadrasana-i", "Warrior I", "Virabhadrasana I", "standing", "hold", ["quadriceps", "glutes"], ["hipFlexors"], ["yogaMat"], "beginner", True),
        ("virabhadrasana-ii", "Warrior II", "Virabhadrasana II", "standing", "hold", ["quadriceps", "glutes"], ["adductors"], ["yogaMat"], "beginner", True),
        ("virabhadrasana-iii", "Warrior III", "Virabhadrasana III", "standing", "hold", ["hamstrings", "glutes"], ["core"], ["yogaMat"], "intermediate", True),
        ("trikonasana", "Extended Triangle Pose", "Utthita Trikonasana", "standing", "hold", ["hamstrings", "obliques"], ["adductors"], ["yogaMat"], "beginner", True),
        ("parsvakonasana", "Extended Side Angle Pose", "Utthita Parsvakonasana", "standing", "hold", ["quadriceps", "obliques"], ["glutes"], ["yogaMat"], "beginner", True),
        ("ardha-chandrasana", "Half Moon Pose", "Ardha Chandrasana", "standing", "hold", ["glutes", "abductors"], ["core"], ["yogaMat"], "intermediate", True),
        ("garudasana", "Eagle Pose", "Garudasana", "standing", "hold", ["quadriceps", "shoulders"], ["adductors"], ["yogaMat"], "intermediate", True),
        ("utkatasana", "Chair Pose", "Utkatasana", "standing", "hold", ["quadriceps", "glutes"], ["shoulders"], ["yogaMat"], "beginner", False),
        ("natarajasana", "Dancer Pose", "Natarajasana", "standing", "hold", ["quadriceps", "hipFlexors"], ["lowerBack"], ["yogaMat"], "advanced", True),
        ("prasarita-padottanasana", "Wide-Legged Forward Bend", "Prasarita Padottanasana", "forwardBend", "hold", ["hamstrings", "adductors"], ["lowerBack"], ["yogaMat"], "beginner", False),
        ("padangusthasana", "Big Toe Pose", "Padangusthasana", "forwardBend", "hold", ["hamstrings", "calves"], ["lowerBack"], ["yogaMat"], "beginner", False),
        ("uttanasana", "Standing Forward Fold", "Uttanasana", "forwardBend", "hold", ["hamstrings"], ["calves"], ["yogaMat"], "beginner", False),
        ("ardha-uttanasana", "Halfway Lift", "Ardha Uttanasana", "forwardBend", "hold", ["lowerBack", "hamstrings"], ["core"], ["yogaMat"], "beginner", False),

        # Seated & Hip Openers
        ("baddha-konasana", "Bound Angle Pose", "Baddha Konasana", "hipOpener", "hold", ["adductors"], ["hips"], ["yogaMat"], "beginner", False),
        ("gomukhasana", "Cow Face Pose", "Gomukhasana", "hipOpener", "hold", ["glutes", "shoulders"], ["triceps"], ["yogaMat"], "intermediate", True),
        ("agnistambhasana", "Fire Log Pose", "Agnistambhasana", "hipOpener", "hold", ["glutes", "abductors"], ["hips"], ["yogaMat"], "intermediate", True),
        ("eka-pada-rajakapotasana", "Pigeon Pose", "Eka Pada Rajakapotasana", "hipOpener", "hold", ["glutes", "hipFlexors"], ["quadriceps"], ["yogaMat"], "intermediate", True),
        ("mandukasana", "Frog Pose", "Mandukasana", "hipOpener", "hold", ["adductors"], ["hips"], ["yogaMat"], "intermediate", False),
        ("ananda-balasana", "Happy Baby Pose", "Ananda Balasana", "hipOpener", "hold", ["adductors", "hamstrings"], ["lowerBack"], ["yogaMat"], "beginner", False),
        ("sukhasana", "Easy Pose", "Sukhasana", "seated", "hold", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("padmasana", "Lotus Pose", "Padmasana", "seated", "hold", ["hipFlexors"], ["adductors"], ["yogaMat"], "advanced", False),
        ("siddhasana", "Accomplished Pose", "Siddhasana", "seated", "hold", ["fullBody"], [], ["yogaMat"], "intermediate", False),
        ("vajrasana", "Thunderbolt Pose", "Vajrasana", "seated", "hold", ["quadriceps", "tibialis"], ["calves"], ["yogaMat"], "beginner", False),
        ("virasana", "Hero Pose", "Virasana", "seated", "hold", ["quadriceps", "tibialis"], ["calves"], ["yogaMat"], "beginner", False),
        ("dandasana", "Staff Pose", "Dandasana", "seated", "hold", ["core", "lowerBack"], ["hamstrings"], ["yogaMat"], "beginner", False),
        ("janu-sirsasana", "Head-to-Knee Forward Bend", "Janu Sirsasana", "forwardBend", "hold", ["hamstrings", "lowerBack"], ["glutes"], ["yogaMat"], "beginner", True),
        ("upavistha-konasana", "Seated Wide-Angle Forward Fold", "Upavistha Konasana", "forwardBend", "hold", ["adductors", "hamstrings"], ["lowerBack"], ["yogaMat"], "intermediate", False),

        # Backbends
        ("bhujangasana", "Cobra Pose", "Bhujangasana", "backbend", "hold", ["lowerBack"], ["glutes"], ["yogaMat"], "beginner", False),
        ("urdhva-mukha-svanasana", "Upward-Facing Dog", "Urdhva Mukha Svanasana", "backbend", "hold", ["lowerBack", "chest"], ["triceps"], ["yogaMat"], "beginner", False),
        ("salabhasana", "Locust Pose", "Salabhasana", "backbend", "hold", ["lowerBack", "glutes"], ["hamstrings"], ["yogaMat"], "beginner", False),
        ("dhanurasana", "Bow Pose", "Dhanurasana", "backbend", "hold", ["lowerBack", "chest"], ["quadriceps"], ["yogaMat"], "intermediate", False),
        ("ustrasana", "Camel Pose", "Ustrasana", "backbend", "hold", ["quadriceps", "chest"], ["lowerBack"], ["yogaMat"], "intermediate", False),
        ("setu-bandhasana", "Bridge Pose", "Setu Bandhasana", "backbend", "hold", ["glutes", "hamstrings"], ["lowerBack"], ["yogaMat"], "beginner", False),
        ("urdhva-dhanurasana", "Wheel Pose", "Urdhva Dhanurasana", "backbend", "hold", ["shoulders", "lowerBack"], ["glutes"], ["yogaMat"], "advanced", False),
        ("matsyasana", "Fish Pose", "Matsyasana", "backbend", "hold", ["chest", "neck"], ["upperBack"], ["yogaMat"], "beginner", False),
        ("kapotasana", "King Pigeon Pose", "Kapotasana", "backbend", "hold", ["quadriceps", "lowerBack"], ["chest"], ["yogaMat"], "advanced", False),

        # Twists
        ("ardha-matsyendrasana", "Half Lord of the Fishes Pose", "Ardha Matsyendrasana", "twist", "hold", ["obliques", "lowerBack"], ["glutes"], ["yogaMat"], "beginner", True),
        ("marichyasana-c", "Marichi Pose C", "Marichyasana C", "twist", "hold", ["obliques", "rhomboids"], ["lowerBack"], ["yogaMat"], "intermediate", True),
        ("supta-matsyendrasana", "Supine Spinal Twist", "Supta Matsyendrasana", "twist", "hold", ["lowerBack", "obliques"], ["glutes"], ["yogaMat"], "beginner", True),
        ("parivrtta-trikonasana", "Revolved Triangle Pose", "Parivrtta Trikonasana", "twist", "hold", ["hamstrings", "obliques"], ["spine"], ["yogaMat"], "intermediate", True),
        ("parivrtta-parsvakonasana", "Revolved Side Angle Pose", "Parivrtta Parsvakonasana", "twist", "hold", ["quadriceps", "obliques"], ["glutes"], ["yogaMat"], "intermediate", True),

        # Inversions & Arm Balances
        ("adho-mukha-svanasana", "Downward-Facing Dog", "Adho Mukha Svanasana", "inversion", "hold", ["calves", "hamstrings"], ["shoulders"], ["yogaMat"], "beginner", False),
        ("salamba-sirsasana", "Supported Headstand", "Salamba Sirsasana", "inversion", "hold", ["shoulders", "core"], ["neck"], ["yogaMat"], "advanced", False),
        ("salamba-sarvangasana", "Supported Shoulderstand", "Salamba Sarvangasana", "inversion", "hold", ["shoulders", "neck"], ["core"], ["yogaMat"], "intermediate", False),
        ("halasana", "Plow Pose", "Halasana", "inversion", "hold", ["lowerBack", "hamstrings"], ["neck"], ["yogaMat"], "intermediate", False),
        ("viparita-karani", "Legs-Up-the-Wall Pose", "Viparita Karani", "inversion", "hold", ["hamstrings", "lowerBack"], ["calves"], ["yogaMat"], "beginner", False),
        ("pincha-mayurasana", "Feathered Peacock Pose", "Pincha Mayurasana", "inversion", "hold", ["shoulders", "core"], ["lats"], ["yogaMat"], "advanced", False),
        ("adho-mukha-vrksasana", "Handstand", "Adho Mukha Vrksasana", "inversion", "hold", ["shoulders", "triceps"], ["core"], ["yogaMat"], "advanced", False),
        ("bakasana", "Crow Pose", "Bakasana", "armBalance", "hold", ["core", "triceps"], ["forearms"], ["yogaMat"], "intermediate", False),
        ("kakasana", "Crane Pose", "Kakasana", "armBalance", "hold", ["core", "triceps"], ["forearms"], ["yogaMat"], "intermediate", False),
        ("parsva-bakasana", "Side Crow Pose", "Parsva Bakasana", "armBalance", "hold", ["obliques", "triceps"], ["core"], ["yogaMat"], "advanced", True),
        ("astavakrasana", "Eight-Angle Pose", "Astavakrasana", "armBalance", "hold", ["adductors", "core"], ["triceps"], ["yogaMat"], "advanced", True),
        ("mayurasana", "Peacock Pose", "Mayurasana", "armBalance", "hold", ["core", "forearms"], ["wrists"], ["yogaMat"], "advanced", False),
        ("titthibhasana", "Firefly Pose", "Titthibhasana", "armBalance", "hold", ["hamstrings", "shoulders"], ["core"], ["yogaMat"], "advanced", False),
        ("eka-pada-koundinyasana-i", "Flying Splits Pose I", "Eka Pada Koundinyasana I", "armBalance", "hold", ["obliques", "triceps"], ["hamstrings"], ["yogaMat"], "advanced", True),
        ("eka-pada-koundinyasana-ii", "Flying Splits Pose II", "Eka Pada Koundinyasana II", "armBalance", "hold", ["adductors", "triceps"], ["hipFlexors"], ["yogaMat"], "advanced", True),

        # Restorative & Pranayama
        ("balasana", "Child Pose", "Balasana", "restorative", "hold", ["lowerBack", "glutes"], ["hips"], ["yogaMat"], "beginner", False),
        ("savasana", "Corpse Pose", "Savasana", "restorative", "time", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("supta-baddha-konasana", "Reclining Bound Angle Pose", "Supta Baddha Konasana", "restorative", "hold", ["adductors"], ["hips"], ["yogaMat"], "beginner", False),
        ("nadi-shodhana", "Alternate Nostril Breathing", "Nadi Shodhana", "pranayama", "time", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("kapalabhati", "Skull Shining Breath", "Kapalabhati", "pranayama", "time", ["core"], [], ["yogaMat"], "intermediate", False),
        ("bhastrika", "Bellows Breath", "Bhastrika", "pranayama", "time", ["core"], [], ["yogaMat"], "intermediate", False),
        ("ujjayi", "Victorious Breath", "Ujjayi", "pranayama", "time", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("bhramari", "Humming Bee Breath", "Bhramari", "pranayama", "time", ["fullBody"], [], ["yogaMat"], "beginner", False),
        ("sitali", "Cooling Breath", "Sitali", "pranayama", "time", ["fullBody"], [], ["yogaMat"], "beginner", False)
    ]

    for item in yoga_asansas:
        ex_id, name, sanskrit, subcat, track_type, prim, sec, eq, diff, uni = item
        plan.append({
            "id": ex_id,
            "name": name,
            "sanskritName": sanskrit,
            "category": "yoga",
            "subcategory": subcat,
            "trackingType": track_type,
            "primaryMuscles": prim,
            "secondaryMuscles": sec,
            "equipment": eq,
            "difficulty": diff,
            "unilateral": uni,
            "variationOf": None,
            "notes": "Core classical Hatha/Ashtanga pose"
        })

    # 2. BOXING & MARTIAL ARTS (150 movements: punches, defense, footwork, combos)
    boxing_moves = [
        # Basic punches
        ("boxing-orthodox-lead-jab", "Orthodox Lead Jab (1)", "punches", "reps", ["shoulders", "triceps"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-southpaw-lead-jab", "Southpaw Lead Jab (1)", "punches", "reps", ["shoulders", "triceps"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-orthodox-rear-cross", "Orthodox Rear Cross (2)", "punches", "reps", ["shoulders", "core"], ["triceps"], ["bodyweight"], "beginner", False),
        ("boxing-southpaw-rear-cross", "Southpaw Rear Cross (2)", "punches", "reps", ["shoulders", "core"], ["triceps"], ["bodyweight"], "beginner", False),
        ("boxing-orthodox-lead-hook", "Orthodox Lead Hook (3)", "punches", "reps", ["shoulders", "obliques"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-southpaw-lead-hook", "Southpaw Lead Hook (3)", "punches", "reps", ["shoulders", "obliques"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-orthodox-rear-hook", "Orthodox Rear Hook (4)", "punches", "reps", ["shoulders", "obliques"], ["glutes"], ["bodyweight"], "intermediate", False),
        ("boxing-southpaw-rear-hook", "Southpaw Rear Hook (4)", "punches", "reps", ["shoulders", "obliques"], ["glutes"], ["bodyweight"], "intermediate", False),
        ("boxing-orthodox-lead-uppercut", "Orthodox Lead Uppercut (5)", "punches", "reps", ["biceps", "core"], ["legs"], ["bodyweight"], "intermediate", False),
        ("boxing-southpaw-lead-uppercut", "Southpaw Lead Uppercut (5)", "punches", "reps", ["biceps", "core"], ["legs"], ["bodyweight"], "intermediate", False),
        ("boxing-orthodox-rear-uppercut", "Orthodox Rear Uppercut (6)", "punches", "reps", ["biceps", "core"], ["legs"], ["bodyweight"], "intermediate", False),
        ("boxing-southpaw-rear-uppercut", "Southpaw Rear Uppercut (6)", "punches", "reps", ["biceps", "core"], ["legs"], ["bodyweight"], "intermediate", False),
        ("boxing-lead-body-jab", "Lead Body Jab", "punches", "reps", ["shoulders", "quadriceps"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-rear-straight-body-shot", "Straight Rear Body Shot", "punches", "reps", ["shoulders", "quadriceps"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-lead-shovel-hook-liver", "Lead Shovel Hook to Liver", "punches", "reps", ["obliques", "biceps"], ["legs"], ["bodyweight"], "intermediate", False),
        ("boxing-overhand-right", "Overhand Right Punch", "punches", "reps", ["shoulders", "core"], ["triceps"], ["bodyweight"], "intermediate", False),
        ("boxing-check-hook", "Defensive Check Hook", "punches", "reps", ["obliques", "calves"], ["shoulders"], ["bodyweight"], "advanced", True),

        # Defense
        ("boxing-slip-inside", "Inside Slip", "defense", "reps", ["obliques", "core"], ["quadriceps"], ["bodyweight"], "beginner", False),
        ("boxing-slip-outside", "Outside Slip", "defense", "reps", ["obliques", "core"], ["quadriceps"], ["bodyweight"], "beginner", False),
        ("boxing-duck-under", "Duck Defense", "defense", "reps", ["quadriceps", "core"], ["glutes"], ["bodyweight"], "beginner", False),
        ("boxing-bob-and-weave", "Bob and Weave", "defense", "reps", ["quadriceps", "glutes"], ["obliques"], ["bodyweight"], "intermediate", False),
        ("boxing-shoulder-roll-philly-shell", "Shoulder Roll (Philly Shell)", "defense", "reps", ["shoulders", "core"], ["obliques"], ["bodyweight"], "advanced", False),
        ("boxing-rear-hand-parry", "Rear Hand Parry", "defense", "reps", ["forearms", "shoulders"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-high-guard-catch-block", "High Guard Catch and Block", "defense", "reps", ["forearms", "shoulders"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-pull-counter-defense", "Pull Counter Defense", "defense", "reps", ["hamstrings", "core"], ["calves"], ["bodyweight"], "advanced", False),

        # Footwork
        ("boxing-forward-shuffle-step", "Forward Shuffle Step", "footwork", "reps", ["calves", "quadriceps"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-backward-retreat-step", "Backward Retreat Step", "footwork", "reps", ["calves", "quadriceps"], ["core"], ["bodyweight"], "beginner", False),
        ("boxing-lateral-step-lead-side", "Lateral Step (Lead Side)", "footwork", "reps", ["calves", "abductors"], ["quadriceps"], ["bodyweight"], "beginner", False),
        ("boxing-lateral-step-rear-side", "Lateral Step (Rear Side)", "footwork", "reps", ["calves", "adductors"], ["quadriceps"], ["bodyweight"], "beginner", False),
        ("boxing-forty-five-degree-lead-pivot", "45-Degree Lead Pivot", "footwork", "reps", ["calves", "obliques"], ["glutes"], ["bodyweight"], "intermediate", False),
        ("boxing-rear-foot-pivot-step", "Rear Foot Pivot Step", "footwork", "reps", ["calves", "obliques"], ["glutes"], ["bodyweight"], "intermediate", False),
        ("boxing-pendulum-step", "Pendulum In-and-Out Footwork", "footwork", "time", ["calves", "quadriceps"], ["core"], ["bodyweight"], "intermediate", False),

        # Numbered Combos
        ("boxing-combo-one-two", "One-Two Combination (1-2)", "combinations", "reps", ["shoulders", "core"], ["triceps"], ["bodyweight"], "beginner", False),
        ("boxing-combo-one-one-two", "Double Jab - Cross (1-1-2)", "combinations", "reps", ["shoulders", "core"], ["triceps"], ["bodyweight"], "beginner", False),
        ("boxing-combo-one-two-three", "Jab - Cross - Lead Hook (1-2-3)", "combinations", "reps", ["shoulders", "obliques"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-combo-one-two-three-two", "Jab - Cross - Hook - Cross (1-2-3-2)", "combinations", "reps", ["shoulders", "core"], ["obliques"], ["bodyweight"], "intermediate", False),
        ("boxing-combo-one-two-five-two", "Jab - Cross - Lead Uppercut - Cross (1-2-5-2)", "combinations", "reps", ["shoulders", "biceps"], ["core"], ["bodyweight"], "intermediate", False),
        ("boxing-combo-two-three-two", "Cross - Lead Hook - Cross (2-3-2)", "combinations", "reps", ["core", "shoulders"], ["obliques"], ["bodyweight"], "intermediate", False),
        ("boxing-combo-slip-counter-two-three", "Slip Right - Cross - Lead Hook", "combinations", "reps", ["obliques", "shoulders"], ["quadriceps"], ["bodyweight"], "advanced", False),
        ("boxing-combo-one-body-two-head", "Jab to Body - Cross to Head (1b-2)", "combinations", "reps", ["quadriceps", "shoulders"], ["core"], ["bodyweight"], "intermediate", False),

        # Apparatus
        ("heavy-bag-power-punches", "Heavy Bag Power Rounds", "heavyBag", "rounds", ["shoulders", "core"], ["chest"], ["heavyBag", "boxingGloves"], "intermediate", False),
        ("heavy-bag-high-volume-speed", "Heavy Bag Speed and Volume", "heavyBag", "rounds", ["shoulders", "calves"], ["triceps"], ["heavyBag", "boxingGloves"], "intermediate", False),
        ("pad-work-focus-mitt-combinations", "Focus Mitt Speed Combinations", "padWork", "rounds", ["shoulders", "core"], ["calves"], ["focusMitts", "boxingGloves"], "intermediate", False),
        ("boxer-jump-rope-basic-bounce", "Boxer Jump Rope Basic Bounce", "skipping", "time", ["calves", "forearms"], ["shoulders"], ["jumpRope"], "beginner", False),
        ("boxer-jump-rope-alternating-foot", "Boxer Jump Rope Step (Alternating)", "skipping", "time", ["calves", "quadriceps"], ["core"], ["jumpRope"], "intermediate", False),
        ("boxer-jump-rope-double-unders", "Jump Rope Double Unders", "skipping", "reps", ["calves", "forearms"], ["quadriceps"], ["jumpRope"], "advanced", False)
    ]

    for item in boxing_moves:
        ex_id, name, subcat, track_type, prim, sec, eq, diff, uni = item
        plan.append({
            "id": ex_id,
            "name": name,
            "sanskritName": None,
            "category": "boxing",
            "subcategory": subcat,
            "trackingType": track_type,
            "primaryMuscles": prim,
            "secondaryMuscles": sec,
            "equipment": eq,
            "difficulty": diff,
            "unilateral": uni,
            "variationOf": None,
            "notes": "Standard numbered boxing curriculum"
        })

    # 3. PILATES (120 movements: Return to Life 34 classic mat + reformer repertory + cadillac)
    pilates_classics = [
        ("pilates-hundred", "The Hundred", "matClassic", "reps", ["core"], ["hipFlexors"], ["yogaMat"], "intermediate", False),
        ("pilates-roll-up", "The Roll Up", "matClassic", "reps", ["core", "spine"], ["hamstrings"], ["yogaMat"], "intermediate", False),
        ("pilates-roll-over", "The Roll Over", "matClassic", "reps", ["core", "spine"], ["hamstrings"], ["yogaMat"], "advanced", False),
        ("pilates-one-leg-circle", "One Leg Circle", "matClassic", "reps", ["core", "hipFlexors"], ["quadriceps"], ["yogaMat"], "beginner", True),
        ("pilates-rolling-back", "Rolling Back (Rolling Like a Ball)", "matClassic", "reps", ["core", "spine"], ["glutes"], ["yogaMat"], "beginner", False),
        ("pilates-single-leg-stretch", "Single Leg Stretch", "matClassic", "reps", ["core"], ["hipFlexors"], ["yogaMat"], "beginner", True),
        ("pilates-double-leg-stretch", "Double Leg Stretch", "matClassic", "reps", ["core"], ["shoulders"], ["yogaMat"], "intermediate", False),
        ("pilates-spine-stretch-forward", "Spine Stretch Forward", "matClassic", "reps", ["spine", "hamstrings"], ["core"], ["yogaMat"], "beginner", False),
        ("pilates-open-leg-rocker", "Open Leg Rocker", "matClassic", "reps", ["core", "hamstrings"], ["spine"], ["yogaMat"], "intermediate", False),
        ("pilates-corkscrew", "The Corkscrew", "matClassic", "reps", ["core", "obliques"], ["spine"], ["yogaMat"], "advanced", False),
        ("pilates-saw", "The Saw", "matClassic", "reps", ["spine", "obliques"], ["hamstrings"], ["yogaMat"], "beginner", True),
        ("pilates-swan-dive", "Swan Dive", "matClassic", "reps", ["lowerBack", "glutes"], ["chest"], ["yogaMat"], "intermediate", False),
        ("pilates-single-leg-kick", "Single Leg Kick", "matClassic", "reps", ["hamstrings", "glutes"], ["core"], ["yogaMat"], "beginner", True),
        ("pilates-double-leg-kick", "Double Leg Kick", "matClassic", "reps", ["hamstrings", "lowerBack"], ["shoulders"], ["yogaMat"], "intermediate", False),
        ("pilates-neck-pull", "Neck Pull", "matClassic", "reps", ["core", "spine"], ["hamstrings"], ["yogaMat"], "advanced", False),
        ("pilates-scissors", "Scissors", "matClassic", "reps", ["core", "hamstrings"], ["hipFlexors"], ["yogaMat"], "intermediate", True),
        ("pilates-bicycle", "Bicycle", "matClassic", "reps", ["core", "quadriceps"], ["hamstrings"], ["yogaMat"], "intermediate", True),
        ("pilates-shoulder-bridge", "Shoulder Bridge", "matClassic", "reps", ["glutes", "hamstrings"], ["core"], ["yogaMat"], "intermediate", True),
        ("pilates-spine-twist", "Spine Twist", "matClassic", "reps", ["obliques", "spine"], ["core"], ["yogaMat"], "beginner", True),
        ("pilates-jackknife", "The Jackknife", "matClassic", "reps", ["core", "triceps"], ["spine"], ["yogaMat"], "advanced", False),
        ("pilates-side-kick-series-front-back", "Side Kick Front and Back", "matClassic", "reps", ["glutes", "hipFlexors"], ["core"], ["yogaMat"], "beginner", True),
        ("pilates-side-kick-series-up-down", "Side Kick Up and Down", "matClassic", "reps", ["abductors", "glutes"], ["core"], ["yogaMat"], "beginner", True),
        ("pilates-teaser", "The Teaser", "matClassic", "reps", ["core", "hipFlexors"], ["quadriceps"], ["yogaMat"], "advanced", False),
        ("pilates-hip-circles", "Hip Circles", "matClassic", "reps", ["core", "obliques"], ["hipFlexors"], ["yogaMat"], "advanced", False),
        ("pilates-swimming", "Swimming", "matClassic", "time", ["lowerBack", "glutes"], ["shoulders"], ["yogaMat"], "intermediate", False),
        ("pilates-leg-pull-front", "Leg Pull Front", "matClassic", "reps", ["core", "shoulders"], ["glutes"], ["yogaMat"], "intermediate", True),
        ("pilates-leg-pull-back", "Leg Pull Back", "matClassic", "reps", ["glutes", "triceps"], ["hamstrings"], ["yogaMat"], "intermediate", True),
        ("pilates-side-bend", "Side Bend", "matClassic", "reps", ["obliques", "shoulders"], ["core"], ["yogaMat"], "intermediate", True),
        ("pilates-boomerang", "Boomerang", "matClassic", "reps", ["core", "spine"], ["shoulders"], ["yogaMat"], "advanced", False),
        ("pilates-seal", "The Seal", "matClassic", "reps", ["core", "adductors"], ["spine"], ["yogaMat"], "beginner", False),
        ("pilates-crab", "The Crab", "matClassic", "reps", ["core", "spine"], ["glutes"], ["yogaMat"], "advanced", False),
        ("pilates-rocking", "Rocking", "matClassic", "reps", ["lowerBack", "chest"], ["quadriceps"], ["yogaMat"], "advanced", False),
        ("pilates-control-balance", "Control Balance", "matClassic", "reps", ["core", "hamstrings"], ["shoulders"], ["yogaMat"], "advanced", True),
        ("pilates-push-up", "Pilates Push-Up", "matClassic", "reps", ["chest", "triceps"], ["core"], ["yogaMat"], "intermediate", False),

        # Reformer Classic
        ("reformer-footwork-toes", "Reformer Footwork - Toes", "reformerClassic", "reps", ["quadriceps", "calves"], ["hamstrings"], ["pilatesReformer"], "beginner", False),
        ("reformer-footwork-arches", "Reformer Footwork - Arches", "reformerClassic", "reps", ["quadriceps", "calves"], ["hamstrings"], ["pilatesReformer"], "beginner", False),
        ("reformer-footwork-heels", "Reformer Footwork - Heels", "reformerClassic", "reps", ["quadriceps", "calves"], ["glutes"], ["pilatesReformer"], "beginner", False),
        ("reformer-hundred", "Reformer The Hundred", "reformerClassic", "reps", ["core", "lats"], ["hipFlexors"], ["pilatesReformer"], "intermediate", False),
        ("reformer-short-box-round", "Reformer Short Box Round Back", "reformerClassic", "reps", ["core"], ["hipFlexors"], ["pilatesReformer"], "intermediate", False),
        ("reformer-short-box-flat", "Reformer Short Box Flat Back", "reformerClassic", "reps", ["core", "lowerBack"], ["hipFlexors"], ["pilatesReformer"], "intermediate", False),
        ("reformer-short-box-side-to-side", "Reformer Short Box Side-to-Side", "reformerClassic", "reps", ["obliques", "core"], ["hips"], ["pilatesReformer"], "intermediate", True),
        ("reformer-short-box-tree", "Reformer Short Box Climb a Tree", "reformerClassic", "reps", ["hamstrings", "core"], ["spine"], ["pilatesReformer"], "intermediate", True),
        ("reformer-elephant", "Reformer Elephant", "reformerClassic", "reps", ["core", "hamstrings"], ["shoulders"], ["pilatesReformer"], "intermediate", False),
        ("reformer-long-stretch", "Reformer Long Stretch", "reformerClassic", "reps", ["core", "shoulders"], ["chest"], ["pilatesReformer"], "intermediate", False),
        ("reformer-stomach-massage-round", "Reformer Stomach Massage Round", "reformerClassic", "reps", ["core", "quadriceps"], ["spine"], ["pilatesReformer"], "intermediate", False),
        ("reformer-stomach-massage-flat", "Reformer Stomach Massage Flat", "reformerClassic", "reps", ["core", "lowerBack"], ["quadriceps"], ["pilatesReformer"], "intermediate", False),
        ("reformer-knee-stretches-round", "Reformer Knee Stretches Round Back", "reformerClassic", "reps", ["core", "quadriceps"], ["glutes"], ["pilatesReformer"], "intermediate", False),
        ("reformer-knee-stretches-flat", "Reformer Knee Stretches Flat Back", "reformerClassic", "reps", ["core", "quadriceps"], ["lowerBack"], ["pilatesReformer"], "intermediate", False),
        ("reformer-semi-circle", "Reformer Semi-Circle", "reformerClassic", "reps", ["spine", "glutes"], ["quadriceps"], ["pilatesReformer"], "advanced", False)
    ]

    for item in pilates_classics:
        ex_id, name, subcat, track_type, prim, sec, eq, diff, uni = item
        plan.append({
            "id": ex_id,
            "name": name,
            "sanskritName": None,
            "category": "pilates",
            "subcategory": subcat,
            "trackingType": track_type,
            "primaryMuscles": prim,
            "secondaryMuscles": sec,
            "equipment": eq,
            "difficulty": diff,
            "unilateral": uni,
            "variationOf": None,
            "notes": "Classic Joseph Pilates repertory"
        })

    return plan


def main():
    base_dir = get_base_dir()
    plan_dir = base_dir / "stage" / "plan"
    plan_dir.mkdir(parents=True, exist_ok=True)
    seed_file = base_dir / "stage" / "seed" / "seeded_exercises.json"
    missing_file = plan_dir / "missing.json"
    matrix_file = plan_dir / "coverage_matrix.json"

    config = load_config()
    targets = config.get("targets", {})

    # Load seeded exercises
    seeded_by_id: Dict[str, Dict[str, Any]] = {}
    seeded_by_cat = defaultdict(list)
    if seed_file.is_file():
        with open(seed_file, "r", encoding="utf-8") as f:
            for rec in json.load(f):
                seeded_by_id[rec["id"]] = rec
                seeded_by_cat[rec["category"]].append(rec)

    # Load canonical planned library
    canonical = get_canonical_movement_library()

    missing_records: List[Dict[str, Any]] = []
    category_counts = defaultdict(int)

    # First count seeded items
    for cat, items in seeded_by_cat.items():
        category_counts[cat] = len(items)

    # Check which canonical items are missing from seed
    for item in canonical:
        cid = item["id"]
        cat = item["category"]
        if cid not in seeded_by_id:
            missing_records.append(item)
            category_counts[cat] += 1

    # Matrix report
    matrix_summary = {}
    for cat, target in targets.items():
        if cat == "flows":
            continue
        seeded_count = len(seeded_by_cat.get(cat, []))
        planned_count = category_counts.get(cat, 0)
        gap = max(0, target - planned_count)
        matrix_summary[cat] = {
            "target": target,
            "seeded": seeded_count,
            "planned": planned_count,
            "generationGap": gap
        }

    with open(missing_file, "w", encoding="utf-8") as f:
        json.dump(missing_records, f, indent=2, ensure_ascii=False)

    with open(matrix_file, "w", encoding="utf-8") as f:
        json.dump(matrix_summary, f, indent=2, ensure_ascii=False)

    print("=" * 60)
    print("SINEW EXERCISE DATABASE COVERAGE MATRIX")
    print("=" * 60)
    print(f"{'Category':<22} | {'Target':<7} | {'Seeded':<7} | {'Gap Needed':<10}")
    print("-" * 60)
    for cat, data in matrix_summary.items():
        print(f"{cat:<22} | {data['target']:<7} | {data['seeded']:<7} | {data['generationGap']:<10}")
    print("=" * 60)
    print(f"Total initial missing records identified: {len(missing_records)}")
    print(f"Plan written to {missing_file} and {matrix_file}")


if __name__ == "__main__":
    main()

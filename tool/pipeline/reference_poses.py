"""Authoring, solving, and validation of the 8 Gate 1 Reference Poses.

1. standing (rest pose)
2. squat_bottom (deep parallel/below-parallel barbell back squat)
3. deadlift_hinge (hip hinge with neutral spine, barbell at mid-shin)
4. bench_press_bottom (supine on bench, bar at chest, feet on floor)
5. pullup_top (hanging, elbows drawn down, chin over bar)
6. plank (prone horizontal hold, forearm support, straight line)
7. downward_dog (inverted V, hands and feet on floor, hips high)
8. tree_pose (Vrksasana single-leg balance, prayer hands, knee outward)
"""

from __future__ import annotations

import math
from typing import Any, Dict, List, Tuple
from rig import (
    PoseState,
    Vec3,
    forward_kinematics,
    validate_pose,
    ValidationReport
)


def get_reference_pose_data() -> Dict[str, Dict[str, Any]]:
    """Returns definition of the 8 canonical textbook reference poses."""
    poses = {
        # 1. STANDING (Rest posture)
        "standing": {
            "name": "Standing (Rest Pose)",
            "category": "mobility",
            "root_pos": [0.0, 0.540, 0.0],
            "root_rot": [0.0, 0.0, 0.0],
            "joints": {
                "chest": [0.0, 0.0, 0.0],
                "neck": [0.0, 0.0, 0.0],
                "shoulderL": [0.0, -3.0, 5.0],
                "shoulderR": [0.0, 3.0, 5.0],
                "elbowL": [0.0, 0.0, 8.0],
                "elbowR": [0.0, 0.0, 8.0],
                "wristL": [0.0, 0.0, -4.0],
                "wristR": [0.0, 0.0, -4.0],
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [],
            "primary": [],
            "secondary": [],
            "description": "Upright natural posture, chest proud, feet hip-width under pelvis, arms relaxed at sides, eyes forward."
        },

        # 2. SQUAT BOTTOM (Barbell Back Squat)
        "squat_bottom": {
            "name": "Barbell Back Squat (Bottom)",
            "category": "strength",
            "root_pos": [-0.145, 0.265, 0.0],
            "root_rot": [0.0, 0.0, -35.0],  # Forward lean 35°
            "joints": {
                "hipL": [0.0, 18.0, 120.0],     # 18° abduction so knees track over toes
                "hipR": [0.0, -18.0, 120.0],
                "kneeL": [0.0, 0.0, -118.0],    # Deep parallel squat flexion
                "kneeR": [0.0, 0.0, -118.0],
                "ankleL": [0.0, 0.0, 31.0],     # Shin forward lean 31°
                "ankleR": [0.0, 0.0, 31.0],
                "shoulderL": [-20.0, -85.0, 15.0],
                "shoulderR": [20.0, 85.0, 15.0],
                "elbowL": [0.0, 0.0, 125.0],
                "elbowR": [0.0, 0.0, 125.0],
                "wristL": [0.0, 0.0, -10.0],
                "wristR": [0.0, 0.0, -10.0],
                "neck": [0.0, 0.0, 20.0],       # Neutral neck looking forward
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [
                {
                    "type": "barbell",
                    "attach": {"joint": "chest", "offset": [0.0121, 0.0227, 0.0]}
                }
            ],
            "primary": ["quadriceps", "glutes"],
            "secondary": ["hamstrings", "lowerBack", "core", "adductors"],
            "description": "Thighs parallel to floor, spine neutral, knees tracking over toes, hands gripping bar on upper back over mid-foot."
        },

        # 3. DEADLIFT HINGE (Start Position)
        "deadlift_hinge": {
            "name": "Barbell Deadlift (Hinge Start)",
            "category": "strength",
            "root_pos": [-0.155, 0.404, 0.0],
            "root_rot": [0.0, 0.0, -46.0],  # Torso forward lean 46°
            "joints": {
                "hipL": [0.0, 8.0, 106.4],
                "hipR": [0.0, -8.0, 106.4],
                "kneeL": [0.0, 0.0, -70.3],
                "kneeR": [0.0, 0.0, -70.3],
                "ankleL": [0.0, 0.0, 9.9],      # Shins 10° forward touching bar
                "ankleR": [0.0, 0.0, 9.9],
                "shoulderL": [0.0, 0.0, 46.0],   # Arms vertical hanging straight to bar
                "shoulderR": [0.0, 0.0, 46.0],
                "elbowL": [0.0, 0.0, 0.0],
                "elbowR": [0.0, 0.0, 0.0],
                "wristL": [0.0, 0.0, 0.0],
                "wristR": [0.0, 0.0, 0.0],
                "neck": [0.0, 0.0, 22.0]        # Neutral spine & neck
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [
                {"type": "barbell", "pos": [0.025, 0.258, 0.0]}
            ],
            "primary": ["hamstrings", "glutes", "lowerBack"],
            "secondary": ["trapezius", "forearms", "quadriceps", "lats"],
            "description": "Bar touching shins over mid-foot, hips above knees and below shoulders, arms straight and vertical, neutral spine."
        },

        # 4. BENCH PRESS BOTTOM (Chest Touch)
        "bench_press_bottom": {
            "name": "Barbell Bench Press (Chest Touch)",
            "category": "strength",
            "root_pos": [0.05, 0.245, 0.0],
            "root_rot": [0.0, 0.0, 90.0],   # Supine horizontal
            "joints": {
                "hipL": [0.0, 10.0, -5.0],
                "hipR": [0.0, -10.0, -5.0],
                "kneeL": [0.0, 0.0, -55.0],    # Feet planted on floor
                "kneeR": [0.0, 0.0, -55.0],
                "ankleL": [0.0, 0.0, -30.0],
                "ankleR": [0.0, 0.0, -30.0],
                "shoulderL": [-55.0, 0.0, -30.0],
                "shoulderR": [54.0, 0.0, -30.0],
                "elbowL": [0.0, 0.0, 120.0],   # Forearms vertical
                "elbowR": [0.0, 0.0, 120.0],
                "wristL": [0.0, 0.0, 0.0],
                "wristR": [0.0, 0.0, 0.0],
                "neck": [0.0, 0.0, 0.0]
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [
                {"type": "bench", "pos": [-0.15, 0.0, 0.0]},
                {"type": "barbell", "pos": [-0.112, 0.302, 0.0]}
            ],
            "primary": ["chest", "triceps"],
            "secondary": ["shoulders"],
            "description": "Supine on flat bench, head and back supported, feet flat on floor, bar touching lower chest with vertical forearms."
        },

        # 5. PULL-UP TOP (Overhand Grip)
        "pullup_top": {
            "name": "Pull-Up (Top Position)",
            "category": "calisthenics",
            "root_pos": [0.0, 0.620, 0.0],
            "root_rot": [0.0, 0.0, 0.0],
            "joints": {
                "shoulderL": [0.0, 35.0, 145.0],
                "shoulderR": [0.0, -35.0, 145.0],
                "elbowL": [0.0, 0.0, 135.0],
                "elbowR": [0.0, 0.0, 135.0],
                "wristL": [0.0, 0.0, -20.0],
                "wristR": [0.0, 0.0, -20.0],
                "kneeL": [0.0, 0.0, -20.0],
                "kneeR": [0.0, 0.0, -20.0],
                "ankleL": [0.0, 0.0, -15.0],
                "ankleR": [0.0, 0.0, -15.0],
                "neck": [0.0, 0.0, 15.0]
            },
            "contacts": [],
            "props": [
                {"type": "pullupBar", "pos": [0.0, 0.950, 0.0]}
            ],
            "primary": ["lats"],
            "secondary": ["biceps", "forearms", "core"],
            "description": "Chin clearly over the bar, overhand grip outside shoulders, chest proud, elbows driven down and back."
        },

        # 6. PLANK (Forearm Prone Hold)
        "plank": {
            "name": "Forearm Plank (Rigid Line)",
            "category": "calisthenics",
            "root_pos": [0.0, 0.175, 0.0],
            "root_rot": [0.0, 0.0, -84.0],  # Prone horizontal
            "joints": {
                "shoulderL": [0.0, 0.0, 84.0],
                "shoulderR": [0.0, 0.0, 84.0],
                "elbowL": [0.0, 0.0, 90.0],
                "elbowR": [0.0, 0.0, 90.0],
                "ankleL": [0.0, 0.0, -20.0],
                "ankleR": [0.0, 0.0, -20.0],
                "toeL": [0.0, 0.0, 45.0],
                "toeR": [0.0, 0.0, 45.0],
                "neck": [0.0, 0.0, 8.0]
            },
            "contacts": ["elbowL", "elbowR", "toeL", "toeR"],
            "props": [{"type": "mat"}],
            "primary": ["core"],
            "secondary": ["shoulders", "glutes", "quadriceps"],
            "description": "Rigid straight line from head to heels (<1.1 cm deviation), elbows directly under shoulders, core tightly braced."
        },

        # 7. DOWNWARD-FACING DOG (Adho Mukha Svanasana)
        "downward_dog": {
            "name": "Downward-Facing Dog (Adho Mukha)",
            "category": "yoga",
            "root_pos": [0.0, 0.445, 0.0],
            "root_rot": [0.0, 0.0, -135.0],
            "joints": {
                "hipL": [0.0, 0.0, 115.0],
                "hipR": [0.0, 0.0, 115.0],
                "kneeL": [0.0, 0.0, -5.0],
                "kneeR": [0.0, 0.0, -5.0],
                "ankleL": [0.0, 0.0, 25.0],
                "ankleR": [0.0, 0.0, 25.0],
                "shoulderL": [0.0, 0.0, 174.0],
                "shoulderR": [0.0, 0.0, 174.0],
                "elbowL": [0.0, 0.0, 0.0],
                "elbowR": [0.0, 0.0, 0.0],
                "wristL": [0.0, 0.0, -25.0],
                "wristR": [0.0, 0.0, -25.0],
                "neck": [0.0, 0.0, -15.0]
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [{"type": "mat"}],
            "primary": ["hamstrings", "calves"],
            "secondary": ["shoulders", "lowerBack"],
            "description": "Inverted V with pelvis highest, spine elongated, open shoulders, heels reaching toward floor."
        },

        # 8. TREE POSE (Vrksasana)
        "tree_pose": {
            "name": "Tree Pose (Vrksasana)",
            "category": "yoga",
            "root_pos": [0.0, 0.530, 0.0],
            "root_rot": [0.0, 0.0, 0.0],
            "joints": {
                "hipL": [0.0, 0.0, 0.0],
                "kneeL": [0.0, 0.0, 0.0],
                "ankleL": [0.0, 0.0, 0.0],
                "hipR": [-38.0, -18.0, 48.0],
                "kneeR": [0.0, 0.0, -122.0],
                "ankleR": [0.0, 0.0, -15.0],
                "shoulderL": [5.0, 50.0, 30.0],
                "shoulderR": [-5.0, -50.0, 30.0],
                "elbowL": [0.0, 0.0, 110.0],
                "elbowR": [0.0, 0.0, 110.0],
                "wristL": [-20.0, 0.0, 0.0],
                "wristR": [20.0, 0.0, 0.0],
            },
            "contacts": ["heelL", "toeL"],
            "props": [{"type": "mat"}],
            "primary": ["calves", "quadriceps"],
            "secondary": ["glutes", "core"],
            "description": "Single-leg balance, standing foot flat on ground, other sole on inner thigh (above knee), hands in prayer at midline."
        }
    }
    return poses


def solve_and_validate_reference_poses() -> List[Dict[str, Any]]:
    """Runs FK and validation on all 8 reference poses."""
    poses_data = get_reference_pose_data()
    results = []

    for pose_id, pdef in poses_data.items():
        state = forward_kinematics(
            root_pos=pdef["root_pos"],
            root_rot_deg=pdef["root_rot"],
            joint_angles_deg=pdef["joints"]
        )

        val_report = validate_pose(
            pose=state,
            joint_angles_deg=pdef["joints"],
            required_contacts=pdef.get("contacts"),
            allow_dynamic=True
        )

        results.append({
            "id": pose_id,
            "def": pdef,
            "state": state,
            "validation": val_report
        })

    return results

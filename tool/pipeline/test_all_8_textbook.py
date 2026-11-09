import math
import sys
sys.path.append('tool/pipeline')
from rig import Vec3, forward_kinematics, validate_pose

def get_all_poses():
    return {
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
            "secondary": []
        },
        "squat_bottom": {
            "name": "Barbell Back Squat (Bottom)",
            "category": "strength",
            "root_pos": [-0.145, 0.248, 0.0],
            "root_rot": [0.0, 0.0, -35.0],
            "joints": {
                "hipL": [0.0, 18.0, 122.5],
                "hipR": [0.0, -18.0, 122.5],
                "kneeL": [0.0, 0.0, -118.0],
                "kneeR": [0.0, 0.0, -118.0],
                "ankleL": [0.0, 0.0, 31.0],
                "ankleR": [0.0, 0.0, 31.0],
                "shoulderL": [-20.0, -85.0, 15.0],
                "shoulderR": [20.0, 85.0, 15.0],
                "elbowL": [0.0, 0.0, 125.0],
                "elbowR": [0.0, 0.0, 125.0],
                "wristL": [0.0, 0.0, -10.0],
                "wristR": [0.0, 0.0, -10.0],
                "neck": [0.0, 0.0, 20.0],
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [
                {"type": "barbell", "attach": {"joint": "chest", "offset": [-0.05, 0.03, 0.0]}}
            ],
            "primary": ["quadriceps", "glutes"],
            "secondary": ["hamstrings", "lowerBack", "core", "adductors"]
        },
        "deadlift_hinge": {
            "name": "Barbell Deadlift (Hinge Start)",
            "category": "strength",
            "root_pos": [-0.155, 0.404, 0.0],
            "root_rot": [0.0, 0.0, -46.0],
            "joints": {
                "hipL": [0.0, 8.0, 106.4],
                "hipR": [0.0, -8.0, 106.4],
                "kneeL": [0.0, 0.0, -70.3],
                "kneeR": [0.0, 0.0, -70.3],
                "ankleL": [0.0, 0.0, 9.9],
                "ankleR": [0.0, 0.0, 9.9],
                "shoulderL": [0.0, 0.0, 46.0],
                "shoulderR": [0.0, 0.0, 46.0],
                "elbowL": [0.0, 0.0, 0.0],
                "elbowR": [0.0, 0.0, 0.0],
                "wristL": [0.0, 0.0, 0.0],
                "wristR": [0.0, 0.0, 0.0],
                "neck": [0.0, 0.0, 22.0]
            },
            "contacts": ["heelL", "heelR", "toeL", "toeR"],
            "props": [
                {"type": "barbell", "pos": [0.025, 0.225, 0.0]}
            ],
            "primary": ["hamstrings", "glutes", "lowerBack"],
            "secondary": ["trapezius", "forearms", "quadriceps", "lats"]
        },
        "bench_press_bottom": {
            "name": "Barbell Bench Press (Chest Touch)",
            "category": "strength",
            "root_pos": [0.05, 0.245, 0.0],
            "root_rot": [0.0, 0.0, 90.0],
            "joints": {
                "hipL": [0.0, 10.0, -5.0],
                "hipR": [0.0, -10.0, -5.0],
                "kneeL": [0.0, 0.0, -55.0],
                "kneeR": [0.0, 0.0, -55.0],
                "ankleL": [0.0, 0.0, -30.0],
                "ankleR": [0.0, 0.0, -30.0],
                "shoulderL": [-55.0, 0.0, -30.0],
                "shoulderR": [54.0, 0.0, -30.0],
                "elbowL": [0.0, 0.0, 120.0],
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
            "secondary": ["shoulders"]
        },
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
            "secondary": ["biceps", "forearms", "core"]
        },
        "plank": {
            "name": "Forearm Plank (Rigid Line)",
            "category": "calisthenics",
            "root_pos": [0.0, 0.175, 0.0],
            "root_rot": [0.0, 0.0, -89.0],
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
            "secondary": ["shoulders", "glutes", "quadriceps"]
        },
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
            "secondary": ["shoulders", "lowerBack"]
        },
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
            "secondary": ["glutes", "core"]
        }
    }

if __name__ == '__main__':
    poses = get_all_poses()
    for pid, p in poses.items():
        st = forward_kinematics(p["root_pos"], p["root_rot"], p["joints"])
        val = validate_pose(st, p["joints"], required_contacts=p.get("contacts"), allow_dynamic=True)
        print(f"{pid:20s}: valid={val.is_valid}, excess={val.max_limit_excess_deg:.1f}°, pen={val.ground_penetration_cm:.2f}cm")
        if not val.is_valid:
            print(f"  VIOLATIONS: {val.violations}")

def check_textbook_ranges():
    poses = get_all_poses()
    reports = {}

    # 1. STANDING
    st1 = forward_kinematics(poses["standing"]["root_pos"], poses["standing"]["root_rot"], poses["standing"]["joints"])
    reports["standing"] = [
        ("feet_flat", abs(st1.world_positions["ankleL"].y - 0.045) < 0.01),
        ("arms_relaxed", abs(st1.world_positions["wristL"].x) < 0.05),
    ]

    # 2. SQUAT BOTTOM
    st2 = forward_kinematics(poses["squat_bottom"]["root_pos"], poses["squat_bottom"]["root_rot"], poses["squat_bottom"]["joints"])
    reports["squat_bottom"] = [
        ("thigh_parallel", st2.world_positions["hipL"].y <= st2.world_positions["kneeL"].y + 0.01),
        ("knee_angle", 110.0 <= abs(poses["squat_bottom"]["joints"]["kneeL"][2]) <= 130.0),
        ("torso_angle", 30.0 <= abs(poses["squat_bottom"]["root_rot"][2]) <= 45.0),
        ("shin_forward", 25.0 <= poses["squat_bottom"]["joints"]["ankleL"][2] <= 40.0),
        ("heels_down", abs(st2.world_positions["ankleL"].y - 0.045) < 0.01),
        ("bar_over_midfoot", abs(st2.world_positions["chest"].x - 0.0) < 0.05),
    ]

    # 3. DEADLIFT HINGE
    st3 = forward_kinematics(poses["deadlift_hinge"]["root_pos"], poses["deadlift_hinge"]["root_rot"], poses["deadlift_hinge"]["joints"])
    reports["deadlift_hinge"] = [
        ("bar_over_midfoot", abs(poses["deadlift_hinge"]["props"][0]["pos"][0] - 0.025) < 0.02),
        ("shins_forward", 5.0 <= poses["deadlift_hinge"]["joints"]["ankleL"][2] <= 15.0),
        ("hips_above_knees", st3.world_positions["hipL"].y > st3.world_positions["kneeL"].y),
        ("hips_below_shoulders", st3.world_positions["hipL"].y < st3.world_positions["shoulderL"].y),
        ("shoulders_ahead_of_bar", st3.world_positions["shoulderL"].x >= poses["deadlift_hinge"]["props"][0]["pos"][0] - 0.01),
        ("arms_vertical", abs(st3.world_positions["wristL"].x - st3.world_positions["shoulderL"].x) < 0.02),
    ]

    # 4. BENCH PRESS BOTTOM
    st4 = forward_kinematics(poses["bench_press_bottom"]["root_pos"], poses["bench_press_bottom"]["root_rot"], poses["bench_press_bottom"]["joints"])
    reports["bench_press_bottom"] = [
        ("head_glutes_on_bench", abs(st4.world_positions["pelvis"].y - 0.245) < 0.02),
        ("feet_flat", abs(st4.world_positions["ankleL"].y - 0.041) < 0.01),
        ("bar_touching_chest", abs(poses["bench_press_bottom"]["props"][1]["pos"][0] - st4.world_positions["chest"].x) < 0.06),
        ("forearms_vertical", abs(st4.world_positions["wristL"].x - st4.world_positions["elbowL"].x) < 0.02),
        ("upper_arms_angle", 45.0 <= abs(poses["bench_press_bottom"]["joints"]["shoulderL"][0]) <= 70.0),
    ]

    # 5. PULL-UP TOP
    st5 = forward_kinematics(poses["pullup_top"]["root_pos"], poses["pullup_top"]["root_rot"], poses["pullup_top"]["joints"])
    reports["pullup_top"] = [
        ("chin_above_bar", st5.world_positions["head"].y > 0.95),
        ("grip_outside_shoulders", abs(st5.world_positions["wristL"].z) > abs(st5.world_positions["shoulderL"].z)),
    ]

    # 6. PLANK
    st6 = forward_kinematics(poses["plank"]["root_pos"], poses["plank"]["root_rot"], poses["plank"]["joints"])
    reports["plank"] = [
        ("straight_line", abs(st6.world_positions["head"].y - st6.world_positions["ankleL"].y) < 0.06),
        ("elbows_under_shoulders", abs(st6.world_positions["elbowL"].x - st6.world_positions["shoulderL"].x) < 0.04),
    ]

    # 7. DOWNWARD DOG
    st7 = forward_kinematics(poses["downward_dog"]["root_pos"], poses["downward_dog"]["root_rot"], poses["downward_dog"]["joints"])
    reports["downward_dog"] = [
        ("hips_highest", st7.world_positions["pelvis"].y >= max(st7.world_positions[j].y for j in ["wristL", "ankleL", "head"])),
    ]

    # 8. TREE POSE
    st8 = forward_kinematics(poses["tree_pose"]["root_pos"], poses["tree_pose"]["root_rot"], poses["tree_pose"]["joints"])
    reports["tree_pose"] = [
        ("standing_foot_flat", abs(st8.world_positions["ankleL"].y - 0.045) < 0.01),
        ("other_foot_on_thigh", st8.world_positions["ankleR"].y > st8.world_positions["kneeL"].y),
        ("hips_level", abs(st8.world_positions["hipL"].y - st8.world_positions["hipR"].y) < 0.02),
    ]

    print("\n--- TEXTBOOK REFERENCE CHECKS ---")
    all_passed = True
    for pid, checks in reports.items():
        print(f"{pid:20s}:")
        for cname, passed in checks:
            status = "PASS" if passed else "FAIL"
            print(f"  {cname:25s} -> {status}")
            if not passed:
                all_passed = False
    return all_passed

check_textbook_ranges()

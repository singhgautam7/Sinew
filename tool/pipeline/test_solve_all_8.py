import math
import sys
sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics, validate_pose, JOINT_LIMITS

def verify_pose_textbook_ranges():
    # 1. STANDING
    standing = {
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
        "props": []
    }

    # 2. SQUAT BOTTOM
    # Stance: hip abduction +-18 deg, knees tracked out, torso lean -35 deg
    squat_bottom = {
        "root_pos": [-0.140, 0.230, 0.0],
        "root_rot": [0.0, 0.0, -35.0],  # Forward lean 35 deg
        "joints": {
            "hipL": [0.0, 18.0, 120.0],
            "hipR": [0.0, -18.0, 120.0],
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
            "neck": [0.0, 0.0, 20.0],  # Neutral neck looking forward
        },
        "contacts": ["heelL", "heelR", "toeL", "toeR"],
        "props": [
            {
                "type": "barbell",
                "attach": {"joint": "chest", "offset": [-0.05, 0.03, 0.0]}
            }
        ]
    }

    # 3. DEADLIFT HINGE
    deadlift_hinge = {
        "root_pos": [-0.155, 0.404, 0.0],
        "root_rot": [0.0, 0.0, -46.0],  # Torso forward lean 46 deg
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
            {
                "type": "barbell",
                "pos": [0.025, 0.225, 0.0]
            }
        ]
    }

    # 4. BENCH PRESS BOTTOM
    # Supine horizontal: root_rot around Z is -90 deg. Body at y=0.24 on bench
    bench_press_bottom = {
        "root_pos": [-0.150, 0.240, 0.0],
        "root_rot": [0.0, 0.0, -90.0],  # Supine horizontal
        "joints": {
            # Hips extended, knees flexed down to floor
            "hipL": [0.0, 12.0, -10.0],
            "hipR": [0.0, -12.0, -10.0],
            "kneeL": [0.0, 0.0, -75.0],
            "kneeR": [0.0, 0.0, -75.0],
            "ankleL": [0.0, 0.0, 15.0],
            "ankleR": [0.0, 0.0, 15.0],
            # Shoulder tucked 55 deg from torso (abducted 70 deg in coronal plane)
            "shoulderL": [0.0, -50.0, 55.0],
            "shoulderR": [0.0, 50.0, 55.0],
            "elbowL": [0.0, 0.0, 90.0],  # Forearms vertical
            "elbowR": [0.0, 0.0, 90.0],
            "wristL": [0.0, 0.0, 0.0],
            "wristR": [0.0, 0.0, 0.0],
            "neck": [0.0, 0.0, 0.0]
        },
        "contacts": ["heelL", "heelR", "toeL", "toeR"],
        "props": [
            {"type": "bench", "pos": [0.0, 0.0, 0.0]},
            {"type": "barbell", "attach": {"joint": "chest", "offset": [0.07, 0.0, 0.0]}}
        ]
    }

    # 5. PULL-UP TOP
    pullup_top = {
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
        "props": [{"type": "pullupBar", "pos": [0.0, 0.950, 0.0]}]
    }

    # 6. PLANK
    plank = {
        "root_pos": [0.0, 0.175, 0.0],
        "root_rot": [0.0, 0.0, -84.0],
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
        "props": [{"type": "mat"}]
    }

    # 7. DOWNWARD DOG
    downward_dog = {
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
        "props": [{"type": "mat"}]
    }

    # 8. TREE POSE
    tree_pose = {
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
        "props": [{"type": "mat"}]
    }

    poses = {
        "standing": standing,
        "squat_bottom": squat_bottom,
        "deadlift_hinge": deadlift_hinge,
        "bench_press_bottom": bench_press_bottom,
        "pullup_top": pullup_top,
        "plank": plank,
        "downward_dog": downward_dog,
        "tree_pose": tree_pose,
    }

    for pid, p in poses.items():
        st = forward_kinematics(p["root_pos"], p["root_rot"], p["joints"])
        val = validate_pose(st, p["joints"], required_contacts=p.get("contacts"), allow_dynamic=True)
        print(f"Pose {pid:18s}: valid={val.is_valid}, excess={val.max_limit_excess_deg:.1f}deg, pen={val.ground_penetration_cm:.2f}cm")
        if not val.is_valid:
            print(f"   VIOLATIONS: {val.violations}")

verify_pose_textbook_ranges()

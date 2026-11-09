import math
import sys
from typing import List, Tuple

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data


def convex_hull_2d(points: List[Tuple[float, float]]) -> List[Tuple[float, float]]:
    """Monotone chain 2D convex hull."""
    pts = sorted(list(set(points)))
    if len(pts) <= 2:
        return pts
    
    def cross(o, a, b):
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower = []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)

    upper = []
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)

    return lower[:-1] + upper[:-1]


def get_torso_points(st: PoseState) -> List[Vec3]:
    R_c = st.world_rotations['chest']
    p_c = st.world_positions['chest']
    f_c = R_c.rotate_vec(Vec3(1, 0, 0))
    l_c = R_c.rotate_vec(Vec3(0, 0, 1))
    u_c = R_c.rotate_vec(Vec3(0, 1, 0))

    R_s = st.world_rotations['spineLower']
    p_s = st.world_positions['spineLower']
    f_s = R_s.rotate_vec(Vec3(1, 0, 0))
    l_s = R_s.rotate_vec(Vec3(0, 0, 1))

    R_p = st.world_rotations['pelvis']
    p_p = st.world_positions['pelvis']
    f_p = R_p.rotate_vec(Vec3(1, 0, 0))
    l_p = R_p.rotate_vec(Vec3(0, 0, 1))
    u_p = R_p.rotate_vec(Vec3(0, 1, 0))

    p_neck = st.world_positions['neck']
    p_shL = st.world_positions['shoulderL']
    p_shR = st.world_positions['shoulderR']
    p_hipL = st.world_positions['hipL']
    p_hipR = st.world_positions['hipR']

    points = [
        # Neck & Traps
        p_neck,
        p_neck + f_c * 0.025,
        p_neck - f_c * 0.030,
        (p_neck + p_shL) * 0.5 + u_c * 0.020,
        (p_neck + p_shR) * 0.5 + u_c * 0.020,
        p_shL,
        p_shR,
        # Chest & Scapula
        p_c + f_c * 0.070 + u_c * 0.035, # Clavicle
        p_c + f_c * 0.088,                # Pectorals
        p_c - f_c * 0.062,                # Scapula
        p_c + l_c * 0.155,                # Left Lat
        p_c - l_c * 0.155,                # Right Lat
        # Waist
        p_s + f_s * 0.065,                # Abs
        p_s - f_s * 0.048,                # Lumbar
        p_s + l_s * 0.115,                # Left waist
        p_s - l_s * 0.115,                # Right waist
        # Pelvis & Glutes
        p_p + f_p * 0.055,                # Pubis
        p_p - f_p * 0.092,                # Gluteus
        p_p + l_p * 0.130,                # Left Hip
        p_p - l_p * 0.130,                # Right Hip
        p_p - u_p * 0.045                 # Perineum
    ]
    return points

st = forward_kinematics([0, 0.54, 0], [0, 0, 0], {})
pts = get_torso_points(st)
for view in ["side", "front", "threeQuarter"]:
    cam = Camera(view=view)
    proj_pts = [cam.project_point(p)[:2] for p in pts]
    hull = convex_hull_2d(proj_pts)
    print(f"View {view}: Torso hull has {len(hull)} vertices")

import math
import sys
from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data


def get_side_torso_polygon(st: PoseState, cam: Camera):
    R_c = st.world_rotations['chest']
    p_c = st.world_positions['chest']
    f_c = R_c.rotate_vec(Vec3(1, 0, 0))
    u_c = R_c.rotate_vec(Vec3(0, 1, 0))

    R_s = st.world_rotations['spineLower']
    p_s = st.world_positions['spineLower']
    f_s = R_s.rotate_vec(Vec3(1, 0, 0))

    R_p = st.world_rotations['pelvis']
    p_p = st.world_positions['pelvis']
    f_p = R_p.rotate_vec(Vec3(1, 0, 0))
    u_p = R_p.rotate_vec(Vec3(0, 1, 0))

    p_neck = st.world_positions['neck']

    boundary_3d = [
        p_neck + f_c * 0.025,                  # Throat
        p_c + f_c * 0.070 + u_c * 0.035,        # Clavicle
        p_c + f_c * 0.088,                      # Pectorals
        p_s + f_s * 0.065,                      # Abdominal wall
        p_p + f_p * 0.055,                      # Pubis
        p_p - u_p * 0.045,                      # Perineum
        p_p - f_p * 0.092,                      # Gluteal curve (buttocks)
        p_s - f_s * 0.048,                      # Lumbar indent
        p_c - f_c * 0.062,                      # Scapular upper back
        p_neck - f_c * 0.030                    # Occipital trapezius
    ]
    return [cam.project_point(p)[:2] for p in boundary_3d]


def get_front_torso_polygon(st: PoseState, cam: Camera):
    R_c = st.world_rotations['chest']
    p_c = st.world_positions['chest']
    l_c = R_c.rotate_vec(Vec3(0, 0, 1))
    u_c = R_c.rotate_vec(Vec3(0, 1, 0))

    R_s = st.world_rotations['spineLower']
    p_s = st.world_positions['spineLower']
    l_s = R_s.rotate_vec(Vec3(0, 0, 1))

    R_p = st.world_rotations['pelvis']
    p_p = st.world_positions['pelvis']
    l_p = R_p.rotate_vec(Vec3(0, 0, 1))
    u_p = R_p.rotate_vec(Vec3(0, 1, 0))

    p_neck = st.world_positions['neck']
    p_shL = st.world_positions['shoulderL']
    p_shR = st.world_positions['shoulderR']

    boundary_3d = [
        p_neck,
        (p_neck + p_shR) * 0.5 + u_c * 0.015,   # Right Trapezius slope
        p_shR,                                  # Right Shoulder
        p_c - l_c * 0.155,                      # Right Lat
        p_s - l_s * 0.115,                      # Right Waist
        p_p - l_p * 0.130,                      # Right Hip
        p_p - u_p * 0.045,                      # Groin arch
        p_p + l_p * 0.130,                      # Left Hip
        p_s + l_s * 0.115,                      # Left Waist
        p_c + l_c * 0.155,                      # Left Lat
        p_shL,                                  # Left Shoulder
        (p_neck + p_shL) * 0.5 + u_c * 0.015    # Left Trapezius slope
    ]
    return [cam.project_point(p)[:2] for p in boundary_3d]


pdef = get_reference_pose_data()["standing"]
st = forward_kinematics(pdef["root_pos"], pdef["root_rot"], pdef["joints"])
cam_side = Camera(view="side")
cam_front = Camera(view="front")

poly_side = get_side_torso_polygon(st, cam_side)
poly_front = get_front_torso_polygon(st, cam_front)

print("Side torso points count:", len(poly_side))
print("Front torso points count:", len(poly_front))

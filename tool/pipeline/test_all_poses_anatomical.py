import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data

def get_2d_normal(p1, p2):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-6:
        return (0.0, 1.0)
    return (-dy / l, dx / l)

def draw_contoured_limb(draw, p1, p2, r_start, r_mid, r_end, color, bulge_t=0.35, bulge_offset=(0.0, 0.0)):
    nx, ny = get_2d_normal(p1, p2)
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    pm = (p1[0] + dx * bulge_t + bulge_offset[0], p1[1] + dy * bulge_t + bulge_offset[1])
    
    base_a = math.atan2(dy, dx) + math.pi * 0.5
    poly = []
    
    # Cap 1 around p1
    for i in range(9):
        a = base_a + (math.pi * i / 8.0)
        poly.append((p1[0] + r_start * math.cos(a), p1[1] + r_start * math.sin(a)))
        
    poly.append((pm[0] - nx * r_mid, pm[1] - ny * r_mid))
    
    # Cap 2 around p2
    base_a2 = base_a + math.pi
    for i in range(9):
        a = base_a2 + (math.pi * i / 8.0)
        poly.append((p2[0] + r_end * math.cos(a), p2[1] + r_end * math.sin(a)))
        
    poly.append((pm[0] + nx * r_mid, pm[1] + ny * r_mid))
    draw.polygon(poly, fill=color)

def test_run():
    poses = get_reference_pose_data()
    for pid in ["standing", "squat_bottom", "deadlift_hinge"]:
        print("Pose:", pid)

test_run()

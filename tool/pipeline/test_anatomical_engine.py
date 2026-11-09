import math
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Any, Optional

from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data


def get_ortho_normal(p1: Tuple[float, float], p2: Tuple[float, float]) -> Tuple[float, float]:
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-6:
        return (0.0, 1.0)
    return (-dy / l, dx / l)


def draw_muscle_limb(
    draw: ImageDraw.ImageDraw,
    p1: Tuple[float, float],
    p2: Tuple[float, float],
    r_start: float,
    r_mid: float,
    r_end: float,
    color: Any,
    bulge_t: float = 0.35,
    bulge_asymmetry: float = 0.0  # -1.0 to 1.0 shift towards one side of normal
):
    """Renders an anatomically contoured limb with muscular belly and tapering."""
    nx, ny = get_ortho_normal(p1, p2)
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    
    # Mid bulge position along the axis
    pm = (p1[0] + dx * bulge_t, p1[1] + dy * bulge_t)
    
    # Radii on positive and negative normal sides (for asymmetric muscle curves like calf or quad)
    r_mid_pos = r_mid * (1.0 + bulge_asymmetry * 0.4)
    r_mid_neg = r_mid * (1.0 - bulge_asymmetry * 0.4)
    
    poly = []
    
    # Cap 1 around p1 (start joint)
    base_a = math.atan2(dy, dx) + math.pi * 0.5
    for i in range(9):
        a = base_a + (math.pi * i / 8.0)
        poly.append((p1[0] + r_start * math.cos(a), p1[1] + r_start * math.sin(a)))
        
    # Along negative normal to mid bulge
    poly.append((pm[0] - nx * r_mid_neg, pm[1] - ny * r_mid_neg))
    
    # Cap 2 around p2 (end joint)
    base_a2 = base_a + math.pi
    for i in range(9):
        a = base_a2 + (math.pi * i / 8.0)
        poly.append((p2[0] + r_end * math.cos(a), p2[1] + r_end * math.sin(a)))
        
    # Along positive normal to mid bulge
    poly.append((pm[0] + nx * r_mid_pos, pm[1] + ny * r_mid_pos))
    
    draw.polygon(poly, fill=color)


def test():
    print("Muscle limb function compiled cleanly")

test()

import math
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Any

from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data


def get_screen_normal(p1: Tuple[float, float], p2: Tuple[float, float]) -> Tuple[float, float]:
    """Returns unit normal perpendicular to segment (p1, p2)."""
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-6:
        return (0.0, 1.0)
    return (-dy / l, dx / l)


def draw_tapered_capsule(
    draw: ImageDraw.ImageDraw,
    p1: Tuple[float, float],
    p2: Tuple[float, float],
    r1: float,
    r2: float,
    color: Any,
    mid_factor: float = 1.0,
    mid_offset: Tuple[float, float] = (0.0, 0.0)
):
    """Draws an anatomically tapered and contoured muscle limb."""
    nx, ny = get_screen_normal(p1, p2)
    
    # Midpoint
    pm = (
        (p1[0] + p2[0]) * 0.5 + mid_offset[0],
        (p1[1] + p2[1]) * 0.5 + mid_offset[1]
    )
    rm = ((r1 + r2) * 0.5) * mid_factor

    # Profile points along the limb
    # Upper cap around p1
    n_steps = 8
    poly = []
    
    # Cap 1 (from -normal to +normal)
    base_angle = math.atan2(p2[1] - p1[1], p2[0] - p1[0]) + math.pi * 0.5
    for i in range(n_steps + 1):
        a = base_angle + (math.pi * i / n_steps)
        poly.append((p1[0] + r1 * math.cos(a), p1[1] + r1 * math.sin(a)))

    # Down to mid right
    poly.append((pm[0] - nx * rm, pm[1] - ny * rm))
    
    # Down to p2
    # Cap 2 (around p2)
    base_angle2 = base_angle + math.pi
    for i in range(n_steps + 1):
        a = base_angle2 + (math.pi * i / n_steps)
        poly.append((p2[0] + r2 * math.cos(a), p2[1] + r2 * math.sin(a)))

    # Back up to mid left
    poly.append((pm[0] + nx * rm, pm[1] + ny * rm))

    draw.polygon(poly, fill=color)


def test_render():
    poses = get_reference_pose_data()
    cam = Camera(view="side", canvas_w=600, canvas_h=600, scale=420.0)
    theme = THEMES["light"]
    
    for pid in ["standing", "squat_bottom"]:
        pdef = poses[pid]
        st = forward_kinematics(pdef["root_pos"], pdef["root_rot"], pdef["joints"])
        
        img = Image.new("RGBA", (cam.canvas_w, cam.canvas_h), theme["background"])
        draw = ImageDraw.Draw(img, "RGBA")
        
        # Ground line
        gy = cam.canvas_h - cam.margin_bottom
        draw.line([(40, gy), (cam.canvas_w - 40, gy)], fill=theme["ground"], width=2)
        
        # Far Leg
        hk_far = (cam.project_point(st.world_positions["hipL"])[:2], cam.project_point(st.world_positions["kneeL"])[:2])
        ka_far = (cam.project_point(st.world_positions["kneeL"])[:2], cam.project_point(st.world_positions["ankleL"])[:2])
        draw_tapered_capsule(draw, hk_far[0], hk_far[1], 20.0, 14.0, theme["figureFar"], mid_factor=1.15)
        draw_tapered_capsule(draw, ka_far[0], ka_far[1], 14.0, 9.0, theme["figureFar"], mid_factor=1.25)
        
        # Torso
        p_pelvis = cam.project_point(st.world_positions["pelvis"])[:2]
        p_spine = cam.project_point(st.world_positions["spineLower"])[:2]
        p_chest = cam.project_point(st.world_positions["chest"])[:2]
        p_neck = cam.project_point(st.world_positions["neck"])[:2]
        
        # Draw torso as connected smooth volume
        draw_tapered_capsule(draw, p_pelvis, p_spine, 24.0, 22.0, theme["torso"], mid_factor=1.1)
        draw_tapered_capsule(draw, p_spine, p_chest, 22.0, 25.0, theme["torso"], mid_factor=1.1)
        draw_tapered_capsule(draw, p_chest, p_neck, 25.0, 14.0, theme["torso"], mid_factor=1.0)
        
        # Head
        p_head = cam.project_point(st.world_positions["head"])[:2]
        hr = 25.0
        draw.ellipse([(p_head[0]-hr, p_head[1]-hr), (p_head[0]+hr, p_head[1]+hr)], fill=theme["head"])
        
        # Near Leg
        hk_near = (cam.project_point(st.world_positions["hipR"])[:2], cam.project_point(st.world_positions["kneeR"])[:2])
        ka_near = (cam.project_point(st.world_positions["kneeR"])[:2], cam.project_point(st.world_positions["ankleR"])[:2])
        draw_tapered_capsule(draw, hk_near[0], hk_near[1], 22.0, 15.0, theme["figureNear"], mid_factor=1.15)
        draw_tapered_capsule(draw, ka_near[0], ka_near[1], 15.0, 10.0, theme["figureNear"], mid_factor=1.25)

        # Near Arm
        se_near = (cam.project_point(st.world_positions["shoulderR"])[:2], cam.project_point(st.world_positions["elbowR"])[:2])
        ew_near = (cam.project_point(st.world_positions["elbowR"])[:2], cam.project_point(st.world_positions["wristR"])[:2])
        draw_tapered_capsule(draw, se_near[0], se_near[1], 15.0, 11.0, theme["figureNear"], mid_factor=1.1)
        draw_tapered_capsule(draw, ew_near[0], ew_near[1], 11.0, 8.0, theme["figureNear"], mid_factor=1.15)
        
        out_path = f"review/gate1_rig/test_{pid}_tapered.png"
        img.save(out_path)
        print(f"Saved {out_path}")

test_render()

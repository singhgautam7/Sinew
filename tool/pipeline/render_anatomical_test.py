import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data


def get_normal(p1, p2):
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-6:
        return (0.0, 1.0)
    return (-dy / l, dx / l)


def draw_muscle_segment(draw, p1, p2, r1, r_mid, r2, color, bulge_t=0.35, bulge_side=0.0):
    """Draws an anatomically tapered and contoured limb with smooth muscle belly."""
    nx, ny = get_normal(p1, p2)
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    
    pm = (p1[0] + dx * bulge_t, p1[1] + dy * bulge_t)
    r_pos = r_mid * (1.0 + bulge_side * 0.35)
    r_neg = r_mid * (1.0 - bulge_side * 0.35)
    
    base_a = math.atan2(dy, dx) + math.pi * 0.5
    poly = []
    
    # Cap 1 around p1
    for i in range(9):
        a = base_a + (math.pi * i / 8.0)
        poly.append((p1[0] + r1 * math.cos(a), p1[1] + r1 * math.sin(a)))
        
    poly.append((pm[0] - nx * r_neg, pm[1] - ny * r_neg))
    
    # Cap 2 around p2
    base_a2 = base_a + math.pi
    for i in range(9):
        a = base_a2 + (math.pi * i / 8.0)
        poly.append((p2[0] + r2 * math.cos(a), p2[1] + r2 * math.sin(a)))
        
    poly.append((pm[0] + nx * r_pos, pm[1] + ny * r_pos))
    draw.polygon(poly, fill=color)


def draw_anatomical_foot(draw, p_ankle, p_toe, color, facing_right=True):
    """Draws an anatomical foot with heel cup, flat sole, instep arch, and rounded toe."""
    u_a, v_a = p_ankle
    u_t, v_t = p_toe
    
    sign = 1.0 if facing_right else -1.0
    
    # In side view:
    # Ankle is at (u_a, v_a)
    # Heel is behind ankle
    p_heel_top = (u_a - sign * 14.0, v_a)
    p_heel_back = (u_a - sign * 16.0, v_a + 12.0)
    p_heel_sole = (u_a - sign * 12.0, v_a + 18.0)
    
    # Sole rests on ground
    p_arch = (u_a + sign * 12.0, v_a + 16.0)
    p_ball = (u_t, v_a + 18.0)
    p_toe_tip = (u_t + sign * 14.0, v_a + 16.0)
    p_toe_top = (u_t + sign * 10.0, v_a + 8.0)
    p_instep = (u_a + sign * 8.0, v_a + 5.0)
    
    foot_poly = [
        (u_a, v_a),
        p_instep,
        p_toe_top,
        p_toe_tip,
        p_ball,
        p_arch,
        p_heel_sole,
        p_heel_back,
        p_heel_top
    ]
    draw.polygon(foot_poly, fill=color)


def test():
    poses = get_reference_pose_data()
    pdef = poses["standing"]
    st = forward_kinematics(pdef["root_pos"], pdef["root_rot"], pdef["joints"])
    
    cam = Camera(view="side", canvas_w=600, canvas_h=600, scale=420.0)
    theme = THEMES["light"]
    img = Image.new("RGBA", (cam.canvas_w, cam.canvas_h), theme["background"])
    draw = ImageDraw.Draw(img, "RGBA")
    
    # Ground line
    gy = cam.canvas_h - cam.margin_bottom
    draw.line([(40, gy), (cam.canvas_w - 40, gy)], fill=theme["ground"], width=2)
    
    # Draw Foot
    pa = cam.project_point(st.world_positions["ankleR"])[:2]
    pt = cam.project_point(st.world_positions["toeR"])[:2]
    draw_anatomical_foot(draw, pa, pt, theme["figureNear"])
    
    # Draw Calf
    pk = cam.project_point(st.world_positions["kneeR"])[:2]
    draw_muscle_segment(draw, pk, pa, 14.0, 17.5, 9.0, theme["figureNear"], bulge_t=0.30, bulge_side=-0.5)
    
    # Draw Thigh
    ph = cam.project_point(st.world_positions["hipR"])[:2]
    draw_muscle_segment(draw, ph, pk, 22.0, 24.5, 14.0, theme["figureNear"], bulge_t=0.35, bulge_side=0.3)
    
    img.save("review/gate1_rig/test_human_leg.png")
    print("Saved review/gate1_rig/test_human_leg.png successfully")

test()

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


def draw_tapered_muscle(draw, p1, p2, r_start, r_mid, r_end, color, bulge_t=0.35, bulge_asym=0.0):
    """Draws an anatomically contoured limb segment."""
    nx, ny = get_2d_normal(p1, p2)
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    
    pm = (p1[0] + dx * bulge_t, p1[1] + dy * bulge_t)
    r_pos = r_mid * (1.0 + bulge_asym * 0.35)
    r_neg = r_mid * (1.0 - bulge_asym * 0.35)
    
    base_a = math.atan2(dy, dx) + math.pi * 0.5
    poly = []
    
    # Cap 1 around p1
    for i in range(9):
        a = base_a + (math.pi * i / 8.0)
        poly.append((p1[0] + r_start * math.cos(a), p1[1] + r_start * math.sin(a)))
        
    poly.append((pm[0] - nx * r_neg, pm[1] - ny * r_neg))
    
    # Cap 2 around p2
    base_a2 = base_a + math.pi
    for i in range(9):
        a = base_a2 + (math.pi * i / 8.0)
        poly.append((p2[0] + r_end * math.cos(a), p2[1] + r_end * math.sin(a)))
        
    poly.append((pm[0] + nx * r_pos, pm[1] + ny * r_pos))
    draw.polygon(poly, fill=color)


def draw_foot_contour(draw, p_ankle, p_toe, color, facing_sign=1.0):
    u_a, v_a = p_ankle
    u_t, v_t = p_toe
    
    # Heel extends backwards from ankle
    p_heel_top = (u_a - facing_sign * 14.0, v_a)
    p_heel_back = (u_a - facing_sign * 16.0, v_a + 10.0)
    p_heel_sole = (u_a - facing_sign * 12.0, v_a + 17.0)
    
    # Sole along ground
    p_arch = (u_a + facing_sign * 10.0, v_a + 15.0)
    p_ball = (u_t, v_a + 17.0)
    p_toe_tip = (u_t + facing_sign * 14.0, v_a + 15.0)
    p_toe_top = (u_t + facing_sign * 10.0, v_a + 7.0)
    p_instep = (u_a + facing_sign * 8.0, v_a + 4.0)
    
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


def draw_hand_contour(draw, p_wrist, p_elbow, color):
    # Hand extends past wrist
    dx = p_wrist[0] - p_elbow[0]
    dy = p_wrist[1] - p_elbow[1]
    l = math.hypot(dx, dy)
    if l < 1e-4:
        dx, dy, l = 0.0, 1.0, 1.0
    ux, uy = dx / l, dy / l
    nx, ny = -uy, ux
    
    hr = 7.0
    p_tip = (p_wrist[0] + ux * 16.0, p_wrist[1] + uy * 16.0)
    p_thumb = (p_wrist[0] + ux * 10.0 + nx * 8.0, p_wrist[1] + uy * 10.0 + ny * 8.0)
    
    poly = [
        (p_wrist[0] - nx * hr, p_wrist[1] - ny * hr),
        p_tip,
        p_thumb,
        (p_wrist[0] + nx * hr, p_wrist[1] + ny * hr)
    ]
    draw.polygon(poly, fill=color)
    draw.ellipse([(p_tip[0]-5, p_tip[1]-5), (p_tip[0]+5, p_tip[1]+5)], fill=color)


def render_human_pose(st: PoseState, cam: Camera, theme: Dict[str, Any], pdef: Dict[str, Any]) -> Image.Image:
    img = Image.new("RGBA", (cam.canvas_w, cam.canvas_h), theme["background"])
    draw = ImageDraw.Draw(img, "RGBA")
    
    # 1. Ground line
    gy = cam.canvas_h - cam.margin_bottom
    draw.line([(30, gy), (cam.canvas_w - 30, gy)], fill=theme["ground"], width=2)
    
    # Contact shadows
    for cname in ["toeL", "toeR", "heelL", "heelR", "elbowL", "elbowR"]:
        if cname in st.contact_positions:
            cp = st.contact_positions[cname]
            if abs(cp.y) < 0.08:
                u, v, _ = cam.project_point(Vec3(cp.x, 0.0, cp.z))
                draw.ellipse([(u - 20, v - 7 + 1), (u + 20, v + 7 + 1)], fill=theme["shadow"])
                
    scale = cam.scale
    view = cam.view
    
    # Project joints
    pts = {j: cam.project_point(st.world_positions[j]) for j in st.world_positions}
    
    # Determine limb draw order based on depth
    # Far limbs
    col_far = theme["figureFar"]
    col_near = theme["figureNear"]
    col_torso = theme["torso"]
    col_head = theme["head"]
    
    # FAR LEG
    draw_tapered_muscle(draw, pts["hipL"][:2], pts["kneeL"][:2], 0.046*scale, 0.052*scale, 0.033*scale, col_far, bulge_t=0.35, bulge_asym=0.2)
    draw_tapered_muscle(draw, pts["kneeL"][:2], pts["ankleL"][:2], 0.033*scale, 0.039*scale, 0.020*scale, col_far, bulge_t=0.30, bulge_asym=-0.4)
    if view == "side":
        draw_foot_contour(draw, pts["ankleL"][:2], pts["toeL"][:2], col_far)
    else:
        draw_tapered_muscle(draw, pts["ankleL"][:2], pts["toeL"][:2], 0.020*scale, 0.022*scale, 0.020*scale, col_far)

    # FAR ARM
    draw_tapered_muscle(draw, pts["shoulderL"][:2], pts["elbowL"][:2], 0.036*scale, 0.030*scale, 0.022*scale, col_far, bulge_t=0.40)
    draw_tapered_muscle(draw, pts["elbowL"][:2], pts["wristL"][:2], 0.022*scale, 0.026*scale, 0.017*scale, col_far, bulge_t=0.25)
    draw_hand_contour(draw, pts["wristL"][:2], pts["elbowL"][:2], col_far)

    # TORSO
    if view == "side":
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

        boundary = [
            p_neck + f_c * 0.025,
            p_c + f_c * 0.075 + u_c * 0.035,
            p_c + f_c * 0.090,                # Pectorals
            p_s + f_s * 0.065,                # Abdomen
            p_p + f_p * 0.055,                # Pubis
            p_p - u_p * 0.045,                # Perineum
            p_p - f_p * 0.095,                # GLUTES
            p_s - f_s * 0.048,                # Lumbar
            p_c - f_c * 0.065,                # Scapular back
            p_neck - f_c * 0.030              # Upper trapezius
        ]
        poly_torso = [cam.project_point(p)[:2] for p in boundary]
        draw.polygon(poly_torso, fill=col_torso)
    else:
        # Front / 3Q Torso
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

        boundary = [
            p_neck,
            (p_neck + p_shR) * 0.5 + u_c * 0.015,
            p_shR,
            p_c - l_c * 0.155,
            p_s - l_s * 0.115,
            p_p - l_p * 0.130,
            p_p - u_p * 0.045,
            p_p + l_p * 0.130,
            p_s + l_s * 0.115,
            p_c + l_c * 0.155,
            p_shL,
            (p_neck + p_shL) * 0.5 + u_c * 0.015
        ]
        poly_torso = [cam.project_point(p)[:2] for p in boundary]
        draw.polygon(poly_torso, fill=col_torso)

    # HEAD & NECK
    p_head = pts["head"][:2]
    p_neck = pts["neck"][:2]
    # Neck column
    draw.line([p_neck, p_head], fill=col_torso, width=int(0.038 * scale))
    # Head cranium
    hr_w = 0.052 * scale
    hr_h = 0.065 * scale
    draw.ellipse([(p_head[0]-hr_w, p_head[1]-hr_h), (p_head[0]+hr_w, p_head[1]+hr_h)], fill=col_head)

    # NEAR LEG
    draw_tapered_muscle(draw, pts["hipR"][:2], pts["kneeR"][:2], 0.048*scale, 0.054*scale, 0.034*scale, col_near, bulge_t=0.35, bulge_asym=0.25)
    draw_tapered_muscle(draw, pts["kneeR"][:2], pts["ankleR"][:2], 0.034*scale, 0.040*scale, 0.021*scale, col_near, bulge_t=0.30, bulge_asym=-0.45)
    if view == "side":
        draw_foot_contour(draw, pts["ankleR"][:2], pts["toeR"][:2], col_near)
    else:
        draw_tapered_muscle(draw, pts["ankleR"][:2], pts["toeR"][:2], 0.021*scale, 0.023*scale, 0.021*scale, col_near)

    # NEAR ARM
    draw_tapered_muscle(draw, pts["shoulderR"][:2], pts["elbowR"][:2], 0.038*scale, 0.032*scale, 0.023*scale, col_near, bulge_t=0.40)
    draw_tapered_muscle(draw, pts["elbowR"][:2], pts["wristR"][:2], 0.023*scale, 0.028*scale, 0.018*scale, col_near, bulge_t=0.25)
    draw_hand_contour(draw, pts["wristR"][:2], pts["elbowR"][:2], col_near)

    return img


def test_batch():
    poses = get_reference_pose_data()
    cam = Camera(view="side", canvas_w=600, canvas_h=600, scale=420.0)
    theme = THEMES["light"]
    
    for pid in ["standing", "squat_bottom", "deadlift_hinge", "plank"]:
        pdef = poses[pid]
        st = forward_kinematics(pdef["root_pos"], pdef["root_rot"], pdef["joints"])
        im = render_human_pose(st, cam, theme, pdef)
        out_f = f"review/gate1_rig/human_{pid}_side.png"
        im.save(out_f)
        print(f"Generated {out_f}")

test_batch()

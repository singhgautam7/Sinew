"""Sinew Reference Figure Renderer.

Renders themeable exercise figures matching the Sinew design muscle-map system:
- Soft rounded body base (male and female bases)
- Anatomical muscle patches (pec plates, 2x3 abs grid, obliques, deltoid caps, oval limb bellies, glutes, lats, traps)
- Flat fills without outlines, using design tokens and color roles
- 3D view projection (side, front, threeQuarter) with identical vertical joint heights (<0.5 px drift)
- Equipment props rasterization (end-on plates in side view, full bar in front, bench, pull-up bar, mat)
- Depth-sorted painter's algorithm for proper limb and prop occlusion
- Card rendering on muscle-map surface with automated verification check lines
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

from PIL import Image, ImageDraw, ImageFont

from rig import (
    JOINTS,
    JOINT_RADII,
    PoseState,
    Quat,
    Vec3,
    forward_kinematics
)


# -----------------------------------------------------------------------------
# 1. Palettes and Figure Style Loaders
# -----------------------------------------------------------------------------

def hex_to_rgba(h: str, alpha: int = 255) -> Tuple[int, int, int, int]:
    if h.startswith("rgba"):
        # Parse rgba(r, g, b, a)
        inner = h[h.find("(") + 1:h.find(")")].split(",")
        r, g, b = int(inner[0].strip()), int(inner[1].strip()), int(inner[2].strip())
        a = int(float(inner[3].strip()) * 255)
        return (r, g, b, a)
    h = h.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    return (r, g, b, alpha)


def load_preview_palettes() -> Dict[str, Dict[str, Tuple[int, int, int, int]]]:
    """Loads color role palettes from dist/preview_palettes.json."""
    palette_file = Path("dist/preview_palettes.json")
    if not palette_file.exists():
        palette_file = Path("specs/data/preview_palettes.json")
    with open(palette_file, "r", encoding="utf-8") as f:
        data = json.load(f)["palettes"]

    themes = {}
    for theme_name, roles in data.items():
        themes[theme_name] = {role: hex_to_rgba(c) for role, c in roles.items()}
    return themes


def load_figure_style() -> Dict[str, Any]:
    """Loads base specifications from dist/figure_style.json."""
    style_file = Path("dist/figure_style.json")
    if not style_file.exists():
        style_file = Path("specs/data/figure_style.json")
    with open(style_file, "r", encoding="utf-8") as f:
        return json.load(f)


THEMES = load_preview_palettes()
FIGURE_STYLE = load_figure_style()


# -----------------------------------------------------------------------------
# 2. Camera Projection (Strict Vertical Axis Rotation Only)
# -----------------------------------------------------------------------------

@dataclass
class Camera:
    view: str = "side"  # "side", "front", "threeQuarter"
    canvas_w: int = 400
    canvas_h: int = 400
    scale: float = 300.0  # Pixels per 1.0 meter
    center_x: float = 0.0
    center_y: float = 0.45
    margin_bottom: float = 65.0

    def project_point(self, p: Vec3) -> Tuple[float, float, float]:
        """Projects 3D point p to (screen_u, screen_v, depth_z).

        All camera views rotate ONLY around the vertical axis (+Y).
        Therefore, proj_y = p.y in ALL three views, guaranteeing zero vertical drift.
        """
        if self.view == "side":
            # Looking from -Z towards +Z. Figure faces +X (screen right).
            proj_x = p.x
            proj_y = p.y
            depth = p.z
        elif self.view == "front":
            # Looking from +X towards -X. Figure's left (+Z) is on screen left.
            proj_x = p.z
            proj_y = p.y
            depth = -p.x
        elif self.view == "threeQuarter":
            # 35° yaw rotation around vertical axis Y
            yaw = math.radians(35.0)
            cos_y = math.cos(yaw)
            sin_y = math.sin(yaw)
            proj_x = p.x * cos_y + p.z * sin_y
            proj_y = p.y
            depth = -p.x * sin_y + p.z * cos_y
        else:
            proj_x, proj_y, depth = p.x, p.y, p.z

        u = self.canvas_w / 2.0 + (proj_x - self.center_x) * self.scale
        v = self.canvas_h - self.margin_bottom - (proj_y) * self.scale
        return u, v, depth


# -----------------------------------------------------------------------------
# 3. Shape Drawing Helpers
# -----------------------------------------------------------------------------

def get_2d_normal(p1: Tuple[float, float], p2: Tuple[float, float]) -> Tuple[float, float]:
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-6:
        return (0.0, 1.0)
    return (-dy / l, dx / l)


def draw_capsule_segment(
    draw: ImageDraw.ImageDraw,
    p1: Tuple[float, float],
    p2: Tuple[float, float],
    r_start: float,
    r_end: float,
    color: Any
):
    """Draws a clean tapered capsule segment with rounded joint caps."""
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-4:
        r = max(r_start, r_end)
        draw.ellipse([(p1[0]-r, p1[1]-r), (p1[0]+r, p1[1]+r)], fill=color)
        return

    nx, ny = -dy / l, dx / l
    base_a = math.atan2(dy, dx) + math.pi * 0.5
    poly = []

    # Cap 1 around p1
    for i in range(9):
        a = base_a + (math.pi * i / 8.0)
        poly.append((p1[0] + r_start * math.cos(a), p1[1] + r_start * math.sin(a)))

    # Cap 2 around p2
    base_a2 = base_a + math.pi
    for i in range(9):
        a = base_a2 + (math.pi * i / 8.0)
        poly.append((p2[0] + r_end * math.cos(a), p2[1] + r_end * math.sin(a)))

    draw.polygon(poly, fill=color)


def draw_muscle_belly(
    draw: ImageDraw.ImageDraw,
    p1: Tuple[float, float],
    p2: Tuple[float, float],
    r_belly: float,
    color: Any,
    t_center: float = 0.45,
    length_scale: float = 0.70,
    offset_normal: float = 0.0
):
    """Draws an oval muscle belly located along a segment (e.g. quad, hamstring, bicep)."""
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    l = math.hypot(dx, dy)
    if l < 1e-4:
        return

    ux, uy = dx / l, dy / l
    nx, ny = -uy, ux

    cx = p1[0] + dx * t_center + nx * offset_normal
    cy = p1[1] + dy * t_center + ny * offset_normal

    rx = r_belly
    ry = (l * length_scale) * 0.5

    # Rotated ellipse polygon
    ang = math.atan2(dy, dx) + math.pi * 0.5
    cos_a, sin_a = math.cos(ang), math.sin(ang)

    pts = []
    num_pts = 16
    for i in range(num_pts):
        th = 2.0 * math.pi * i / num_pts
        px0 = rx * math.cos(th)
        py0 = ry * math.sin(th)
        px = cx + px0 * cos_a - py0 * sin_a
        py = cy + px0 * sin_a + py0 * cos_a
        pts.append((px, py))

    draw.polygon(pts, fill=color)


@dataclass
class DrawableElement:
    depth: float
    draw_fn: Callable[[ImageDraw.ImageDraw, Dict[str, Tuple[int, int, int, int]]], None]


# -----------------------------------------------------------------------------
# 4. Reference Renderer Class
# -----------------------------------------------------------------------------

class ReferenceRenderer:
    def __init__(self, camera: Optional[Camera] = None, base: str = "male"):
        self.camera = camera or Camera()
        self.base_name = base
        self.base_style = FIGURE_STYLE["bases"].get(base, FIGURE_STYLE["bases"]["male"])

    def _get_muscle_role(
        self,
        muscle_id: str,
        is_far: bool,
        primary_muscles: List[str],
        secondary_muscles: List[str]
    ) -> str:
        """Determines the color role for a muscle patch."""
        # Normalize muscle names (e.g., lower-back -> lowerBack)
        norm_id = muscle_id.replace("-", "").lower()
        prim_norms = [m.replace("-", "").lower() for m in primary_muscles]
        sec_norms = [m.replace("-", "").lower() for m in secondary_muscles]

        if any(norm_id in p or p in norm_id for p in prim_norms):
            return "musclePrimary"
        if any(norm_id in s or s in norm_id for s in sec_norms):
            return "muscleSecondary"
        if is_far:
            return "bodyFar"
        return "bodyMuscle"

    def render_pose(
        self,
        pose: PoseState,
        props: Optional[List[Dict[str, Any]]] = None,
        theme_name: str = "light",
        primary_muscles: Optional[List[str]] = None,
        secondary_muscles: Optional[List[str]] = None,
        is_card: bool = False,
        card_label: str = "",
        check_lines: Optional[List[str]] = None
    ) -> Image.Image:
        """Renders the muscle-map body into a Pillow RGBA image."""
        theme = THEMES.get(theme_name, THEMES["light"])
        cam = self.camera
        scale = cam.scale
        view = cam.view
        base = self.base_style

        prim = primary_muscles or []
        sec = secondary_muscles or []

        # Target canvas size
        canvas_w = cam.canvas_w
        canvas_h = cam.canvas_h

        img = Image.new("RGBA", (canvas_w, canvas_h), theme["cardBackground"] if is_card else theme.get("background", (255, 255, 255, 0)))
        draw = ImageDraw.Draw(img, "RGBA")

        # If rendering as an Image 1 muscle-map card:
        card_pad = 12
        card_rect = [card_pad, card_pad, canvas_w - card_pad, canvas_h - card_pad]
        if is_card:
            # Card surface
            draw.rounded_rectangle(card_rect, radius=18, fill=theme["cardSurface"], outline=theme["cardOutline"], width=1)
            # Card header
            if card_label:
                draw.text((card_pad + 14, card_pad + 12), card_label, fill=theme["textMuted"])

        # Ground plane reference line
        ground_y = cam.canvas_h - cam.margin_bottom
        if not is_card or view == "side":
            draw.line(
                [(card_pad + 10, ground_y), (canvas_w - card_pad - 10, ground_y)],
                fill=theme["ground"],
                width=1
            )

        # Contact shadows
        shadow_col = theme["shadow"]
        for cname in ["toeL", "toeR", "heelL", "heelR", "elbowL", "elbowR"]:
            if cname in pose.contact_positions:
                cp = pose.contact_positions[cname]
                if abs(cp.y) < 0.08:
                    u, v, _ = cam.project_point(Vec3(cp.x, 0.0, cp.z))
                    draw.ellipse([(u - 18, v - 5), (u + 18, v + 5)], fill=shadow_col)

        # Project 3D joints
        pts = {j: cam.project_point(pose.world_positions[j]) for j in JOINTS}

        elements: List[DrawableElement] = []

        # Determine which limbs are near vs far
        # Left side is near in side view (+Z towards camera)
        is_far_left = (view == "side" and pts["hipL"][2] < pts["hipR"][2])
        is_far_right = (view == "side" and pts["hipR"][2] < pts["hipL"][2])

        # ---------------------------------------------------------------------
        # 1. FAR LEG
        # ---------------------------------------------------------------------
        far_hip = "hipR" if is_far_right else "hipL"
        far_knee = "kneeR" if is_far_right else "kneeL"
        far_ankle = "ankleR" if is_far_right else "ankleL"
        far_toe = "toeR" if is_far_right else "toeL"

        near_hip = "hipL" if is_far_right else "hipR"
        near_knee = "kneeL" if is_far_right else "kneeR"
        near_ankle = "ankleL" if is_far_right else "ankleR"
        near_toe = "toeL" if is_far_right else "toeR"

        depth_far_leg = (pts[far_hip][2] + pts[far_knee][2] + pts[far_ankle][2]) / 3.0

        def draw_far_leg(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            p_hip = pts[far_hip][:2]
            p_knee = pts[far_knee][:2]
            p_ankle = pts[far_ankle][:2]
            p_toe = pts[far_toe][:2]

            # Thigh segment base
            draw_capsule_segment(d, p_hip, p_knee, 0.042 * scale, 0.032 * scale, th["bodyFar"])
            # Thigh muscles (quad & hamstring)
            q_col = th[self._get_muscle_role("quadriceps", True, prim, sec)]
            h_col = th[self._get_muscle_role("hamstrings", True, prim, sec)]
            draw_muscle_belly(d, p_hip, p_knee, 0.040 * scale, q_col, t_center=0.45, offset_normal=0.010 * scale)
            draw_muscle_belly(d, p_hip, p_knee, 0.036 * scale, h_col, t_center=0.45, offset_normal=-0.010 * scale)

            # Knee joint dot
            kr = base["jointDots"]["knee"] * scale
            d.ellipse([(p_knee[0]-kr, p_knee[1]-kr), (p_knee[0]+kr, p_knee[1]+kr)], fill=th["bodyBase"])

            # Shank segment base
            draw_capsule_segment(d, p_knee, p_ankle, 0.030 * scale, 0.020 * scale, th["bodyFar"])
            c_col = th[self._get_muscle_role("calves", True, prim, sec)]
            draw_muscle_belly(d, p_knee, p_ankle, 0.028 * scale, c_col, t_center=0.35, offset_normal=-0.008 * scale)

            # Ankle / Foot
            frx = base["feet"]["rx"] * scale
            fry = base["feet"]["ry"] * scale
            p_foot = ((p_ankle[0] + p_toe[0]) * 0.5, p_ankle[1] + 0.008 * scale)
            d.ellipse([(p_foot[0]-frx, p_foot[1]-fry), (p_foot[0]+frx, p_foot[1]+fry)], fill=th["bodyFar"])

        elements.append(DrawableElement(depth=depth_far_leg, draw_fn=draw_far_leg))

        # ---------------------------------------------------------------------
        # 2. FAR ARM
        # ---------------------------------------------------------------------
        far_sh = "shoulderR" if is_far_right else "shoulderL"
        far_el = "elbowR" if is_far_right else "elbowL"
        far_wr = "wristR" if is_far_right else "wristL"

        near_sh = "shoulderL" if is_far_right else "shoulderR"
        near_el = "elbowL" if is_far_right else "elbowR"
        near_wr = "wristL" if is_far_right else "wristR"

        depth_far_arm = (pts[far_sh][2] + pts[far_el][2] + pts[far_wr][2]) / 3.0

        def draw_far_arm(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            p_sh = pts[far_sh][:2]
            p_el = pts[far_el][:2]
            p_wr = pts[far_wr][:2]

            # Shoulder deltoid cap
            dr = base["patches"]["shoulders"]["rx"] * scale
            d_col = th[self._get_muscle_role("shoulders", True, prim, sec)]
            d.ellipse([(p_sh[0]-dr, p_sh[1]-dr), (p_sh[0]+dr, p_sh[1]+dr)], fill=d_col)

            # Upper arm
            draw_capsule_segment(d, p_sh, p_el, 0.030 * scale, 0.022 * scale, th["bodyFar"])
            b_col = th[self._get_muscle_role("biceps", True, prim, sec)]
            draw_muscle_belly(d, p_sh, p_el, 0.026 * scale, b_col, t_center=0.45)

            # Forearm
            draw_capsule_segment(d, p_el, p_wr, 0.022 * scale, 0.016 * scale, th["bodyFar"])
            f_col = th[self._get_muscle_role("forearms", True, prim, sec)]
            draw_muscle_belly(d, p_el, p_wr, 0.024 * scale, f_col, t_center=0.35)

            # Wrist dot
            wr = base["jointDots"]["wrist"] * scale
            d.ellipse([(p_wr[0]-wr, p_wr[1]-wr), (p_wr[0]+wr, p_wr[1]+wr)], fill=th["bodyBase"])

        elements.append(DrawableElement(depth=depth_far_arm, draw_fn=draw_far_arm))

        # ---------------------------------------------------------------------
        # 3. TORSO, MUSCLE PATCHES & HEAD
        # ---------------------------------------------------------------------
        depth_torso = (pts["pelvis"][2] + pts["chest"][2]) * 0.5

        def draw_torso_and_head(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            p_pelvis = pts["pelvis"][:2]
            p_spine = pts["spineLower"][:2]
            p_chest = pts["chest"][:2]
            p_neck = pts["neck"][:2]
            p_head = pts["head"][:2]

            # Torso base silhouette
            sh_w = base["torsoBase"]["shoulderWidth"] * scale * 0.5
            w_w = base["torsoBase"]["waistWidth"] * scale * 0.5
            h_w = base["torsoBase"]["hipWidth"] * scale * 0.5

            if view == "side":
                # Anatomical profile silhouette with gluteal curve and chest contour
                R_c = pose.world_rotations["chest"]
                f_c = R_c.rotate_vec(Vec3(1, 0, 0))
                u_c = R_c.rotate_vec(Vec3(0, 1, 0))

                R_p = pose.world_rotations["pelvis"]
                f_p = R_p.rotate_vec(Vec3(1, 0, 0))
                u_p = R_p.rotate_vec(Vec3(0, 1, 0))

                boundary = [
                    cam.project_point(pose.world_positions["neck"] + f_c * 0.025)[:2],
                    cam.project_point(pose.world_positions["chest"] + f_c * 0.085)[:2],     # Chest
                    cam.project_point(pose.world_positions["spineLower"] + f_c * 0.065)[:2],# Abs wall
                    cam.project_point(pose.world_positions["pelvis"] + f_p * 0.060)[:2],    # Pubis
                    cam.project_point(pose.world_positions["pelvis"] - u_p * 0.045)[:2],    # Groin
                    cam.project_point(pose.world_positions["pelvis"] - f_p * 0.095)[:2],    # GLUTES curve
                    cam.project_point(pose.world_positions["spineLower"] - f_p * 0.050)[:2],# Lower back
                    cam.project_point(pose.world_positions["chest"] - f_c * 0.065)[:2],     # Upper back
                    cam.project_point(pose.world_positions["neck"] - f_c * 0.030)[:2]       # Traps slope
                ]
                d.polygon(boundary, fill=th["bodyBase"])

                # Side muscle patches:
                # Glute patch
                g_col = th[self._get_muscle_role("glutes", False, prim, sec)]
                p_glute = cam.project_point(pose.world_positions["pelvis"] - f_p * 0.055 - u_p * 0.01)[:2]
                d.ellipse([(p_glute[0]-0.038*scale, p_glute[1]-0.042*scale), (p_glute[0]+0.038*scale, p_glute[1]+0.042*scale)], fill=g_col)

                # Chest patch
                ch_col = th[self._get_muscle_role("chest", False, prim, sec)]
                p_pec = cam.project_point(pose.world_positions["chest"] + f_c * 0.045)[:2]
                d.ellipse([(p_pec[0]-0.028*scale, p_pec[1]-0.032*scale), (p_pec[0]+0.028*scale, p_pec[1]+0.032*scale)], fill=ch_col)

                # Core patch
                core_col = th[self._get_muscle_role("core", False, prim, sec)]
                p_abs = cam.project_point(pose.world_positions["spineLower"] + f_c * 0.035)[:2]
                d.ellipse([(p_abs[0]-0.022*scale, p_abs[1]-0.040*scale), (p_abs[0]+0.022*scale, p_abs[1]+0.040*scale)], fill=core_col)

                # Traps patch
                tr_col = th[self._get_muscle_role("trapezius", False, prim, sec)]
                p_trap = cam.project_point(pose.world_positions["chest"] - f_c * 0.035 + u_c * 0.03)[:2]
                d.polygon([p_neck, p_trap, cam.project_point(pose.world_positions["chest"] - f_c * 0.04)[:2]], fill=tr_col)
            else:
                # Front / 3Q Torso Base
                poly_torso = [
                    (p_neck[0] - sh_w * 0.5, p_neck[1] + 0.015 * scale),
                    (p_chest[0] - sh_w, p_chest[1]),
                    (p_spine[0] - w_w, p_spine[1]),
                    (p_pelvis[0] - h_w, p_pelvis[1]),
                    (p_pelvis[0] - h_w * 0.5, p_pelvis[1] + 0.040 * scale),
                    (p_pelvis[0] + h_w * 0.5, p_pelvis[1] + 0.040 * scale),
                    (p_pelvis[0] + h_w, p_pelvis[1]),
                    (p_spine[0] + w_w, p_spine[1]),
                    (p_chest[0] + sh_w, p_chest[1]),
                    (p_neck[0] + sh_w * 0.5, p_neck[1] + 0.015 * scale)
                ]
                d.polygon(poly_torso, fill=th["bodyBase"])

                # Muscle patches:
                # Pectoral plates (Left and Right)
                ch_col = th[self._get_muscle_role("chest", False, prim, sec)]
                pw = base["patches"]["chest"]["width"] * scale * 0.5
                ph = base["patches"]["chest"]["height"] * scale * 0.5
                # Left pec
                d.rounded_rectangle([p_chest[0] - pw*1.5, p_chest[1] - ph, p_chest[0] - pw*0.2, p_chest[1] + ph], radius=4, fill=ch_col)
                # Right pec
                d.rounded_rectangle([p_chest[0] + pw*0.2, p_chest[1] - ph, p_chest[0] + pw*1.5, p_chest[1] + ph], radius=4, fill=ch_col)

                # Abs 2x3 Grid
                core_col = th[self._get_muscle_role("core", False, prim, sec)]
                rw = base["patches"]["abs"]["rectWidth"] * scale * 0.5
                rh = base["patches"]["abs"]["rectHeight"] * scale * 0.3
                for row in range(3):
                    y_off = (row - 1) * (rh * 2.2)
                    cy = p_spine[1] + y_off
                    # Left ab
                    d.rounded_rectangle([p_spine[0] - rw*1.8, cy - rh, p_spine[0] - rw*0.2, cy + rh], radius=3, fill=core_col)
                    # Right ab
                    d.rounded_rectangle([p_spine[0] + rw*0.2, cy - rh, p_spine[0] + rw*1.8, cy + rh], radius=3, fill=core_col)

                # Obliques
                obl_col = th[self._get_muscle_role("obliques", False, prim, sec)]
                orx = base["patches"]["obliques"]["rx"] * scale
                ory = base["patches"]["obliques"]["ry"] * scale
                d.ellipse([(p_spine[0] - w_w + 2, p_spine[1] - ory), (p_spine[0] - w_w + 2 + orx*2, p_spine[1] + ory)], fill=obl_col)
                d.ellipse([(p_spine[0] + w_w - 2 - orx*2, p_spine[1] - ory), (p_spine[0] + w_w - 2, p_spine[1] + ory)], fill=obl_col)

            # Neck
            nw = base["neck"]["width"] * scale * 0.5
            nh = base["neck"]["height"] * scale * 0.5
            d.rounded_rectangle([(p_neck[0]-nw, p_neck[1]-nh), (p_neck[0]+nw, p_neck[1]+nh)], radius=3, fill=th["bodyBase"])

            # Head
            hr = base["head"]["radius"] * scale
            d.ellipse([(p_head[0]-hr, p_head[1]-hr), (p_head[0]+hr, p_head[1]+hr)], fill=th["bodyBase"])

            # Female Top Hair Bun
            if "hairBun" in base["head"]:
                bun = base["head"]["hairBun"]
                bun_r = bun["radius"] * scale
                bun_y = p_head[1] - bun["offsetY"] * scale
                d.ellipse([(p_head[0]-bun_r, bun_y-bun_r), (p_head[0]+bun_r, bun_y+bun_r)], fill=th["bodyBase"])

        elements.append(DrawableElement(depth=depth_torso, draw_fn=draw_torso_and_head))

        # ---------------------------------------------------------------------
        # 4. NEAR LEG
        # ---------------------------------------------------------------------
        depth_near_leg = (pts[near_hip][2] + pts[near_knee][2] + pts[near_ankle][2]) / 3.0

        def draw_near_leg(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            p_hip = pts[near_hip][:2]
            p_knee = pts[near_knee][:2]
            p_ankle = pts[near_ankle][:2]
            p_toe = pts[near_toe][:2]

            # Thigh segment base
            draw_capsule_segment(d, p_hip, p_knee, 0.044 * scale, 0.034 * scale, th["bodyBase"])

            # Thigh muscles (quad & hamstring)
            q_col = th[self._get_muscle_role("quadriceps", False, prim, sec)]
            h_col = th[self._get_muscle_role("hamstrings", False, prim, sec)]
            # In side view: quad in front (+X), hamstring in back (-X)
            if view == "side":
                draw_muscle_belly(d, p_hip, p_knee, 0.042 * scale, q_col, t_center=0.45, offset_normal=0.012 * scale)
                draw_muscle_belly(d, p_hip, p_knee, 0.038 * scale, h_col, t_center=0.45, offset_normal=-0.012 * scale)
            else:
                draw_muscle_belly(d, p_hip, p_knee, 0.042 * scale, q_col, t_center=0.45)
                # Adductors on inner side
                ad_col = th[self._get_muscle_role("adductors", False, prim, sec)]
                med_sign = 1.0 if near_hip == "hipL" else -1.0
                draw_muscle_belly(d, p_hip, p_knee, 0.022 * scale, ad_col, t_center=0.40, offset_normal=med_sign * 0.012 * scale)

            # Knee joint dot
            kr = base["jointDots"]["knee"] * scale
            d.ellipse([(p_knee[0]-kr, p_knee[1]-kr), (p_knee[0]+kr, p_knee[1]+kr)], fill=th["bodyBase"])

            # Shank segment base
            draw_capsule_segment(d, p_knee, p_ankle, 0.032 * scale, 0.022 * scale, th["bodyBase"])
            c_col = th[self._get_muscle_role("calves", False, prim, sec)]
            if view == "side":
                draw_muscle_belly(d, p_knee, p_ankle, 0.030 * scale, c_col, t_center=0.35, offset_normal=-0.010 * scale)
            else:
                draw_muscle_belly(d, p_knee, p_ankle, 0.030 * scale, c_col, t_center=0.35)

            # Ankle / Foot
            frx = base["feet"]["rx"] * scale
            fry = base["feet"]["ry"] * scale
            p_foot = ((p_ankle[0] + p_toe[0]) * 0.5, p_ankle[1] + 0.008 * scale)
            d.ellipse([(p_foot[0]-frx, p_foot[1]-fry), (p_foot[0]+frx, p_foot[1]+fry)], fill=th["bodyBase"])

        elements.append(DrawableElement(depth=depth_near_leg, draw_fn=draw_near_leg))

        # ---------------------------------------------------------------------
        # 5. NEAR ARM
        # ---------------------------------------------------------------------
        depth_near_arm = (pts[near_sh][2] + pts[near_el][2] + pts[near_wr][2]) / 3.0

        def draw_near_arm(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            p_sh = pts[near_sh][:2]
            p_el = pts[near_el][:2]
            p_wr = pts[near_wr][:2]

            # Shoulder deltoid cap
            dr = base["patches"]["shoulders"]["rx"] * scale
            d_col = th[self._get_muscle_role("shoulders", False, prim, sec)]
            d.ellipse([(p_sh[0]-dr, p_sh[1]-dr), (p_sh[0]+dr, p_sh[1]+dr)], fill=d_col)

            # Upper arm
            draw_capsule_segment(d, p_sh, p_el, 0.032 * scale, 0.024 * scale, th["bodyBase"])
            b_col = th[self._get_muscle_role("biceps", False, prim, sec)]
            t_col = th[self._get_muscle_role("triceps", False, prim, sec)]
            if view == "side":
                draw_muscle_belly(d, p_sh, p_el, 0.028 * scale, b_col, t_center=0.45, offset_normal=0.008 * scale)
                draw_muscle_belly(d, p_sh, p_el, 0.028 * scale, t_col, t_center=0.45, offset_normal=-0.008 * scale)
            else:
                draw_muscle_belly(d, p_sh, p_el, 0.028 * scale, b_col, t_center=0.45)

            # Forearm
            draw_capsule_segment(d, p_el, p_wr, 0.024 * scale, 0.018 * scale, th["bodyBase"])
            f_col = th[self._get_muscle_role("forearms", False, prim, sec)]
            draw_muscle_belly(d, p_el, p_wr, 0.026 * scale, f_col, t_center=0.35)

            # Wrist dot
            wr = base["jointDots"]["wrist"] * scale
            d.ellipse([(p_wr[0]-wr, p_wr[1]-wr), (p_wr[0]+wr, p_wr[1]+wr)], fill=th["bodyBase"])

        elements.append(DrawableElement(depth=depth_near_arm, draw_fn=draw_near_arm))

        # ---------------------------------------------------------------------
        # 6. EQUIPMENT PROPS
        # ---------------------------------------------------------------------
        if props:
            for pdef in props:
                ptype = pdef.get("type")
                if ptype == "barbell":
                    self._add_barbell_drawable(elements, pdef, pose, cam)
                elif ptype == "dumbbell":
                    self._add_dumbbell_drawable(elements, pdef, pose, cam)
                elif ptype == "kettlebell":
                    self._add_kettlebell_drawable(elements, pdef, pose, cam)
                elif ptype == "bench":
                    self._add_bench_drawable(elements, pdef, pose, cam)
                elif ptype == "pullupBar":
                    self._add_pullup_bar_drawable(elements, pdef, pose, cam)
                elif ptype == "mat":
                    self._add_mat_drawable(elements, pdef, pose, cam)

        # ---------------------------------------------------------------------
        # 7. DEPTH SORT & RENDER
        # ---------------------------------------------------------------------
        elements.sort(key=lambda elem: elem.depth, reverse=True)
        for elem in elements:
            elem.draw_fn(draw, theme)

        # Automated check lines under card
        if is_card and check_lines:
            line_y = canvas_h - card_pad - 14 - (len(check_lines) * 14)
            for idx, line in enumerate(check_lines):
                draw.text((card_pad + 14, line_y + idx * 14), line, fill=theme["textMuted"])

        return img

    def _add_barbell_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        """Adds a 3D Olympic barbell with end-on plates in side view."""
        attach = pdef.get("attach", {})
        if "pos" in pdef:
            bar_center = Vec3.from_list(pdef["pos"])
        elif "joint" in attach:
            jname = attach["joint"]
            jpos = pose.world_positions.get(jname, Vec3(0, 0.75, 0))
            offset = Vec3.from_list(attach.get("offset", [0, 0, 0]))
            jrot = pose.world_rotations.get(jname, Quat())
            bar_center = jpos + jrot.rotate_vec(offset)
        else:
            wl = pose.world_positions["wristL"]
            wr = pose.world_positions["wristR"]
            bar_center = (wl + wr) * 0.5

        bar_half_len = 0.44
        p_left = bar_center + Vec3(0.0, 0.0, bar_half_len)
        p_right = bar_center + Vec3(0.0, 0.0, -bar_half_len)

        ul, vl, zl = cam.project_point(p_left)
        ur, vr, zr = cam.project_point(p_right)
        bar_depth = (zl + zr) * 0.5

        def draw_barbell(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            scale = cam.scale
            plate_r = 0.110 * scale  # 22 cm radius Olympic plate

            if cam.view == "side":
                # SIDE VIEW: END-ON PLATE DISC, NEVER A VERTICAL STICK!
                uc, vc, _ = cam.project_point(bar_center)
                # Outer Olympic plate disc
                d.ellipse([(uc - plate_r, vc - plate_r), (uc + plate_r, vc + plate_r)], fill=th["propDetail"])
                # Inner collar rim
                d.ellipse([(uc - plate_r * 0.45, vc - plate_r * 0.45), (uc + plate_r * 0.45, vc + plate_r * 0.45)], fill=th["prop"])
                # Center hub dot
                d.ellipse([(uc - plate_r * 0.15, vc - plate_r * 0.15), (uc + plate_r * 0.15, vc + plate_r * 0.15)], fill=th["propDetail"])
            elif cam.view == "front":
                # FRONT VIEW: FULL SHAFT WITH PLATES
                d.line([(ul, vl), (ur, vr)], fill=th["prop"], width=max(2, int(0.014 * scale)))
                # Left plate
                d.rounded_rectangle([(ul - 4, vl - plate_r), (ul + 4, vl + plate_r)], radius=2, fill=th["propDetail"])
                # Right plate
                d.rounded_rectangle([(ur - 4, vr - plate_r), (ur + 4, vr + plate_r)], radius=2, fill=th["propDetail"])
            else:
                # THREE-QUARTER VIEW: FORESHORTENED BAR WITH ELLIPTICAL PLATES
                d.line([(ul, vl), (ur, vr)], fill=th["prop"], width=max(2, int(0.014 * scale)))
                plate_w = plate_r * 0.35
                d.ellipse([(ul - plate_w, vl - plate_r), (ul + plate_w, vl + plate_r)], fill=th["propDetail"])
                d.ellipse([(ur - plate_w, vr - plate_r), (ur + plate_w, vr + plate_r)], fill=th["propDetail"])

        elements.append(DrawableElement(depth=bar_depth, draw_fn=draw_barbell))

    def _add_bench_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        """Adds flat exercise bench beneath supine figure."""
        pos = Vec3.from_list(pdef.get("pos", [0.0, 0.0, 0.0]))
        u_mid, v_mid, depth = cam.project_point(pos)

        def draw_bench(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            scale = cam.scale
            # Bench pad surface at y = 0.220
            p_top_l = cam.project_point(Vec3(pos.x - 0.42, 0.220, pos.z))[:2]
            p_top_r = cam.project_point(Vec3(pos.x + 0.38, 0.220, pos.z))[:2]
            p_bot_l = (p_top_l[0], p_top_l[1] + 0.035 * scale)
            p_bot_r = (p_top_r[0], p_top_r[1] + 0.035 * scale)

            # Bench Pad
            d.polygon([p_top_l, p_top_r, p_bot_r, p_bot_l], fill=th["propDetail"])

            # Bench Legs
            ground_y = cam.canvas_h - cam.margin_bottom
            d.line([(p_bot_l[0] + 15, p_bot_l[1]), (p_bot_l[0] + 15, ground_y)], fill=th["prop"], width=4)
            d.line([(p_bot_r[0] - 15, p_bot_r[1]), (p_bot_r[0] - 15, ground_y)], fill=th["prop"], width=4)

        elements.append(DrawableElement(depth=-0.15, draw_fn=draw_bench))

    def _add_pullup_bar_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        pos = Vec3.from_list(pdef.get("pos", [0.0, 0.950, 0.0]))
        _, _, depth = cam.project_point(pos)

        def draw_bar(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            scale = cam.scale
            p_l = cam.project_point(Vec3(pos.x, pos.y, pos.z + 0.45))[:2]
            p_r = cam.project_point(Vec3(pos.x, pos.y, pos.z - 0.45))[:2]
            d.line([p_l, p_r], fill=th["prop"], width=max(3, int(0.016 * scale)))

        elements.append(DrawableElement(depth=depth, draw_fn=draw_bar))

    def _add_mat_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        def draw_mat(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            scale = cam.scale
            ground_y = cam.canvas_h - cam.margin_bottom
            d.rounded_rectangle([(30, ground_y - 2), (cam.canvas_w - 30, ground_y + 4)], radius=2, fill=th["propDetail"])

        elements.append(DrawableElement(depth=-0.50, draw_fn=draw_mat))

    def _add_dumbbell_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        """Adds a realistic dumbbell in the hand(s) of the figure."""
        attach = pdef.get("attach", {})
        target_joints = []
        if "joint" in attach:
            target_joints.append(attach["joint"])
        else:
            target_joints = ["wristL", "wristR"]

        axis = pdef.get("axis", "x" if cam.view == "side" else "z")

        for jname in target_joints:
            if jname not in pose.world_positions:
                continue
            pos = pose.world_positions[jname]
            u_mid, v_mid, depth = cam.project_point(pos)

            if axis == "x":
                vec = Vec3(0.045, 0.0, 0.0)
            elif axis == "y":
                vec = Vec3(0.0, 0.045, 0.0)
            else:
                vec = Vec3(0.0, 0.0, 0.045)

            p1 = pos + vec
            p2 = pos - vec
            u1, v1, _ = cam.project_point(p1)
            u2, v2, _ = cam.project_point(p2)

            def make_draw_dumbbell(u1, v1, u2, v2, u_mid, v_mid, axis):
                def draw_db(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
                    scale = cam.scale
                    # Handle shaft
                    d.line([(u1, v1), (u2, v2)], fill=th["propDetail"], width=max(2, int(0.012 * scale)))

                    bell_r = 0.038 * scale  # ~9 px radius
                    bell_w = 0.018 * scale  # ~4.5 px half-width

                    if cam.view == "side":
                        if axis == "x":
                            # Front & rear bell along handle
                            d.rounded_rectangle([(u1 - bell_w, v1 - bell_r), (u1 + bell_w, v1 + bell_r)], radius=3, fill=th["prop"])
                            d.rounded_rectangle([(u2 - bell_w, v2 - bell_r), (u2 + bell_w, v2 + bell_r)], radius=3, fill=th["prop"])
                            d.ellipse([(u1 - bell_w + 1, v1 - bell_r + 2), (u1 + bell_w - 1, v1 + bell_r - 2)], outline=th["propDetail"])
                            d.ellipse([(u2 - bell_w + 1, v2 - bell_r + 2), (u2 + bell_w - 1, v2 + bell_r - 2)], outline=th["propDetail"])
                        else:
                            # End-on disc
                            d.ellipse([(u_mid - bell_r, v_mid - bell_r), (u_mid + bell_r, v_mid + bell_r)], fill=th["prop"])
                            d.ellipse([(u_mid - bell_r * 0.4, v_mid - bell_r * 0.4), (u_mid + bell_r * 0.4, v_mid + bell_r * 0.4)], fill=th["propDetail"])
                    elif cam.view == "front":
                        if axis == "z":
                            d.rounded_rectangle([(u1 - bell_w, v1 - bell_r), (u1 + bell_w, v1 + bell_r)], radius=3, fill=th["prop"])
                            d.rounded_rectangle([(u2 - bell_w, v2 - bell_r), (u2 + bell_w, v2 + bell_r)], radius=3, fill=th["prop"])
                        else:
                            d.ellipse([(u_mid - bell_r, v_mid - bell_r), (u_mid + bell_r, v_mid + bell_r)], fill=th["prop"])
                            d.ellipse([(u_mid - bell_r * 0.4, v_mid - bell_r * 0.4), (u_mid + bell_r * 0.4, v_mid + bell_r * 0.4)], fill=th["propDetail"])
                    else:
                        d.ellipse([(u1 - bell_w, v1 - bell_r), (u1 + bell_w, v1 + bell_r)], fill=th["prop"])
                        d.ellipse([(u2 - bell_w, v2 - bell_r), (u2 + bell_w, v2 + bell_r)], fill=th["prop"])

                return draw_db

            elements.append(DrawableElement(depth=depth, draw_fn=make_draw_dumbbell(u1, v1, u2, v2, u_mid, v_mid, axis)))

    def _add_kettlebell_drawable(
        self,
        elements: List[DrawableElement],
        pdef: Dict[str, Any],
        pose: PoseState,
        cam: Camera
    ):
        """Adds a realistic cast-iron kettlebell held in hand(s)."""
        attach = pdef.get("attach", {})
        if "joint" in attach:
            jname = attach["joint"]
            pos = pose.world_positions.get(jname, Vec3(0, 0.5, 0))
        else:
            wl = pose.world_positions.get("wristL", Vec3(0, 0.5, 0))
            wr = pose.world_positions.get("wristR", Vec3(0, 0.5, 0))
            pos = (wl + wr) * 0.5

        u_grip, v_grip, depth = cam.project_point(pos)

        def draw_kb(d: ImageDraw.ImageDraw, th: Dict[str, Tuple[int, int, int, int]]):
            scale = cam.scale
            bell_r = 0.038 * scale  # ~9 px radius
            handle_h = 0.032 * scale  # ~8 px drop to bell
            u_c = u_grip
            v_c = v_grip + handle_h + bell_r * 0.65

            handle_w = 0.026 * scale
            # Triangular handle arch
            d.line([(u_grip - handle_w, v_grip), (u_grip + handle_w, v_grip),
                    (u_c + bell_r * 0.6, v_c - bell_r * 0.4),
                    (u_c - bell_r * 0.6, v_c - bell_r * 0.4),
                    (u_grip - handle_w, v_grip)],
                   fill=th["propDetail"], width=max(2, int(0.012 * scale)))

            # Spherical cast-iron bell
            d.ellipse([(u_c - bell_r, v_c - bell_r), (u_c + bell_r, v_c + bell_r)], fill=th["prop"])
            # Subtle highlight ring
            d.ellipse([(u_c - bell_r * 0.65, v_c - bell_r * 0.65), (u_c + bell_r * 0.65, v_c + bell_r * 0.65)],
                      outline=th["propDetail"], width=1)

        elements.append(DrawableElement(depth=depth, draw_fn=draw_kb))

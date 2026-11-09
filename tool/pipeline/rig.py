"""Sinew Exercise Rig & Kinematics Engine.

Defines the 19-joint neutral 3D figure rig, bone proportions (Drillis & Contini),
coordinate frames, joint limits, contact points, Forward Kinematics (FK),
analytic two-bone Inverse Kinematics (IK), and physiological validation.
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Set, Union


# -----------------------------------------------------------------------------
# 1. Math Library: Vector3, Quaternion, Euler
# -----------------------------------------------------------------------------

@dataclass
class Vec3:
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def __add__(self, other: Vec3) -> Vec3:
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: Vec3) -> Vec3:
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, scalar: float) -> Vec3:
        return Vec3(self.x * scalar, self.y * scalar, self.z * scalar)

    def __truediv__(self, scalar: float) -> Vec3:
        return Vec3(self.x / scalar, self.y / scalar, self.z / scalar)

    def __neg__(self) -> Vec3:
        return Vec3(-self.x, -self.y, -self.z)

    def dot(self, other: Vec3) -> float:
        return self.x * other.x + self.y * other.y + self.z * other.z

    def cross(self, other: Vec3) -> Vec3:
        return Vec3(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x
        )

    def length_sq(self) -> float:
        return self.x * self.x + self.y * self.y + self.z * self.z

    def length(self) -> float:
        return math.sqrt(self.length_sq())

    def normalized(self) -> Vec3:
        l = self.length()
        if l < 1e-9:
            return Vec3(0.0, 0.0, 0.0)
        return self / l

    def to_list(self, decimals: int = 4) -> List[float]:
        return [round(self.x, decimals), round(self.y, decimals), round(self.z, decimals)]

    @classmethod
    def from_list(cls, l: List[float]) -> Vec3:
        return cls(float(l[0]), float(l[1]), float(l[2]))


@dataclass
class Quat:
    w: float = 1.0
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def __mul__(self, other: Quat) -> Quat:
        return Quat(
            self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
            self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
            self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
            self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w
        )

    def conjugate(self) -> Quat:
        return Quat(self.w, -self.x, -self.y, -self.z)

    def length(self) -> float:
        return math.sqrt(self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z)

    def normalized(self) -> Quat:
        l = self.length()
        if l < 1e-9:
            return Quat(1.0, 0.0, 0.0, 0.0)
        return Quat(self.w / l, self.x / l, self.y / l, self.z / l)

    def rotate_vec(self, v: Vec3) -> Vec3:
        qv = Quat(0.0, v.x, v.y, v.z)
        res = self * qv * self.conjugate()
        return Vec3(res.x, res.y, res.z)

    @classmethod
    def from_axis_angle(cls, axis: Vec3, angle_deg: float) -> Quat:
        rad = math.radians(angle_deg) * 0.5
        n_axis = axis.normalized()
        sin_a = math.sin(rad)
        return cls(math.cos(rad), n_axis.x * sin_a, n_axis.y * sin_a, n_axis.z * sin_a)

    @classmethod
    def from_euler(cls, euler_deg: List[float]) -> Quat:
        """Euler XYZ in degrees: R = Rx * Ry * Rz."""
        qx = cls.from_axis_angle(Vec3(1, 0, 0), euler_deg[0])
        qy = cls.from_axis_angle(Vec3(0, 1, 0), euler_deg[1])
        qz = cls.from_axis_angle(Vec3(0, 0, 1), euler_deg[2])
        return (qx * qy * qz).normalized()

    def to_euler_deg(self) -> List[float]:
        """Converts quaternion to Euler XYZ in degrees."""
        w, x, y, z = self.w, self.x, self.y, self.z
        siny_cosp = 2.0 * (w * y - z * x)
        if abs(siny_cosp) >= 1.0:
            pitch = math.copysign(math.pi / 2.0, siny_cosp)
            roll = 0.0
            yaw = math.atan2(2.0 * (w * z + x * y), 1.0 - 2.0 * (y * y + z * z))
        else:
            pitch = math.asin(siny_cosp)
            sinr_cosp = 2.0 * (w * x + y * z)
            cosr_cosp = 1.0 - 2.0 * (x * x + y * y)
            roll = math.atan2(sinr_cosp, cosr_cosp)

            siny_cosy = 2.0 * (w * z + x * y)
            cosy_cosy = 1.0 - 2.0 * (y * y + z * z)
            yaw = math.atan2(siny_cosy, cosy_cosy)

        return [
            round(math.degrees(roll) * 2.0) / 2.0,
            round(math.degrees(pitch) * 2.0) / 2.0,
            round(math.degrees(yaw) * 2.0) / 2.0,
        ]

    @classmethod
    def slerp(cls, q0: Quat, q1: Quat, t: float) -> Quat:
        """Spherical linear interpolation between two quaternions."""
        cos_half_theta = q0.w * q1.w + q0.x * q1.x + q0.y * q1.y + q0.z * q1.z
        q1_adj = q1
        if cos_half_theta < 0.0:
            q1_adj = Quat(-q1.w, -q1.x, -q1.y, -q1.z)
            cos_half_theta = -cos_half_theta

        if abs(cos_half_theta) >= 1.0 - 1e-6:
            return Quat(
                q0.w + t * (q1_adj.w - q0.w),
                q0.x + t * (q1_adj.x - q0.x),
                q0.y + t * (q1_adj.y - q0.y),
                q0.z + t * (q1_adj.z - q0.z)
            ).normalized()

        half_theta = math.acos(cos_half_theta)
        sin_half_theta = math.sqrt(1.0 - cos_half_theta * cos_half_theta)
        ratio_a = math.sin((1 - t) * half_theta) / sin_half_theta
        ratio_b = math.sin(t * half_theta) / sin_half_theta

        return Quat(
            q0.w * ratio_a + q1_adj.w * ratio_b,
            q0.x * ratio_a + q1_adj.x * ratio_b,
            q0.y * ratio_a + q1_adj.y * ratio_b,
            q0.z * ratio_a + q1_adj.z * ratio_b
        ).normalized()


# -----------------------------------------------------------------------------
# 2. Rig Definition: 19 Joints, Proportions, Limits, Contacts
# -----------------------------------------------------------------------------

JOINTS = [
    "pelvis",
    "spineLower",
    "chest",
    "neck",
    "head",
    "shoulderL",
    "elbowL",
    "wristL",
    "shoulderR",
    "elbowR",
    "wristR",
    "hipL",
    "kneeL",
    "ankleL",
    "toeL",
    "hipR",
    "kneeR",
    "ankleR",
    "toeR"
]

PARENT_MAP = {
    "pelvis": None,
    "spineLower": "pelvis",
    "chest": "spineLower",
    "neck": "chest",
    "head": "neck",
    "shoulderL": "chest",
    "elbowL": "shoulderL",
    "wristL": "elbowL",
    "shoulderR": "chest",
    "elbowR": "shoulderR",
    "wristR": "elbowR",
    "hipL": "pelvis",
    "kneeL": "hipL",
    "ankleL": "kneeL",
    "toeL": "ankleL",
    "hipR": "pelvis",
    "kneeR": "hipR",
    "ankleR": "kneeR",
    "toeR": "ankleR"
}

# Drillis & Contini (1966) segment offsets (normalized to standing height H = 1.0 m)
# Coords: +x = Forward, +y = Up, +z = Figure's Left, -z = Figure's Right
# Foot sole is exactly at ground level y = 0.0. Head vertex reaches exactly y = 1.000.
REST_OFFSETS: Dict[str, Vec3] = {
    "pelvis": Vec3(0.0, 0.540, 0.0),            # Root position in rest stance (y = 0.540)
    "spineLower": Vec3(0.0, 0.090, 0.0),        # y = 0.630
    "chest": Vec3(0.0, 0.130, 0.0),             # y = 0.760
    "neck": Vec3(0.0, 0.100, 0.0),              # y = 0.860
    "head": Vec3(0.0, 0.080, 0.0),              # y = 0.940 (head radius 0.06 -> crown at 1.000)
    "shoulderL": Vec3(0.0, 0.030, 0.170),       # Left shoulder (lateral +z)
    "elbowL": Vec3(0.0, -0.175, 0.0),           # Left upper arm hanging down
    "wristL": Vec3(0.0, -0.145, 0.0),           # Left forearm hanging down
    "shoulderR": Vec3(0.0, 0.030, -0.170),      # Right shoulder (lateral -z)
    "elbowR": Vec3(0.0, -0.175, 0.0),           # Right upper arm
    "wristR": Vec3(0.0, -0.145, 0.0),           # Right forearm
    "hipL": Vec3(0.0, -0.035, 0.095),           # Left hip socket (y = 0.505)
    "kneeL": Vec3(0.0, -0.245, 0.0),            # Left thigh (y = 0.260)
    "ankleL": Vec3(0.0, -0.215, 0.0),           # Left shank (ankle center at y = 0.045)
    "toeL": Vec3(0.120, -0.023, 0.0),           # Toe joint center at y = 0.022 (sole at 0.0)
    "hipR": Vec3(0.0, -0.035, -0.095),          # Right hip socket
    "kneeR": Vec3(0.0, -0.245, 0.0),            # Right thigh
    "ankleR": Vec3(0.0, -0.215, 0.0),           # Right shank
    "toeR": Vec3(0.120, -0.023, 0.0)            # Toe joint center at y = 0.022 (sole at 0.0)
}

# Capsule radii for rendering and collision detection
JOINT_RADII: Dict[str, float] = {
    "pelvis": 0.048,
    "spineLower": 0.046,
    "chest": 0.050,
    "neck": 0.026,
    "head": 0.060,  # Circular head radius
    "shoulderL": 0.028, "shoulderR": 0.028,
    "elbowL": 0.024, "elbowR": 0.024,
    "wristL": 0.020, "wristR": 0.020,
    "hipL": 0.036, "hipR": 0.036,
    "kneeL": 0.032, "kneeR": 0.032,
    "ankleL": 0.026, "ankleR": 0.026,
    "toeL": 0.022, "toeR": 0.022
}

# Anatomical Joint Limits: [min_x, max_x, min_y, max_y, min_z, max_z] in degrees
JOINT_LIMITS: Dict[str, Tuple[float, float, float, float, float, float]] = {
    "pelvis": (-180.0, 180.0, -180.0, 180.0, -180.0, 180.0),
    "spineLower": (-30.0, 30.0, -35.0, 35.0, -40.0, 65.0),
    "chest": (-25.0, 25.0, -35.0, 35.0, -35.0, 50.0),
    "neck": (-35.0, 35.0, -55.0, 55.0, -45.0, 55.0),
    "head": (-20.0, 20.0, -35.0, 35.0, -30.0, 30.0),
    "shoulderL": (-180.0, 180.0, -110.0, 110.0, -180.0, 180.0),
    "elbowL": (-15.0, 15.0, -15.0, 15.0, 0.0, 155.0),
    "wristL": (-70.0, 70.0, -35.0, 35.0, -85.0, 85.0),
    "shoulderR": (-180.0, 180.0, -110.0, 110.0, -180.0, 180.0),
    "elbowR": (-15.0, 15.0, -15.0, 15.0, 0.0, 155.0),
    "wristR": (-70.0, 70.0, -35.0, 35.0, -85.0, 85.0),
    "hipL": (-60.0, 60.0, -50.0, 50.0, -40.0, 150.0),
    "kneeL": (-15.0, 15.0, -15.0, 15.0, -155.0, 0.0),
    "ankleL": (-25.0, 25.0, -20.0, 20.0, -50.0, 45.0),
    "toeL": (0.0, 0.0, 0.0, 0.0, 0.0, 65.0),
    "hipR": (-60.0, 60.0, -50.0, 50.0, -40.0, 150.0),
    "kneeR": (-15.0, 15.0, -15.0, 15.0, -155.0, 0.0),
    "ankleR": (-25.0, 25.0, -20.0, 20.0, -50.0, 45.0),
    "toeR": (0.0, 0.0, 0.0, 0.0, 0.0, 65.0)
}

# Contact Point offsets relative to associated joint
CONTACT_OFFSETS: Dict[str, Tuple[str, Vec3]] = {
    "palmL": ("wristL", Vec3(0.040, -0.030, 0.0)),
    "palmR": ("wristR", Vec3(0.040, -0.030, 0.0)),
    "heelL": ("ankleL", Vec3(-0.040, -0.045, 0.0)),
    "heelR": ("ankleR", Vec3(-0.040, -0.045, 0.0)),
    "toeL": ("toeL", Vec3(0.0, -0.022, 0.0)),
    "toeR": ("toeR", Vec3(0.0, -0.022, 0.0)),
    "kneeL": ("kneeL", Vec3(0.035, 0.0, 0.0)),
    "kneeR": ("kneeR", Vec3(0.035, 0.0, 0.0)),
    "elbowL": ("elbowL", Vec3(-0.025, 0.0, 0.0)),
    "elbowR": ("elbowR", Vec3(-0.025, 0.0, 0.0)),
    "hipL": ("hipL", Vec3(-0.040, -0.035, 0.0)),
    "hipR": ("hipR", Vec3(-0.040, -0.035, 0.0)),
    "headBack": ("head", Vec3(-0.060, 0.0, 0.0)),
    "upperBack": ("chest", Vec3(-0.065, 0.0, 0.0))
}


def build_rig_schema_dict() -> Dict[str, Any]:
    """Generates the rig.json specification file content."""
    joints_data = {}
    for j in JOINTS:
        parent = PARENT_MAP[j]
        offset = REST_OFFSETS[j].to_list()
        limits = list(JOINT_LIMITS[j])
        radius = JOINT_RADII[j]
        joints_data[j] = {
            "parent": parent,
            "restOffset": offset,
            "limitsDeg": {
                "min": [limits[0], limits[2], limits[4]],
                "max": [limits[1], limits[3], limits[5]]
            },
            "radius": radius
        }

    contacts_data = {}
    for cname, (joint, off) in CONTACT_OFFSETS.items():
        contacts_data[cname] = {
            "joint": joint,
            "offset": off.to_list()
        }

    return {
        "version": 1,
        "standardHeight": 1.0,
        "coordinateSystem": {
            "hand": "rightHanded",
            "forward": "+x",
            "up": "+y",
            "left": "+z",
            "right": "-z"
        },
        "joints": joints_data,
        "contactPoints": contacts_data,
        "boneProportionsRef": "Drillis & Contini (1966)",
        "limbs": {
            "arms": {
                "upperArm": 0.175,
                "forearm": 0.145,
                "biacromialWidth": 0.340
            },
            "legs": {
                "thigh": 0.245,
                "shank": 0.215,
                "pelvisWidth": 0.190,
                "footLength": 0.160
            },
            "torso": {
                "pelvisHeight": 0.540,
                "spineLength": 0.220,
                "headRadius": 0.060
            }
        }
    }


# -----------------------------------------------------------------------------
# 3. Forward Kinematics (FK)
# -----------------------------------------------------------------------------

@dataclass
class PoseState:
    root_pos: Vec3
    root_rot: Quat
    world_positions: Dict[str, Vec3] = field(default_factory=dict)
    world_rotations: Dict[str, Quat] = field(default_factory=dict)
    contact_positions: Dict[str, Vec3] = field(default_factory=dict)


def forward_kinematics(
    root_pos: List[float],
    root_rot_deg: List[float],
    joint_angles_deg: Dict[str, List[float]]
) -> PoseState:
    """Computes global joint positions from root translation and local Euler rotations."""
    state = PoseState(
        root_pos=Vec3.from_list(root_pos),
        root_rot=Quat.from_euler(root_rot_deg)
    )

    state.world_positions["pelvis"] = state.root_pos
    state.world_rotations["pelvis"] = state.root_rot

    # Topological traversal in hierarchy order
    for j in JOINTS:
        if j == "pelvis":
            continue
        parent = PARENT_MAP[j]
        parent_pos = state.world_positions[parent]
        parent_rot = state.world_rotations[parent]

        local_rot_deg = joint_angles_deg.get(j, [0.0, 0.0, 0.0])
        local_quat = Quat.from_euler(local_rot_deg)
        global_rot = (parent_rot * local_quat).normalized()
        state.world_rotations[j] = global_rot

        offset = REST_OFFSETS[j]
        rotated_offset = parent_rot.rotate_vec(offset)
        state.world_positions[j] = parent_pos + rotated_offset

    # Compute contact points
    for cname, (joint, off) in CONTACT_OFFSETS.items():
        j_pos = state.world_positions[joint]
        j_rot = state.world_rotations[joint]
        state.contact_positions[cname] = j_pos + j_rot.rotate_vec(off)

    return state


# -----------------------------------------------------------------------------
# 4. Analytic Two-Bone Inverse Kinematics (IK)
# -----------------------------------------------------------------------------

def solve_two_bone_ik(
    p0: Vec3,
    p_target: Vec3,
    len1: float,
    len2: float,
    pole_hint: Vec3
) -> Tuple[Vec3, float, float]:
    """Analytic two-bone solver.

    Returns:
        (p1, alpha, beta)
        where p1 is solved mid-joint position, alpha is angle at p0, beta is angle at p1.
    """
    diff = p_target - p0
    dist = diff.length()
    max_reach = len1 + len2 - 1e-4
    min_reach = abs(len1 - len2) + 1e-4

    clamped_dist = max(min_reach, min(max_reach, dist))
    d_dir = diff.normalized()
    if diff.length() < 1e-6:
        d_dir = Vec3(0, -1, 0)

    cos_alpha = (len1 * len1 + clamped_dist * clamped_dist - len2 * len2) / (2.0 * len1 * clamped_dist)
    cos_alpha = max(-1.0, min(1.0, cos_alpha))
    alpha = math.acos(cos_alpha)

    cos_beta = (len1 * len1 + len2 * len2 - clamped_dist * clamped_dist) / (2.0 * len1 * len2)
    cos_beta = max(-1.0, min(1.0, cos_beta))
    beta = math.acos(cos_beta)

    plane_normal = diff.cross(pole_hint)
    if plane_normal.length() < 1e-6:
        alt = Vec3(1, 0, 0) if abs(diff.x) < 0.9 else Vec3(0, 0, 1)
        plane_normal = diff.cross(alt)
    plane_normal = plane_normal.normalized()

    bend_dir = plane_normal.cross(d_dir).normalized()
    p1 = p0 + d_dir * (len1 * math.cos(alpha)) + bend_dir * (len1 * math.sin(alpha))
    return p1, alpha, beta


# -----------------------------------------------------------------------------
# 5. Physiological Validator
# -----------------------------------------------------------------------------

@dataclass
class ValidationReport:
    is_valid: bool
    violations: List[str]
    max_limit_excess_deg: float = 0.0
    ground_penetration_cm: float = 0.0
    balance_offset_cm: float = 0.0


def validate_pose(
    pose: PoseState,
    joint_angles_deg: Dict[str, List[float]],
    required_contacts: Optional[Union[Dict[str, float], List[str]]] = None,
    allow_dynamic: bool = False
) -> ValidationReport:
    """Rigorous physical validator for the 3D stick figure."""
    violations = []
    max_limit_excess = 0.0
    max_penetration = 0.0

    # 1. Joint Limits Check
    for j, angles in joint_angles_deg.items():
        if j not in JOINT_LIMITS:
            continue
        limits = JOINT_LIMITS[j]
        for ax, name in [(0, "rotX"), (1, "rotY"), (2, "rotZ")]:
            min_l, max_l = limits[ax * 2], limits[ax * 2 + 1]
            val = angles[ax]
            if val < min_l - 1.0 or val > max_l + 1.0:
                excess = max(min_l - val, val - max_l)
                max_limit_excess = max(max_limit_excess, excess)
                violations.append(f"{j} {name} {val:.1f}° outside [{min_l}, {max_l}]")

    # 2. Ground Penetration Check (tolerance 1.5 cm)
    for j, pos in pose.world_positions.items():
        radius = JOINT_RADII.get(j, 0.02)
        bottom = pos.y - radius
        if bottom < -0.020:
            pen = abs(bottom) * 100.0
            max_penetration = max(max_penetration, pen)
            violations.append(f"Joint {j} penetrates ground by {pen:.1f} cm (y={pos.y:.3f})")

    for cname, cpos in pose.contact_positions.items():
        if cpos.y < -0.020:
            pen = abs(cpos.y) * 100.0
            max_penetration = max(max_penetration, pen)
            violations.append(f"Contact {cname} penetrates ground by {pen:.1f} cm (y={cpos.y:.3f})")

    # 3. Required Contact Points Check against expected surface
    if required_contacts:
        contact_dict = (
            required_contacts
            if isinstance(required_contacts, dict)
            else {c: 0.0 for c in required_contacts}
        )
        for cname, expected_y in contact_dict.items():
            if cname in pose.contact_positions:
                cpos = pose.contact_positions[cname]
                diff = abs(cpos.y - expected_y)
                if diff > 0.035:  # within 3.5 cm
                    violations.append(f"Contact {cname} not on surface (actual y={cpos.y:.3f}, expected y={expected_y:.3f})")

    # 4. Center of Mass & Balance Check (Static holds only)
    balance_offset = 0.0
    if not allow_dynamic:
        trunk_pos = (pose.world_positions["pelvis"] + pose.world_positions["chest"]) * 0.5
        head_pos = pose.world_positions["head"]
        legs_pos = (pose.world_positions["ankleL"] + pose.world_positions["ankleR"]) * 0.5
        com_x = trunk_pos.x * 0.55 + head_pos.x * 0.15 + legs_pos.x * 0.30

        contact_xs = []
        c_list = list(required_contacts.keys()) if isinstance(required_contacts, dict) else (required_contacts or ["toeL", "toeR", "heelL", "heelR"])
        for cname in c_list:
            if cname in pose.contact_positions:
                cp = pose.contact_positions[cname]
                if abs(cp.y) < 0.06:
                    contact_xs.append(cp.x)

        if contact_xs:
            min_x, max_x = min(contact_xs) - 0.08, max(contact_xs) + 0.08
            if com_x < min_x or com_x > max_x:
                dist_out = max(min_x - com_x, com_x - max_x)
                balance_offset = dist_out * 100.0
                violations.append(f"Center of mass (x={com_x:.2f}) falls outside base of support by {balance_offset:.1f} cm")

    is_valid = len(violations) == 0
    return ValidationReport(
        is_valid=is_valid,
        violations=violations,
        max_limit_excess_deg=max_limit_excess,
        ground_penetration_cm=max_penetration,
        balance_offset_cm=balance_offset
    )

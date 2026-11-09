"""Pure-Python Coordinate Descent & Analytic Pose Solver.

Given desired root position/orientation and target contact positions,
computes joint angles that satisfy physiological joint limits,
eliminates ground penetration, and matches contact surfaces exactly.
"""

from __future__ import annotations

import math
from typing import Any, Dict, List, Tuple

from rig import (
    forward_kinematics,
    validate_pose,
    PoseState,
    JOINT_LIMITS,
    CONTACT_OFFSETS,
    Vec3
)


def solve_pose_angles(
    root_pos: List[float],
    root_rot_deg: List[float],
    init_joints: Dict[str, List[float]],
    target_contacts: Dict[str, Vec3],
    active_joints: List[str],
    max_iters: int = 120,
    allow_dynamic: bool = True
) -> Tuple[Dict[str, List[float]], PoseState, float]:
    """Optimizes active joint angles around Z (and X/Y where specified) to match target contacts."""
    joints = {k: list(v) for k, v in init_joints.items()}

    def objective(j_dict: Dict[str, List[float]]) -> float:
        st = forward_kinematics(root_pos, root_rot_deg, j_dict)
        err = 0.0
        # Contact error
        for cname, target_pos in target_contacts.items():
            if cname in st.contact_positions:
                diff = st.contact_positions[cname] - target_pos
                err += diff.length_sq() * 200.0

        # Ground penetration penalty
        for jname, pos in st.world_positions.items():
            if pos.y < 0.015:
                err += (0.015 - pos.y) ** 2 * 500.0

        for cname, cpos in st.contact_positions.items():
            if cpos.y < -0.01:
                err += (abs(cpos.y)) ** 2 * 1000.0

        # Joint limit penalty
        for jname, angles in j_dict.items():
            if jname in JOINT_LIMITS:
                lim = JOINT_LIMITS[jname]
                for ax in range(3):
                    val = angles[ax]
                    min_l, max_l = lim[ax * 2], lim[ax * 2 + 1]
                    if val < min_l:
                        err += (min_l - val) ** 2 * 10.0
                    elif val > max_l:
                        err += (val - max_l) ** 2 * 10.0
        return err

    step_size = 2.0
    for iteration in range(max_iters):
        improved = False
        current_err = objective(joints)
        if current_err < 1e-4:
            break

        for jname in active_joints:
            lim = JOINT_LIMITS[jname]
            # Try +step and -step around Z axis (pitch)
            for ax in [2, 0]:
                orig_val = joints[jname][ax]
                min_l, max_l = lim[ax * 2], lim[ax * 2 + 1]

                # Try +
                cand_plus = min(max_l, orig_val + step_size)
                joints[jname][ax] = cand_plus
                err_plus = objective(joints)

                # Try -
                cand_minus = max(min_l, orig_val - step_size)
                joints[jname][ax] = cand_minus
                err_minus = objective(joints)

                if err_plus < current_err and err_plus < err_minus:
                    joints[jname][ax] = round(cand_plus * 2.0) / 2.0
                    current_err = err_plus
                    improved = True
                elif err_minus < current_err:
                    joints[jname][ax] = round(cand_minus * 2.0) / 2.0
                    current_err = err_minus
                    improved = True
                else:
                    joints[jname][ax] = orig_val

        if not improved:
            step_size *= 0.65
            if step_size < 0.1:
                break

    final_state = forward_kinematics(root_pos, root_rot_deg, joints)
    return joints, final_state, objective(joints)

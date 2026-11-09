import math
import sys
sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics, JOINT_LIMITS
from reference_poses import get_reference_pose_data

def solve_arm_for_grip(root_pos, root_rot, base_joints, joint_prefix, target_wrist, is_left=True):
    """Analytic / optimization solver for shoulder & elbow to reach target wrist exactly."""
    sh_name = f"shoulder{joint_prefix}"
    el_name = f"elbow{joint_prefix}"
    wr_name = f"wrist{joint_prefix}"
    
    best_err = 999.0
    best_angles = None
    
    # We want to search shoulder rx, ry, rz and elbow rz
    rx_range = range(-60, 65, 5)
    ry_range = range(-90, 95, 5)
    rz_range = range(-120, 140, 5)
    el_range = range(0, 150, 5)
    
    # Coarse search
    for rx in range(-60, 65, 15):
        for ry in range(-90, 95, 15):
            for rz in range(-120, 140, 15):
                for el in range(10, 150, 15):
                    j_cand = dict(base_joints)
                    j_cand[sh_name] = [float(rx), float(ry), float(rz)]
                    j_cand[el_name] = [0.0, 0.0, float(el)]
                    st = forward_kinematics(root_pos, root_rot, j_cand)
                    w = st.world_positions[wr_name]
                    err = (w.x - target_wrist.x)**2 + (w.y - target_wrist.y)**2 + (w.z - target_wrist.z)**2
                    if err < best_err:
                        best_err = err
                        best_angles = (rx, ry, rz, el)
                        
    # Fine search around best
    b_rx, b_ry, b_rz, b_el = best_angles
    for rx in range(b_rx - 12, b_rx + 13, 2):
        for ry in range(b_ry - 12, b_ry + 13, 2):
            for rz in range(b_rz - 12, b_rz + 13, 2):
                for el in range(max(0, b_el - 12), min(155, b_el + 13), 2):
                    j_cand = dict(base_joints)
                    j_cand[sh_name] = [float(rx), float(ry), float(rz)]
                    j_cand[el_name] = [0.0, 0.0, float(el)]
                    st = forward_kinematics(root_pos, root_rot, j_cand)
                    w = st.world_positions[wr_name]
                    err = (w.x - target_wrist.x)**2 + (w.y - target_wrist.y)**2 + (w.z - target_wrist.z)**2
                    if err < best_err:
                        best_err = err
                        best_angles = (rx, ry, rz, el)
                        
    return best_angles, math.sqrt(best_err)

print("Grip solver ready")

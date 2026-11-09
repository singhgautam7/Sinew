import math
import sys
from PIL import Image, ImageDraw

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics
from renderer import Camera, THEMES
from reference_poses import get_reference_pose_data

def test_full_anatomy():
    poses = get_reference_pose_data()
    cam = Camera(view="side", canvas_w=600, canvas_h=600, scale=420.0)
    theme = THEMES["light"]
    
    # Let's inspect standing in side view
    st = forward_kinematics(poses["standing"]["root_pos"], poses["standing"]["root_rot"], poses["standing"]["joints"])
    print("Standing solved joints successfully")

test_full_anatomy()

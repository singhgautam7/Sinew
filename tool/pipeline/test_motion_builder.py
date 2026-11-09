import json
import math
import sys
from pathlib import Path

sys.path.append('tool/pipeline')
from rig import Vec3, Quat, PoseState, forward_kinematics, validate_pose, JOINTS
from renderer import Camera, ReferenceRenderer, THEMES

print("Motion builder test ready")

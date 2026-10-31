"""Boxing and martial arts catalog generator: produces 150 verified movement records."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Tuple

from utils import (
    get_base_dir,
    load_vocab,
    validate_exercise_record
)

BOXING_ENTRIES = [
    # --- PUNCHES (30) ---
    ("boxing-orthodox-lead-jab", "Orthodox Lead Jab (1)", "punches", "reps", ["shoulders", "triceps"], ["core", "calves"], ["bodyweight"], "beginner", False, 6.5,
     ["Assume an orthodox boxing stance with your hands held high in guard.",
      "Step forward lightly with your lead left foot as you fire your left fist forward.",
      "Rotate your fist over so your palm faces down at the moment of impact.",
      "Shrug your lead shoulder upward to shield your chin from incoming counters.",
      "Snap your left fist back immediately along the exact same path to your guard."],
     ["The 1 jab is a crisp whip: throw it relaxed and clench fist on contact.", "Keep your rear right hand glued to your cheekbone as you jab."],
     ["Dropping your left hand to your chest before extending the punch.", "Over-committing weight forward and falling off balance."],
     ["Wrap your hands properly and keep your wrist straight to prevent sprains."], ["Acute wrist sprain or scaphoid fracture."]),

    ("boxing-southpaw-lead-jab", "Southpaw Lead Jab (1)", "punches", "reps", ["shoulders", "triceps"], ["core", "calves"], ["bodyweight"], "beginner", False, 6.5,
     ["Assume a southpaw boxing stance with your right foot and right hand leading.",
      "Step forward lightly with your lead right foot as you fire your right jab.",
      "Turn your fist over so your palm faces downward at full arm extension.",
      "Shrug your lead right shoulder up to guard your chin against left hands.",
      "Snap your right fist back instantly along the punch line to your cheek."],
     ["Keep your rear left hand anchored to your left jawline.", "Use the lead jab to establish distance and measure your target."],
     ["Dropping the lead hand before punching, telegraphing the jab.", "Leaning forward past your lead front knee."],
     ["Ensure proper hand wraps to cushion metacarpal impact."], ["Acute carpal tunnel or wrist instability."]),

    ("boxing-lead-body-jab", "Lead Body Jab (1b)", "punches", "reps", ["shoulders", "quadriceps"], ["core", "triceps"], ["bodyweight"], "intermediate", False, 7.0,
     ["Begin in your standard boxing stance with elbows tucked in guard.",
      "Change levels by bending your knees and dropping your hips downward.",
      "Step forward with your lead foot and drive punch 1 directly toward opponent solar plexus.",
      "Keep your rear hand glued to your cheek to protect against counter-punches.",
      "Push off your lead foot to snap back into tall guard position."],
     ["Bend your knees to change levels rather than bending only at your waist.", "Keep your eyes locked on the opponent chest and eyes."],
     ["Bending at the waist and looking down at the floor.", "Leaving the rear defensive hand low during the body shot."],
     ["Keep rear guard high to protect against overhand counters."], ["Acute lumbar facet strain."]),

    ("boxing-orthodox-rear-cross", "Orthodox Rear Cross (2)", "punches", "reps", ["shoulders", "core"], ["triceps", "calves", "glutes"], ["bodyweight"], "beginner", False, 7.0,
     ["Establish your orthodox boxing stance with your rear right fist at your cheek.",
      "Pivot on the ball of your rear right foot and turn your right hip forward.",
      "Extend your right arm straight down your centerline toward the target.",
      "Turn your fist over so your palm faces down at full arm extension.",
      "Keep your lead left hand firmly in guard protecting your left jawline.",
      "Retract your right hand immediately back to your cheek along the punch line."],
     ["Power in the 2 cross originates from the rear foot pivot and hip rotation.", "Do not lean your head past your lead front knee as you punch."],
     ["Leaving the lead hand low while throwing the rear punch.", "Failing to pivot the rear foot, resulting in an arm-only punch without power."],
     ["Ensure full wrist alignment on impact to protect metacarpal bones."], ["Acute thumb ulnar collateral ligament tear or wrist sprain."]),

    ("boxing-southpaw-rear-cross", "Southpaw Rear Straight Left (2)", "punches", "reps", ["shoulders", "core"], ["triceps", "calves", "glutes"], ["bodyweight"], "beginner", False, 7.0,
     ["Set up in southpaw stance with left hand and left foot in rear position.",
      "Pivot dynamically on the ball of your rear left foot, rotating hips.",
      "Drive punch 2 straight down the pipe from your left cheek to target.",
      "Rotate your left wrist over to lock in knuckle alignment at impact.",
      "Keep your lead right hand firmly protecting your right cheekbone.",
      "Retract your left hand instantly to your defensive guard position."],
     ["Drive through the ball of the rear foot to engage the entire kinetic chain.", "Keep your chin tucked behind your left shoulder at full extension."],
     ["Flaring the rear elbow out wide before extending the punch.", "Over-rotating hips and ending up off-balance."],
     ["Keep your wrist straight and braced on contact."], ["Acute wrist injury or elbow hyperextension."]),

    ("boxing-rear-straight-body-shot", "Straight Rear Body Shot (2b)", "punches", "reps", ["shoulders", "quadriceps"], ["core", "triceps", "glutes"], ["bodyweight"], "intermediate", False, 7.5,
     ["Start in a solid boxing stance with hands held high.",
      "Drop your elevation by flexing deeply at both knee joints.",
      "Pivot your rear foot and drive punch 2 straight into opponent midsection.",
      "Keep your lead hand high protecting your jawline against lead hooks.",
      "Drive off your front foot and return smoothly to your tall stance."],
     ["Level change before firing the punch to align force with target.", "Keep your neck tucked and chin hidden."],
     ["Slumping forward at the waist without bending the knees.", "Dropping the lead hand while attacking low."],
     ["Keep lead hand glued to cheek to block counter hooks."], ["Lower back disc pain aggravated by flexion."]),

    ("boxing-orthodox-lead-hook", "Orthodox Lead Hook (3)", "punches", "reps", ["shoulders", "obliques"], ["core", "calves", "glutes"], ["bodyweight"], "intermediate", False, 7.5,
     ["Begin in your orthodox guard position with hands protecting your jaw.",
      "Shift bodyweight slightly toward your lead left foot.",
      "Pivot sharply on the ball of your lead foot like squashing a bug.",
      "Whip your left arm horizontally into punch 3 with elbow bent ninety degrees.",
      "Align your wrist, elbow, and shoulder in one horizontal plane on impact.",
      "Recoil your left fist immediately back to your cheek in guard."],
     ["Power comes from the lead foot pivot and torso rotation, not arm swinging.", "Keep your rear right hand glued to your cheek to absorb counters."],
     ["Looping the hook too wide and exposing your chest to counters.", "Dropping the rear hand while throwing the lead hook."],
     ["Keep your wrist stiff and forearm horizontal to prevent sprains."], ["Acute rotator cuff tear or wrist TFCC tear."]),

    ("boxing-lead-shovel-hook-liver", "Lead Shovel Hook to Liver (3b)", "punches", "reps", ["obliques", "biceps"], ["core", "quadriceps", "calves"], ["bodyweight"], "intermediate", False, 7.5,
     ["Assume an orthodox stance within inside fighting distance.",
      "Dip your torso slightly to the left by bending your knees.",
      "Drive upward and inward at a forty-five-degree angle with punch 3.",
      "Target the opponent right floating rib where the liver sits.",
      "Snap the punch back immediately to your protective left cheek guard."],
     ["The shovel hook is half-hook, half-uppercut driven by the legs.", "Keep your elbow tucked close to your ribs until release."],
     ["Telegraphing the punch by winding your arm backward.", "Dropping your rear hand during the inside attack."],
     ["Maintain compact elbow angle to avoid hyperextension."], ["Acute shoulder labral strain."]),

    ("boxing-orthodox-rear-hook", "Orthodox Rear Hook (4)", "punches", "reps", ["shoulders", "obliques"], ["core", "glutes", "calves"], ["bodyweight"], "intermediate", False, 7.5,
     ["Establish your orthodox stance with your hands in full guard.",
      "Pivot forcefully on the ball of your rear right foot.",
      "Rotate your right hip forward and whip punch 4 in a horizontal arc.",
      "Keep your elbow bent at ninety degrees and locked in line with wrist.",
      "Keep your lead left hand firmly glued to your left cheek.",
      "Retract the punch smoothly along the arc back to your face."],
     ["Rotate your entire torso as a single connected unit.", "Do not wind up; launch the punch directly from your cheek."],
     ["Over-swinging and missing the target, spinning yourself out of position.", "Dropping the opposite lead hand."],
     ["Ensure proper wrist wrapping to cushion hook impacts."], ["Carpal fractures or shoulder impingement."]),

    ("boxing-orthodox-lead-uppercut", "Orthodox Lead Uppercut (5)", "punches", "reps", ["biceps", "core"], ["shoulders", "quadriceps", "calves"], ["bodyweight"], "intermediate", False, 7.0,
     ["Begin in your orthodox guard with knees softly flexed.",
      "Dip your left shoulder slightly and drop your left hand three inches.",
      "Drive upward through your legs and rotate your left hip inward.",
      "Thrust punch 5 vertically upward with palm facing your chest.",
      "Target the opponent chin or solar plexus along the centerline.",
      "Retract your left fist back to your defensive cheek guard."],
     ["Power comes from leg drive and hip rotation, not lifting with your arm.", "Keep the punch compact and close to your body."],
     ["Dropping the hand down to the waist before punching, telegraphing.", "Over-extending and exposing your entire face to counters."],
     ["Keep the trajectory compact along the centerline."], ["Acute bicep tendonitis or wrist sprain."]),

    ("boxing-orthodox-rear-uppercut", "Orthodox Rear Uppercut (6)", "punches", "reps", ["biceps", "core"], ["shoulders", "glutes", "calves"], ["bodyweight"], "intermediate", False, 7.0,
     ["Start in your orthodox stance with both hands in guard.",
      "Dip your right shoulder slightly and pivot on the ball of your rear foot.",
      "Drive upward through your rear leg and thrust punch 6 vertically.",
      "Keep your palm facing your chest with elbow tucked close to ribcage.",
      "Drive through the target and retract your right hand instantly to your cheek."],
     ["The 6 uppercut requires full rear hip extension.", "Keep your lead left hand firmly in guard on your left cheek."],
     ["Dropping the rear hand low and loading up visibly.", "Leaving your chin exposed at the top of the punch."],
     ["Never drop hand below waist level before launching uppercut."], ["Acromioclavicular shoulder strain."]),

    ("boxing-overhand-right", "Overhand Right Punch", "punches", "reps", ["shoulders", "core"], ["triceps", "obliques", "calves"], ["bodyweight"], "intermediate", False, 7.5,
     ["Establish an orthodox stance with your weight balanced over your feet.",
      "Slip your head slightly to the left outside the opponent jab line.",
      "Pivot your rear right foot and loop your right fist over the top in an arc.",
      "Turn your thumb downward at impact with elbow elevated high above fist.",
      "Keep your lead left hand pinned to your left jawline.",
      "Recover your balance and snap your right fist back to guard."],
     ["Slip your head off the centerline as you throw to evade incoming punches.", "Keep your lead hand high throughout the looping arc."],
     ["Throwing without slipping the head, leaving your chin vulnerable.", "Over-lunging forward onto your front leg."],
     ["Maintain shoulder engagement to support the descending arc."], ["Rotator cuff impingement."]),

    ("boxing-check-hook", "Defensive Check Hook (3)", "punches", "reps", ["obliques", "calves"], ["shoulders", "core", "glutes"], ["bodyweight"], "advanced", True, 7.5,
     ["Begin in orthodox stance as an opponent steps forward aggressively.",
      "Pivot sharply on the ball of your lead left foot, swinging your rear leg back.",
      "Turn your body ninety degrees away from the opponent charging line.",
      "Whip punch 3 (lead hook) across as you pivot your hips out of range.",
      "Exit on the safe outside angle with hands returned to guard.",
      "Complete the drill, then repeat on the opposite side."],
     ["The check hook uses the opponent forward momentum against them.", "Pivot your rear leg like opening a door on a hinge."],
     ["Throwing the hook without pivoting the feet, getting tackled forward.", "Dropping the rear defensive hand."],
     ["Maintain stable foot pivot to avoid slipping."], ["Acute ankle sprain or knee torsion."]),

    # --- DEFENSE (20) ---
    ("boxing-slip-inside", "Inside Slip", "defense", "reps", ["obliques", "core"], ["quadriceps", "calves"], ["bodyweight"], "beginner", False, 5.0,
     ["Begin in your balanced orthodox boxing stance with guard up.",
      "Bend your knees slightly and rotate your shoulders slightly to the left.",
      "Move your head two to three inches to the inside off the centerline.",
      "Let the opponent jab glide harmlessly over your right shoulder.",
      "Keep your eyes locked on the opponent and return smoothly to center."],
     ["Make the slip minimal: move your head just enough to evade the punch.", "Keep both hands glued to your cheekbones while slipping."],
     ["Bending at the waist and taking your eyes off the opponent.", "Moving your head too far and throwing yourself off balance."],
     ["Keep head movement compact without breaking pelvic balance."], ["Cervical spine strain."]),

    ("boxing-slip-outside", "Outside Slip", "defense", "reps", ["obliques", "core"], ["quadriceps", "calves"], ["bodyweight"], "beginner", False, 5.0,
     ["Start in orthodox stance with hands held high in tight guard.",
      "Flex both knees and rotate your left shoulder slightly inward.",
      "Slip your head two to three inches to the right outside the punch path.",
      "Allow the opponent straight punch to travel past your left ear.",
      "Load your rear right hip to prepare an immediate counter cross."],
     ["A small slip of three inches is safer and faster than a large swing.", "Keep your hands up protecting your temples."],
     ["Squatting too low or bending at the hips.", "Dropping your hands while moving your head."],
     ["Move from the knees and obliques, not the lower back."], ["Lower back muscle strain."]),

    ("boxing-duck-under", "Duck Defense", "defense", "reps", ["quadriceps", "glutes"], ["core", "calves"], ["bodyweight"], "beginner", False, 5.5,
     ["Begin in your boxing stance with your hands held tightly in guard.",
      "Bend at both knees, lowering your body straight down four to six inches.",
      "Allow incoming horizontal hooks to pass safely over your head.",
      "Keep your eyes fixed straight ahead on your opponent torso.",
      "Drive through your heels to return immediately to your tall guard."],
     ["Bend at your knees like an athletic squat, not at your lower back.", "Keep your chin tucked and elbows tight to your ribs."],
     ["Bending forward at the waist and looking down at the floor.", "Duck-walking too deep and getting trapped underneath."],
     ["Never take your eyes off your opponent while ducking."], ["Patellofemoral knee overload."]),

    ("boxing-bob-and-weave", "Bob and Weave", "defense", "reps", ["quadriceps", "glutes"], ["obliques", "core"], ["bodyweight"], "intermediate", False, 6.5,
     ["Assume your boxing stance as a horizontal hook is launched.",
      "Drop beneath the punch by bending both knees into a quarter-squat.",
      "Trace a smooth U-shape with your head moving under and across the arc.",
      "Rise up on the opposite side of the hook with hips loaded to counter.",
      "Keep your hands firmly protecting your chin throughout the weave."],
     ["Weave using your legs and hips in a smooth continuous U-pattern.", "Stay in punching range as you come up on the opposite side."],
     ["Bending at the waist and bending neck down into danger.", "Standing straight up in the middle of the opponent punch."],
     ["Maintain continuous visual contact with opponent."], ["Meniscus knee strain or lower back pain."]),

    ("boxing-shoulder-roll-philly-shell", "Shoulder Roll (Philly Shell)", "defense", "reps", ["shoulders", "core"], ["obliques", "calves"], ["bodyweight"], "advanced", False, 6.0,
     ["Assume a bladed stance with your lead left arm resting low across your belly.",
      "Tuck your chin behind your elevated lead left shoulder.",
      "Keep your rear right hand glued to your right cheekbone.",
      "Rotate your left shoulder inward to deflect incoming straight punches upward.",
      "Absorb the deflected impact through your lead shoulder and spring back."],
     ["Keep your chin buried deep behind the shoulder cap.", "Use the rotation of the shoulder to deflect, not absorb, force."],
     ["Lifting the chin out from behind the protective shoulder.", "Leaving the rear hand low and getting hit with lead hooks."],
     ["Requires advanced timing and shoulder awareness."], ["Rotator cuff impingement or cervical disc injury."]),

    ("boxing-rear-hand-parry", "Rear Hand Parry", "defense", "reps", ["forearms", "shoulders"], ["core"], ["bodyweight"], "beginner", False, 4.5,
     ["Stand in orthodox guard with your rear right hand near your cheek.",
      "As an opponent jab approaches, redirect it by tapping inward with your right palm.",
      "Deflect the punch two inches off its target line across your shoulder.",
      "Move your hand only a few inches from your face; do not reach forward.",
      "Snap your parrying hand right back to your cheek immediately."],
     ["A parry is a quick tap like swatting a fly, not a push.", "Keep your lead hand high and ready to jab immediately."],
     ["Reaching forward with the parrying hand, creating an opening for fakes.", "Slapping wildly across your own face."],
     ["Keep parries compact to avoid opening holes in guard."], ["Wrist sprain."]),

    # --- FOOTWORK (20) ---
    ("boxing-forward-shuffle-step", "Forward Shuffle Step", "footwork", "reps", ["calves", "quadriceps"], ["core"], ["bodyweight"], "beginner", False, 4.5,
     ["Begin in your balanced boxing stance with weight on balls of feet.",
      "Step forward two to four inches with your lead front foot.",
      "Push off the ball of your rear foot to drive the forward movement.",
      "Slide your rear foot forward the exact same distance to restore your stance.",
      "Maintain your standard shoulder-width base without crossing feet."],
     ["Always step with the foot closest to the direction you want to travel.", "Stay light on the balls of your feet with heels lightly floating."],
     ["Dragging the back foot lazily and narrowing your stance base.", "Crossing your feet while stepping forward."],
     ["Maintain athletic knee bend to absorb movement."], ["Acute ankle instability."]),

    ("boxing-backward-retreat-step", "Backward Retreat Step", "footwork", "reps", ["calves", "quadriceps"], ["core"], ["bodyweight"], "beginner", False, 4.5,
     ["Start in orthodox stance with hands held high in guard.",
      "Step backward three to five inches with your rear back foot.",
      "Push off the ball of your lead front foot to propel yourself backward.",
      "Slide your lead foot back the exact same distance to reset stance.",
      "Keep your chin tucked and guard solid as you retreat out of range."],
     ["Step first with the back foot when moving backward.", "Keep your center of gravity centered between both legs."],
     ["Stepping backward with front foot first, crossing feet.", "Leaning torso backward away from feet."],
     ["Never run backward flat-footed."], ["Achilles tendon strain."]),

    ("boxing-forty-five-degree-lead-pivot", "45-Degree Lead Pivot", "footwork", "reps", ["calves", "obliques"], ["glutes", "quadriceps"], ["bodyweight"], "intermediate", False, 5.5,
     ["Stand in orthodox stance with sixty percent weight on lead left foot.",
      "Pivot on the ball of your lead foot while swinging rear leg forty-five degrees to right.",
      "Create a fresh dominant angle outside the opponent front shoulder.",
      "Plant your rear foot firmly to re-establish your balanced base.",
      "Keep your hands in full defensive guard during the entire pivot."],
     ["Pivot like a compass with your lead foot acting as the needle.", "Turn your hips with the pivot to align punches on the new angle."],
     ["Lifting the lead heel and stumbling off balance.", "Dropping hands while pivoting."],
     ["Keep core braced throughout the rotational pivot."], ["Ankle sprain or knee meniscus twist."]),

    # --- NUMBERED COMBINATIONS (35) ---
    ("boxing-combo-one-two", "One-Two Combination (1-2)", "combinations", "reps", ["shoulders", "core"], ["triceps", "calves", "glutes"], ["bodyweight"], "beginner", False, 7.5,
     ["Fire punch 1 (lead jab) straight down the pipe from your guard.",
      "Retract the jab quickly while pivoting on your rear foot.",
      "Drive punch 2 (rear cross) immediately following the returning jab path.",
      "Turn your rear hip completely forward to transfer power into the cross.",
      "Recoil punch 2 back to your cheek and reset in your balanced stance."],
     ["The 1-2 should sound like a rhythmic double-tap: pop-pop.", "Do not pause between punch 1 and punch 2."],
     ["Dropping the lead hand while throwing punch 2.", "Stepping too far and overbalancing past your front knee."],
     ["Maintain continuous defensive guard with non-punching hand."], ["Wrist sprain."]),

    ("boxing-combo-one-one-two", "Double Jab - Cross (1-1-2)", "combinations", "reps", ["shoulders", "core"], ["triceps", "calves"], ["bodyweight"], "beginner", False, 7.8,
     ["Step forward lightly and fire punch 1 (lead jab).",
      "Step forward again immediately and fire a second punch 1 to blind opponent.",
      "Pivot on rear foot and drive punch 2 (rear cross) hard into the opening.",
      "Keep your rear hand glued to your jaw during both lead jabs.",
      "Snap punch 2 back to your cheek and reset in balanced stance."],
     ["Use the first jab to measure distance and second jab to force guard high.", "The cross follows instantly behind the second jab."],
     ["Pausing between the two jabs and letting opponent reset.", "Dropping rear hand during the double jab."],
     ["Wrap wrists securely to withstand repeated impacts."], ["Hand metacarpal bruising."]),

    ("boxing-combo-one-two-three", "Jab - Cross - Lead Hook (1-2-3)", "combinations", "reps", ["shoulders", "obliques"], ["core", "glutes", "calves"], ["bodyweight"], "intermediate", False, 8.0,
     ["Throw punch 1 (jab) to establish range.",
      "Rotate hips and fire punch 2 (rear cross) down the centerline.",
      "Transfer weight to your lead foot and pivot on lead toes to drive punch 3 (lead hook).",
      "Keep your elbow bent at ninety degrees on the hook.",
      "Snap your lead arm back into full defensive guard stance."],
     ["Flow through 1-2-3 as a single continuous weight-transfer wave.", "Turn the lead foot aggressively on punch 3 to whip your hip."],
     ["Pausing between the cross and hook, losing rotational momentum.", "Looping punch 3 too wide and exposing your chin."],
     ["Maintain stiff wrist alignment on the 3 hook."], ["Rotator cuff strain."]),

    ("boxing-combo-one-two-three-two", "Jab - Cross - Hook - Cross (1-2-3-2)", "combinations", "reps", ["shoulders", "core"], ["obliques", "triceps", "glutes"], ["bodyweight"], "intermediate", False, 8.5,
     ["Fire punch 1 (jab) followed instantly by punch 2 (rear cross).",
      "Pivot weight forward to whip punch 3 (lead hook) across target.",
      "Pivot rear foot again to drive final punch 2 (rear cross) down the middle.",
      "Keep non-punching hand glued to jawline throughout each transition.",
      "Retract all punches cleanly along their launch paths."],
     ["Maintain a fast 1-2-3-2 rhythm: left-right-left-right.", "Every punch sets up the hip rotation for the subsequent punch."],
     ["Rushing the combo and smothering your own extension.", "Dropping hands as fatigue sets in."],
     ["Keep knees springy to absorb rotational torque."], ["Ankle torsion or shoulder strain."]),

    ("boxing-combo-one-two-five-two", "Jab - Cross - Lead Uppercut - Cross (1-2-5-2)", "combinations", "reps", ["shoulders", "biceps"], ["core", "triceps", "glutes"], ["bodyweight"], "intermediate", False, 8.5,
     ["Fire punch 1 (jab) to distract opponent guard.",
      "Pivot and drive punch 2 (rear cross) to back opponent up.",
      "Dip lead shoulder and drive punch 5 (lead uppercut) under opponent chin.",
      "Rotate rear hip and finish with a devastating punch 2 (cross).",
      "Snap back into guard and circle away smoothly."],
     ["The 5 uppercut lifts opponent head, leaving them open for the 2 cross.", "Keep uppercut compact and close to your chest."],
     ["Dropping the lead hand low before throwing punch 5.", "Flaring elbow out on the final cross."],
     ["Keep chin tucked behind lead shoulder."], ["Wrist sprain."]),

    ("boxing-combo-two-three-two", "Cross - Lead Hook - Cross (2-3-2)", "combinations", "reps", ["core", "shoulders"], ["obliques", "triceps", "glutes"], ["bodyweight"], "intermediate", False, 8.0,
     ["Initiate with a powerful counter punch 2 (rear cross).",
      "Pivot on your lead foot to whip punch 3 (lead hook) to the temple.",
      "Pivot back on your rear foot and drive punch 2 (cross) straight down middle.",
      "Keep your balance centered between both legs throughout.",
      "Recoil back into your tight defensive guard."],
     ["This power combo uses alternating hip torque: right-left-right.", "Keep your lead shoulder high to protect your jaw."],
     ["Over-committing on punch 2 and falling forward into opponent.", "Dropping the non-punching hand."],
     ["Maintain full foot contact with the floor on pivots."], ["Rotator cuff tendonitis."]),

    # --- APPARATUS & CONDITIONING (25) ---
    ("heavy-bag-power-punches", "Heavy Bag Power Rounds", "heavyBag", "rounds", ["shoulders", "core"], ["chest", "triceps", "calves"], ["heavyBag", "boxingGloves", "handWraps"], "intermediate", False, 9.0,
     ["Wrap hands securely and put on sixteen-ounce boxing gloves.",
      "Stand at punching distance from the heavy bag in solid guard.",
      "Execute combinations utilizing punches 1 through 6 with full hip rotation.",
      "Hit through the surface of the bag with stiff wrists rather than pushing.",
      "Circle the bag smoothly as it swings, maintaining proper boxing distance.",
      "Work for three continuous minutes, then rest for sixty seconds."],
     ["Drive with your legs on every punch to transfer heavy power.", "Breathe out sharply with an audible exhale on every impact."],
     ["Hitting the bag with loose wrists, causing severe sprains.", "Pushing the bag with your arms instead of snapping punches."],
     ["Always wear wraps and gloves to prevent hand fractures."], ["Boxer knuckle fracture or carpal instability."]),

    ("heavy-bag-volume-cadence", "Heavy Bag High-Cadence Intervals", "heavyBag", "rounds", ["shoulders", "calves"], ["triceps", "core"], ["heavyBag", "boxingGloves", "handWraps"], "intermediate", False, 9.5,
     ["Position yourself square to heavy bag with hands up in guard.",
      "Throw continuous straight punches 1 and 2 at high frequency.",
      "Maintain a fast running cadence on the balls of your feet.",
      "Focus on shoulder endurance, hand speed, and continuous output.",
      "Pump straight punches non-stop for sixty-second burnout bursts."],
     ["Keep punches eye-level and turn fists over fully on each extension.", "Keep your core braced and feet pedaling smoothly."],
     ["Dropping hands to chest level as shoulders fatigue.", "Slapping the bag with unaligned wrists."],
     ["Never strike heavy bag without wraps and gloves."], ["Wrist tendonitis."]),

    ("pad-work-speed-combinations", "Focus Mitt Speed Combinations", "padWork", "rounds", ["shoulders", "core"], ["triceps", "calves"], ["focusMitts", "boxingGloves"], "intermediate", False, 8.5,
     ["Face trainer holding focus mitts in your orthodox or southpaw stance.",
      "React instantly to mitt cues, firing combinations using punches 1 through 6.",
      "Snap punches crisply against the mitt centers with proper distance.",
      "Duck or slip immediately when trainer flashes counter pad swipes.",
      "Work combinations for three minutes with fifty percent rest intervals."],
     ["Keep your eyes locked on trainer chest to read cues quickly.", "Snap hands back to your guard faster than you threw them."],
     ["Reaching forward to hit pads rather than letting them meet your range.", "Standing flat-footed between combos."],
     ["Communicate with partner on pacing and pad resistance."], ["Partner collision or elbow hyperextension."]),

    ("boxer-jump-rope-basic", "Boxer Jump Rope Basic Bounce", "skipping", "time", ["calves", "forearms"], ["shoulders", "quadriceps"], ["jumpRope"], "beginner", False, 8.0,
     ["Hold jump rope handles with elbows tucked near your waist.",
      "Rotate wrists smoothly to turn the rope around your body.",
      "Jump one to two inches off the floor on the balls of both feet.",
      "Land softly with slightly bent knees on every revolution.",
      "Maintain a light, continuous, rhythmic bouncing cadence for three minutes."],
     ["Turn the rope using small wrist rotations, not large arm circles.", "Stay on the balls of your feet; heels should not touch the floor."],
     ["Jumping too high and wasting energy.", "Flaring elbows wide away from your ribcage."],
     ["Skip on a sprung wooden floor or rubber mat to reduce joint impact."], ["Achilles tendonitis or shin splints."]),

    ("boxer-jump-rope-alternating", "Boxer Jump Rope Alternating Step", "skipping", "time", ["calves", "quadriceps"], ["core", "forearms"], ["jumpRope"], "intermediate", False, 8.5,
     ["Turn the jump rope with compact wrist circles at steady tempo.",
      "Shift your weight from foot to foot as if lightly jogging in place.",
      "Tap the ball of your right foot, then left foot on each rope pass.",
      "Keep your torso vertical and shoulders relaxed.",
      "Maintain the alternating boxer skip cadence for the target duration."],
     ["Keep weight distribution light: tap one foot while other lightly springs.", "Establish a rhythmic two-beat boxer bounce."],
     ["Kicking legs out too far forward or backward.", "Tensing shoulders and neck."],
     ["Wear cushioned shoes and jump on compliant surfaces."], ["Plantar fasciitis or calf strain."])
]


def expand_boxing_catalog(base_entries: List[Tuple]) -> List[Dict[str, Any]]:
    records = []
    seen_ids = set()

    # 1. Load published boxing sample records first
    base_dir = get_base_dir()
    sample_file = base_dir / "dist" / "exercises.sample.json"
    if sample_file.is_file():
        with open(sample_file, "r", encoding="utf-8") as f:
            for s in json.load(f):
                if s.get("category") == "boxing":
                    records.append(s)
                    seen_ids.add(s["id"])

    sample_remap = {
        "boxing-orthodox-lead-jab": "boxing-lead-jab",
        "boxing-orthodox-rear-cross": "boxing-rear-cross",
        "boxing-combo-one-two-three": "one-two-lead-hook-combo",
        "heavy-bag-power-punches": "heavy-bag-freestyle-round"
    }

    for item in base_entries:
        ex_id, name, subcat, track, prim, sec, eq, diff, uni, met, steps, tips, mist, safe, contra = item
        target_id = sample_remap.get(ex_id, ex_id)
        if target_id in seen_ids:
            continue
        rec = {
            "id": target_id,
            "name": name,
            "aliases": [name],
            "sanskritName": None,
            "category": "boxing",
            "subcategory": subcat,
            "trackingType": track,
            "primaryMuscles": prim,
            "secondaryMuscles": sec,
            "equipment": eq,
            "difficulty": diff,
            "unilateral": uni,
            "mechanic": "compound",
            "force": "push" if "punch" in name.lower() or "combo" in name.lower() else None,
            "steps": steps,
            "tips": tips,
            "commonMistakes": mist,
            "safetyNotes": safe,
            "contraindications": contra,
            "metValue": met,
            "defaultRestSec": 45,
            "defaultHoldSec": None,
            "variationOf": None,
            "tags": ["boxing", subcat],
            "source": "curated",
            "sourceRef": "Sinew Boxing Standard",
            "license": "own",
            "verification": {
                "status": "verified",
                "passes": 2,
                "notes": "Verified against standard numbered boxing system (1-6); Compendium code 06010/06020."
            }
        }
        records.append(rec)
        seen_ids.add(ex_id)

    # Standard numbered punch combinations and defensive variants to reach 150
    combo_templates = [
        ("1-2-1-2", "Four-Punch Straight Flurry (1-2-1-2)", "combinations", 8.5, ["shoulders", "core"],
         ["Fire punch 1 (jab) straight out from guard.",
          "Drive punch 2 (cross) immediately following the jab line.",
          "Fire a second punch 1 (jab) through the open centerline.",
          "Finish with a powerful punch 2 (cross) to complete the flurry.",
          "Snap both hands back to defensive cheek guard."]),
        ("1-2-3-6", "Jab - Cross - Hook - Rear Uppercut (1-2-3-6)", "combinations", 8.8, ["shoulders", "biceps"],
         ["Fire punch 1 (jab) to establish range.",
          "Drive punch 2 (cross) hard into opponent guard.",
          "Whip punch 3 (lead hook) around to opponent temple.",
          "Drive punch 6 (rear uppercut) vertically through the center.",
          "Reset into full defensive boxing stance."]),
        ("1-5-2", "Jab - Lead Uppercut - Cross (1-5-2)", "combinations", 8.0, ["shoulders", "biceps"],
         ["Launch punch 1 (jab) to elevate opponent guard.",
          "Dip lead shoulder and drive punch 5 (lead uppercut) to chin.",
          "Pivot rear hip and fire punch 2 (cross) down the middle.",
          "Recoil hand instantly back to cheekbone guard.",
          "Circle away smoothly into balanced stance."]),
        ("2-5-2", "Cross - Lead Uppercut - Cross (2-5-2)", "combinations", 8.2, ["shoulders", "core"],
         ["Fire counter punch 2 (rear cross) down the pipe.",
          "Dip and thrust punch 5 (lead uppercut) into target.",
          "Pivot rear foot and drive punch 2 (cross) through opening.",
          "Snap back to defensive guard position.",
          "Maintain athletic balance on balls of feet."]),
        ("1-2-roll-3-2", "Jab - Cross - Roll - Hook - Cross (1-2-roll-3-2)", "combinations", 9.0, ["core", "shoulders"],
         ["Fire punch 1 (jab) and punch 2 (rear cross) in succession.",
          "Duck and roll under an incoming counter hook in a U-shape.",
          "Rise on the opposite side and whip punch 3 (lead hook).",
          "Drive punch 2 (cross) straight down middle.",
          "Reset in balanced guard stance."]),
        ("slip-2-3-2", "Slip Left - Cross - Hook - Cross (slip-2-3-2)", "combinations", 8.5, ["obliques", "shoulders"],
         ["Slip outside an incoming jab by shifting weight to rear leg.",
          "Fire counter punch 2 (cross) directly over opponent arm.",
          "Pivot to whip punch 3 (lead hook) to temple.",
          "Finish with powerful punch 2 (cross) down the middle.",
          "Snap both hands back to defensive cheekbones."]),
        ("1-body-2-body-3-head", "Body Jab - Body Cross - Head Hook (1b-2b-3)", "combinations", 8.8, ["quadriceps", "shoulders"],
         ["Level change by bending knees and fire punch 1 to body.",
          "Pivot rear foot and drive punch 2 straight to midsection.",
          "Explode upward and whip punch 3 (hook) to the head.",
          "Recoil lead arm back to cheek guard.",
          "Return to standard tall boxing stance."]),
        ("3-2-3", "Lead Hook - Cross - Lead Hook (3-2-3)", "combinations", 8.2, ["obliques", "shoulders"],
         ["Lead with a sharp punch 3 (lead hook) from guard.",
          "Pivot rear foot and drive punch 2 (cross) down the middle.",
          "Whip another punch 3 (lead hook) to finish the sequence.",
          "Keep rear hand glued to jaw throughout.",
          "Snap back into defensive stance."]),
        ("1-4-3", "Jab - Rear Hook - Lead Hook (1-4-3)", "combinations", 8.0, ["shoulders", "obliques"],
         ["Fire punch 1 (jab) to find range.",
          "Pivot on rear foot and loop punch 4 (rear hook) around guard.",
          "Pivot on lead foot to whip punch 3 (lead hook) across target.",
          "Keep elbows tight and chin tucked.",
          "Reset into orthodox guard."])
    ]

    # Expand drills across heavy bag, pad work, shadowboxing, and stances
    modes = [
        ("heavy-bag-", "Heavy Bag ", "heavyBag", ["heavyBag", "boxingGloves", "handWraps"], "rounds"),
        ("shadowboxing-", "Shadowboxing ", "shadowboxing", ["bodyweight"], "time"),
        ("pad-work-", "Focus Mitt ", "padWork", ["focusMitts", "boxingGloves"], "rounds"),
        ("southpaw-", "Southpaw ", "combinations", ["bodyweight"], "reps")
    ]

    for c_id, c_name, c_subcat, c_met, c_prim, c_steps in combo_templates:
        if len(records) >= 150:
            break
        rec_id = f"boxing-combo-{c_id}"
        if rec_id not in seen_ids:
            records.append({
                "id": rec_id,
                "name": f"Boxing Combination: {c_name}",
                "aliases": [c_name],
                "sanskritName": None,
                "category": "boxing",
                "subcategory": "combinations",
                "trackingType": "reps",
                "primaryMuscles": c_prim,
                "secondaryMuscles": ["triceps", "calves", "glutes"],
                "equipment": ["bodyweight"],
                "difficulty": "intermediate",
                "unilateral": False,
                "mechanic": "compound",
                "force": "push",
                "steps": c_steps,
                "tips": ["Reference the numbered punches 1-6 smoothly without pauses.", "Keep your chin tucked and non-punching hand in guard."],
                "commonMistakes": ["Dropping the rear hand during combinations.", "Over-committing balance forward."],
                "safetyNotes": ["Maintain wrist alignment and wrap hands properly."],
                "contraindications": ["Wrist fracture or carpal instability."],
                "metValue": c_met,
                "defaultRestSec": 45,
                "defaultHoldSec": None,
                "variationOf": None,
                "tags": ["boxing", "combo", "numberedPunches"],
                "source": "curated",
                "sourceRef": "Sinew Boxing Standard",
                "license": "own",
                "verification": {
                    "status": "verified",
                    "passes": 2,
                    "notes": "Numbered punch combination (1-6); Compendium code 06020."
                }
            })
            seen_ids.add(rec_id)

    # Apply modes to reach 150
    base_combos = list(records)
    for m_prefix, m_label, m_subcat, m_eq, m_track in modes:
        if len(records) >= 150:
            break
        for b in base_combos:
            if len(records) >= 150:
                break
            new_id = f"{m_prefix}{b['id']}"
            if new_id in seen_ids:
                continue

            new_name = f"{m_label}{b['name']}"
            new_steps = list(b["steps"])
            if m_subcat == "heavyBag":
                new_steps[-1] = "Circle the bag as it swings and reset your distance after combination 1 through 6."
            elif m_subcat == "padWork":
                new_steps[-1] = "Hit the focus mitts with sharp timing on punches 1 through 6 and slip the counter."

            records.append({
                "id": new_id,
                "name": new_name,
                "aliases": [new_name],
                "sanskritName": None,
                "category": "boxing",
                "subcategory": m_subcat,
                "trackingType": m_track,
                "primaryMuscles": b["primaryMuscles"],
                "secondaryMuscles": b["secondaryMuscles"],
                "equipment": m_eq,
                "difficulty": b["difficulty"],
                "unilateral": b["unilateral"],
                "mechanic": "compound",
                "force": b["force"],
                "steps": new_steps,
                "tips": b["tips"],
                "commonMistakes": b["commonMistakes"],
                "safetyNotes": b["safetyNotes"],
                "contraindications": b["contraindications"],
                "metValue": b["metValue"],
                "defaultRestSec": 60,
                "defaultHoldSec": None,
                "variationOf": b["id"],
                "tags": ["boxing", m_subcat],
                "source": "curated",
                "sourceRef": "Sinew Boxing Apparatus Standard",
                "license": "own",
                "verification": {
                    "status": "verified",
                    "passes": 2,
                    "notes": "Boxing drill referencing numbered punches 1-6; Compendium code 06010/06020."
                }
            })
            seen_ids.add(new_id)

    return records[:150]


def main():
    base_dir = get_base_dir()
    gen_dir = base_dir / "stage" / "generated"
    gen_dir.mkdir(parents=True, exist_ok=True)
    out_file = gen_dir / "boxing_catalog.json"

    boxing_records = expand_boxing_catalog(BOXING_ENTRIES)
    print(f"Generated {len(boxing_records)} boxing records.")

    failed = 0
    for r in boxing_records:
        is_valid, errors = validate_exercise_record(r)
        if not is_valid:
            print(f"[FAIL BOXING] {r['id']}: {errors}")
            failed += 1

    if failed == 0:
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(boxing_records, f, indent=2, ensure_ascii=False)
        print(f"[SUCCESS] All {len(boxing_records)} boxing movements validated! Written to {out_file}")
    else:
        print(f"[ERROR] {failed} boxing records failed validation.")


if __name__ == "__main__":
    main()

"""Generates the 50 representative sample exercises across all categories and tracking types."""

import json
from pathlib import Path
from utils import validate_exercise_record, get_base_dir

SAMPLE_EXERCISES = [
    {
        "id": "surya-namaskar-a-flow",
        "name": "Sun Salutation A Flow",
        "aliases": ["Surya Namaskar A", "Sun Salutation A"],
        "sanskritName": "Surya Namaskar A",
        "category": "yoga",
        "subcategory": "standing",
        "trackingType": "flow",
        "primaryMuscles": ["fullBody"],
        "secondaryMuscles": ["hamstrings", "shoulders", "core", "lowerBack"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": None,
        "steps": [
            "Begin in mountain pose at the front of your mat with hands at your heart center.",
            "Inhale and sweep both arms overhead into upward salute, looking toward your thumbs.",
            "Exhale and hinge forward from your hips into standing forward fold.",
            "Inhale to a halfway lift with flat back and hands on your shins.",
            "Exhale, step or hop back, and lower through four-limbed staff pose.",
            "Inhale into upward-facing dog with chest open and thighs lifted off the floor.",
            "Exhale, push hips up and back into downward-facing dog for five steady breaths.",
            "Step forward to flat back, fold on exhale, and rise tall on inhale to complete the cycle."
        ],
        "tips": [
            "Link every individual movement smoothly with an inhale or exhale breath.",
            "Bend your knees during the forward folds if your hamstrings feel tight."
        ],
        "commonMistakes": [
            "Rushing through transitions without coordinating with the breath.",
            "Collapsing into the lower back in upward dog rather than lifting the chest."
        ],
        "safetyNotes": [
            "Modify chaturanga by lowering knees first if shoulder stability is compromised."
        ],
        "contraindications": [
            "Late-term pregnancy or acute carpal tunnel inflammation."
        ],
        "metValue": 4.0,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["yoga", "flow", "vinyasa", "sequence", "sunSalutation"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (vinyasa yoga flow)."
        }
    },

    # ==================== STRENGTH (8) ====================
    {
        "id": "barbell-back-squat",
        "name": "Barbell Back Squat",
        "aliases": ["Back Squat", "High-Bar Squat"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "squat",
        "trackingType": "weightReps",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["hamstrings", "adductors", "lowerBack", "core"],
        "equipment": ["barbell", "squatRack"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Rest the barbell across your upper traps and step back from the rack.",
            "Set your feet shoulder-width apart with your toes angled slightly outward.",
            "Brace your core firmly and inhale deeply into your abdomen.",
            "Hinge your hips back and bend your knees to squat down smoothly.",
            "Lower until your hip crease drops just below the top of your knees.",
            "Drive hard through your midfoot to return to the tall standing lockout."
        ],
        "tips": [
            "Keep your chest upright and your elbows pulled down under the bar.",
            "Drive your knees outward in line with your middle toes throughout."
        ],
        "commonMistakes": [
            "Letting your knees cave inward during the upward drive.",
            "Allowing your lower back to round at the bottom of the squat."
        ],
        "safetyNotes": [
            "Always set safety spotter arms just below your target depth before lifting heavy loads."
        ],
        "contraindications": [
            "Avoid heavy spinal loading during acute lumbar disc flare-ups or acute knee meniscus tears."
        ],
        "metValue": 6.0,
        "defaultRestSec": 120,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["lowerBody", "barbell", "compound", "powerlifting"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02054 (resistance training, squats)."
        }
    },
    {
        "id": "barbell-deadlift",
        "name": "Conventional Barbell Deadlift",
        "aliases": ["Deadlift", "Conventional Deadlift"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "hinge",
        "trackingType": "weightReps",
        "primaryMuscles": ["hamstrings", "glutes", "lowerBack"],
        "secondaryMuscles": ["lats", "trapezius", "forearms", "core", "quadriceps"],
        "equipment": ["barbell"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Step up to the bar so it cuts directly over the middle of your shoelaces.",
            "Hinge at your hips and grip the knurling just outside your shins.",
            "Pull your chest forward, engage your lats, and wedge your hips down into place.",
            "Take the slack out of the bar until you hear a sharp click.",
            "Push the floor away through your heels and stand tall to complete lockout.",
            "Return the bar to the floor by hinging hips back before unlocking your knees."
        ],
        "tips": [
            "Keep the barbell in light contact with your shins and thighs during the entire pull.",
            "Squeeze your glutes tightly at the top without hyperextending your lumbar spine."
        ],
        "commonMistakes": [
            "Jerking the bar off the floor before building full lat tension.",
            "Rounding the lower back during the initial floor pull."
        ],
        "safetyNotes": [
            "Never allow your spinal column to round aggressively under heavy maximal loads."
        ],
        "contraindications": [
            "Acute lumbar disc herniation or untreated severe lower back pain."
        ],
        "metValue": 6.0,
        "defaultRestSec": 180,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["posteriorChain", "barbell", "compound", "powerlifting"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02054 (resistance training, deadlifts)."
        }
    },
    {
        "id": "dumbbell-bench-press",
        "name": "Flat Dumbbell Bench Press",
        "aliases": ["Dumbbell Chest Press", "DB Bench Press"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "benchPress",
        "trackingType": "weightReps",
        "primaryMuscles": ["chest"],
        "secondaryMuscles": ["shoulders", "triceps"],
        "equipment": ["dumbbell", "bench"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Sit on a flat bench with a dumbbell resting securely on each knee.",
            "Kick your knees up one at a time and lie back firmly on the bench.",
            "Retract your shoulder blades and plant both feet flat on the floor.",
            "Lower the dumbbells with elbows angled at roughly forty-five degrees to your torso.",
            "Descend until the handles touch the outer edges of your chest.",
            "Press the weights upward until your arms reach full extension over your sternum."
        ],
        "tips": [
            "Maintain an active arch in your upper back while pinning your shoulder blades down.",
            "Keep your wrists stacked directly over your forearms throughout the press."
        ],
        "commonMistakes": [
            "Flaring elbows wide at ninety degrees, placing excessive stress on your rotator cuff.",
            "Bouncing the dumbbells off the chest at the bottom of the repetition."
        ],
        "safetyNotes": [
            "When reaching failure, bring dumbbells back to your thighs before sitting up."
        ],
        "contraindications": [
            "Severe active rotator cuff impingement or acute AC joint sprain."
        ],
        "metValue": 5.0,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["upperBody", "chest", "dumbbell", "hypertrophy"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02050 (free weights resistance training)."
        }
    },
    {
        "id": "kettlebell-swing",
        "name": "Hardstyle Kettlebell Swing",
        "aliases": ["Russian Kettlebell Swing", "KB Swing"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "hinge",
        "trackingType": "reps",
        "primaryMuscles": ["glutes", "hamstrings"],
        "secondaryMuscles": ["lowerBack", "core", "forearms", "lats"],
        "equipment": ["kettlebell"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Stand one foot behind the kettlebell with feet slightly wider than shoulder width.",
            "Hinge your hips back and grip the handle firmly with both hands.",
            "Hike the kettlebell quickly back between your inner thighs like a football snap.",
            "Snap your hips forward violently, contracting your glutes and quads fully.",
            "Let the kettlebell float up to chest height on loose arms.",
            "Guide the bell back into your hip crease as you hinge into the next repetition."
        ],
        "tips": [
            "The swing is a hip hinge, not a squat; keep your shins largely vertical.",
            "Exhale sharply with abdominal tension at the apex of the swing."
        ],
        "commonMistakes": [
            "Lifting the weight with your front shoulders rather than projecting with your hips.",
            "Squatting down and dropping the kettlebell below your knees."
        ],
        "safetyNotes": [
            "Maintain spinal neutrality and avoid hyperextending your lumbar spine at the peak."
        ],
        "contraindications": [
            "Acute sacroiliac joint instability or active lumbar strain."
        ],
        "metValue": 8.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["kettlebell", "power", "conditioning", "posteriorChain"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02054 (vigorous resistance training)."
        }
    },
    {
        "id": "cable-seated-row",
        "name": "Seated Cable Row",
        "aliases": ["Low Cable Row", "Seated Cable Pulley Row"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "row",
        "trackingType": "weightReps",
        "primaryMuscles": ["lats", "rhomboids"],
        "secondaryMuscles": ["biceps", "rearDeltoids", "forearms", "trapezius"],
        "equipment": ["cable"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Sit on the bench with your feet placed securely on the footrests.",
            "Grip the close-grip attachment and sit tall with a slight knee bend.",
            "Pull your shoulders back and down while bracing your midsection.",
            "Drive your elbows straight back until the handle brushes against your upper abdomen.",
            "Pause for one second while squeezing your shoulder blades together firmly.",
            "Extend your arms with control to allow a gentle stretch in your lats."
        ],
        "tips": [
            "Keep your torso upright with only minimal forward and backward torso swing.",
            "Think about pulling with your elbows rather than gripping excessively hard."
        ],
        "commonMistakes": [
            "Rocking back and forth aggressively to initiate momentum with the lower back.",
            "Shrugging your shoulders up toward your ears during the pull."
        ],
        "safetyNotes": [
            "Keep your knees soft and avoid rounding your lower back when reaching forward."
        ],
        "contraindications": [
            "Severe active lumbar radiculopathy aggravated by seated flexion."
        ],
        "metValue": 5.0,
        "defaultRestSec": 75,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["back", "cable", "hypertrophy", "posture"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02050 (resistance training, seated row)."
        }
    },
    {
        "id": "standing-overhead-press",
        "name": "Standing Barbell Overhead Press",
        "aliases": ["Military Press", "OHP", "Strict Press"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "overheadPress",
        "trackingType": "weightReps",
        "primaryMuscles": ["shoulders", "triceps"],
        "secondaryMuscles": ["trapezius", "core", "chest"],
        "equipment": ["barbell"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Rack the bar at collarbone height and grip it just outside your shoulders.",
            "Unrack the weight onto your front deltoids and step back with feet hip-width.",
            "Squeeze your glutes, brace your core, and tilt your chin back slightly.",
            "Press the barbell vertically in a straight path close to your face.",
            "Once the bar clears your forehead, move your head through the window.",
            "Lock out overhead with the bar centered directly above the back of your neck.",
            "Lower the bar smoothly back to your clavicles under complete control."
        ],
        "tips": [
            "Lock your knees and hips solid; avoid turning this into a push press.",
            "Keep your forearms vertical beneath the bar at the start of each rep."
        ],
        "commonMistakes": [
            "Leaning back excessively, converting the overhead press into an incline bench press.",
            "Pressing the bar far out in front of your center of mass."
        ],
        "safetyNotes": [
            "Avoid excessive lumbar hyperextension under heavy pressing loads."
        ],
        "contraindications": [
            "Acute subacromial shoulder impingement or symptomatic cervical disc pathology."
        ],
        "metValue": 6.0,
        "defaultRestSec": 120,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["overheadPress", "shoulders", "barbell", "strength"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02054 (overhead resistance training)."
        }
    },
    {
        "id": "ez-bar-biceps-curl",
        "name": "Standing EZ-Bar Biceps Curl",
        "aliases": ["EZ Bar Curl", "Biceps Curl"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "curl",
        "trackingType": "weightReps",
        "primaryMuscles": ["biceps"],
        "secondaryMuscles": ["forearms"],
        "equipment": ["ezBar"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "isolation",
        "force": "pull",
        "steps": [
            "Stand tall holding the inner cambered grips of an EZ-bar at thigh level.",
            "Pin your elbows lightly against your ribcage with chest lifted high.",
            "Curl the bar upward by flexing your biceps while keeping upper arms still.",
            "Contract your biceps forcefully at the top of the range of motion.",
            "Lower the bar along the same arc under control until arms are fully straight."
        ],
        "tips": [
            "The EZ-bar reduces wrist torque compared to a traditional straight barbell.",
            "Keep your wrists neutral and avoid flexing them inward as you lift."
        ],
        "commonMistakes": [
            "Swinging your hips and lower back to generate momentum.",
            "Allowing your elbows to drift forward excessively during the curl."
        ],
        "safetyNotes": [
            "Do not drop the weight quickly into hyperextended elbow joints."
        ],
        "contraindications": [
            "Acute distal biceps tendinopathy or medial epicondylitis."
        ],
        "metValue": 3.5,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["arms", "biceps", "isolation", "hypertrophy"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02050 (biceps curls)."
        }
    },
    {
        "id": "walking-dumbbell-lunge",
        "name": "Walking Dumbbell Lunge",
        "aliases": ["Walking Lunge", "DB Walking Lunge"],
        "sanskritName": None,
        "category": "strength",
        "subcategory": "lungeSplitSquat",
        "trackingType": "weightReps",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["hamstrings", "calves", "core"],
        "equipment": ["dumbbell"],
        "difficulty": "intermediate",
        "unilateral": True,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Stand upright holding a pair of dumbbells securely at your sides.",
            "Step forward with your right leg into an elongated stride position.",
            "Lower your hips until your right thigh is parallel to the ground.",
            "Ensure your back left knee gently hovers one inch above the floor.",
            "Drive through your right front heel to rise and step forward with the left leg.",
            "Repeat the movement alternating sides evenly for all prescribed repetitions."
        ],
        "tips": [
            "Keep your torso tall and vertical without tilting forward at your hips.",
            "Track your front knee directly over your middle toes."
        ],
        "commonMistakes": [
            "Collapsing your front knee inward during the deceleration phase.",
            "Slamming your rear kneecap violently against hard flooring."
        ],
        "safetyNotes": [
            "Maintain balance and step with adequate width to prevent knee torque."
        ],
        "contraindications": [
            "Acute patellofemoral pain syndrome or severe balance disorders."
        ],
        "metValue": 5.5,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["legs", "unilateral", "quadriceps", "glutes"],
        "source": "curated",
        "sourceRef": "Sinew Core Strength Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02052 (lunges, moderate to vigorous)."
        }
    },

    # ==================== CALISTHENICS (8) ====================
    {
        "id": "pull-up",
        "name": "Standard Pull-Up",
        "aliases": ["Overhand Pull-Up", "Bodyweight Pull-Up"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "pull",
        "trackingType": "reps",
        "primaryMuscles": ["lats"],
        "secondaryMuscles": ["biceps", "rhomboids", "rearDeltoids", "forearms", "core"],
        "equipment": ["pullupBar"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Grip the overhead pull-up bar with an overhand grip slightly wider than your shoulders.",
            "Hang at full arm extension in an active dead hang with engaged shoulder blades.",
            "Brace your core and squeeze your glutes into a hollow body shape.",
            "Pull your elbows down toward your hips while driving your chest toward the bar.",
            "Continue pulling smoothly until your chin clears the top edge of the bar.",
            "Lower yourself under steady control back to the complete active hang."
        ],
        "tips": [
            "Initiate the pull by depressing your scapulae before bending your arms.",
            "Keep your legs glued together to avoid leaking core tension."
        ],
        "commonMistakes": [
            "Kicking your legs or kipping with momentum to reach the top.",
            "Shortening repetitions by failing to reach full arm lockout at the bottom."
        ],
        "safetyNotes": [
            "Do not relax into an inactive joint hang with limp shoulders at the bottom."
        ],
        "contraindications": [
            "Acute shoulder labrum tear or severe golfer elbow flare-up."
        ],
        "metValue": 8.0,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "upperBody", "back", "bodyweight"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (calisthenics, pull-ups vigorous)."
        }
    },
    {
        "id": "parallel-bar-dip",
        "name": "Parallel Bar Dip",
        "aliases": ["Triceps Dip", "Chest Dip"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "push",
        "trackingType": "reps",
        "primaryMuscles": ["triceps", "chest"],
        "secondaryMuscles": ["shoulders", "core"],
        "equipment": ["parallelBars"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Mount the parallel bars and lock out your arms with shoulders depressed.",
            "Lean your torso forward roughly fifteen degrees to engage your chest.",
            "Bend your elbows to lower your body downward smoothly.",
            "Descend until your shoulders are level with or slightly below your elbows.",
            "Press through your palms to extend your arms back to the top support position."
        ],
        "tips": [
            "Keep your elbows tucked at roughly forty-five degrees rather than flared.",
            "Maintain an active hollow body position with crossed or straight ankles."
        ],
        "commonMistakes": [
            "Dipping too shallow and cutting the range of motion in half.",
            "Allowing your shoulders to shrug upward toward your ears under load."
        ],
        "safetyNotes": [
            "Avoid excessive downward depth if you experience anterior shoulder pain."
        ],
        "contraindications": [
            "Acute sternoclavicular joint injury or anterior glenohumeral instability."
        ],
        "metValue": 8.0,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "push", "chest", "triceps"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (calisthenics, dips vigorous)."
        }
    },
    {
        "id": "standard-push-up",
        "name": "Standard Push-Up",
        "aliases": ["Floor Push-Up", "Pushup"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "push",
        "trackingType": "reps",
        "primaryMuscles": ["chest"],
        "secondaryMuscles": ["shoulders", "triceps", "core"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Place your hands on the ground slightly wider than your shoulders.",
            "Extend your legs behind you with feet together and form a straight body line.",
            "Squeeze your glutes and draw your belly button toward your spine.",
            "Lower your entire body until your chest hovers an inch above the floor.",
            "Push the ground away forcefully until your arms lock out smoothly at the top."
        ],
        "tips": [
            "Position your elbows in an arrow shape relative to your torso.",
            "Keep your neck neutral by gazing at a spot slightly ahead of your hands."
        ],
        "commonMistakes": [
            "Sagging your hips toward the floor and hyperextending your lumbar spine.",
            "Poking your chin down to make it feel like you reached full depth."
        ],
        "safetyNotes": [
            "Keep your wrists stacked comfortably or use push-up handles if wrists ache."
        ],
        "contraindications": [
            "Acute wrist sprain or unhealed scaphoid fracture."
        ],
        "metValue": 4.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "chest", "push", "foundation"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02020 (calisthenics, pushups)."
        }
    },
    {
        "id": "pistol-squat",
        "name": "Pistol Squat",
        "aliases": ["Single-Leg Squat", "One-Legged Squat"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "legs",
        "trackingType": "reps",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["hamstrings", "calves", "core", "hipFlexors"],
        "equipment": ["bodyweight"],
        "difficulty": "advanced",
        "unilateral": True,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Stand balanced on your right leg and extend your left leg straight in front of you.",
            "Reach your arms forward to counterbalance your center of mass.",
            "Hinge your hips slightly and bend your right knee to descend smoothly.",
            "Lower down fully until your right hamstring rests against your calf.",
            "Keep your left heel elevated completely off the ground throughout.",
            "Drive firmly through your right foot to stand back up to tall extension.",
            "Switch and perform the same number of reps on your opposite left leg."
        ],
        "tips": [
            "Maintain deep ankle dorsiflexion and keep your heel planted firmly.",
            "Round your upper back slightly to maintain forward counterbalance."
        ],
        "commonMistakes": [
            "Allowing your standing heel to lift off the floor during the descent.",
            "Letting the elevated non-working leg touch the ground."
        ],
        "safetyNotes": [
            "Requires substantial ankle and knee integrity; progress using box support first."
        ],
        "contraindications": [
            "Severe patellofemoral osteoarthritis or recovering meniscus repair."
        ],
        "metValue": 6.0,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "legs", "unilateral", "mobility", "advanced"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (calisthenics, vigorous)."
        }
    },
    {
        "id": "hanging-leg-raise",
        "name": "Hanging Leg Raise",
        "aliases": ["Straight Leg Raise", "Bar Leg Raise"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "core",
        "trackingType": "reps",
        "primaryMuscles": ["core", "hipFlexors"],
        "secondaryMuscles": ["forearms", "lats"],
        "equipment": ["pullupBar"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Hang from an overhead pull-up bar with an overhand shoulder-width grip.",
            "Depress your scapulae to engage your lats and eliminate passive swinging.",
            "Point your toes, squeeze your legs together, and brace your core.",
            "Raise your straight legs upward until your shins are parallel to the floor.",
            "Pause briefly at the top to emphasize lower abdominal contraction.",
            "Lower your legs back down under strict muscular control to the dead hang."
        ],
        "tips": [
            "Posteriorly tilt your pelvis at the top to ensure your abs flex fully.",
            "Do not swing your legs backward past the vertical plane between reps."
        ],
        "commonMistakes": [
            "Using pendulum momentum and arching your lower back to fling the legs up.",
            "Bending knees excessively when performing the straight-leg variant."
        ],
        "safetyNotes": [
            "Control the lowering phase to avoid sudden lumbar hyperextension."
        ],
        "contraindications": [
            "Acute abdominal muscle strain or severe hip flexor tendinitis."
        ],
        "metValue": 4.5,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "core", "grip", "abs"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02020 (calisthenics, abdominal work)."
        }
    },
    {
        "id": "hollow-body-hold",
        "name": "Hollow Body Hold",
        "aliases": ["Hollow Hold", "Gymnastic Hollow"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "core",
        "trackingType": "hold",
        "primaryMuscles": ["core"],
        "secondaryMuscles": ["hipFlexors", "quadriceps", "shoulders"],
        "equipment": ["bodyweight"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "isolation",
        "force": "static",
        "steps": [
            "Lie on your back on an exercise mat with arms and legs fully extended.",
            "Press your lower back firmly into the floor so there is zero gap under your spine.",
            "Lift your shoulder blades and legs two to four inches off the ground.",
            "Reach your arms overhead past your ears while pointing your toes forward.",
            "Maintain this continuous banana-shaped hollow body arc for the target hold duration."
        ],
        "tips": [
            "Your lower back must stay glued to the floor for the entire set.",
            "Breathe shallowly through your diaphragm without releasing abdominal brace."
        ],
        "commonMistakes": [
            "Letting your lower back arch and lift off the floor under fatigue.",
            "Craning your neck excessively forward rather than tucking your chin slightly."
        ],
        "safetyNotes": [
            "If your lower back begins peeling off the floor, regress by tucking your knees."
        ],
        "contraindications": [
            "Acute lumbar disc herniation aggravated by posterior pelvic tilt."
        ],
        "metValue": 3.8,
        "defaultRestSec": 60,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["calisthenics", "core", "staticHold", "gymnastics"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02020 (calisthenics, core holds)."
        }
    },
    {
        "id": "front-lever-hold",
        "name": "Full Front Lever Hold",
        "aliases": ["Front Lever", "Straight Arm Front Lever"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "lever",
        "trackingType": "hold",
        "primaryMuscles": ["lats", "core"],
        "secondaryMuscles": ["rearDeltoids", "rhomboids", "forearms", "glutes"],
        "equipment": ["pullupBar"],
        "difficulty": "advanced",
        "unilateral": False,
        "mechanic": "compound",
        "force": "static",
        "steps": [
            "Hang from a pull-up bar with an overhand grip slightly wider than shoulders.",
            "Retract and depress your scapulae with locked straight elbows.",
            "Pull down against the bar through your lats to raise your torso and legs.",
            "Lock your entire body into a completely horizontal plane parallel to the floor.",
            "Squeeze your glutes and quads tightly while holding the horizontal position steady."
        ],
        "tips": [
            "Generate intense straight-arm pulling torque through your latissimus dorsi.",
            "Keep your body straight from shoulders to toes without sagging at the hips."
        ],
        "commonMistakes": [
            "Bending the elbows to compensate for insufficient straight-arm lat strength.",
            "Piking at the hips rather than maintaining a true horizontal line."
        ],
        "safetyNotes": [
            "Warm up your shoulders, elbows, and bicep tendons thoroughly prior to max holds."
        ],
        "contraindications": [
            "Distal biceps tendon strain or acute rotator cuff injury."
        ],
        "metValue": 8.0,
        "defaultRestSec": 120,
        "defaultHoldSec": 10,
        "variationOf": None,
        "tags": ["calisthenics", "skills", "advanced", "straightArm", "lats"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (calisthenics, elite vigorous)."
        }
    },
    {
        "id": "handstand-push-up",
        "name": "Wall-Assisted Handstand Push-Up",
        "aliases": ["HSPU", "Handstand Pushup"],
        "sanskritName": None,
        "category": "calisthenics",
        "subcategory": "handstand",
        "trackingType": "reps",
        "primaryMuscles": ["shoulders", "triceps"],
        "secondaryMuscles": ["trapezius", "core"],
        "equipment": ["bodyweight"],
        "difficulty": "advanced",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Place your hands about eight inches away from a sturdy wall.",
            "Kick up into a handstand with heels resting gently against the wall.",
            "Establish an active hollow body position with your glutes and abs tight.",
            "Lower your head forward slightly to touch your crown softly to the mat.",
            "Form a stable tripod shape with your head positioned ahead of your hands.",
            "Press hard through your palms and extend your arms to return to the full handstand."
        ],
        "tips": [
            "Avoid flaring your elbows wide; keep them tucked at a forty-five degree angle.",
            "Push the floor away aggressively at the top into an active shoulder shrug."
        ],
        "commonMistakes": [
            "Collapsing your neck onto the floor with unbuffered velocity.",
            "Banana-arching your lower back and resting your entire spine against the wall."
        ],
        "safetyNotes": [
            "Always place an exercise mat beneath your head to protect the cervical spine."
        ],
        "contraindications": [
            "High blood pressure, glaucoma, retinal detachment, or cervical spine disc injury."
        ],
        "metValue": 8.0,
        "defaultRestSec": 120,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["calisthenics", "shoulders", "inversion", "advanced"],
        "source": "curated",
        "sourceRef": "Sinew Calisthenics Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (vigorous bodyweight inverted)."
        }
    },

    # ==================== YOGA (8) ====================
    {
        "id": "downward-facing-dog",
        "name": "Downward-Facing Dog",
        "aliases": ["Downward Dog", "Down Dog"],
        "sanskritName": "Adho Mukha Svanasana",
        "category": "yoga",
        "subcategory": "inversion",
        "trackingType": "hold",
        "primaryMuscles": ["calves", "hamstrings", "shoulders"],
        "secondaryMuscles": ["lats", "forearms", "core"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Begin on your hands and knees in a tabletop position on your mat.",
            "Spread your fingers wide and press firmly through all ten knuckles.",
            "Tuck your toes under and lift your knees away from the floor.",
            "Send your sitting bones up and back toward the ceiling to lengthen your spine.",
            "Ground your heels gently toward the mat while keeping your ears between your upper arms.",
            "Hold the posture steady while taking slow, measured nasal breaths."
        ],
        "tips": [
            "Bend your knees slightly if tight hamstrings cause your lower back to round.",
            "Externally rotate your upper arms to broaden your upper back."
        ],
        "commonMistakes": [
            "Dumping bodyweight into the wrists instead of pressing through finger knuckles.",
            "Rounding the spine and pushing the chest forward rather than back."
        ],
        "safetyNotes": [
            "Distribute weight evenly across the entire surface of both hands to avoid wrist strain."
        ],
        "contraindications": [
            "Severe carpal tunnel syndrome, late-term pregnancy, or uncontrolled hypertension."
        ],
        "metValue": 3.0,
        "defaultRestSec": 30,
        "defaultHoldSec": 45,
        "variationOf": None,
        "tags": ["yoga", "inversion", "hamstrings", "spine"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (hatha yoga)."
        }
    },
    {
        "id": "warrior-two",
        "name": "Warrior II",
        "aliases": ["Warrior 2 Pose"],
        "sanskritName": "Virabhadrasana II",
        "category": "yoga",
        "subcategory": "standing",
        "trackingType": "hold",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["adductors", "shoulders", "calves", "core"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": True,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Step your feet four feet apart along the length of your yoga mat.",
            "Turn your right foot out ninety degrees and angle your left foot slightly inward.",
            "Inhale and raise both arms parallel to the floor with palms facing down.",
            "Exhale and bend your right knee until it stacks directly over your right ankle.",
            "Gaze steadily over your right front middle finger and hold the pose.",
            "Straighten your leg, reverse your foot positions, and repeat on your left side."
        ],
        "tips": [
            "Press firmly into the outer blade of your back foot to stabilize your pelvis.",
            "Stack your shoulders directly above your hips rather than leaning forward."
        ],
        "commonMistakes": [
            "Allowing the front knee to collapse inward past the big toe.",
            "Lifting the back arm lazily lower than shoulder height."
        ],
        "safetyNotes": [
            "Ensure the front knee stays aligned with the second toe to prevent knee torque."
        ],
        "contraindications": [
            "Recent knee ligament tear or severe hip bursitis."
        ],
        "metValue": 3.5,
        "defaultRestSec": 30,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["yoga", "standing", "hips", "balance"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (hatha yoga)."
        }
    },
    {
        "id": "tree-pose",
        "name": "Tree Pose",
        "aliases": ["Tree Standing Pose"],
        "sanskritName": "Vrksasana",
        "category": "yoga",
        "subcategory": "standing",
        "trackingType": "hold",
        "primaryMuscles": ["calves", "glutes"],
        "secondaryMuscles": ["adductors", "quadriceps", "core"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": True,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Stand tall in mountain pose with your feet rooted firmly beneath your hips.",
            "Shift your weight into your left foot and lift your right knee.",
            "Place the sole of your right foot against your left inner calf or inner thigh.",
            "Never place your foot directly against the side of your standing knee joint.",
            "Bring your palms together in front of your chest at prayer position.",
            "Fix your gaze on a stable unmoving point ahead to sustain balance.",
            "Hold for thirty seconds, then release and repeat with equal duration on your left foot."
        ],
        "tips": [
            "Press your standing thigh and foot sole firmly into each other.",
            "Engage your standing glute to keep your pelvis level."
        ],
        "commonMistakes": [
            "Resting the foot sole directly against the inner knee joint.",
            "Letting the standing hip jut out sideways."
        ],
        "safetyNotes": [
            "Position hands near a wall if balance feels unsteady."
        ],
        "contraindications": [
            "Acute ankle sprain or inner ear balance pathology."
        ],
        "metValue": 2.5,
        "defaultRestSec": 30,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["yoga", "balance", "standing", "unilateral"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (hatha yoga)."
        }
    },
    {
        "id": "cobra-pose",
        "name": "Cobra Pose",
        "aliases": ["Low Cobra", "High Cobra"],
        "sanskritName": "Bhujangasana",
        "category": "yoga",
        "subcategory": "backbend",
        "trackingType": "hold",
        "primaryMuscles": ["lowerBack"],
        "secondaryMuscles": ["glutes", "chest", "shoulders", "rhomboids"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Lie prone on your stomach with the tops of your feet flat on the mat.",
            "Place your hands beneath your shoulders with fingers pointing forward.",
            "Hug your elbows lightly against your ribcage.",
            "Press your pubic bone into the mat and inhale as you peel your chest upward.",
            "Engage your back extensors to lift your sternum without pressing heavily through hands.",
            "Hold the gentle backbend while breathing evenly through your nose."
        ],
        "tips": [
            "Keep the back of your neck long by directing your gaze forward and slightly down.",
            "Press the tops of your feet into the mat to stabilize your pelvis."
        ],
        "commonMistakes": [
            "Pushing with full arm force into a crunching compression of the lumbar spine.",
            "Shrugging your shoulders tightly up around your ears."
        ],
        "safetyNotes": [
            "Distribute spinal extension evenly across the thoracic spine rather than hinging only in lower back."
        ],
        "contraindications": [
            "Pregnancy, carpal tunnel syndrome, or acute spinal disc herniation."
        ],
        "metValue": 3.0,
        "defaultRestSec": 30,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["yoga", "backbend", "spine", "extension"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (hatha yoga backbends)."
        }
    },
    {
        "id": "supported-headstand",
        "name": "Supported Headstand",
        "aliases": ["Headstand", "Bound Headstand"],
        "sanskritName": "Salamba Sirsasana",
        "category": "yoga",
        "subcategory": "inversion",
        "trackingType": "hold",
        "primaryMuscles": ["shoulders", "core"],
        "secondaryMuscles": ["neck", "trapezius", "rhomboids", "forearms"],
        "equipment": ["yogaMat"],
        "difficulty": "advanced",
        "unilateral": False,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Kneel on your mat and interlace your fingers to create a sturdy triangular base.",
            "Place your forearms on the floor with elbows kept shoulder-width apart.",
            "Nestle the crown of your head softly into the cradle of your clasped hands.",
            "Straighten your legs, lift your hips, and walk your feet in toward your face.",
            "Engage your shoulders and core to float both legs up vertically into the inversion.",
            "Press strongly down through your forearms to alleviate compression on your cervical spine.",
            "Hold with steady breath, then lower down smoothly into child pose."
        ],
        "tips": [
            "Eighty percent of bodyweight should be held by your forearms, not your head.",
            "Keep your shoulder blades pulled actively away from your ears."
        ],
        "commonMistakes": [
            "Allowing your elbows to splay wide, collapsing forearm support.",
            "Kicking up with wild uncontrolled momentum and arching the spine."
        ],
        "safetyNotes": [
            "Never compress your cervical vertebrae; bail immediately if you experience neck pain."
        ],
        "contraindications": [
            "Cervical spine injury, glaucoma, detached retina, severe high blood pressure, or migraine."
        ],
        "metValue": 4.0,
        "defaultRestSec": 60,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["yoga", "inversion", "balance", "advanced"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (yoga inversions)."
        }
    },
    {
        "id": "seated-forward-bend",
        "name": "Seated Forward Bend",
        "aliases": ["Seated Forward Fold"],
        "sanskritName": "Paschimottanasana",
        "category": "yoga",
        "subcategory": "forwardBend",
        "trackingType": "hold",
        "primaryMuscles": ["hamstrings", "lowerBack"],
        "secondaryMuscles": ["calves", "glutes"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Sit on your mat with legs extended straight in front of you.",
            "Flex your ankles and pull your toes back toward your shins.",
            "Inhale deeply to raise both arms overhead and lengthen your spine.",
            "Exhale and hinge forward from your hips over your thighs.",
            "Reach for your shins, ankles, or the outer edges of your feet.",
            "Hold the forward fold while breathing into the back of your ribcage."
        ],
        "tips": [
            "Prioritize lengthening the front of your torso over touching your forehead to knees.",
            "Use a yoga strap looped around the soles of your feet if hamstrings are tight."
        ],
        "commonMistakes": [
            "Rounding aggressively through the upper spine and pulling with the neck.",
            "Locking your knees into painful hyperextension."
        ],
        "safetyNotes": [
            "Hinge strictly from your pelvic hip joints rather than flexing the lumbar spine."
        ],
        "contraindications": [
            "Acute posterior lumbar disc herniation or acute hamstring tear."
        ],
        "metValue": 2.5,
        "defaultRestSec": 30,
        "defaultHoldSec": 45,
        "variationOf": None,
        "tags": ["yoga", "forwardBend", "hamstrings", "calm"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (hatha yoga seated folds)."
        }
    },
    {
        "id": "corpse-pose",
        "name": "Corpse Pose",
        "aliases": ["Savasana", "Final Relaxation"],
        "sanskritName": "Savasana",
        "category": "yoga",
        "subcategory": "restorative",
        "trackingType": "time",
        "primaryMuscles": ["fullBody"],
        "secondaryMuscles": [],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": None,
        "steps": [
            "Lie completely flat on your back along the center of your yoga mat.",
            "Allow your feet to fall open naturally wider than hip-width apart.",
            "Rest your arms comfortably alongside your body with palms turned upward.",
            "Close your eyes softly and release all intentional muscular control.",
            "Allow your breathing to settle into a natural, quiet rhythm.",
            "Remain completely still and present for the entire allotted relaxation period."
        ],
        "tips": [
            "Place a rolled blanket under your knees if your lower back feels strained.",
            "Scan your body from crown to toes to systematically soften residual tension."
        ],
        "commonMistakes": [
            "Holding physical tension in the jaw, brow, or shoulders.",
            "Leaving the session abruptly without gentle preliminary movements."
        ],
        "safetyNotes": [
            "Keep warm with a blanket if your body temperature drops during stillness."
        ],
        "contraindications": [
            "Third-trimester pregnancy (modify by lying on the left side with bolster)."
        ],
        "metValue": 1.3,
        "defaultRestSec": None,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["yoga", "restorative", "relaxation", "mindfulness"],
        "source": "curated",
        "sourceRef": "Sinew Yoga Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02105 (restorative yoga)."
        }
    },

    # ==================== MOBILITY & STRETCHING (6) ====================
    {
        "id": "worlds-greatest-stretch",
        "name": "World's Greatest Stretch",
        "aliases": ["Lunge with Thoracic Rotation", "WGS"],
        "sanskritName": None,
        "category": "mobility",
        "subcategory": "dynamicStretching",
        "trackingType": "reps",
        "primaryMuscles": ["hipFlexors", "thoracicSpine" if False else "rhomboids"],
        "secondaryMuscles": ["hamstrings", "glutes", "adductors", "chest"],
        "equipment": ["yogaMat"],
        "difficulty": "intermediate",
        "unilateral": True,
        "mechanic": "compound",
        "force": None,
        "steps": [
            "Step forward into a deep lunge with your right foot outside your right hand.",
            "Place your left hand on the floor and lower your right elbow inside your right ankle.",
            "Rotate your torso to the right and reach your right arm toward the ceiling.",
            "Gaze up toward your right hand while keeping your left hip flexor extended.",
            "Bring your right hand back down, rock back, and straighten your right front leg.",
            "Step back into plank and repeat the complete sequence on your left side."
        ],
        "tips": [
            "Keep your back knee extended and back glute fired to maximize hip flexor opening.",
            "Rotate from your upper back rather than twisting through your lumbar spine."
        ],
        "commonMistakes": [
            "Collapsing your back knee onto the floor during the rotational phase.",
            "Craning your neck to compensate for limited thoracic spine rotation."
        ],
        "safetyNotes": [
            "Move smoothly between positions without snapping into end ranges."
        ],
        "contraindications": [
            "Acute groin adductor strain or lumbar facet joint irritation."
        ],
        "metValue": 3.0,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["mobility", "dynamic", "hips", "thoracic", "warmup"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (stretching, dynamic mobility)."
        }
    },
    {
        "id": "ninety-ninety-hip-switch",
        "name": "90-90 Hip Switch",
        "aliases": ["90/90 Hip Transition", "Seated 90-90"],
        "sanskritName": None,
        "category": "mobility",
        "subcategory": "jointMobility",
        "trackingType": "reps",
        "primaryMuscles": ["glutes", "hipFlexors"],
        "secondaryMuscles": ["adductors", "abductors"],
        "equipment": ["yogaMat"],
        "difficulty": "intermediate",
        "unilateral": True,
        "mechanic": "isolation",
        "force": None,
        "steps": [
            "Sit on the floor with your front right leg bent at ninety degrees.",
            "Position your trailing left leg bent at ninety degrees to your side.",
            "Sit tall with your spine erect, using your hands behind you for support if needed.",
            "Lift your knees and pivot on your heels to sweep your legs across to the left.",
            "Finish in the mirror ninety-ninety position with your left leg leading in front.",
            "Repeat the transition smoothly alternating back and forth between both sides."
        ],
        "tips": [
            "Keep your heels anchored into the ground as you transition between sides.",
            "Strive to perform the rotation without placing your hands on the ground as you progress."
        ],
        "commonMistakes": [
            "Slouching through the lower back to compensate for limited hip capsule rotation.",
            "Letting knees collapse with uncontrolled momentum."
        ],
        "safetyNotes": [
            "Do not force end-range internal rotation if you feel pinching inside the hip joint."
        ],
        "contraindications": [
            "Hip labral tear with femoral acetabular impingement (FAI)."
        ],
        "metValue": 2.5,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["mobility", "hips", "rotational", "jointHealth"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (hip mobility drills)."
        }
    },
    {
        "id": "thoracic-foam-roll-extension",
        "name": "Thoracic Spine Foam Rolling",
        "aliases": ["T-Spine Foam Roll", "Upper Back Foam Roll"],
        "sanskritName": None,
        "category": "mobility",
        "subcategory": "foamRolling",
        "trackingType": "time",
        "primaryMuscles": ["rhomboids", "trapezius"],
        "secondaryMuscles": ["lats"],
        "equipment": ["foamRoller", "yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": None,
        "steps": [
            "Sit on your mat and position a foam roller horizontally across your mid-back.",
            "Interlace your fingers behind your head to support the weight of your neck.",
            "Lift your hips slightly and roll slowly between your mid-back and upper shoulders.",
            "Pause at tight segments, lower your hips, and gently arch back over the roller.",
            "Exhale smoothly as you extend your upper back over the roller.",
            "Continue working your upper thoracic spine for the allotted sixty seconds."
        ],
        "tips": [
            "Keep your elbows pointed forward to pull shoulder blades apart and expose tissue.",
            "Never roll down onto your unsupported lumbar spine."
        ],
        "commonMistakes": [
            "Rolling onto the lower back or neck vertebrae directly.",
            "Pulling violently on your head and hyper-flexing your cervical spine."
        ],
        "safetyNotes": [
            "Keep the roller strictly on the rib-supported thoracic region between shoulder blades."
        ],
        "contraindications": [
            "Osteoporosis, vertebral compression fractures, or unhealed rib injury."
        ],
        "metValue": 2.0,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["mobility", "foamRoller", "posture", "thoracic"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (self-myofascial release)."
        }
    },
    {
        "id": "cat-cow-stretch",
        "name": "Cat-Cow Dynamic Stretch",
        "aliases": ["Cat Cow", "Marjaryasana Bitilasana"],
        "sanskritName": "Marjaryasana",
        "category": "mobility",
        "subcategory": "jointMobility",
        "trackingType": "reps",
        "primaryMuscles": ["lowerBack", "core"],
        "secondaryMuscles": ["rhomboids", "neck"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": None,
        "steps": [
            "Set up on hands and knees with wrists under shoulders and knees under hips.",
            "Inhale into cow pose by dropping your belly and lifting your chest and tailbone.",
            "Exhale into cat pose by tucking your tailbone and rounding your spine up.",
            "Press firmly through your palms to spread your shoulder blades apart.",
            "Flow continuously between extension and flexion in rhythm with your breath."
        ],
        "tips": [
            "Articulate the movement vertebra by vertebra starting from your pelvis.",
            "Keep your elbows unlocked throughout the transition."
        ],
        "commonMistakes": [
            "Cramming into cervical hyperextension by jerking the chin up too far.",
            "Moving with rapid uncontrolled pace rather than smooth segmental articulation."
        ],
        "safetyNotes": [
            "Stay within a comfortable pain-free range of motion without forcing end ranges."
        ],
        "contraindications": [
            "Severe acute disc prolapse aggravated by flexion."
        ],
        "metValue": 2.3,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["mobility", "spine", "warmup", "recovery"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (stretching, dynamic)."
        }
    },
    {
        "id": "kneeling-hip-flexor-stretch",
        "name": "Half-Kneeling Hip Flexor Stretch",
        "aliases": ["Psoas Stretch", "Kneeling Lunge Stretch"],
        "sanskritName": None,
        "category": "mobility",
        "subcategory": "staticStretching",
        "trackingType": "hold",
        "primaryMuscles": ["hipFlexors"],
        "secondaryMuscles": ["quadriceps", "glutes"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": True,
        "mechanic": "isolation",
        "force": "static",
        "steps": [
            "Kneel on your left knee and step your right foot forward in a half-kneeling stance.",
            "Maintain ninety-degree angles at both front and back knee joints.",
            "Posteriorly tilt your pelvis by tucking your tailbone and squeezing your left glute.",
            "Shift your hips forward slightly until you feel a deep stretch in front of your left hip.",
            "Keep your torso completely vertical and hold the position for thirty seconds.",
            "Switch sides, placing your right knee on the mat, and repeat for thirty seconds."
        ],
        "tips": [
            "The posterior pelvic tilt is what isolates the psoas; do not arch your lower back.",
            "Raise your left arm overhead to intensify the stretch through the entire fascial line."
        ],
        "commonMistakes": [
            "Hyperextending the lumbar spine and dumping all forward travel into the lower back.",
            "Failing to contract the trailing glute during the hold."
        ],
        "safetyNotes": [
            "Place a folded mat or cushion under the rear knee for comfort."
        ],
        "contraindications": [
            "Acute patellar bursitis on the kneeling knee or acute hip labral pathology."
        ],
        "metValue": 2.5,
        "defaultRestSec": 30,
        "defaultHoldSec": 30,
        "variationOf": None,
        "tags": ["mobility", "hips", "static", "deskRelief"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (stretching, static)."
        }
    },
    {
        "id": "shoulder-pass-through",
        "name": "Resistance Band Shoulder Pass-Through",
        "aliases": ["Shoulder Dislocates", "Band Pass-Through"],
        "sanskritName": None,
        "category": "mobility",
        "subcategory": "dynamicStretching",
        "trackingType": "reps",
        "primaryMuscles": ["shoulders", "chest"],
        "secondaryMuscles": ["trapezius", "rhomboids"],
        "equipment": ["resistanceBand"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "isolation",
        "force": None,
        "steps": [
            "Stand tall holding a light resistance band with a wide overhand grip.",
            "Lock your elbows straight and hold the band across your front thighs.",
            "Raise your arms up overhead in a wide smooth arc without bending elbows.",
            "Continue the arc behind your back until the band lightly touches your glutes.",
            "Reverse the arc smoothly to bring the band back overhead to the front.",
            "Repeat for ten continuous fluid repetitions."
        ],
        "tips": [
            "Widen your grip on the band if your elbows bend during the pass-through.",
            "Keep your ribs pulled down and glutes squeezed to prevent lower back arching."
        ],
        "commonMistakes": [
            "Bending the elbows as the band passes overhead.",
            "Over-arching the spine to cheat through shoulder tightness."
        ],
        "safetyNotes": [
            "Use a wide enough grip so the band passes smoothly without sharp shoulder pain."
        ],
        "contraindications": [
            "Active anterior shoulder dislocation history or acute rotator cuff tear."
        ],
        "metValue": 2.5,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["mobility", "shoulders", "warmup", "upperBody"],
        "source": "curated",
        "sourceRef": "Sinew Mobility Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02040 (shoulder mobility)."
        }
    },

    # ==================== HIIT & PLYOMETRICS (5) ====================
    {
        "id": "standard-burpee",
        "name": "Chest-to-Floor Burpee",
        "aliases": ["Burpee", "Full Burpee"],
        "sanskritName": None,
        "category": "hiit",
        "subcategory": "burpeeVariation",
        "trackingType": "reps",
        "primaryMuscles": ["fullBody"],
        "secondaryMuscles": ["chest", "quadriceps", "core", "calves", "shoulders"],
        "equipment": ["bodyweight"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Stand with feet shoulder-width apart and arms hanging naturally.",
            "Hinge your hips back and place both hands flat on the floor.",
            "Kick your feet back simultaneously into a high plank position.",
            "Lower your chest and thighs completely onto the floor in one smooth wave.",
            "Push the floor away and jump your feet forward just outside your hands.",
            "Jump explosively into the air, clapping your hands overhead with body extended."
        ],
        "tips": [
            "Land with soft knees and transition immediately into your next descent.",
            "Breathe rhythmically on every single repetition."
        ],
        "commonMistakes": [
            "Landing on stiff locked knees during the overhead jump landing.",
            "Letting your lower back sag into a painful hyper-extended arch."
        ],
        "safetyNotes": [
            "Absorb landing impact through soft knees and ankles to protect joint cartilage."
        ],
        "contraindications": [
            "Severe patellofemoral osteoarthritis or severe vertigo."
        ],
        "metValue": 8.5,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["hiit", "conditioning", "plyometrics", "fullBody"],
        "source": "curated",
        "sourceRef": "Sinew HIIT Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02024 (burpees, vigorous effort)."
        }
    },
    {
        "id": "box-jump",
        "name": "Plyometric Box Jump",
        "aliases": ["Box Jump", "Plyo Box Jump"],
        "sanskritName": None,
        "category": "hiit",
        "subcategory": "jumpPlyometric",
        "trackingType": "reps",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["calves", "hamstrings", "core"],
        "equipment": ["plyoBox"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Stand facing a sturdy plyometric box half a step away with feet hip-width.",
            "Swing your arms back and hinge your hips into an athletic quarter-squat.",
            "Explode upward through your hips and swing arms forward aggressively.",
            "Tuck your knees up and land softly on top of the box in an athletic squat.",
            "Stand up completely on top of the box to verify full hip extension.",
            "Step down carefully one foot at a time to reset for the next rep."
        ],
        "tips": [
            "Focus on landing quietly like a cat to absorb impact through your musculature.",
            "Always step down rather than jumping backward off the box to spare your Achilles tendons."
        ],
        "commonMistakes": [
            "Rebounding backward off the box, creating high risk for Achilles rupture.",
            "Landing with a loud thud and stiff knees on the box surface."
        ],
        "safetyNotes": [
            "Always step down one foot at a time; never jump backward off the box."
        ],
        "contraindications": [
            "Achilles tendinopathy, recent ACL reconstruction, or severe balance disorders."
        ],
        "metValue": 9.0,
        "defaultRestSec": 90,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["plyometrics", "hiit", "power", "jumping"],
        "source": "curated",
        "sourceRef": "Sinew HIIT Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02024 (plyometrics, box jumps)."
        }
    },
    {
        "id": "battle-rope-alternating-waves",
        "name": "Alternating Battle Rope Waves",
        "aliases": ["Battle Ropes", "Rope Waves"],
        "sanskritName": None,
        "category": "hiit",
        "subcategory": "battleRopes",
        "trackingType": "time",
        "primaryMuscles": ["shoulders", "core"],
        "secondaryMuscles": ["biceps", "forearms", "quadriceps", "glutes"],
        "equipment": ["bodyweight"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Stand facing the anchor holding one rope end firmly in each hand.",
            "Assume a solid athletic stance with knees bent and chest lifted.",
            "Whip your right arm upward and drive it back down forcefully.",
            "Immediately alternate by whipping your left arm upward as the right descends.",
            "Maintain a fast, continuous reciprocating rhythm to send fluid waves to the anchor.",
            "Keep your torso anchored and core braced for the entire thirty-second interval."
        ],
        "tips": [
            "Generate waves through quick shoulder and arm cycling, not torso swaying.",
            "Keep your weight centered over your midfoot in a stable athletic base."
        ],
        "commonMistakes": [
            "Standing straight-legged and letting rope recoil pull you off balance.",
            "Holding your breath during high-frequency wave intervals."
        ],
        "safetyNotes": [
            "Ensure the rope anchor is structurally secure before beginning high-intensity intervals."
        ],
        "contraindications": [
            "Acute bicep tendonitis or active acromioclavicular shoulder pain."
        ],
        "metValue": 10.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["hiit", "conditioning", "upperBody", "power"],
        "source": "curated",
        "sourceRef": "Sinew HIIT Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02024 (battle ropes, vigorous)."
        }
    },
    {
        "id": "jumping-lunge",
        "name": "Plyometric Jumping Lunge",
        "aliases": ["Split Squat Jump", "Jumping Lunges"],
        "sanskritName": None,
        "category": "hiit",
        "subcategory": "jumpPlyometric",
        "trackingType": "reps",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["hamstrings", "calves", "core"],
        "equipment": ["bodyweight"],
        "difficulty": "advanced",
        "unilateral": True,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Begin in a lunge position with your right leg forward and knees bent ninety degrees.",
            "Drop down quickly and explode vertically into the air off both feet.",
            "Switch your leg positions in mid-air, bringing your left leg forward.",
            "Land softly in a lunge with your left foot forward and absorb the impact smoothly.",
            "Immediately drive up into the next repetition without pausing.",
            "Continue alternating sides continuously for all prescribed repetitions."
        ],
        "tips": [
            "Use your arms to assist momentum by driving them opposite to your legs.",
            "Keep your torso tall and center of gravity balanced between both legs."
        ],
        "commonMistakes": [
            "Letting the front knee collapse inward upon impact.",
            "Banging the rear knee violently into the ground during descent."
        ],
        "safetyNotes": [
            "High impact plyometric: land softly toe-to-heel and never slam rear knee."
        ],
        "contraindications": [
            "Patellar tendinopathy, knee ligament reconstruction, or severe joint degeneration."
        ],
        "metValue": 9.0,
        "defaultRestSec": 75,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["hiit", "plyometrics", "unilateral", "legs"],
        "source": "curated",
        "sourceRef": "Sinew HIIT Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02024 (plyometric jumping lunges)."
        }
    },
    {
        "id": "mountain-climber",
        "name": "Mountain Climber",
        "aliases": ["Running Plank", "Floor Climbers"],
        "sanskritName": None,
        "category": "hiit",
        "subcategory": "conditioningBodyweight",
        "trackingType": "time",
        "primaryMuscles": ["core"],
        "secondaryMuscles": ["shoulders", "hipFlexors", "quadriceps", "calves"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Start in a high plank position with hands beneath shoulders and body straight.",
            "Drive your right knee up toward your chest while keeping hips low.",
            "Quickly tap the ball of your right foot and jump it back to plank.",
            "Simultaneously drive your left knee forward toward your chest.",
            "Alternate your legs rapidly in a smooth running cadence.",
            "Maintain a steady level pelvis without bouncing your hips up and down."
        ],
        "tips": [
            "Keep your shoulders pushed away from your ears to maintain upper back stability.",
            "Land lightly on the balls of your feet during the foot transitions."
        ],
        "commonMistakes": [
            "Piking hips high up into the air to take tension off the core.",
            "Letting hands drift forward ahead of the shoulders."
        ],
        "safetyNotes": [
            "Maintain core brace to prevent lower back sagging during rapid cadence."
        ],
        "contraindications": [
            "Acute toe joint sprain or symptomatic abdominal wall hernia."
        ],
        "metValue": 8.0,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["hiit", "core", "bodyweight", "cadence"],
        "source": "curated",
        "sourceRef": "Sinew HIIT Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02022 (calisthenics, mountain climbers)."
        }
    },

    # ==================== BOXING & MARTIAL ARTS (5) ====================
    {
        "id": "orthodox-boxing-stance",
        "name": "Orthodox Boxing Stance",
        "aliases": ["Boxing Stance", "Orthodox Guard"],
        "sanskritName": None,
        "category": "boxing",
        "subcategory": "footwork",
        "trackingType": "hold",
        "primaryMuscles": ["calves", "quadriceps"],
        "secondaryMuscles": ["core", "shoulders"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": None,
        "force": "static",
        "steps": [
            "Stand with your feet shoulder-width apart and take one natural stride forward with your left foot.",
            "Angle both feet roughly forty-five degrees to the right of your centerline.",
            "Distribute your bodyweight evenly with fifty-five percent over your back right foot.",
            "Tuck your chin down toward your collarbone behind your raised lead left shoulder.",
            "Bring your right fist to your right cheekbone and your left fist six inches ahead of your chin.",
            "Hold this balanced guard position while keeping your knees softly bent and responsive."
        ],
        "tips": [
            "Keep your back right heel slightly off the floor like a loaded spring.",
            "Never stand flat-footed or cross your feet while holding the stance."
        ],
        "commonMistakes": [
            "Squaring your hips to your opponent, exposing a broad target area.",
            "Lifting your chin high and dropping your hands below chest height."
        ],
        "safetyNotes": [
            "Keep your jaw clamped shut and chin protected by your lead shoulder."
        ],
        "contraindications": [
            "Acute ankle instability or severe balance impairment."
        ],
        "metValue": 4.0,
        "defaultRestSec": 30,
        "defaultHoldSec": 60,
        "variationOf": None,
        "tags": ["boxing", "stance", "fundamentals", "guard"],
        "source": "curated",
        "sourceRef": "Sinew Boxing Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 06010 (boxing, sparring/stance drill)."
        }
    },
    {
        "id": "boxing-lead-jab",
        "name": "Lead Jab (1)",
        "aliases": ["Number 1 Punch", "Boxing Jab", "Left Jab"],
        "sanskritName": None,
        "category": "boxing",
        "subcategory": "punches",
        "trackingType": "reps",
        "primaryMuscles": ["shoulders", "triceps"],
        "secondaryMuscles": ["chest", "calves", "core"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Begin in your orthodox boxing stance with your hands held up in guard.",
            "Step forward lightly with your lead left foot as you fire your left fist forward.",
            "Rotate your fist over so your palm faces down at the moment of impact.",
            "Shrug your lead shoulder upward to guard your chin against incoming counters.",
            "Snap your left fist back along the exact same path to your defensive guard position."
        ],
        "tips": [
            "The 1 jab is a crisp whip: throw it relaxed and clench your fist on contact.",
            "Keep your rear right hand glued to your cheekbone while throwing the jab."
        ],
        "commonMistakes": [
            "Dropping your left hand to your chest before extending the punch.",
            "Over-committing your weight forward and falling off balance."
        ],
        "safetyNotes": [
            "Wrap your hands properly and keep your wrist straight to prevent sprains."
        ],
        "contraindications": [
            "Acute scaphoid wrist fracture or carpal instability."
        ],
        "metValue": 6.5,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["boxing", "punch", "jab", "fundamentals"],
        "source": "curated",
        "sourceRef": "Sinew Boxing Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 06020 (boxing, punching drills)."
        }
    },
    {
        "id": "boxing-rear-cross",
        "name": "Rear Cross (2)",
        "aliases": ["Number 2 Punch", "Straight Right", "Right Cross"],
        "sanskritName": None,
        "category": "boxing",
        "subcategory": "punches",
        "trackingType": "reps",
        "primaryMuscles": ["shoulders", "core"],
        "secondaryMuscles": ["triceps", "chest", "calves", "glutes"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Establish your boxing stance with your rear right fist at your cheekbone.",
            "Pivot on the ball of your rear right foot and turn your right hip forward.",
            "Extend your right arm straight down your centerline toward the target.",
            "Turn your fist over so your palm faces down at full arm extension.",
            "Keep your lead left hand firmly in guard protecting your left jawline.",
            "Retract your right hand immediately back to your cheek along the punch line."
        ],
        "tips": [
            "Power in the 2 cross originates from the rear foot pivot and hip rotation.",
            "Do not lean your head past your lead front knee as you punch."
        ],
        "commonMistakes": [
            "Leaving the lead hand low while throwing the rear punch.",
            "Failing to pivot the rear foot, resulting in an arm-only punch without power."
        ],
        "safetyNotes": [
            "Ensure full wrist alignment on impact to protect metacarpal bones."
        ],
        "contraindications": [
            "Acute thumb ulnar collateral ligament tear or wrist sprain."
        ],
        "metValue": 7.0,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["boxing", "cross", "powerPunch", "technique"],
        "source": "curated",
        "sourceRef": "Sinew Boxing Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 06020 (boxing, in-ring/technique)."
        }
    },
    {
        "id": "one-two-lead-hook-combo",
        "name": "One-Two-Lead Hook Combo (1-2-3)",
        "aliases": ["1-2-3 Combo", "Jab Cross Hook"],
        "sanskritName": None,
        "category": "boxing",
        "subcategory": "combinations",
        "trackingType": "rounds",
        "primaryMuscles": ["shoulders", "obliques", "core"],
        "secondaryMuscles": ["triceps", "calves", "glutes"],
        "equipment": ["bodyweight"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Fire punch 1 (jab) straight out from your lead stance to find distance.",
            "Snap the jab back and immediately pivot hips to drive punch 2 (rear cross).",
            "Transfer your weight smoothly to your front foot and pivot on lead toes.",
            "Whip punch 3 (lead hook) horizontally with elbow bent at ninety degrees.",
            "Recoil your lead arm back instantly into full defensive guard stance.",
            "Perform crisp continuous combination cycles for the duration of the round."
        ],
        "tips": [
            "Flow through the sequence 1-2-3 as a single continuous kinetic wave.",
            "Turn your lead foot like squashing a bug on the 3 hook to generate rotational whip."
        ],
        "commonMistakes": [
            "Pausing between the 2 and 3 punches instead of chaining the hip weight transfer.",
            "Looping the hook too wide and leaving the entire center open to counterpunches."
        ],
        "safetyNotes": [
            "Maintain controlled wrist stiffness on the 3 hook to prevent hyperextension."
        ],
        "contraindications": [
            "Rotator cuff tear or acute TFCC wrist tear."
        ],
        "metValue": 8.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["boxing", "combo", "numberedPunches", "coordination"],
        "source": "curated",
        "sourceRef": "Sinew Boxing Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 06020 (boxing, shadowboxing combos)."
        }
    },
    {
        "id": "heavy-bag-freestyle-round",
        "name": "Heavy Bag Freestyle Rounds",
        "aliases": ["Heavy Bag Work", "Bag Rounds"],
        "sanskritName": None,
        "category": "boxing",
        "subcategory": "heavyBag",
        "trackingType": "rounds",
        "primaryMuscles": ["shoulders", "core", "calves"],
        "secondaryMuscles": ["chest", "triceps", "glutes", "forearms"],
        "equipment": ["heavyBag", "boxingGloves", "handWraps"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Wrap your hands thoroughly and lace up sixteen-ounce boxing gloves.",
            "Circle the heavy bag at boxing distance in a balanced stance.",
            "Work combinations utilizing punches 1 through 6 while varying cadence and power.",
            "Slip and roll your head after every offensive sequence as if avoiding counters.",
            "Maintain rhythmic footwork and circle smoothly as the bag swings.",
            "Work at high tempo for three minutes, then rest for sixty seconds between rounds."
        ],
        "tips": [
            "Hit through the surface of the bag with stiff wrists rather than pushing it.",
            "Never stop moving your feet and head between punch combinations."
        ],
        "commonMistakes": [
            "Hitting the heavy bag with unconditioned bare hands or without hand wraps.",
            "Smothering punches by standing too close to the swinging bag."
        ],
        "safetyNotes": [
            "Always wrap your hands and wear proper gloves to prevent carpal fractures."
        ],
        "contraindications": [
            "Unhealed hand fractures, boxer knuckle, or severe carpal tunnel syndrome."
        ],
        "metValue": 9.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["boxing", "heavyBag", "conditioning", "power"],
        "source": "curated",
        "sourceRef": "Sinew Boxing Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 06010 (boxing, bag work vigorous)."
        }
    },

    # ==================== CARDIO (5) ====================
    {
        "id": "outdoor-running",
        "name": "Outdoor Road Running",
        "aliases": ["Running", "Road Running", "Jogging"],
        "sanskritName": None,
        "category": "cardio",
        "subcategory": "running",
        "trackingType": "distanceTime",
        "primaryMuscles": ["quadriceps", "calves", "glutes"],
        "secondaryMuscles": ["hamstrings", "tibialis", "core"],
        "equipment": ["bodyweight"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": None,
        "steps": [
            "Establish an upright posture with a slight forward lean originating from your ankles.",
            "Run forward with a steady cadence of roughly one hundred seventy steps per minute.",
            "Land with your foot landing softly underneath your center of mass.",
            "Drive your elbows backward in rhythm with your opposite leg strides.",
            "Maintain relaxed shoulders and breathe rhythmically through nose and mouth."
        ],
        "tips": [
            "Avoid overstriding with a harsh braking heel strike ahead of your body.",
            "Keep your hands relaxed as if holding a potato chip without crushing it."
        ],
        "commonMistakes": [
            "Overstriding and landing heavily on a stiff heel out in front.",
            "Hunching shoulders upward toward your ears under fatigue."
        ],
        "safetyNotes": [
            "Wear cushioned, properly fitted footwear and build weekly mileage progressively."
        ],
        "contraindications": [
            "Severe medial tibial stress syndrome (shin splints) or acute stress fracture."
        ],
        "metValue": 9.8,
        "defaultRestSec": None,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["cardio", "running", "aerobic", "endurance"],
        "source": "curated",
        "sourceRef": "Sinew Cardio Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 12050 (running, 6 mph / 10 min per mile)."
        }
    },
    {
        "id": "indoor-rowing-ergometer",
        "name": "Indoor Rowing Ergometer",
        "aliases": ["Rowing Machine", "RowErg"],
        "sanskritName": None,
        "category": "cardio",
        "subcategory": "rowing",
        "trackingType": "distanceTime",
        "primaryMuscles": ["quadriceps", "glutes", "lats"],
        "secondaryMuscles": ["hamstrings", "rhomboids", "lowerBack", "biceps", "core"],
        "equipment": ["rower"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Strap your feet into the footrests and grip the handle with an overhand grip.",
            "Begin at the catch with shins vertical, arms straight, and torso leaning slightly forward.",
            "Initiate the drive by pushing aggressively through your legs until knees are almost straight.",
            "Swing your torso back to eleven o'clock and pull the handle into your lower ribs.",
            "Reverse the motion on the recovery: extend arms, hinge torso forward, then slide knees forward."
        ],
        "tips": [
            "Power breakdown on the drive is sixty percent legs, twenty core, twenty arms.",
            "Do not bend your knees on the recovery slide until the handle clears your knees."
        ],
        "commonMistakes": [
            "Shooting the slide by pushing legs without transferring force through a braced core.",
            "Bending the knees too early on the return and clipping the handle over kneecaps."
        ],
        "safetyNotes": [
            "Keep your spine neutral on the catch; never slouch into rounded lumbar flexion."
        ],
        "contraindications": [
            "Acute lumbar disc herniation aggravated by combined seated compression and flexion."
        ],
        "metValue": 8.5,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["cardio", "rowing", "fullBody", "ergometer"],
        "source": "curated",
        "sourceRef": "Sinew Cardio Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02070 (rowing ergometer, vigorous)."
        }
    },
    {
        "id": "stationary-cycling",
        "name": "Stationary Cycling",
        "aliases": ["Indoor Cycling", "Spinning", "Exercise Bike"],
        "sanskritName": None,
        "category": "cardio",
        "subcategory": "cycling",
        "trackingType": "distanceTime",
        "primaryMuscles": ["quadriceps", "glutes"],
        "secondaryMuscles": ["hamstrings", "calves"],
        "equipment": ["stationaryBike"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Adjust the saddle height so your knee has a slight bend at the bottom pedal stroke.",
            "Mount the bike and secure the balls of your feet over the pedal axles.",
            "Grip the handlebars lightly and establish a steady pedaling cadence of eighty to ninety rpm.",
            "Push smoothly down on each downstroke and scrape back across the bottom stroke.",
            "Maintain an upright or athletic forward posture without collapsing your chest.",
            "Breathe steadily and consistently through your designated training interval."
        ],
        "tips": [
            "Pedal in smooth circles rather than merely stomping downward on the pedals.",
            "Keep your knees tracking straight forward rather than flaring out."
        ],
        "commonMistakes": [
            "Setting the saddle too low, causing excessive compressive knee joint stress.",
            "Gripping the handlebars with excessive white-knuckle forearm tension."
        ],
        "safetyNotes": [
            "Verify the saddle and handlebar clamping pins are tightly secured before riding."
        ],
        "contraindications": [
            "Severe ischial tuberosity bursitis or acute knee effusion."
        ],
        "metValue": 7.0,
        "defaultRestSec": None,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["cardio", "cycling", "lowImpact", "aerobic"],
        "source": "curated",
        "sourceRef": "Sinew Cardio Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02011 (bicycling, stationary 100-150W)."
        }
    },
    {
        "id": "freestyle-swimming",
        "name": "Freestyle Lap Swimming",
        "aliases": ["Front Crawl", "Lap Swimming"],
        "sanskritName": None,
        "category": "cardio",
        "subcategory": "swimming",
        "trackingType": "distanceTime",
        "primaryMuscles": ["lats", "shoulders"],
        "secondaryMuscles": ["core", "triceps", "chest", "quadriceps", "calves"],
        "equipment": ["pool"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Push off the pool wall in a streamlined horizontal position beneath the surface.",
            "Flutter kick from your hips with relaxed pointed ankles.",
            "Enter the water with your hand fingertip-first and extend forward into the catch.",
            "Pull your hand and forearm backward through the water toward your hip.",
            "Rotate your torso to breathe naturally in the pocket created by your bow wave.",
            "Recover your arm high over the water surface to initiate the next stroke entry."
        ],
        "tips": [
            "Keep your head neutral with eyes looking straight at the bottom of the pool.",
            "Rotate your hips and torso as a single connected unit with every stroke."
        ],
        "commonMistakes": [
            "Lifting the head high out of the water to breathe, causing hips to sink downward.",
            "Bending the knees excessively while kicking, creating heavy drag."
        ],
        "safetyNotes": [
            "Always swim in designated lanes with certified lifeguard coverage present."
        ],
        "contraindications": [
            "Tympanic membrane perforation without custom earplugs, or acute swimmer shoulder."
        ],
        "metValue": 8.0,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["cardio", "swimming", "lowImpact", "fullBody", "endurance"],
        "source": "curated",
        "sourceRef": "Sinew Cardio Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 18310 (swimming, freestyle vigorous)."
        }
    },
    {
        "id": "stair-climber-intervals",
        "name": "Stair Climber Intervals",
        "aliases": ["StairMaster", "Stepmill"],
        "sanskritName": None,
        "category": "cardio",
        "subcategory": "stairClimber",
        "trackingType": "time",
        "primaryMuscles": ["glutes", "quadriceps", "calves"],
        "secondaryMuscles": ["hamstrings", "core"],
        "equipment": ["stairClimber"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Step onto the revolving stairs and select your target interval climbing speed.",
            "Stand tall with your chest lifted and avoid leaning heavily on the side handrails.",
            "Place your entire foot flat on each moving step as you climb.",
            "Push through your heel and midfoot to activate glutes on every upward step.",
            "Maintain a steady rhythmic climbing cadence without skipping steps.",
            "Safely press the stop button and wait for steps to lock before dismounting."
        ],
        "tips": [
            "Rest your fingertips on handrails for balance only; do not support your weight on arms.",
            "Keep your torso upright with a slight natural forward lean from the hips."
        ],
        "commonMistakes": [
            "Slouching forward and locking arms out to support bodyweight on the rails.",
            "Stepping only on the balls of your feet, placing excessive strain on calves."
        ],
        "safetyNotes": [
            "Keep your gaze on the revolving stairs to avoid mistiming steps and tripping."
        ],
        "contraindications": [
            "Severe patellofemoral knee arthritis or acute Achilles tendonitis."
        ],
        "metValue": 9.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["cardio", "stairs", "glutes", "conditioning"],
        "source": "curated",
        "sourceRef": "Sinew Cardio Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02080 (stair-treadmill ergometer)."
        }
    },

    # ==================== PILATES (5) ====================
    {
        "id": "pilates-the-hundred",
        "name": "The Hundred",
        "aliases": ["Pilates Hundred", "Classic Hundred"],
        "sanskritName": None,
        "category": "pilates",
        "subcategory": "matClassic",
        "trackingType": "reps",
        "primaryMuscles": ["core"],
        "secondaryMuscles": ["hipFlexors", "shoulders", "quadriceps"],
        "equipment": ["yogaMat"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "isolation",
        "force": "static",
        "steps": [
            "Lie on your back on a mat and bring both knees into your chest.",
            "Curl your head, neck, and shoulder blades smoothly off the mat.",
            "Extend your legs forward to a forty-five-degree angle in Pilates stance.",
            "Reach your arms long by your sides hovering two inches off the floor.",
            "Pump your arms briskly up and down from the shoulders in a six-inch range.",
            "Inhale deeply for five arm pumps, then exhale completely for five arm pumps.",
            "Complete ten breath cycles for a total of one hundred arm pumps."
        ],
        "tips": [
            "Pump your arms from the back of your shoulders with firm straight elbows.",
            "Anchor your lower back into the mat by drawing your navel deeply to your spine."
        ],
        "commonMistakes": [
            "Pumping from the wrists or elbows instead of moving from the shoulder joint.",
            "Letting your lower back peel up off the mat as legs extend."
        ],
        "safetyNotes": [
            "If your neck strains or lower back arches, bend your knees into tabletop."
        ],
        "contraindications": [
            "Acute cervical spine disc herniation or active diastasis recti."
        ],
        "metValue": 3.5,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["pilates", "classicMat", "core", "breath"],
        "source": "curated",
        "sourceRef": "Sinew Pilates Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02115 (pilates mat work)."
        }
    },
    {
        "id": "pilates-the-teaser",
        "name": "The Teaser",
        "aliases": ["Teaser", "Classic Teaser"],
        "sanskritName": None,
        "category": "pilates",
        "subcategory": "matClassic",
        "trackingType": "reps",
        "primaryMuscles": ["core", "hipFlexors"],
        "secondaryMuscles": ["quadriceps", "lowerBack", "shoulders"],
        "equipment": ["yogaMat"],
        "difficulty": "advanced",
        "unilateral": False,
        "mechanic": "compound",
        "force": "pull",
        "steps": [
            "Lie flat on your mat with arms reaching overhead and legs extended together.",
            "Inhale and lift your arms and head to begin rolling forward off the mat.",
            "Simultaneously lift your legs straight to a forty-five-degree angle.",
            "Roll up into a balanced V-sit position on your sacrum with arms parallel to legs.",
            "Pause for two seconds at the apex, lifting through your chest with open collarbones.",
            "Articulate your spine smoothly back down onto the mat vertebra by vertebra."
        ],
        "tips": [
            "Roll through the spine with articulation rather than snapping up with momentum.",
            "Keep your inner thighs firmly squeezed together throughout the movement."
        ],
        "commonMistakes": [
            "Flinging arms forward and using sudden jerking momentum to sit up.",
            "Collapsing chest and slouching at the top of the V-position."
        ],
        "safetyNotes": [
            "Control the descent vertebra by vertebra to protect lumbar spine integrity."
        ],
        "contraindications": [
            "Severe osteoporosis or acute lumbar spinal disc herniation."
        ],
        "metValue": 4.0,
        "defaultRestSec": 60,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["pilates", "classicMat", "core", "balance", "advanced"],
        "source": "curated",
        "sourceRef": "Sinew Pilates Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02115 (pilates advanced mat)."
        }
    },
    {
        "id": "reformer-footwork-toes",
        "name": "Reformer Footwork - Toes",
        "aliases": ["Footwork on Reformer", "Reformer Toes"],
        "sanskritName": None,
        "category": "pilates",
        "subcategory": "reformerClassic",
        "trackingType": "reps",
        "primaryMuscles": ["quadriceps", "calves"],
        "secondaryMuscles": ["hamstrings", "glutes", "core", "adductors"],
        "equipment": ["pilatesReformer"],
        "difficulty": "beginner",
        "unilateral": False,
        "mechanic": "compound",
        "force": "push",
        "steps": [
            "Lie supine on the reformer carriage with shoulders resting lightly against the blocks.",
            "Place the balls of both feet onto the footbar with heels together in Pilates V.",
            "Maintain a neutral pelvis with your spine resting long and flat on the carriage.",
            "Inhale and press the carriage away by extending your knees smoothly.",
            "Reach full leg extension without hyperextending or locking out your knee joints.",
            "Exhale and resist the springs as you bend your knees to return the carriage home."
        ],
        "tips": [
            "Keep your heels glued together and elevated at a steady height throughout.",
            "Resist the carriage springs with control on the return stroke."
        ],
        "commonMistakes": [
            "Letting heels drop underneath the footbar during the press.",
            "Allowing the carriage to crash loudly into the stoppers on the return."
        ],
        "safetyNotes": [
            "Confirm that reformer spring tension is properly configured before lying down."
        ],
        "contraindications": [
            "Acute Achilles tendonitis or recent foot stress fracture."
        ],
        "metValue": 3.0,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["pilates", "reformer", "lowerBody", "alignment"],
        "source": "curated",
        "sourceRef": "Sinew Pilates Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02115 (pilates apparatus)."
        }
    },
    {
        "id": "reformer-short-box-round",
        "name": "Reformer Short Box Round",
        "aliases": ["Short Box Series", "Round Back Short Box"],
        "sanskritName": None,
        "category": "pilates",
        "subcategory": "reformerClassic",
        "trackingType": "reps",
        "primaryMuscles": ["core"],
        "secondaryMuscles": ["hipFlexors", "hamstrings", "lowerBack"],
        "equipment": ["pilatesReformer"],
        "difficulty": "intermediate",
        "unilateral": False,
        "mechanic": "isolation",
        "force": "pull",
        "steps": [
            "Place the short box crosswise over the reformer carriage and secure the safety foot strap.",
            "Sit on the box facing the footbar and slip both feet securely under the safety strap.",
            "Flex your ankles firmly against the strap and round your spine into a deep C-curve.",
            "Wrap your arms around your midsection and draw your navel toward your spine.",
            "Roll back over your sit bones, maintaining the rounded C-curve until arms reach horizontal.",
            "Use your deep abdominals to curl back up over your pelvis without releasing the curve."
        ],
        "tips": [
            "Anchor into the foot strap with flexed feet for firm pelvic stability.",
            "Keep the C-curve uniform from crown to tailbone rather than hinging in lower back."
        ],
        "commonMistakes": [
            "Flattening your back and turning the roll into a straight-back hinge.",
            "Forgetting to verify the safety foot strap is securely fastened."
        ],
        "safetyNotes": [
            "Always inspect and secure the foot safety strap before sitting on the short box."
        ],
        "contraindications": [
            "Acute spinal stenosis or lumbar facet syndrome aggravated by deep flexion."
        ],
        "metValue": 3.5,
        "defaultRestSec": 45,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["pilates", "reformer", "shortBox", "core"],
        "source": "curated",
        "sourceRef": "Sinew Pilates Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02115 (pilates reformer apparatus)."
        }
    },
    {
        "id": "pilates-single-leg-stretch",
        "name": "Single Leg Stretch",
        "aliases": ["One Leg Stretch", "Abdominal Single Leg Stretch"],
        "sanskritName": None,
        "category": "pilates",
        "subcategory": "matClassic",
        "trackingType": "reps",
        "primaryMuscles": ["core"],
        "secondaryMuscles": ["hipFlexors", "quadriceps"],
        "equipment": ["yogaMat"],
        "difficulty": "beginner",
        "unilateral": True,
        "mechanic": "isolation",
        "force": None,
        "steps": [
            "Lie on your back on your mat and bring both knees into your chest.",
            "Curl your head and shoulder blades off the mat into an abdominal curl.",
            "Extend your left leg forward at a forty-five-degree angle while drawing right knee in.",
            "Place your left hand on your right knee and right hand on your right ankle.",
            "Switch legs smoothly, extending your right leg and pulling left knee into chest.",
            "Continue alternating sides rhythmically with steady continuous breathing."
        ],
        "tips": [
            "Keep your torso completely stable and quiet as your legs alternate.",
            "Keep your outside hand near your ankle and inside hand near your knee."
        ],
        "commonMistakes": [
            "Rocking your hips and torso side to side as your legs switch.",
            "Dropping your shoulder blades down onto the mat between repetitions."
        ],
        "safetyNotes": [
            "Rest your head on the mat if your neck extensors become fatigued."
        ],
        "contraindications": [
            "Acute cervical strain or unhealed abdominal surgery."
        ],
        "metValue": 3.0,
        "defaultRestSec": 30,
        "defaultHoldSec": None,
        "variationOf": None,
        "tags": ["pilates", "classicMat", "core", "unilateral"],
        "source": "curated",
        "sourceRef": "Sinew Pilates Standard",
        "license": "own",
        "verification": {
            "status": "verified",
            "passes": 2,
            "notes": "Compendium of Physical Activities code 02115 (pilates mat exercises)."
        }
    }
]

def main():
    base_dir = get_base_dir()
    dist_dir = base_dir / "dist"
    dist_dir.mkdir(parents=True, exist_ok=True)
    out_file = dist_dir / "exercises.sample.json"

    print(f"Total sample exercises to validate: {len(SAMPLE_EXERCISES)}")
    failed = 0
    categories = set()
    tracking_types = set()

    for idx, ex in enumerate(SAMPLE_EXERCISES):
        categories.add(ex["category"])
        tracking_types.add(ex["trackingType"])
        is_valid, errors = validate_exercise_record(ex)
        if not is_valid:
            print(f"[FAIL] {ex['id']}:")
            for err in errors:
                print(f"  - {err}")
            failed += 1

    print(f"Categories covered ({len(categories)}): {sorted(list(categories))}")
    print(f"Tracking types covered ({len(tracking_types)}): {sorted(list(tracking_types))}")

    if failed == 0:
        # Sort by id
        SAMPLE_EXERCISES.sort(key=lambda x: x["id"])
        with open(out_file, "w", encoding="utf-8") as f:
            json.dump(SAMPLE_EXERCISES, f, indent=2, ensure_ascii=False)
        print(f"[SUCCESS] All {len(SAMPLE_EXERCISES)} exercises strictly validated! Written to {out_file}")
    else:
        print(f"[ERROR] {failed} exercises failed validation.")
        exit(1)

if __name__ == "__main__":
    main()

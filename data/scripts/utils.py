"""Shared utilities for Sinew exercise database pipeline."""

from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
import yaml
import jsonschema


def get_base_dir() -> Path:
    """Returns the data/ root directory."""
    cwd = Path.cwd().resolve()
    if (cwd / "schema" / "exercise.schema.json").is_file():
        return cwd
    if (cwd / "data" / "schema" / "exercise.schema.json").is_file():
        return cwd / "data"
    # Fallback to repo root data dir
    data_dir = Path("/Users/gautam/Desktop/Projects/Personal/Sinew/data")
    if data_dir.is_dir():
        return data_dir
    return cwd


def load_config() -> Dict[str, Any]:
    base_dir = get_base_dir()
    config_path = base_dir / "config.yaml"
    if not config_path.is_file():
        raise FileNotFoundError(f"Missing config at {config_path}")
    with open(config_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def load_vocab() -> Dict[str, Any]:
    base_dir = get_base_dir()
    vocab_path = base_dir / "schema" / "vocab.json"
    with open(vocab_path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_muscle_regions() -> Dict[str, Any]:
    base_dir = get_base_dir()
    path = base_dir / "schema" / "muscle_regions.json"
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def get_gemini_api_key() -> Optional[str]:
    """Loads Gemini API key from environment or Mull/.env."""
    key = os.environ.get("GEMINI_API_KEY")
    if key:
        return key.strip().strip("'\"")

    env_paths = [
        Path("/Users/gautam/Desktop/Projects/Personal/Mull/.env"),
        Path.cwd() / ".env",
        Path.cwd().parent / ".env"
    ]
    for p in env_paths:
        if p.is_file():
            try:
                for line in p.read_text(encoding="utf-8").splitlines():
                    line = line.strip().lstrip("\ufeff")
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        if k.strip() == "GEMINI_API_KEY":
                            api_key = v.strip().strip("'\"")
                            os.environ["GEMINI_API_KEY"] = api_key
                            return api_key
            except Exception:
                pass
    return None


_SCHEMA_CACHE: Dict[str, Any] = {}


def get_exercise_schema() -> Dict[str, Any]:
    if "exercise" not in _SCHEMA_CACHE:
        schema_path = get_base_dir() / "schema" / "exercise.schema.json"
        with open(schema_path, "r", encoding="utf-8") as f:
            _SCHEMA_CACHE["exercise"] = json.load(f)
    return _SCHEMA_CACHE["exercise"]


def get_flow_schema() -> Dict[str, Any]:
    if "flow" not in _SCHEMA_CACHE:
        schema_path = get_base_dir() / "schema" / "flow.schema.json"
        with open(schema_path, "r", encoding="utf-8") as f:
            _SCHEMA_CACHE["flow"] = json.load(f)
    return _SCHEMA_CACHE["flow"]


def count_words(text: str) -> int:
    return len(re.findall(r"\b[\w'-]+\b", text))


def validate_exercise_record(record: Dict[str, Any]) -> Tuple[bool, List[str]]:
    """Validates an exercise record against JSON Schema and domain quality rules."""
    errors = []
    schema = get_exercise_schema()

    # 1. JSON Schema validation
    validator = jsonschema.Draft202012Validator(schema)
    for err in validator.iter_errors(record):
        field = ".".join(str(p) for p in err.path) if err.path else "root"
        errors.append(f"Schema error at '{field}': {err.message}")

    # 2. Em dash check (rule: no em dashes)
    json_str = json.dumps(record, ensure_ascii=False)
    if "—" in json_str:
        errors.append("Contains em dash ('—'). Style rule requires standard punctuation (hyphen or comma).")

    # 3. Steps word count check (under 25 words each)
    steps = record.get("steps", [])
    if isinstance(steps, list):
        for idx, step in enumerate(steps):
            if isinstance(step, str):
                wc = count_words(step)
                if wc > 25:
                    errors.append(f"Step {idx+1} exceeds 25 words ({wc} words): '{step}'")

    # 4. Tips and mistakes count & word check
    tips = record.get("tips", [])
    if isinstance(tips, list):
        for idx, tip in enumerate(tips):
            if isinstance(tip, str) and count_words(tip) > 35:
                errors.append(f"Tip {idx+1} exceeds 35 words: '{tip}'")

    mistakes = record.get("commonMistakes", [])
    if isinstance(mistakes, list):
        for idx, m in enumerate(mistakes):
            if isinstance(m, str) and count_words(m) > 35:
                errors.append(f"Mistake {idx+1} exceeds 35 words: '{m}'")

    # 5. Tracking type specific rules
    tracking = record.get("trackingType")
    if tracking == "hold":
        hold_sec = record.get("defaultHoldSec")
        if hold_sec is None or not isinstance(hold_sec, int) or hold_sec <= 0:
            errors.append("Tracking type 'hold' requires a positive integer 'defaultHoldSec'.")

    # 6. Unilateral consistency
    if record.get("unilateral") is True:
        steps_text = " ".join(steps).lower() if isinstance(steps, list) else ""
        side_keywords = ["side", "each leg", "each arm", "opposite", "repeat on", "switch"]
        if not any(k in steps_text for k in side_keywords):
            errors.append("Unilateral exercise must mention switching sides or repeating on the other side in steps.")

    # 7. Equipment consistency
    equipment = record.get("equipment", [])
    if isinstance(equipment, list):
        if "bodyweight" in equipment and any(e in equipment for e in ["barbell", "smithMachine", "trapBar", "ezBar"]):
            errors.append("Bodyweight exercise cannot include barbell/machine equipment.")

    # 8. Boxing numbered punch system check
    category = record.get("category")
    if category == "boxing":
        # Check combos mention standard punch numbers 1-6
        subcat = record.get("subcategory")
        if subcat in ["combinations", "padWork"]:
            text = (record.get("name", "") + " " + " ".join(steps)).lower()
            # Combos should reference 1-6 punch numbers
            if not any(char.isdigit() for char in text):
                errors.append("Boxing combination movement should reference the standard numbered punch system (1-6).")

    return (len(errors) == 0, errors)


def validate_flow_record(record: Dict[str, Any]) -> Tuple[bool, List[str]]:
    """Validates a flow record against flow.schema.json."""
    errors = []
    schema = get_flow_schema()
    validator = jsonschema.Draft202012Validator(schema)
    for err in validator.iter_errors(record):
        field = ".".join(str(p) for p in err.path) if err.path else "root"
        errors.append(f"Flow schema error at '{field}': {err.message}")
    return (len(errors) == 0, errors)

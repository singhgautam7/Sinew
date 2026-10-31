# Data Sources & Licensing Verification

This document records the exact licensing, origin, and permitted usage of all external seed datasets and reference compendiums used in Sinew's exercise library pipeline.

All exercise steps, form tips, common mistakes, and safety contraindications are written fresh in Sinew's clean imperative voice. No proprietary descriptions, copyrighted images, animation GIFs, or videos are imported or distributed.

---

## 1. Approved Permissive Datasets (Used for Factual Seed Extraction)

### Free Exercise DB (`yuhonas/free-exercise-db`)
- **Repository URL:** https://github.com/yuhonas/free-exercise-db
- **License:** The Unlicense (Public Domain dedication)
- **License URL:** https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/LICENSE
- **Date Verified:** 2026-11-01
- **Usage:** Seed catalog for canonical English exercise names, category taxonomy, and primary/secondary muscle associations.
- **License Compliance:** The Unlicense waives all copyright restrictions and allows unrestricted commercial redistribution, modification, and sublicensing without mandatory attribution.

### Hasan Emir Yıldırım Exercises Dataset (`hasaneyldrm/exercises-dataset`)
- **Repository URL:** https://github.com/hasaneyldrm/exercises-dataset
- **Data License:** MIT License (Copyright 2026 Hasan Emir Yıldırım)
- **Media License Warning:** The media assets (images/GIFs) in that repository are copyrighted by **Gym visual** under restrictive terms.
- **Date Verified:** 2026-11-01
- **Usage:** Factual metadata extraction only (exercise names, muscle groups, equipment requirements).
- **Strict Compliance Notice:** **Zero media files (PNG/JPG/GIF/MP4) are imported or used.** All textual instruction sentences are authored independently from scratch to ensure complete originality.

---

## 2. Scientific Reference Compendiums (Factual Data)

### 2011 / 2024 Adult Compendium of Physical Activities
- **Authors:** Ainsworth BE, Herrmann SD, Whitt-Glover MC, Bassett DR Jr, et al.
- **Official Portal:** https://pacompendium.com/
- **Date Verified:** 2026-11-01
- **Usage:** Standardized Metabolic Equivalent of Task (MET) ratings mapped to activity categories (e.g., conditioning exercise, resistance training, yoga, martial arts, cycling, running).
- **Compliance:** Scientific measurements and factual indices are not subject to copyright under US and international intellectual property law.

---

## 3. Flagged Share-Alike Datasets (NOT Used)

### wger Exercise Database (`wger-project`)
- **License:** AGPL-3.0 / Creative Commons Attribution-ShareAlike (CC BY-SA 4.0)
- **Status:** **FLAGGED & EXCLUDED.**
- **Reason:** CC BY-SA 4.0 contains viral Share-Alike provisions requiring derived databases and downstream distributions to be shared under the identical or compatible copyleft license. To ensure the Sinew SQLite database and app distribution remain 100% license-clean and free of copyleft encumbrances, wger textual data is strictly excluded from the pipeline.

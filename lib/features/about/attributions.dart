// The text of specs/data/ATTRIBUTIONS.md, kept in code so the About screen
// can show it offline without bundling a second asset. A test
// (test/about/attributions_test.dart) fails if the two ever differ: edit the
// markdown file first, then copy it here word for word.

const String kAttributionsMarkdown = r'''
# Third-Party Attributions & Data Credits

Sinew is committed to open-source transparency and rigorous data provenance. All exercise instructions, coaching cues, common mistakes, and safety contraindications are original compositions authored specifically for Sinew in a direct, imperative, second-person style.

Factual metadata (such as exercise nomenclature, anatomical classifications, and metabolic energy expenditure ratings) references the following public sources:

---

## 1. Free Exercise DB
- **Source:** [yuhonas/free-exercise-db](https://github.com/yuhonas/free-exercise-db)
- **License:** The Unlicense (Public Domain dedication)
- **Scope of Use:** Factual catalog cross-referencing for standard English exercise titles and primary/secondary target muscle anatomy.
- **Notice:** This work is dedicated to the public domain. No copyright restrictions apply.

---

## 2. Hasan Emir Yıldırım Exercise Dataset
- **Source:** [hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)
- **License:** MIT License (Copyright © 2026 Hasan Emir Yıldırım)
- **Scope of Use:** Factual movement categorization, equipment lists, and biomechanical classifications.
- **Notice:** Sinew uses zero media assets (images, GIFs, or videos) from this repository. All instructional sentences are written independently from scratch.

---

## 3. Adult Compendium of Physical Activities
- **Reference:** Ainsworth BE, Herrmann SD, Whitt-Glover MC, Bassett DR Jr, et al. *The Compendium of Physical Activities*.
- **Scope of Use:** Factual Metabolic Equivalent of Task (MET) ratings assigned to standard movement categories.
- **Official Portal:** [pacompendium.com](https://pacompendium.com/)

---

All original software, schema definitions, custom flows, and instructional texts are Copyright © Sinew Fit. Distributed under proprietary application license for Sinew on Google Play.
''';

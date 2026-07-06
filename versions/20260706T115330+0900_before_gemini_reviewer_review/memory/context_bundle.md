# Context Bundle ÔÇö 20260705T175457

This is a token-efficient index. It is not a substitute for reading required evidence.


## memory/case_definition.md

# Case Definition

This file is filled separately for each manuscript case.

Do not reuse values from another paper unless the human explicitly says so.

## Status

- Case status: active
- Date opened: 2026-07-05
- Human owner: Eugenio H. Otal
- Project short name: Isotherm Guidelines

## Required before agents can start substantive work

### Manuscript identity

- Research topic: Unified framework and guidelines for adsorption isotherm analysis in water quality studies, focused on material scientists.
- One-sentence paper idea: An introductory reference guide for materials scientists on proper adsorption data treatment, emphasizing thermodynamic consistency (adsorption energy $E_{\text{ads}}$ and capacity $Q_{\text{max}}$), models to avoid, statistical criteria, and Jupyter notebook templates.
- Article type: Reference Article / Introductory Article / Guidelines
- Target journal: ACS Applied Materials & Interfaces
- Backup journals: Water Research, Environmental Science & Technology (ES&T), Journal of Hazardous Materials
- Journal constraints: Standard ACS Applied Materials & Interfaces requirements (TOC graphic, abstract < 150 words, specific reference format).

### Scientific core

- Central hypothesis: Adsorption data treatment in materials science lacks standardization, leading to incompatible comparison of model-specific parameters. A unified framework using saturating capacity $Q_{\text{max}}$ and normalized, standard-state adsorption energy $E_{\text{ads}}$ provides a physically meaningful, model-independent basis for screening.
- Main claim to defend:
  1. $Q_{\text{max}}$ should only be reported for saturating models. Freundlich should be avoided for capacity.
  2. Adsorption affinity must be normalized by a declared reference concentration $C^0$ to obtain a dimensionless constant $K_{\text{aff}}^*$ and standard-state energy $E_{\text{ads}} = RT \ln K_{\text{aff}}^*$.
  3. Goodness-of-fit $R^2$ is insufficient and biases parameter selection; information criteria (AIC/BIC) and nested F-tests must be used for model selection.
- Weakest claim / likely Reviewer 2 attack: The choice of $C^0$ is arbitrary and alters the absolute value of $E_{\text{ads}}$ (though not relative differences).
- Allowed claims:
  - Adsorbent performance classification using ML (KNN/SVM) in descriptor space.
  - Using capacity-weighted average for Double Langmuir.
- Forbidden claims:
  - Generalizing a probe-specific affinity as a universal constant without specifying $C^0$.
  - Extrapolating Sips capacity far beyond experimental data.
- Mechanism status: supported/thermodynamics

### Data status

- Raw data location: data/raw/
- Processed data location: data/processed/
- Figures available: figures/draft/ (KNN.png, SVM.png, Isotherms.drawio_crop.png, TOC_Isotherm.png)
- Replicates available: yes
- Error bars/statistics available: yes
- Controls available: yes
- Missing experiments that must not be hidden: none
- Python analysis allowed: yes
- Expensive analysis allowed without asking: yes

### Literature and journal style

- Bibliography PDF folder: sources/bibliography_pdfs/
- Target-journal manuscript folder: sources/target_journal_manuscripts/
- Direct competitor papers: Latour (2015), de Vargas Briao (2023), Foo & Hameed (2010), Tran (2017)
- Papers that must be cited: standard adsorption literature (Langmuir 1918, Sips 1948, Freundlich 1907)
- Claims needing literature search: PFAS regulatory limits, typical drinking water contaminant concentrations.

### Human preferences

- Conservative vs aggressive tone: Conservative, educational, introductory.
- Preferred manuscript style: Clear, pedagogical, reference guide style for materials scientists.
- Things the AI must not do: Do not invent raw experimental data; do not use promotional hype.
- AI disclosure policy: Standard ACS policy.

## Agent rule

If a task depends on one of the undefined fields above, the agent must create questions in `agent_exchange/questions/` before starting.

## memory/research_context.md

# Research Context

Fill this separately for each manuscript case.

Agents must not reuse context from another paper. If a required item is `undefined`, they must ask before starting any task that depends on it.

## Working title

A Unified Framework for Adsorption Isotherm Analysis in Water Quality Studies: Descriptors, Model Selection, and Reporting Guidelines

## Research topic

Introductory guidelines and best practices for data treatment and modeling of adsorption isotherms, targeted at materials scientists.

## Target journal

ACS Applied Materials & Interfaces (ACS)

## Manuscript type

Reference / Introductory Article / Guidelines

## Central hypothesis

Direct parameter comparison across different isotherm models is physically and mathematically inconsistent. Thermodynamic normalization (using a reference concentration $C^0$ to obtain $E_{\text{ads}}$) and proper statistical model selection (using AIC/BIC and F-tests instead of $R^2$) are necessary to build reproducible structure-property relationships.

## Main claim you want to prove

1. Saturating models ($Q_{\text{max}}$) are required for capacity comparison; Freundlich must be avoided.
2. Adsorption energies ($E_{\text{ads}}$) derived from dimensionless equilibrium constants normalized by $C^0$ are the correct figure of merit for affinity.
3. Goodness-of-fit comparison using $R^2$ is statistically flawed; information criteria (AIC/BIC) and nested F-tests must be used.

## Strongest result

The development of a unified extraction table (Table 2) that maps 14 different isotherm models to universal, model-independent descriptors $\{Q_{\text{max}}, E_{\text{ads}}, \sigma_E\}$ and provides open-source Jupyter notebooks for direct implementation.

## Weakest point / expected Reviewer 2 attack

The choice of standard state concentration $C^0$ is arbitrary (e.g., 1 mol/L or 1 mg/L) and shifts the absolute values of $E_{\text{ads}}$. This needs to be clearly explained so materials scientists understand how to declare it and compare relative differences.

## Claims that are allowed

- Comparison of adsorption capacities across different saturating isotherms is valid if the plateau is well-constrained by the experimental data.
- Averaging of adsorption parameters (like Double Langmuir) using a capacity-weighted formulation.
- Classification of adsorbents in descriptor space using machine learning (KNN and SVM).

## Claims that are desired but not yet proven

- Demonstration of the framework on a diverse range of materials (MOFs, zeolites, carbons) for PFAS and other emerging contaminants (this is simulated/synthetic data in the notebooks for tutorial purposes).

## Claims that are forbidden for this case

- Do not claim field validation unless real field samples were tested.
- Do not claim selectivity unless competing ions/interferences were measured.
- Do not claim low cost or industrial scale-up without economic analysis.

## What data exist

- Simulated/synthetic isotherm fitting data in notebooks.
- Figure 1 (decision workflow).
- Figure 2 (KNN classification).
- Figure 3 (SVM linear and 3D classification).

## Data modality

- Python notebooks (`.ipynb`), LaTeX files (`.tex`), MATLAB code (`.m`), and raster/vector figures.

## What data do not exist

- Actual experimental raw databases (simulated datasets are used for illustrating the methods).

## Python analysis permission

- Can agents run local Python? Yes
- Must agents ask before expensive analysis? Yes

## Expected figure logic

- Figure 1: Workflow for adsorption isotherm model selection combining shape-based screening, AIC/F-test ranking, and physical validation.
- Figure 2: KNN classification of adsorbent materials in descriptor space.

## memory/answered_questions.md

# Answered Questions

This file logs key decisions made by the human author.

## Round 1 Decisions (2026-07-05)

1. **Target Journal:** ACS Applied Materials & Interfaces
2. **Article Type/Scope:** Reference article / Introductory guide on data treatment for materials scientists.
3. **Key Concepts to Focus on:**
   - Adsorption energy ($E_{\text{ads}}$) as a figure of merit.
   - Saturation capacity $Q_{\text{max}}$ (and which isotherms to avoid, like Freundlich).
   - Clear explanation of the reference concentration $C^0$ used to divide.
   - Clear explanation of statistical concepts (AIC/BIC, nested F-tests, and why $R^2$ is not enough).
4. **Integration of Code:** Jupyter notebooks will be incorporated for users and are exemplified in `SI.tex`.
5. **Editing Mode:** Directly review and edit `main.tex` (creating snapshots before and after).

## memory/target_journal.md

# Target Journal

This file is case-specific. If target journal or article type is undefined, agents must ask before doing journal-dependent work.

## Primary target journal

ACS Applied Materials & Interfaces

## Backup journals

1. Water Research
2. Environmental Science & Technology (ES&T)
3. Journal of Hazardous Materials

## Article type

Introductory Article / Reference Guidelines / Research Article

## Formatting constraints

- Word limit: ~5000-8000 words (guideline)
- Figure limit: None strict, but usually 5-8 figures.
- Reference style: ACS (American Chemical Society) format.
- Abstract format: Single paragraph, typically < 150 words.
- Graphical abstract (TOC): Required, 8.1 cm width x 4.4 cm height (or similar aspect ratio).
- SI requirements: Compilable SI.tex, detailing math and derivations.

## Target-journal manuscript folder

```text
sources/target_journal_manuscripts/
```

Status: undefined (empty for now)

## Journal-specific AI policy

Standard ACS policy: AI tools can only be used to improve readability/style; all use must be disclosed, and AI cannot be listed as a co-author.

## memory/forbidden_claims.md

# Forbidden Claims

This file has global defaults plus case-specific additions.

Agents must not make these claims unless the human PI explicitly moves them to allowed claims with evidence.

## Global defaults

- Do not claim field validation unless real field samples were tested.
- Do not claim selectivity unless competing ions/interferences were measured.
- Do not claim mechanism unless supported by direct evidence or clearly marked as hypothesis.
- Do not claim general fluorescence behavior from a probe-specific case.
- Do not claim universal sensor performance unless multiple analytes and matrices were demonstrated.
- Do not claim statistical significance unless a statistical test was performed.
- Do not claim industrial scalability unless scale-up or techno-economic evidence exists.
- Do not claim journal-level novelty without literature comparison.
- Do not claim robustness unless stress tests or reproducibility evidence exist.
- Do not claim low cost unless a bill of materials or defensible estimate exists.

## Case-specific forbidden claims

undefined

## memory/claims_table.md

# Claims Table

This file is case-specific. Do not reuse a previous case's claims.

| ID | Claim | Evidence | Figure/Table/Data | Citation key | Confidence | Status | Questions |
|---|---|---|---|---|---|---|---|
| C001 | Directly comparing parameter values across different isotherm models is physically and mathematically inconsistent due to different units and meanings. | Physical and mathematical analysis of Langmuir, Sips, Freundlich parameters. | Section 2.1-2.3 | Latour (2015), de Vargas Briao (2023) | High | allowed | None |
| C002 | Adsorption capacity comparisons must be restricted to saturating models ($Q_{\text{max}}$); Freundlich must be avoided. | Freundlich equation diverges as $C_e \to \infty$. | Section 2.2 / Table 1 | Foo & Hameed (2010) | High | allowed | None |
| C003 | Standard-state adsorption energy $E_{\text{ads}}$ derived from normalized, dimensionless affinity using a reference concentration $C^0$ is the correct figure of merit for affinity. | Thermodynamic derivation of dimensionless equilibrium constants. | Section 3 / Table 2 | Latour (2015) | High | allowed | None |
| C004 | Statistical model selection requires information criteria (AIC/BIC) and nested F-tests rather than $R^2$. | Overparameterized models artificially improve $R^2$; AIC/BIC penalize parameter count. | Section 5 / Figure 1 | Burnham & Anderson (2002) | High | allowed | None |
| C005 | Adsorbents can be classified and clustered in the universal descriptor space $\{Q_{\text{max}}, E_{\text{ads}}, \sigma_E\}$ using KNN and SVM models. | Simulated data classification mapping. | Figures 2 & 3 | Standard ML literature | High | allowed | None |

## memory/data_inventory.md

´╗┐# Multimodal Data Inventory

Generated by scripts/scan_data.py. This is an inventory, not an interpretation. Agents must ask before inferring file meaning.

[NO DATA FILES FOUND]

## memory/project_summary.md

# Project Summary

[Generated or updated by agents.]

## memory/data_interpretation.md

# Data Interpretation

[Generated or updated by agents.]

## memory/journal_style_model.md

# Journal Style Model

[Generated or updated by agents.]

## memory/literature_map.md

# Literature Map

[Generated or updated by agents.]

## Data files

[NO FILES FOUND]

## Figures

[NO FILES FOUND]

## Bibliography PDFs

[NO FILES FOUND]

## Extracted bibliography text

[NO FILES FOUND]

## Target-journal manuscripts

[NO FILES FOUND]

## Extracted target-journal text

[NO FILES FOUND]

## Manuscript files

[MISSING] manuscript

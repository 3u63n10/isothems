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

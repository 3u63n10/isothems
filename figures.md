# Figure inventory — Isotherm Guidelines manuscript

> Last updated: 2026-03-12

## Main manuscript figures

| Fig. | File | Script | Section | Label | Caption (short) | Status |
|------|------|--------|---------|-------|-----------------|--------|
| 1 | `document/fig_energy_distributions.pdf` | `document/plot_energy_distributions.m` | 4 (Heterogeneity) | `fig:energy_overview` | Comparative overlay of normalised site-energy distributions f(E) for all isotherm models in reduced energy u = (E − E_c)/RT. | Ready |
| 2 | `document/fig_energy_distributions_panel.pdf` | `document/plot_energy_distributions.m` | 4 (Heterogeneity) | `fig:energy_panels` | Individual energy-distribution families with parameter variations: (a) Sips, (b) Toth, (c) Jovanovic, (d) Temkin/UNILAN, (e) Freundlich, (f) D-R/D-A, (g) Hill, (h) Redlich-Peterson, (i) Langmuir. | Ready |
| 3 | `document/fig_sigma_vs_heterogeneity.pdf` | `document/plot_energy_distributions.m` | 4 (Heterogeneity) | `fig:sigma_vs_het` | sigma_E/(RT) vs heterogeneity parameter for Sips and Hill; Jovanovic reference line. | Ready |
| 4 | `KNN.png` | `KNN.m` | 5.4 (KNN classification) | `fig:KNN` | KNN classification of adsorbents in {Q_max, K_aff} space. 3 groups, 3 query points, k=10 neighbours. | Ready (run script) |
| 5 | `SVM.png` | `SVM.m` | 5.5 (SVM classification) | `fig:SVM` | SVM decision boundary and margins in {Q_max, K_aff} space. Support vectors circled. | Ready (run script) |

## Supporting Information figures

| Fig. | File | Script/Source | SI Section | Label | Caption (short) | Status |
|------|------|---------------|------------|-------|-----------------|--------|
| S1 | TikZ (inline) | `SI.tex` | S-4.4 (Decision tree) | `fig:si_decision_tree` | Complete decision tree for isotherm model selection (3 phases). | Ready (TikZ in SI.tex) |
| S2 | `document/fig_energy_distributions.pdf` | `document/plot_energy_distributions.m` | S-5.4 (Visualisation) | `fig:si_energy_overview` | Overlay of normalised f(E) for all models. | Ready |
| S3 | `document/fig_energy_distributions_panel.pdf` | `document/plot_energy_distributions.m` | S-5.4 (Visualisation) | `fig:si_energy_panels` | Individual f(E) families with parameter variations (9 panels). | Ready |
| S4 | `document/fig_sigma_vs_heterogeneity.pdf` | `document/plot_energy_distributions.m` | S-5.4 (Visualisation) | `fig:si_sigma_vs_het` | sigma_E/(RT) vs heterogeneity parameter. | Ready |
| S5 | `document/fig_isotherms.pdf` | `document/universal_route_*.m` | (not yet assigned) | — | Raw isotherms q_e vs C_e for all candidate models. | Ready |
| S6 | `document/fig_v4_models.pdf` | `document/universal_route_v4_limits.m` | (not yet assigned) | — | Comparison of model convergence in asymptotic limits. | Ready |
| S7 | `document/fig_v4_convergence.pdf` | `document/universal_route_v4_limits.m` | (not yet assigned) | — | Convergence diagnostics for iterative fitting. | Ready |
| S8 | `sips_energy_distribution.png` | `plot_sips_energy.m` | (not yet assigned) | — | Sips site-energy distribution f(E) for various n (0.4–0.9). | Ready |
| S9 | `document/Langmuir_energy.jpg` | `Langmuir_energy.m` | (not yet assigned) | — | Temperature-dependent f(E;T) from lognormal distribution in K_L. | Ready |
| S10 | `document/Freundlich_energy.jpg` | `document/freundlich_energy_distribution.m` | (not yet assigned) | — | Freundlich energy distribution (power law, unbounded). | Ready |

## main.tex figure references

| `\label` | `\includegraphics` path | Section | Eq. nearby |
|-----------|------------------------|---------|------------|
| `fig:KNN` | `KNN.png` | 5.4 `\ref{sec:KNN}` | Eq. `\ref{eq:KNN}` |
| `fig:SVM` | `SVM.png` | 5.5 `\ref{sec:SVM}` | Eq. `\ref{eq:SVM}` |

> Figs 1–3 (energy distributions) are referenced in text but `\includegraphics` not yet added to main.tex — moved to SI instead.

## SI.tex figure references

| `\label` | Source | SI Section |
|-----------|--------|------------|
| `fig:si_decision_tree` | TikZ (inline) | S-4.4 |
| `fig:si_energy_overview` | `document/fig_energy_distributions.pdf` | S-5.4 |
| `fig:si_energy_panels` | `document/fig_energy_distributions_panel.pdf` | S-5.4 |
| `fig:si_sigma_vs_het` | `document/fig_sigma_vs_heterogeneity.pdf` | S-5.4 |

## SI.tex table references

| `\label` | SI Section | Caption |
|-----------|------------|---------|
| `tab:si_energy_dist_families` | S-5.2 | Energy-distribution families for all models |
| `tab:si_sigma_numerical` | S-5.3 | Numerical sigma_E at 298 K |
| `tab:si_reporting` | S-7.1 | Minimum reporting set |
| `tab:si_extraction` | S-7.2 | Extraction of universal descriptors |

## Cross-references (main → SI)

| main.tex reference | SI target |
|--------------------|-----------|
| `\ref{SI-eq:si_langmuir}` | Eq. S-langmuir |
| `\ref{SI-eq:si_double_langmuir}` | Eq. S-double langmuir |
| `\ref{SI-eq:si_freundlich}` | Eq. S-freundlich |
| `\ref{SI-eq:si_sips}` | Eq. S-sips |
| `\ref{SI-sec:si_henry}` .. `\ref{SI-sec:si_hill}` | Model sections |
| `\ref{SI-sec:si_residuals}` | Error metrics |
| `\ref{SI-eq:si_Akaike_weight}` | Akaike weights |
| `\ref{SI-eq:si_criterion_LvsS}` | Langmuir vs Sips criterion |
| `\ref{SI-eq:si_criterion_LvsDL}` | Langmuir vs Double Langmuir criterion |
| `\ref{SI-eq:si_criterion_SvsDL}` | Sips vs Double Langmuir criterion |
| `\ref{SI-eq:si_OVL}` | Overlap coefficient |
| `\ref{SI-fig:si_decision_tree}` | Decision tree figure |
| `\ref{SI-eq:si_standardise}` | Feature standardisation |
| `\ref{SI-eq:si_distance}` | Distance metric |
| `\ref{SI-eq:si_Ward}` | Ward linkage |
| `\ref{SI-sec:si_clustering}` | Clustering section |
| `\ref{SI-sec:si_individual_distributions}` | Individual f(E) derivations |
| `\ref{SI-tab:si_energy_dist_families}` | Energy distribution families table |
| `\ref{SI-tab:si_sigma_numerical}` | sigma_E numerical values table |
| `\ref{SI-tab:si_reporting}` | Minimum reporting set table |
| `\ref{SI-tab:si_extraction}` | Descriptor extraction table |

## Scripts inventory

| Script | Location | Outputs | Notes |
|--------|----------|---------|-------|
| `KNN.m` | root | `KNN.png`, `KNN.jpg` | Uses real iris-derived data mapped to {Q_max, K_aff}. 3 species → 3 groups. `RGB_interp` for colors. |
| `SVM.m` | root | `SVM.png`, `SVM.jpg` | Linear SVM on iris-derived data (setosa vs virginica). Plots boundary, margins, support vectors. `RGB_interp`. |
| `plot_energy_distributions.m` | `document/` | `fig_energy_distributions.pdf`, `fig_energy_distributions_panel.pdf`, `fig_sigma_vs_heterogeneity.pdf`, `.dat` files, `.tex` tables | Main energy-distribution generator. Comprehensive. |
| `plot_sips_energy.m` | root | `sips_energy_distribution.png` | Sips-only f(E) at various n. Uses `RGB_interp`. |
| `Langmuir_energy.m` | root | `Langmuir_energy.jpg` | Lognormal g(K_L) → f(E;T) at multiple T. Uses `RGB_interp`. |
| `freundlich_energy_distribution.m` | `document/` | `Freundlich_energy.jpg` | Freundlich f(E). |
| `universal_route_original.m` | `document/` | Multiple figs | Original universal route computation. |
| `universal_route_corrected.m` | `document/` | Multiple figs | Corrected version. |
| `universal_route_v4_limits.m` | `document/` | `fig_v4_models.pdf`, `fig_v4_convergence.pdf` | Asymptotic limit analysis. |

## Jupyter notebooks inventory

| Notebook | Location | Purpose |
|----------|----------|---------|
| `01_isotherm_fitting_test.ipynb` | `notebooks/` | Fit 7 models to synthetic Langmuir data |
| `01_isotherm_fitting_real_data.ipynb` | `notebooks/` | User's real data fitting (user-created) |
| `02_error_metrics_model_selection.ipynb` | `notebooks/` | Error metrics + AIC/BIC ranking + F-test |
| `03_energy_distributions.ipynb` | `notebooks/` | Compute/plot f(E) and sigma_E for all models |
| `04_universal_descriptors.ipynb` | `notebooks/` | Extract {Q_max, E_ads, sigma_E} fingerprint |
| `05_classification_clustering.ipynb` | `notebooks/` | KNN, SVM, Ward clustering |
| `06_statistical_validation.ipynb` | `notebooks/` | Bootstrap, sensitivity, Monte Carlo |
| `utils_isotherms.py` | `notebooks/` | Shared module: 13 models, 8 error metrics, AIC/BIC, extraction formulas, f(E), OVL, F-test |

## Changes log

### 2026-03-12 (c)
- **SI.tex**: Added sections S-3 through S-7 with all equations from `document_2026-02-16b.tex`:
  - S-3: Error metrics (8 residual metrics) and information criteria (AIC, AICc, BIC, Akaike weights)
  - S-4: Model selection (ranking, F-test, OVL, comparison criteria, TikZ decision tree)
  - S-5: Energy distributions (framework, 2 summary tables, 14 individual derivations, 3 figures)
  - S-6: Clustering and classification (standardisation, distance, KNN, SVM, Ward, workflow)
  - S-7: Reporting protocol (minimum reporting set, extraction table, key message)
- **SI.tex**: Added `\graphicspath{{document/}}` and `\usetikzlibrary{arrows.meta, positioning, shapes.geometric, backgrounds, fit}`.
- **main.tex**: Completed all TODO sections:
  - Section 3.3: Post-table prose (Freundlich absent, DL dual values, C0 declaration)
  - Section 4.2: sigma_E prose with bullet list of key models
  - Section 5.1: Non-linear regression prose
  - Section 5.2: AIC interpretation paragraph
  - Section 5.3: Decision criteria prose (L vs S, L vs DL, S vs DL) with SI cross-refs
  - Sections 5.4/5.5: Added SI cross-references for clustering equations
  - Section 6: Full reporting guidelines (3 subsections: minimum set, workflow, practical recs)
  - Section 7: Conclusions (commented out by user for revision)
- **main.tex**: Updated suppinfo block to match actual SI content.
- **notebooks/**: Created `utils_isotherms.py` shared module and 6 Jupyter notebooks (01–06).
- **figures.md**: Major update — added SI figure/table references, cross-reference map, notebook inventory.

### 2026-03-12 (b)
- **main.tex**: KNN figure added as Fig. `fig:KNN` in Section 5.4 (`\ref{sec:KNN}`) with Eq. `\ref{eq:KNN}`.
- **main.tex**: SVM figure added as Fig. `fig:SVM` in Section 5.5 (`\ref{sec:SVM}`) with Eq. `\ref{eq:SVM}`.
- **main.tex**: Closing paragraph after SVM connects both methods, mentions sigma_E as 3rd dimension and RBF kernel.
- **figures.md**: Added `main.tex figure references` table. Updated KNN/SVM entries with final section numbers (5.4, 5.5) and labels. Updated script notes to reflect real data (iris-derived).

### 2026-03-12 (a)
- **KNN.m**: Switched to original MATLAB layout (non-TikZ). Exports `KNN.png` and `KNN.jpg` at 300 dpi.
- **SVM.m**: Switched to original MATLAB layout (non-TikZ). Exports `SVM.png` and `SVM.jpg` at 300 dpi.
- **figures.md**: Created file.

## TODO
- [x] ~~Decide whether KNN and SVM go in Section 5 or SI~~ → Section 5.4 and 5.5
- [x] ~~Run `KNN.m` and `SVM.m` to generate PNG/JPG outputs~~ → Done by user
- [x] ~~Add decision-tree figure~~ → TikZ in SI.tex (fig:si_decision_tree)
- [x] ~~Transfer equations from document_2026-02-16b.tex to SI.tex~~ → Done (S-3 through S-7)
- [x] ~~Complete main.tex prose sections~~ → Done (all TODOs filled)
- [x] ~~Create Jupyter notebooks~~ → 6 notebooks + utils module in notebooks/
- [ ] Add `\includegraphics` for Figs 1–3 (energy distributions) to main.tex if they should appear in main (currently in SI)
- [ ] Decide which of the `universal_route_*.m` outputs go into main vs SI
- [ ] Consider combining Fig 1 (overlay) and Fig 3 (sigma vs heterogeneity) into a single 2-panel figure
- [ ] Standardize all figure fonts to match achemso (Helvetica 8 pt for TOC, but regular for body figures)
- [ ] Uncomment and finalise conclusions in main.tex Section 7
- [ ] Write abstract in main.tex (currently placeholder)
- [ ] Create `references.bib` file

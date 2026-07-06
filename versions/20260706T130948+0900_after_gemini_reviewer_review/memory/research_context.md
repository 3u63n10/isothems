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
- Figure 3: SVM linear and 3D classification.

## Literature context

Bibliography is in `references.bib`.

## Target-journal context

ACS Applied Materials & Interfaces style.

## Preferred language and style

Clear, pedagogical, introductory, precise scientific English. No promotional hype.

## AI disclosure constraints

Standard ACS author guidelines.

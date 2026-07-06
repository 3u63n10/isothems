# Gemini Output — Hostile Reviewer & Auditor — 20260706_1205

## Task
Review `main.tex` and `SI.tex` for physical-chemistry rigor, clarity of jargon/slang for a materials science audience, and concept continuity, and edit the manuscript to correct methodological issues.

## Files read
* [main.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/main.tex)
* [SI.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/SI.tex)
* [case_definition.md](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/memory/case_definition.md)
* [research_context.md](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/memory/research_context.md)

## Files changed
* [main.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/main.tex) (Spelling and grammar corrections, Table 2 capacity capitalization, and molecular weight bias explanation added in Section 3.2).
* [SI.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/SI.tex) (Polanyi potential normalized with $C^0$, derivative and $C_{1/2}$ formulas updated, and a Critical Warning box on unit dependency of $E_a$ added).

## Snapshots created
* `versions/20260706T115330+0900_before_gemini_reviewer_review` (light snapshot of memory, manuscript, scripts, etc.)
* `versions/20260706T120500+0900_after_gemini_reviewer_review` (to be created at the end of the turn)

## Recommendation
Major revision

---

## Fatal issues
None.

## Major issues

### 1. Polanyi Adsorption Potential Dimensional Error in D-R / D-A (Fixed in SI)
*   **Objection:** The Polanyi potential was defined as $\varepsilon = RT \ln(1 + 1/C_e)$, which is dimensionally incorrect because a unit-less $1$ is added to the reciprocal of a concentration ($1/C_e$). If a materials scientist changes concentration units from mg~L$^{-1}$ to $\mu$g~L$^{-1}$ or mol~L$^{-1}$, the value of $\varepsilon$ changes completely, meaning that the fitted mean adsorption energy $E_a$ is highly unit-dependent. 
*   **Impact:** Using standard literature thresholds (e.g., $E_a < 8$~kJ~mol$^{-1}$ for physisorption, $8-16$~kJ~mol$^{-1}$ for ion exchange) is physically invalid unless the concentration is standardized.
*   **Correction applied:** We corrected $\varepsilon$ to $RT \ln(1 + C^0/C_e)$ and updated the corresponding derivative and $C_{1/2}$ equations. We also added a clear `redbox` warning in [SI.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/SI.tex) detailing this unit-dependency issue.

### 2. Molecular Weight Bias in Mass-Based $E_{\mathrm{ads}}$ for Cross-Pollutant Studies (Fixed in Main)
*   **Objection:** Materials scientists often work in mass-based units (mg~L$^{-1}$ or ppm). If they use a mass-based standard concentration (e.g., $C^0 = 1$~mg~L$^{-1}$) to compute $E_{\mathrm{ads}}$ in cross-pollutant studies (e.g., comparing PFAS vs. heavy metals), the thermodynamic comparison is distorted. Solutes with identical molar affinity will display different mass-based $E_{\mathrm{ads}}$ due to differences in molecular weights ($K_{L,\text{mass}} = K_{L,\text{molar}} / M_W$).
*   **Impact:** This violates the premise of a "model-independent, universal basis for screening" across contaminants.
*   **Correction applied:** Added a clarifying paragraph in [main.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/main.tex) (Section 3.2) explaining that molar units and $C^0 = 1$~mol~L$^{-1}$ are mandatory for cross-pollutant comparisons, whereas mass-based $C^0$ is only valid for comparing different adsorbents against the same single solute.

### 3. Sips Model Parameter Discontinuity at $m \to 1$ (To be addressed by Codex)
*   **Objection:** For the Sips (Langmuir-Freundlich) model, Table 3 lists the energy distribution width as $\sigma_E/(RT) = \pi/(m \sqrt{3})$. As the Sips exponent $m \to 1$, the isotherm becomes mathematically identical to the Langmuir model. However, Sips predicts a width of $\sigma_E \approx 1.81 RT \approx 4.5$~kJ~mol$^{-1}$ at $m = 1$, whereas Langmuir is defined as having $\sigma_E = 0$ (homogeneous). This creates a discontinuous jump of $4.5$~kJ~mol$^{-1}$ in the descriptor space.
*   **Impact:** Materials close to the Langmuir limit will have wildly different $\sigma_E$ coordinates depending on whether they were fitted with Sips or Langmuir, disrupting the KNN and SVM classification algorithms.
*   **Action for Codex:** Define the "intrinsic heterogeneity width" $\sigma_H$ by subtracting the thermal width $\sigma_T$ from the condensation-approximation width:
    $$\sigma_{H} = \sigma_T \sqrt{\frac{1}{m^2} - 1}$$
    This ensures that as $m \to 1$, Sips $\sigma_H \to 0$, maintaining mathematical continuity across models.

---

## Minor issues

### 1. Inconsistent Capacity Capitalization (Fixed in Main)
*   In Table 2, Toth and Jovanovic models used $q_{\max}$ while other models used $Q_{\max}$. We standardized this to $Q_{\max}$ to avoid confusing the reader.

### 2. Spelling and Grammatical Typos (Fixed in Main)
*   Line 214: Corrected "principles principles" to "principles".
*   Line 215: Corrected "availables isotherms" to "available isotherms".
*   Line 217: Corrected "an statistical guideline" and "chosing" to "a statistical guideline" and "choosing".
*   Line 218: Corrected "Forth" and "clusterize" to "Fourth" and "cluster".
*   Line 258: Corrected Freundlich units "(mg.g$^{-1}$)(L.gg$^{-1}$)$^{1/n}$" to "(mg$\cdot$g$^{-1}$)(L$\cdot$mg$^{-1}$)$^{1/n}$".

---

## Required corrections (For Codex)
1.  **Integrate $\sigma_H$ (Intrinsic Heterogeneity Width) into Table 2 and Table 3:**
    Update [main.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/main.tex) and [SI.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/SI.tex) to replace $\sigma_E$ with $\sigma_H$ (intrinsic width) for continuous models, or clearly define both so that the machine learning models operate on a continuous feature space.
2.  **Adjust the Companion Jupyter Notebooks:**
    Verify that the KNN/SVM clustering scripts in the notebooks utilize the standardized $\sigma_H$ rather than the discontinuous $\sigma_E$, ensuring that Langmuir-like fits do not cluster separately from true Langmuir fits.

## Questions for human PI
1.  Should we explicitly mandate that all cross-pollutant datasets in the companion notebooks be converted to molar units (mol/L) before extracting descriptors, or is an explanatory warning in the documentation sufficient?

## What Codex should revise next
Codex must update the heterogeneity width definitions ($\sigma_H$) in both [main.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/main.tex) and [SI.tex](file:///c:/Users/eugen/Dropbox/00000_agents/Writing/050-Isotherm_guidelines/SI.tex) to resolve the Sips $m \to 1$ parameter discontinuity, and then run `scripts/check_markers.py` to verify that no unresolved markers or formatting tags remain.

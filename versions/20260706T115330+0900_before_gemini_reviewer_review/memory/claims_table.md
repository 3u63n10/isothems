# Claims Table

This file is case-specific. Do not reuse a previous case's claims.

| ID | Claim | Evidence | Figure/Table/Data | Citation key | Confidence | Status | Questions |
|---|---|---|---|---|---|---|---|
| C001 | Directly comparing parameter values across different isotherm models is physically and mathematically inconsistent due to different units and meanings. | Physical and mathematical analysis of Langmuir, Sips, Freundlich parameters. | Section 2.1-2.3 | Latour (2015), de Vargas Briao (2023) | High | allowed | None |
| C002 | Adsorption capacity comparisons must be restricted to saturating models ($Q_{\text{max}}$); Freundlich must be avoided. | Freundlich equation diverges as $C_e \to \infty$. | Section 2.2 / Table 1 | Foo & Hameed (2010) | High | allowed | None |
| C003 | Standard-state adsorption energy $E_{\text{ads}}$ derived from normalized, dimensionless affinity using a reference concentration $C^0$ is the correct figure of merit for affinity. | Thermodynamic derivation of dimensionless equilibrium constants. | Section 3 / Table 2 | Latour (2015) | High | allowed | None |
| C004 | Statistical model selection requires information criteria (AIC/BIC) and nested F-tests rather than $R^2$. | Overparameterized models artificially improve $R^2$; AIC/BIC penalize parameter count. | Section 5 / Figure 1 | Burnham & Anderson (2002) | High | allowed | None |
| C005 | Adsorbents can be classified and clustered in the universal descriptor space $\{Q_{\text{max}}, E_{\text{ads}}, \sigma_E\}$ using KNN and SVM models. | Simulated data classification mapping. | Figures 2 & 3 | Standard ML literature | High | allowed | None |

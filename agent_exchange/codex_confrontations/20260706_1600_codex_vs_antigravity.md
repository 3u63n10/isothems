# Codex vs Antigravity Confrontation Table -- 20260706_1600

Source reviewed: `review_report_20260706_1550.md` on branch `review_20260706_1550`.

| ID | Antigravity suggestion | Codex classification | Codex decision | Action taken |
|---|---|---|---|---|
| AG-01 | Correct introduction typo "Forth" to "Fourth". | ACCEPT | Pure typographical correction. | Already corrected in `main_20260706_1550.tex`. |
| AG-02 | Replace "clusterize" for KNN/SVM with supervised-classification language. | ACCEPT | KNN and SVM are supervised classifiers; Ward linkage is the unsupervised clustering method. | Confirmed in `main_20260706_1550.tex`: introduction and ML section now distinguish classification from clustering. |
| AG-03 | Correct Freundlich unit typo from `gg` to `mg`. | ACCEPT | Pure typographical correction. | Confirmed no `gg` unit remains in `main_20260706_1550.tex`. |
| AG-04 | Use Sips as `q_e = Qmax K_S C_e^m / (1 + K_S C_e^m)` to match SI. | ACCEPT WITH MODIFICATION | Accepted as the manuscript convention. The modification is to state the convention explicitly: with `K_S C_e^m`, `K_S` has units `[C]^{-m}` and the comparable reciprocal-concentration affinity is `K_S^{1/m}`. | Resolved the Sips "To Discuss" box in `main_20260706_1550.tex`; updated `notebooks/utils_isotherms.py` so `sips()` uses `KS * Ce**m`. |
| AG-05 | Explain divergent Henry limit for Sips/Koble-Corrigan and use operational affinity. | ACCEPT | For `m < 1`, the low-concentration slope diverges and no finite Henry constant exists. The descriptor must use an operational affinity with reciprocal-concentration units. | Confirmed in `main_20260706_1550.tex`: Section 3.1 explains operational affinity, e.g. `K_S^{1/m}`. |
| AG-06 | Replace dimensionally inconsistent Dubinin `RT ln(1+1/C_e)` with `RT ln(1+C_ref/C_e)`. | ACCEPT WITH MODIFICATION | Accepted, with the explicit requirement that `C_ref` be declared and expressed in the same concentration units as `C_e`; the default code convention is `C_ref = 1` in those units. | Resolved the Dubinin "To Discuss" box in `SI_20260706_1550.tex`; updated both SI occurrences and the main-text Dubinin summary. |
| AG-07 | Propagate `C_ref` into the D-R/D-A derivative. | ACCEPT | The derivative term must include `RT C_ref/[C_e(C_e+C_ref)]`; this is required by the normalized Polanyi potential. | Confirmed derivative in `SI_20260706_1550.tex`; updated `notebooks/utils_isotherms.py` so D-R/D-A fitting and `C_{1/2}` descriptor extraction use `Cref`. |

## Remaining Human Decision

No unresolved mathematical blocker remains for AG-01 to AG-07. The human PI should only confirm the reporting convention for the reference concentration, recommended as:

`C_ref = 1` in the same concentration units used for `C_e`, reported explicitly together with fitted D-R/D-A parameters.

## Codex Position

The Antigravity corrections are scientifically sound. The Sips and Dubinin issues are accepted with convention-level clarifications rather than open discussion boxes, so the revised files can be treated as resolved review drafts rather than annotated debate drafts.

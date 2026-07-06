# Isotherm Guidelines - Companion Tools

This folder contains the computational companion files for the manuscript:
fitting notebooks, model-selection utilities, descriptor extraction, and an
interactive Streamlit app.

## Active Files

- `01_isotherm_fitting.ipynb`
  Fits the 13 candidate isotherm models to `Ce`-`qe` data loaded from CSV or
  Excel.
- `02_error_metrics_model_selection.ipynb`
  Computes residual metrics, AIC/AICc/BIC, Akaike weights, F-tests, and the
  descriptor table used for reporting.
- `03_statistical_validation.ipynb`
  Demonstrates bootstrap confidence intervals, sensitivity analysis, and
  uncertainty propagation to `Eads` and `sigma_H`.
- `04_classification_clustering.ipynb`
  Demonstrates KNN, SVM, and Ward clustering from descriptor tables.
- `app_isotherm_fitting.py`
  Streamlit interface for quick fitting and descriptor export.
- `utils_isotherms.py`
  Shared equations, fitting utilities, error metrics, and descriptor
  extraction.

## Sample Data

- `sample_isotherm_data.csv`
  Example adsorption isotherm file with columns `Ce` and `qe`.
- `sample_descriptors_basic.csv`
  Example descriptor table for classification with numeric columns only.
- `sample_descriptors_isotherm.csv`
  Example descriptor table with an additional categorical `isotherm_type`
  column.
- `sample_descriptors_full.csv`
  Example descriptor table with `isotherm_type`, `material_type`, and `group`.

## Recommended Workflow

1. Start with `01_isotherm_fitting.ipynb` or `app_isotherm_fitting.py` to fit
   the raw adsorption data.
2. Use `02_error_metrics_model_selection.ipynb` to compare models and extract
   `Qmax`, `Kaff_star`, `Eads`, and `sigma_H`.
3. Use `03_statistical_validation.ipynb` to add bootstrap intervals and noise
   sensitivity checks.
4. If several materials are available, build a descriptor table and analyze it
   with `04_classification_clustering.ipynb`.

## Stupid-proof first run

Run the notebooks in numerical order. Do not skip ahead on the first pass.

1. `01_isotherm_fitting.ipynb`
   Use `sample_isotherm_data.csv`. Check that at least one model converges and
   that the fit overlay looks reasonable.
2. `02_error_metrics_model_selection.ipynb`
   Use the same sample file. Compare metrics, residuals, AICc/BIC, and the
   extracted descriptor table.
3. `03_statistical_validation.ipynb`
   Run the built-in synthetic Sips example. Check the bootstrap histograms and
   the propagated uncertainty in `Eads` and `sigma_H`.
4. `04_classification_clustering.ipynb`
   Use `sample_descriptors_full.csv`. Check that the workflow uses `sigma_H`,
   standardises numeric descriptors, and separates supervised classification
   from unsupervised clustering.

Each notebook begins with a short checklist and ends with a checkpoint section.
If a checkpoint fails, stop there and fix the input, units, or model choice
before moving to the next notebook.

## Input Requirements

### Raw isotherm fitting

- Required columns: `Ce`, `qe`
- Accepted formats: `.csv`, `.xlsx`, `.xls`

### Classification and clustering

- At least 2 numeric descriptor columns
- One target column named `group`
- Optional categorical columns are one-hot encoded automatically

## Streamlit App

From this folder:

```bash
pip install streamlit
streamlit run app_isotherm_fitting.py
```

The app exports both the fit-metric table and the descriptor table.

## Notes

- `backup_notebooks/` stores older notebook variants kept for reference only.
- `_notebook_snapshots/` stores dated copies made before notebook edits.
- The active workflow is `01 -> 02 -> 03 -> 04`.

## License

MIT - see `LICENSE`.

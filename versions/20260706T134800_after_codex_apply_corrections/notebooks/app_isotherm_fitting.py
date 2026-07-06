import io
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import streamlit as st
from scipy.optimize import curve_fit

# Allow importing utils_isotherms.py from the current folder.
ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from utils_isotherms import (  # noqa: E402
    MODELS,
    compute_SSE,
    compute_R2,
    compute_AIC,
    compute_AICc,
    compute_BIC,
    extract_descriptors,
)


DEFAULT_MODELS = [
    "Langmuir",
    "Freundlich",
    "Sips",
    "Toth",
    "Jovanovic",
    "Hill",
]


def _parse_pasted_data(text: str) -> pd.DataFrame:
    lines = [ln.strip() for ln in text.strip().splitlines() if ln.strip()]
    rows = []
    for ln in lines:
        # Allow comma, tab, or space-separated
        parts = [p for p in ln.replace(",", " ").replace("\t", " ").split(" ") if p]
        if len(parts) < 2:
            continue
        try:
            ce = float(parts[0])
            qe = float(parts[1])
            rows.append((ce, qe))
        except ValueError:
            continue
    return pd.DataFrame(rows, columns=["Ce", "qe"])


def load_data() -> pd.DataFrame:
    st.subheader("Input Data")
    method = st.radio(
        "Choose data input method",
        ["Manual table", "Paste from clipboard", "Upload CSV/Excel"],
        horizontal=True,
    )

    if method == "Manual table":
        default_df = pd.DataFrame({"Ce": [0.1, 0.2, 0.5, 1.0, 2.0], "qe": [np.nan] * 5})
        edited = st.data_editor(
            default_df,
            num_rows="dynamic",
            use_container_width=True,
        )
        return edited

    if method == "Paste from clipboard":
        txt = st.text_area(
            "Paste data (two columns: Ce qe). Supports comma, tab, or space-separated.",
            height=160,
        )
        if not txt.strip():
            return pd.DataFrame(columns=["Ce", "qe"])
        return _parse_pasted_data(txt)

    uploaded = st.file_uploader(
        "Upload CSV or Excel file",
        type=["csv", "xlsx", "xls"],
    )
    if uploaded is None:
        return pd.DataFrame(columns=["Ce", "qe"])

    if uploaded.name.lower().endswith(".csv"):
        df = pd.read_csv(uploaded)
    else:
        df = pd.read_excel(uploaded)
    # Normalize column names
    cols = {c.lower(): c for c in df.columns}
    if "ce" in cols and "qe" in cols:
        df = df[[cols["ce"], cols["qe"]]].rename(columns={cols["ce"]: "Ce", cols["qe"]: "qe"})
    return df


def _initial_guess(model_name: str, ce: np.ndarray, qe: np.ndarray):
    qmax = np.nanmax(qe)
    ce_med = np.nanmedian(ce)
    if model_name == "Langmuir":
        return [qmax, 1.0 / max(ce_med, 1e-8)]
    if model_name == "Double Langmuir":
        return [0.6 * qmax, 1.0 / max(ce_med, 1e-8), 0.4 * qmax, 0.5 / max(ce_med, 1e-8)]
    if model_name == "Freundlich":
        return [np.nanmax(qe) / max(ce_med, 1e-8), 0.7]
    if model_name == "Sips":
        return [qmax, 1.0 / max(ce_med, 1e-8), 0.8]
    if model_name == "Toth":
        return [qmax, 1.0 / max(ce_med, 1e-8), 0.8]
    if model_name == "Jovanovic":
        return [qmax, 1.0 / max(ce_med, 1e-8)]
    if model_name == "Temkin":
        return [1.0 / max(ce_med, 1e-8), 1.0]
    if model_name == "UNILAN":
        return [qmax, 2.0 / max(ce_med, 1e-8), 0.5 / max(ce_med, 1e-8)]
    if model_name == "Redlich-Peterson":
        return [1.0, 1.0, 0.8]
    if model_name == "Koble-Corrigan":
        return [qmax, 1.0, 0.8]
    if model_name == "Radke-Prausnitz":
        return [1.0, 1.0, 0.8]
    if model_name == "D-R/D-A":
        return [qmax, 10.0, 2.0]
    if model_name == "Hill":
        return [qmax, 1.0, 1.0]
    return None


def _bounds_for(model_name: str):
    # Basic positivity bounds where appropriate
    if model_name in {"Langmuir", "Jovanovic"}:
        return (0, np.inf)
    if model_name == "Double Langmuir":
        return (0, np.inf)
    if model_name == "Freundlich":
        return (0, np.inf)
    if model_name in {"Sips", "Toth"}:
        return (0, np.inf)
    if model_name == "Temkin":
        return (0, np.inf)
    if model_name == "UNILAN":
        return (0, np.inf)
    if model_name == "Redlich-Peterson":
        return (0, np.inf)
    if model_name == "Koble-Corrigan":
        return (0, np.inf)
    if model_name == "Radke-Prausnitz":
        return (0, np.inf)
    if model_name == "D-R/D-A":
        return (0, np.inf)
    if model_name == "Hill":
        return (0, np.inf)
    return (0, np.inf)


def fit_models(df: pd.DataFrame, model_names):
    results = []
    ce = df["Ce"].to_numpy(dtype=float)
    qe = df["qe"].to_numpy(dtype=float)

    for name in model_names:
        func, param_names, p = MODELS[name]
        p0 = _initial_guess(name, ce, qe)
        bounds = _bounds_for(name)
        try:
            popt, _ = curve_fit(
                func,
                ce,
                qe,
                p0=p0,
                bounds=bounds,
                maxfev=20000,
            )
            q_pred = func(ce, *popt)
            params = {k: v for k, v in zip(param_names, popt)}
            results.append(
                {
                    "Model": name,
                    "Parameters": params,
                    "q_pred": q_pred,
                    "n_params": p,
                }
            )
        except Exception as exc:
            results.append(
                {
                    "Model": name,
                    "Parameters": None,
                    "q_pred": None,
                    "n_params": p,
                    "error": str(exc),
                }
            )
    return results


def compute_metrics(df: pd.DataFrame, fit_results):
    ce = df["Ce"].to_numpy(dtype=float)
    qe = df["qe"].to_numpy(dtype=float)
    n = len(qe)

    rows = []
    for r in fit_results:
        if r["q_pred"] is None:
            rows.append(
                {
                    "Model": r["Model"],
                    "Parameters": "Fit failed",
                    "SSE": np.nan,
                    "R2": np.nan,
                    "AIC": np.nan,
                    "AICc": np.nan,
                    "BIC": np.nan,
                }
            )
            continue

        q_pred = r["q_pred"]
        p = r["n_params"]
        sse = compute_SSE(qe, q_pred)
        r2 = compute_R2(qe, q_pred)
        aic = compute_AIC(n, sse, p) if sse > 0 else np.nan
        aicc = compute_AICc(n, sse, p) if (sse > 0 and n > p + 1) else np.nan
        bic = compute_BIC(n, sse, p) if sse > 0 else np.nan

        param_str = ", ".join([f"{k}={v:.4g}" for k, v in r["Parameters"].items()])
        rows.append(
            {
                "Model": r["Model"],
                "Parameters": param_str,
                "SSE": sse,
                "R2": r2,
                "AIC": aic,
                "AICc": aicc,
                "BIC": bic,
            }
        )

    out = pd.DataFrame(rows)
    out = out.sort_values(by="AICc", na_position="last")
    return out


def compute_descriptor_table(fit_results, C0: float, T: float):
    rows = []
    for r in fit_results:
        if r["Parameters"] is None:
            continue

        desc = extract_descriptors(r["Model"], r["Parameters"], C0=C0, T=T)
        kaff = desc["Kaff_star"]
        rows.append(
            {
                "Model": r["Model"],
                "Qmax": desc["Qmax"],
                "Kaff_star": kaff,
                "ln_Kaff_star": np.log(kaff) if np.isfinite(kaff) and kaff > 0 else np.nan,
                "Eads_kJ_mol": desc["Eads"],
                "sigma_H_kJ_mol": desc["sigma_H"],
                "sigma_E_apparent_kJ_mol": desc["sigma_E"],
            }
        )

    out = pd.DataFrame(rows)
    if not out.empty:
        out = out.sort_values(by="Model")
    return out


def plot_results(df: pd.DataFrame, fit_results):
    import matplotlib.pyplot as plt

    ce = df["Ce"].to_numpy(dtype=float)
    qe = df["qe"].to_numpy(dtype=float)

    fig, ax = plt.subplots(figsize=(6.5, 4.2), dpi=150)
    ax.scatter(ce, qe, color="black", s=30, label="Experimental")

    ce_grid = np.logspace(np.log10(np.min(ce)), np.log10(np.max(ce)), 200)
    for r in fit_results:
        if r["Parameters"] is None:
            continue
        func = MODELS[r["Model"]][0]
        popt = [r["Parameters"][k] for k in MODELS[r["Model"]][1]]
        q_fit = func(ce_grid, *popt)
        ax.plot(ce_grid, q_fit, linewidth=1.5, label=r["Model"])

    ax.set_xscale("log")
    ax.set_xlabel("Ce")
    ax.set_ylabel("qe")
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, which="both", linestyle=":", linewidth=0.5, alpha=0.5)

    # Residuals plot
    fig_res, ax_res = plt.subplots(figsize=(6.5, 3.5), dpi=150)
    for r in fit_results:
        if r["q_pred"] is None:
            continue
        resid = qe - r["q_pred"]
        ax_res.scatter(ce, resid, s=20, label=r["Model"])
    ax_res.axhline(0, color="black", linewidth=1)
    ax_res.set_xscale("log")
    ax_res.set_xlabel("Ce")
    ax_res.set_ylabel("Residual (qe - q_fit)")
    ax_res.grid(True, which="both", linestyle=":", linewidth=0.5, alpha=0.5)
    ax_res.legend(fontsize=8, ncol=2)

    return fig, fig_res


def main():
    st.title("Adsorption Isotherm Fitting")
    st.write("Fit common isotherm models to experimental data.")

    df = load_data()
    if df.empty:
        st.info("Provide data to continue.")
        return

    df = df.dropna()
    df = df[(df["Ce"] > 0) & (df["qe"] >= 0)]
    if len(df) < 4:
        st.warning("Need at least 4 valid data points.")
        return

    st.subheader("Descriptor Settings")
    col1, col2 = st.columns(2)
    with col1:
        C0 = st.number_input("Standard-state concentration C0", min_value=1e-12, value=1.0, format="%.6g")
    with col2:
        T = st.number_input("Temperature (K)", min_value=1.0, value=298.0, format="%.3f")

    st.subheader("Model Selection")
    model_names = st.multiselect(
        "Select models to fit",
        list(MODELS.keys()),
        default=DEFAULT_MODELS,
    )
    if not model_names:
        st.warning("Select at least one model.")
        return

    if st.button("Run fit"):
        fit_results = fit_models(df, model_names)
        metrics_df = compute_metrics(df, fit_results)
        descriptor_df = compute_descriptor_table(fit_results, C0=C0, T=T)

        st.subheader("Fit Results (sorted by AICc)")
        st.dataframe(metrics_df, use_container_width=True)

        st.subheader("Universal Descriptors")
        st.dataframe(descriptor_df, use_container_width=True)

        fig, fig_res = plot_results(df, fit_results)
        st.subheader("Fits")
        st.pyplot(fig)
        st.subheader("Residuals vs Ce")
        st.pyplot(fig_res)

        # Export table
        st.subheader("Export")
        csv_bytes = metrics_df.to_csv(index=False).encode("utf-8")
        st.download_button(
            "Download results CSV",
            data=csv_bytes,
            file_name="isotherm_fit_results.csv",
            mime="text/csv",
        )

        descriptor_csv = descriptor_df.to_csv(index=False).encode("utf-8")
        st.download_button(
            "Download descriptor CSV",
            data=descriptor_csv,
            file_name="isotherm_descriptors.csv",
            mime="text/csv",
        )

        # Export plot
        buf = io.BytesIO()
        fig.savefig(buf, format="png", dpi=200, bbox_inches="tight")
        buf.seek(0)
        st.download_button(
            "Download fit plot (PNG)",
            data=buf,
            file_name="isotherm_fits.png",
            mime="image/png",
        )


if __name__ == "__main__":
    main()

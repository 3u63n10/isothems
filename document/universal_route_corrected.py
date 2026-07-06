"""
universal_route_corrected.py
CORRECTED implementation based on Universal_route_v2.tex

Improvements over the original:
  1. Quantitative criteria for Henry/plateau region selection (F-test)
  2. Convergence check for iterative Kp estimation
  3. Tikhonov-regularized NNLS with L-curve for lambda selection
  4. Bootstrap confidence intervals
  5. Convergence diagnostics for K_H (first-moment finiteness)
  6. Diagnostic plots

Requirements: numpy, scipy, matplotlib
"""

import warnings
import numpy as np
from scipy.optimize import nnls
from scipy.stats import f as f_dist, t as t_dist
import matplotlib.pyplot as plt


# ======================================================================
#  Core function: corrected workflow
# ======================================================================

def universal_route_corrected(Ce, q, sigma):
    """
    Corrected workflow with quantitative region selection criteria.

    Parameters
    ----------
    Ce : array_like
        Equilibrium concentrations.
    q : array_like
        Equilibrium uptake.
    sigma : array_like
        Uncertainties (standard deviations).

    Returns
    -------
    dict with keys: Qmax, KH, Kaff, Kp, n_henry, n_plateau,
                    use_partition, KH_sensitivity
    """
    Ce = np.asarray(Ce, dtype=float).ravel()
    q = np.asarray(q, dtype=float).ravel()
    sigma = np.asarray(sigma, dtype=float).ravel()
    w = 1.0 / sigma**2
    N = len(Ce)

    idx = np.argsort(Ce)
    Ce, q, w, sigma = Ce[idx], q[idx], w[idx], sigma[idx]

    # ---- Step 1: Partition test ----
    # Use up to 12 high-C points for better statistical power
    m_high = min(12, max(5, N // 3))
    I_high = np.arange(N - m_high, N)

    # Test A: OLS t-test on slope (unweighted -- crucial!)
    # WLS with sigma proportional to q downweights the highest-C points
    # where the partition signal is strongest, killing detection power.
    X_h = np.column_stack([np.ones(m_high), Ce[I_high]])
    XtX = X_h.T @ X_h
    beta_h = np.linalg.pinv(XtX) @ (X_h.T @ q[I_high])
    resid_h = q[I_high] - X_h @ beta_h
    df = max(m_high - 2, 1)
    s2_h = np.sum(resid_h**2) / df
    cov_h = s2_h * np.linalg.pinv(XtX)
    se_slope = np.sqrt(max(cov_h[1, 1], 0))
    t_slope = beta_h[1] / se_slope if se_slope > 0 else 0
    t_crit = t_dist.ppf(0.975, df)
    use_partition_ttest = (t_slope > t_crit) and (beta_h[1] > 0)

    # Test B: ratio check (q/C at high C vs low C)
    ratio_high = q[I_high] / Ce[I_high]
    ratio_low = q[:min(3, N)] / Ce[:min(3, N)]
    mean_ratio_high = np.mean(ratio_high)
    mean_ratio_low = np.mean(ratio_low)
    use_partition_ratio = (mean_ratio_high > 0.10 * mean_ratio_low) and \
                          (mean_ratio_high > 0)

    # Test C: numerical derivative constancy at high C
    # For partition models, dq/dC -> Kp (constant) at high C.
    # For Freundlich/power-law, dq/dC is monotonically decreasing.
    # Require BOTH: derivative above threshold AND approximately flat.
    n_pairs = min(6, m_high - 1)
    I_deriv = np.arange(N - n_pairs, N + 1)
    I_deriv = I_deriv[I_deriv < N]  # safety clip
    if len(I_deriv) >= 2:
        dqdc = np.diff(q[I_deriv]) / np.diff(Ce[I_deriv])
        mean_dqdc = np.mean(dqdc)
        mid_idx = N // 2
        q_mid = q[mid_idx]
        C_mid = Ce[mid_idx]
        deriv_threshold = 0.02 * q_mid / C_mid
        # Flatness check: compare median derivative of second half to first half
        # Partition: ratio ~ 1.  Freundlich: ratio < 0.7.
        if len(dqdc) >= 4:
            half = len(dqdc) // 2
            med_first = np.median(dqdc[:half])
            med_second = np.median(dqdc[half:])
            deriv_ratio = med_second / max(med_first, 1e-10)
            deriv_is_flat = (deriv_ratio > 0.70)
        else:
            deriv_is_flat = True
        use_partition_deriv = (mean_dqdc > deriv_threshold) and deriv_is_flat
    else:
        use_partition_deriv = False

    use_partition = use_partition_ttest or use_partition_ratio \
                    or use_partition_deriv

    # ---- Step 2: Estimate Qmax ----
    if not use_partition:
        # No partition: find plateau region via t-test on log(C) trend
        n_plateau = 3
        for m_try in range(4, min(N - 2, N // 2) + 1):
            I_try = np.arange(N - m_try, N)
            X_t = np.column_stack([np.ones(m_try), np.log(Ce[I_try])])
            W_t = np.diag(w[I_try])
            XWX_t = X_t.T @ W_t @ X_t
            beta_t = np.linalg.pinv(XWX_t) @ (X_t.T @ W_t @ q[I_try])
            resid_t = q[I_try] - X_t @ beta_t
            df_t = max(m_try - 2, 1)
            s2_t = np.sum(w[I_try] * resid_t**2) / df_t
            cov_t = s2_t * np.linalg.pinv(XWX_t)
            se_lnC = np.sqrt(max(cov_t[1, 1], 0))
            t_lnC = abs(beta_t[1]) / se_lnC if se_lnC > 0 else 0
            t_crit_plat = t_dist.ppf(0.975, df_t)
            if t_lnC > t_crit_plat:
                break
            n_plateau = m_try

        I_plat = np.arange(N - n_plateau, N)

        if n_plateau >= 3:
            Qmax = np.sum(w[I_plat] * q[I_plat]) / np.sum(w[I_plat])
        else:
            n_ext = min(5, N // 2)
            I_ext = np.arange(N - n_ext, N)
            X_e = np.column_stack([np.ones(n_ext), 1.0 / Ce[I_ext]])
            W_e = np.diag(w[I_ext])
            beta_e = np.linalg.pinv(X_e.T @ W_e @ X_e) @ \
                     (X_e.T @ W_e @ q[I_ext])
            Qmax = beta_e[0]
            if beta_e[1] > 0:
                warnings.warn("A1 < 0: 1/C extrapolation may be unreliable.")
        Kp = 0.0
    else:
        # Partition detected: jointly estimate Kp and Qmax
        # At high C: q ~ Kp*C + Qmax, so fit q vs C to get both
        n_ext = min(10, max(5, N // 3))
        I_ext = np.arange(N - n_ext, N)

        # First estimate Kp from slope of q vs C at high concentrations
        X_lin = np.column_stack([np.ones(n_ext), Ce[I_ext]])
        W_lin = np.diag(w[I_ext])
        beta_lin = np.linalg.pinv(X_lin.T @ W_lin @ X_lin) @ \
                   (X_lin.T @ W_lin @ q[I_ext])
        Kp = max(beta_lin[1], 0)
        Qmax = max(beta_lin[0], 0)

        # Iterative refinement
        for _iter in range(30):
            q_sat = q - Kp * Ce
            X_e = np.column_stack([np.ones(n_ext), 1.0 / Ce[I_ext]])
            W_e = np.diag(w[I_ext])
            beta_e = np.linalg.pinv(X_e.T @ W_e @ X_e) @ \
                     (X_e.T @ W_e @ q_sat[I_ext])
            Qmax_new = max(beta_e[0], 0)

            q_resid = q[I_high] - Qmax_new
            Kp_new = max(np.sum(w[I_high] * Ce[I_high] * q_resid) /
                         np.sum(w[I_high] * Ce[I_high]**2), 0)

            dKp = abs(Kp_new - Kp) / max(abs(Kp), 1e-10)
            dQmax = abs(Qmax_new - Qmax) / max(abs(Qmax), 1e-10)
            Kp = Kp_new
            Qmax = Qmax_new
            if max(dKp, dQmax) < 1e-4:
                break

        # Determine plateau region on q_sat = q - Kp*C
        q_sat = q - Kp * Ce
        n_plateau = 3
        for m_try in range(4, min(N - 2, N // 2) + 1):
            I_try = np.arange(N - m_try, N)
            X_t = np.column_stack([np.ones(m_try), np.log(Ce[I_try])])
            W_t = np.diag(w[I_try])
            XWX_t = X_t.T @ W_t @ X_t
            beta_t = np.linalg.pinv(XWX_t) @ (X_t.T @ W_t @ q_sat[I_try])
            resid_t = q_sat[I_try] - X_t @ beta_t
            df_t = max(m_try - 2, 1)
            s2_t = np.sum(w[I_try] * resid_t**2) / df_t
            cov_t = s2_t * np.linalg.pinv(XWX_t)
            se_lnC = np.sqrt(max(cov_t[1, 1], 0))
            t_lnC = abs(beta_t[1]) / se_lnC if se_lnC > 0 else 0
            t_crit_plat = t_dist.ppf(0.975, df_t)
            if t_lnC > t_crit_plat:
                break
            n_plateau = m_try

    # ---- Step 3: Estimate KH with F-test ----
    q_for_henry = q - Kp * Ce if use_partition else q.copy()
    n_henry = 3

    for m_try in range(3, min(N - 2, N // 2) + 1):
        I_try = np.arange(m_try)
        q_h = q_for_henry[I_try]
        C_h = Ce[I_try]
        w_h = w[I_try]

        KH_lin = np.sum(w_h * C_h * q_h) / np.sum(w_h * C_h**2)
        resid_lin = q_h - KH_lin * C_h
        SSE_lin = np.sum(w_h * resid_lin**2)

        if m_try >= 4:
            X_q = np.column_stack([C_h, C_h**2])
            W_q = np.diag(w_h)
            beta_q = np.linalg.pinv(X_q.T @ W_q @ X_q) @ \
                     (X_q.T @ W_q @ q_h)
            resid_q = q_h - X_q @ beta_q
            SSE_quad = np.sum(w_h * resid_q**2)
            df2 = m_try - 2
            if SSE_quad > 0 and df2 > 0:
                F_stat = ((SSE_lin - SSE_quad) / 1) / (SSE_quad / df2)
                F_crit = f_dist.ppf(0.95, 1, df2)
                if F_stat > F_crit:
                    break
        n_henry = m_try

    I_henry = np.arange(n_henry)
    q_h = q_for_henry[I_henry]
    KH = max(np.sum(w[I_henry] * Ce[I_henry] * q_h) /
             np.sum(w[I_henry] * Ce[I_henry]**2), 0)

    # ---- Step 4: Kaff ----
    Kaff = KH / max(Qmax, 1e-10)

    # ---- Convergence diagnostic ----
    KH_3 = np.sum(w[:3] * Ce[:3] * q_for_henry[:3]) / \
            np.sum(w[:3] * Ce[:3]**2)
    n_check = min(n_henry + 3, N // 2)
    I_check = np.arange(n_check)
    KH_ext = np.sum(w[I_check] * Ce[I_check] * q_for_henry[I_check]) / \
             np.sum(w[I_check] * Ce[I_check]**2)
    KH_sensitivity = abs(KH_ext - KH_3) / max(KH_3, 1e-10)

    if KH_sensitivity > 0.3:
        warnings.warn("K_H varies >30% with Henry region size. "
                       "First moment may diverge.")

    return {
        'Qmax': Qmax, 'KH': KH, 'Kaff': Kaff, 'Kp': Kp,
        'n_henry': n_henry, 'n_plateau': n_plateau,
        'use_partition': use_partition,
        'KH_sensitivity': KH_sensitivity,
    }


# ======================================================================
#  Bootstrap confidence intervals
# ======================================================================

def bootstrap_universal(Ce, q, sigma, B=2000):
    """
    Nonparametric bootstrap for confidence intervals.

    Returns
    -------
    dict with CI bounds for Qmax, KH, Kaff.
    """
    Ce = np.asarray(Ce, dtype=float).ravel()
    q = np.asarray(q, dtype=float).ravel()
    sigma = np.asarray(sigma, dtype=float).ravel()
    N = len(Ce)

    Qmax_boot = np.full(B, np.nan)
    Kaff_boot = np.full(B, np.nan)
    KH_boot = np.full(B, np.nan)

    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=RuntimeWarning)
        warnings.filterwarnings("ignore", message=".*singular.*")
        for b in range(B):
            idx = np.random.randint(0, N, size=N)
            try:
                res_b = universal_route_corrected(Ce[idx], q[idx], sigma[idx])
                Qmax_boot[b] = res_b['Qmax']
                Kaff_boot[b] = res_b['Kaff']
                KH_boot[b] = res_b['KH']
            except Exception:
                pass

    valid = np.isfinite(Qmax_boot) & np.isfinite(Kaff_boot)
    return {
        'Qmax_lo': np.nanpercentile(Qmax_boot[valid], 2.5),
        'Qmax_hi': np.nanpercentile(Qmax_boot[valid], 97.5),
        'Kaff_lo': np.nanpercentile(Kaff_boot[valid], 2.5),
        'Kaff_hi': np.nanpercentile(Kaff_boot[valid], 97.5),
        'KH_lo': np.nanpercentile(KH_boot[valid], 2.5),
        'KH_hi': np.nanpercentile(KH_boot[valid], 97.5),
        'n_valid': int(np.sum(valid)),
    }


# ======================================================================
#  Tikhonov-regularized NNLS with L-curve
# ======================================================================

def nnls_tikhonov_lcurve(Ce, q, sigma, Kp_fixed=0.0, M=50):
    """
    Nonparametric distribution recovery with L-curve regularization.

    Returns
    -------
    dict with keys: Qmax, KH, Kaff, Kj, qmj, lambda_opt
    """
    Ce = np.asarray(Ce, dtype=float).ravel()
    q = np.asarray(q, dtype=float).ravel()
    sigma = np.asarray(sigma, dtype=float).ravel()
    w = 1.0 / sigma**2
    N = len(Ce)

    Kmin = 0.1 / Ce.max()
    Kmax = 10.0 / Ce.min()
    Kj = np.logspace(np.log10(Kmin), np.log10(Kmax), M)

    # Kernel matrix
    A = np.zeros((N, M))
    for j in range(M):
        A[:, j] = Kj[j] * Ce / (1 + Kj[j] * Ce)

    q_sat = q - Kp_fixed * Ce
    W_half = np.diag(np.sqrt(w))
    A_w = W_half @ A
    q_w = W_half @ q_sat

    # Second-difference matrix
    L = np.zeros((M - 2, M))
    for i in range(M - 2):
        L[i, i] = 1
        L[i, i + 1] = -2
        L[i, i + 2] = 1

    # L-curve scan
    lambdas = np.logspace(-6, 2, 50)
    residual_norm = np.zeros(len(lambdas))
    solution_norm = np.zeros(len(lambdas))
    qmj_all = np.zeros((M, len(lambdas)))

    for il, lam in enumerate(lambdas):
        A_aug = np.vstack([A_w, np.sqrt(lam) * L])
        q_aug = np.concatenate([q_w, np.zeros(M - 2)])
        qmj_try, _ = nnls(A_aug, q_aug)
        qmj_all[:, il] = qmj_try
        residual_norm[il] = np.linalg.norm(A_w @ qmj_try - q_w)
        solution_norm[il] = np.linalg.norm(L @ qmj_try)

    # Find L-curve corner (maximum curvature)
    log_res = np.log10(residual_norm + 1e-16)
    log_sol = np.log10(solution_norm + 1e-16)

    kappa = np.zeros(len(lambdas))
    for i in range(1, len(lambdas) - 1):
        dx1 = log_res[i] - log_res[i - 1]
        dx2 = log_res[i + 1] - log_res[i]
        dy1 = log_sol[i] - log_sol[i - 1]
        dy2 = log_sol[i + 1] - log_sol[i]
        ddx = dx2 - dx1
        ddy = dy2 - dy1
        dx = (dx1 + dx2) / 2
        dy = (dy1 + dy2) / 2
        denom = (dx**2 + dy**2)**1.5
        if denom > 0:
            kappa[i] = abs(dx * ddy - dy * ddx) / denom

    idx_opt = np.argmax(kappa)
    lambda_opt = lambdas[idx_opt]
    qmj = qmj_all[:, idx_opt]

    Qmax = np.sum(qmj)
    KH = np.sum(Kj * qmj)
    Kaff = KH / max(Qmax, 1e-10)

    return {
        'Qmax': Qmax, 'KH': KH, 'Kaff': Kaff,
        'Kj': Kj, 'qmj': qmj, 'lambda_opt': lambda_opt,
    }


# ======================================================================
#  Main
# ======================================================================

def main():
    np.random.seed(42)
    noise_level = 0.05

    def add_noise(q_true):
        sig = np.maximum(noise_level * q_true, 1e-6)
        return np.maximum(q_true + sig * np.random.randn(len(q_true)), 0), sig

    # --- Model A: Langmuir ---
    Qmax_A, KL_A = 100.0, 0.5
    Ce_A = np.logspace(-2, 2, 30)
    q_true_A = Qmax_A * KL_A * Ce_A / (1 + KL_A * Ce_A)
    q_A, sigma_A = add_noise(q_true_A)

    # --- Model B: Sips ---
    Qmax_B, Ks_B, m_B = 80.0, 0.3, 0.7
    Ce_B = np.logspace(-2, 2, 30)
    q_true_B = Qmax_B * (Ks_B * Ce_B)**m_B / (1 + (Ks_B * Ce_B)**m_B)
    q_B, sigma_B = add_noise(q_true_B)

    # --- Model C: Partition + Langmuir ---
    Qmax_C, KL_C, Kp_C = 50.0, 1.0, 2.0
    Ce_C = np.logspace(-2, 2, 30)
    q_true_C = Kp_C * Ce_C + Qmax_C * KL_C * Ce_C / (1 + KL_C * Ce_C)
    q_C, sigma_C = add_noise(q_true_C)

    # --- Model D: Double Langmuir ---
    Qmax1_D, K1_D = 60.0, 5.0
    Qmax2_D, K2_D = 40.0, 0.05
    Ce_D = np.logspace(-2, 2, 30)
    q_true_D = (Qmax1_D * K1_D * Ce_D / (1 + K1_D * Ce_D) +
                Qmax2_D * K2_D * Ce_D / (1 + K2_D * Ce_D))
    Qmax_true_D = Qmax1_D + Qmax2_D
    KH_true_D = Qmax1_D * K1_D + Qmax2_D * K2_D
    Kaff_true_D = KH_true_D / Qmax_true_D
    q_D, sigma_D = add_noise(q_true_D)

    models = ["A: Langmuir", "B: Sips", "C: Part.+Lang.", "D: Double Lang."]
    Ce_all = [Ce_A, Ce_B, Ce_C, Ce_D]
    q_all = [q_A, q_B, q_C, q_D]
    sig_all = [sigma_A, sigma_B, sigma_C, sigma_D]
    q_true_all = [q_true_A, q_true_B, q_true_C, q_true_D]
    true_Qmax = [Qmax_A, Qmax_B, Qmax_C, Qmax_true_D]
    true_Kaff = [KL_A, None, KL_C, Kaff_true_D]

    print("=" * 60)
    print(" CORRECTED METHOD (Universal_route_v2.tex) -- Python")
    print("=" * 60)
    print()

    all_results = []
    all_CI = []

    for k in range(4):
        print(f"--- Model {models[k]} ---")
        res = universal_route_corrected(Ce_all[k], q_all[k], sig_all[k])
        all_results.append(res)

        print(f"  Qmax   = {res['Qmax']:.2f}   (true: {true_Qmax[k]:.2f})")
        print(f"  KH     = {res['KH']:.4f}")
        kaff_str = f"  Kaff   = {res['Kaff']:.4f}"
        if true_Kaff[k] is not None:
            kaff_str += f"   (true: {true_Kaff[k]:.4f})"
        print(kaff_str)
        print(f"  Kp     = {res['Kp']:.4f}")
        print(f"  Henry region: first {res['n_henry']} points")
        print(f"  Plateau region: last {res['n_plateau']} points")
        print(f"  KH sensitivity: {res['KH_sensitivity']:.3f}")

        # Bootstrap
        CI = bootstrap_universal(Ce_all[k], q_all[k], sig_all[k], B=1000)
        all_CI.append(CI)
        print(f"  Bootstrap 95% CI:")
        print(f"    Qmax: [{CI['Qmax_lo']:.2f}, {CI['Qmax_hi']:.2f}]")
        print(f"    Kaff: [{CI['Kaff_lo']:.4f}, {CI['Kaff_hi']:.4f}]")
        print()

    # --- NNLS with L-curve ---
    print("--- NNLS Distribution Recovery (L-curve regularization) ---")
    print()

    fig, axes = plt.subplots(1, 4, figsize=(16, 4))
    true_K_pos = [[KL_A], [], [KL_C], [K1_D, K2_D]]

    for k in range(4):
        nnls_res = nnls_tikhonov_lcurve(
            Ce_all[k], q_all[k], sig_all[k],
            Kp_fixed=all_results[k]['Kp'])
        print(f"Model {models[k]}:")
        print(f"  Qmax(NNLS) = {nnls_res['Qmax']:.2f}, "
              f"Kaff(NNLS) = {nnls_res['Kaff']:.4f}, "
              f"lambda = {nnls_res['lambda_opt']:.2e}")

        ax = axes[k]
        ax.bar(np.log10(nnls_res['Kj']), nnls_res['qmj'],
               width=0.08, color='steelblue', edgecolor='none')
        for Kpos in true_K_pos[k]:
            ax.axvline(np.log10(Kpos), color='r', ls='--', lw=1.5)
        ax.set_xlabel('$\\log_{10} K$', fontsize=11)
        ax.set_ylabel('$q_{m,j}$', fontsize=11)
        ax.set_title(models[k], fontsize=11)

    plt.tight_layout()
    plt.savefig('universal_route_corrected_nnls.png', dpi=150)
    plt.show()
    print()

    # --- Isotherm plots ---
    fig2, axes2 = plt.subplots(1, 4, figsize=(16, 4))
    for k in range(4):
        ax = axes2[k]
        Ce = Ce_all[k]
        res = all_results[k]
        Ce_fine = np.logspace(np.log10(Ce.min()), np.log10(Ce.max()), 200)
        if res['Kp'] > 0:
            q_recon = (res['Kp'] * Ce_fine +
                       res['Qmax'] * res['Kaff'] * Ce_fine /
                       (1 + res['Kaff'] * Ce_fine))
        else:
            q_recon = (res['Qmax'] * res['Kaff'] * Ce_fine /
                       (1 + res['Kaff'] * Ce_fine))

        ax.loglog(Ce, q_true_all[k], 'b-', lw=1.5, label='True')
        ax.loglog(Ce, q_all[k], 'ko', ms=4, label='Data')
        ax.loglog(Ce_fine, q_recon, 'r--', lw=1.2, label='Reconstructed')
        ax.axhline(res['Qmax'], color='g', ls=':', lw=1)
        ax.set_xlabel('$C_e$', fontsize=11)
        ax.set_ylabel('$q_e$', fontsize=11)
        ax.set_title(models[k], fontsize=11)
        ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('universal_route_corrected_isotherms.png', dpi=150)
    plt.show()

    # --- Sensitivity plot ---
    fig3, ax3 = plt.subplots(figsize=(7, 4.5))
    for k in [0, 3]:
        Ce = Ce_all[k]
        q_data = q_all[k]
        sig = sig_all[k]
        w = 1.0 / sig**2
        N = len(Ce)
        idx = np.argsort(Ce)
        Ce_s, q_s, w_s = Ce[idx], q_data[idx], w[idx]
        n_range = range(3, min(16, N // 2 + 1))
        Kaff_sens = []
        for n in n_range:
            I0 = np.arange(n)
            KH_tmp = np.sum(w_s[I0] * Ce_s[I0] * q_s[I0]) / \
                     np.sum(w_s[I0] * Ce_s[I0]**2)
            Kaff_sens.append(KH_tmp / all_results[k]['Qmax'])
        ax3.plot(list(n_range), Kaff_sens, '-o', ms=5, lw=1.5,
                 label=models[k])

    ax3.set_xlabel('Number of points in $\\mathcal{I}_0$', fontsize=12)
    ax3.set_ylabel('$\\hat{K}_{\\mathrm{aff}}$', fontsize=12)
    ax3.set_title('Sensitivity of $K_{\\mathrm{aff}}$ to Henry region size',
                  fontsize=13)
    ax3.legend(fontsize=10)
    plt.tight_layout()
    plt.savefig('universal_route_corrected_sensitivity.png', dpi=150)
    plt.show()

    print("Done. All figures saved.")


if __name__ == "__main__":
    main()

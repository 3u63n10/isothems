"""
universal_route_original.py
Implementation of the ORIGINAL method from Universal_route.tex
"A Universal Route to Q_max and K_aff for PFAS Adsorption in Solids"

This script implements the 4-step workflow as described in the original
manuscript, plus the optional NNLS distribution recovery.

Requirements: numpy, scipy, matplotlib
"""

import numpy as np
from scipy.optimize import nnls
import matplotlib.pyplot as plt


# ======================================================================
#  Core function: original workflow (Steps 0-4)
# ======================================================================

def universal_route_original(Ce, q, sigma):
    """
    Original manuscript workflow for extracting Qmax and Kaff.

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
    dict with keys: Qmax, KH, Kaff, Kp, n_henry, n_plateau
    """
    Ce = np.asarray(Ce, dtype=float).ravel()
    q = np.asarray(q, dtype=float).ravel()
    sigma = np.asarray(sigma, dtype=float).ravel()
    w = 1.0 / sigma**2
    N = len(Ce)

    # Sort by concentration
    idx = np.argsort(Ce)
    Ce, q, w, sigma = Ce[idx], q[idx], w[idx], sigma[idx]

    # --- Step 1: Decide partition ---
    m_high = min(5, N // 3)
    I_high = np.arange(N - m_high, N)
    X_h = np.column_stack([np.ones(m_high), Ce[I_high]])
    W_h = np.diag(w[I_high])
    beta_h = np.linalg.solve(X_h.T @ W_h @ X_h, X_h.T @ W_h @ q[I_high])
    resid_h = q[I_high] - X_h @ beta_h
    df = max(m_high - 2, 1)
    s2_h = np.sum(w[I_high] * resid_h**2) / df
    cov_h = s2_h * np.linalg.inv(X_h.T @ W_h @ X_h)
    se_slope = np.sqrt(max(cov_h[1, 1], 0))
    t_slope = beta_h[1] / se_slope if se_slope > 0 else 0
    use_partition = t_slope > 2.0 and beta_h[1] > 0

    # --- Step 2: Estimate Qmax ---
    if not use_partition:
        # Find plateau region
        n_plateau = 3
        for m_try in range(4, min(N - 2, N // 2) + 1):
            I_try = np.arange(N - m_try, N)
            X_t = np.column_stack([np.ones(m_try), np.log(Ce[I_try])])
            W_t = np.diag(w[I_try])
            beta_t = np.linalg.solve(X_t.T @ W_t @ X_t,
                                     X_t.T @ W_t @ q[I_try])
            resid_t = q[I_try] - X_t @ beta_t
            df_t = max(m_try - 2, 1)
            s2_t = np.sum(w[I_try] * resid_t**2) / df_t
            cov_t = s2_t * np.linalg.inv(X_t.T @ W_t @ X_t)
            se_lnC = np.sqrt(max(cov_t[1, 1], 0))
            t_lnC = abs(beta_t[1]) / se_lnC if se_lnC > 0 else 0
            if t_lnC > 2.0:
                break
            n_plateau = m_try

        I_plat = np.arange(N - n_plateau, N)
        if n_plateau >= 3:
            Qmax = np.sum(w[I_plat] * q[I_plat]) / np.sum(w[I_plat])
        else:
            # 1/C extrapolation
            n_ext = min(5, N // 2)
            I_ext = np.arange(N - n_ext, N)
            X_e = np.column_stack([np.ones(n_ext), 1.0 / Ce[I_ext]])
            W_e = np.diag(w[I_ext])
            beta_e = np.linalg.solve(X_e.T @ W_e @ X_e,
                                     X_e.T @ W_e @ q[I_ext])
            Qmax = beta_e[0]
        Kp = 0.0
    else:
        # Partition case: iterative
        n_ext = min(5, N // 2)
        I_ext = np.arange(N - n_ext, N)
        X_e = np.column_stack([np.ones(n_ext), 1.0 / Ce[I_ext]])
        W_e = np.diag(w[I_ext])
        beta_e = np.linalg.solve(X_e.T @ W_e @ X_e,
                                 X_e.T @ W_e @ q[I_ext])
        Qmax = max(beta_e[0], 0)
        Kp = 0.0
        n_plateau = n_ext

        for _iter in range(10):
            q_high = q[I_high] - Qmax
            Kp_new = max(np.sum(w[I_high] * Ce[I_high] * q_high) /
                         np.sum(w[I_high] * Ce[I_high]**2), 0)
            q_sat = q - Kp_new * Ce
            beta_e2 = np.linalg.solve(X_e.T @ W_e @ X_e,
                                      X_e.T @ W_e @ q_sat[I_ext])
            Qmax_new = max(beta_e2[0], 0)
            if abs(Kp_new - Kp) < 1e-4 * max(Kp, 1e-10):
                Kp = Kp_new
                Qmax = Qmax_new
                break
            Kp = Kp_new
            Qmax = Qmax_new

    # --- Step 3: Estimate KH ---
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
            beta_q = np.linalg.solve(X_q.T @ W_q @ X_q,
                                     X_q.T @ W_q @ q_h)
            resid_q = q_h - X_q @ beta_q
            SSE_quad = np.sum(w_h * resid_q**2)
            df2 = m_try - 2
            if SSE_quad > 0 and df2 > 0:
                F_stat = ((SSE_lin - SSE_quad) / 1) / (SSE_quad / df2)
                if F_stat > 4.0:
                    break
        n_henry = m_try

    I_henry = np.arange(n_henry)
    q_h = q_for_henry[I_henry]
    KH = max(np.sum(w[I_henry] * Ce[I_henry] * q_h) /
             np.sum(w[I_henry] * Ce[I_henry]**2), 0)

    # --- Step 4: Kaff ---
    Kaff = KH / max(Qmax, 1e-10)

    return {
        'Qmax': Qmax, 'KH': KH, 'Kaff': Kaff, 'Kp': Kp,
        'n_henry': n_henry, 'n_plateau': n_plateau
    }


# ======================================================================
#  NNLS distribution recovery (Section 5 of manuscript)
# ======================================================================

def nnls_distribution(Ce, q, sigma, Kp_fixed=0.0, M=50):
    """
    Nonparametric distribution recovery via NNLS.

    Parameters
    ----------
    Ce, q, sigma : array_like
    Kp_fixed : float
        Fixed partition coefficient.
    M : int
        Number of grid points.

    Returns
    -------
    dict with keys: Qmax, KH, Kaff, Kj, qmj
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

    qmj, _ = nnls(A_w, q_w)

    Qmax = np.sum(qmj)
    KH = np.sum(Kj * qmj)
    Kaff = KH / max(Qmax, 1e-10)

    return {'Qmax': Qmax, 'KH': KH, 'Kaff': Kaff, 'Kj': Kj, 'qmj': qmj}


# ======================================================================
#  Main: Synthetic data + demonstration
# ======================================================================

def main():
    np.random.seed(42)
    noise_level = 0.05

    # --- Model A: Single Langmuir ---
    Qmax_A, KL_A = 100.0, 0.5
    Ce_A = np.logspace(-2, 2, 30)
    q_true_A = Qmax_A * KL_A * Ce_A / (1 + KL_A * Ce_A)
    sigma_A = np.maximum(noise_level * q_true_A, 1e-6)
    q_A = np.maximum(q_true_A + sigma_A * np.random.randn(30), 0)

    # --- Model B: Sips ---
    Qmax_B, Ks_B, m_B = 80.0, 0.3, 0.7
    Ce_B = np.logspace(-2, 2, 30)
    q_true_B = Qmax_B * (Ks_B * Ce_B)**m_B / (1 + (Ks_B * Ce_B)**m_B)
    sigma_B = np.maximum(noise_level * q_true_B, 1e-6)
    q_B = np.maximum(q_true_B + sigma_B * np.random.randn(30), 0)

    # --- Model C: Partition + Langmuir ---
    Qmax_C, KL_C, Kp_C = 50.0, 1.0, 2.0
    Ce_C = np.logspace(-2, 2, 30)
    q_true_C = Kp_C * Ce_C + Qmax_C * KL_C * Ce_C / (1 + KL_C * Ce_C)
    sigma_C = np.maximum(noise_level * q_true_C, 1e-6)
    q_C = np.maximum(q_true_C + sigma_C * np.random.randn(30), 0)

    print("=" * 60)
    print(" ORIGINAL METHOD (Universal_route.tex) -- Python")
    print("=" * 60)
    print()

    datasets = [
        ("A: Langmuir", Ce_A, q_A, sigma_A, Qmax_A, KL_A),
        ("B: Sips", Ce_B, q_B, sigma_B, Qmax_B, None),
        ("C: Partition+Langmuir", Ce_C, q_C, sigma_C, Qmax_C, KL_C),
    ]

    results = []
    for name, Ce, q_data, sig, Qmax_true, Kaff_true in datasets:
        res = universal_route_original(Ce, q_data, sig)
        results.append(res)
        print(f"--- Model {name} ---")
        print(f"  Qmax = {res['Qmax']:.2f}  (true: {Qmax_true:.2f})")
        print(f"  KH   = {res['KH']:.4f}")
        print(f"  Kaff = {res['Kaff']:.4f}", end="")
        if Kaff_true is not None:
            print(f"  (true: {Kaff_true:.4f})")
        else:
            print()
        print(f"  Kp   = {res['Kp']:.4f}")
        print()

    # --- NNLS ---
    print("--- NNLS Distribution Recovery (Model A) ---")
    nnls_res = nnls_distribution(Ce_A, q_A, sigma_A)
    print(f"  Qmax(NNLS) = {nnls_res['Qmax']:.2f}")
    print(f"  Kaff(NNLS) = {nnls_res['Kaff']:.4f}")
    print()

    # --- Plots ---
    fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))

    for i, (name, Ce, q_data, sig, Qmax_true, Kaff_true) in enumerate(datasets):
        ax = axes[i]
        q_true_plot = [q_true_A, q_true_B, q_true_C][i]
        ax.loglog(Ce, q_true_plot, 'b-', lw=1.5, label='True')
        ax.loglog(Ce, q_data, 'ko', ms=4, label='Data')
        ax.axhline(results[i]['Qmax'], color='r', ls='--', lw=1.2,
                   label=f'$\\hat{{Q}}_{{\\max}}={results[i]["Qmax"]:.1f}$')
        ax.set_xlabel('$C_e$', fontsize=12)
        ax.set_ylabel('$q_e$', fontsize=12)
        ax.set_title(f'Model {name}', fontsize=12)
        ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('universal_route_original_results.png', dpi=150)
    plt.show()

    # NNLS distribution plot
    fig2, ax2 = plt.subplots(figsize=(7, 4.5))
    ax2.bar(np.log10(nnls_res['Kj']), nnls_res['qmj'], width=0.08,
            color='steelblue', edgecolor='none', label='Recovered $\\rho(K)$')
    ax2.axvline(np.log10(KL_A), color='r', ls='--', lw=1.5,
                label=f'True $K_L={KL_A}$')
    ax2.set_xlabel('$\\log_{10} K$', fontsize=12)
    ax2.set_ylabel('$q_{m,j}$', fontsize=12)
    ax2.set_title('NNLS Distribution Recovery (Model A)', fontsize=12)
    ax2.legend(fontsize=10)
    plt.tight_layout()
    plt.savefig('universal_route_original_nnls.png', dpi=150)
    plt.show()

    print("Done. Figures saved.")


if __name__ == "__main__":
    main()

"""
utils_isotherms.py — Shared utilities for the Isotherm Guidelines project.

Provides:
  - 13 isotherm model functions
  - 8 error metrics (SSE, R², R²adj, EABS, RESID, ARED, MPSED, HYBRID)
  - Information criteria (AIC, AICc, BIC, Akaike weights)
  - Universal descriptor extraction (Qmax, K*aff, Eads, sigma_H)
  - Energy distribution functions f(E) for each model
  - OVL (overlap coefficient) for distribution comparison
  - F-test for nested models
"""

import numpy as np
from scipy.optimize import curve_fit
from scipy.special import gamma as gamma_fn
from scipy.stats import norm, f as f_dist

# =====================================================================
#  ISOTHERM MODELS
# =====================================================================

def langmuir(Ce, Qmax, KL):
    """Langmuir: q = Qmax·KL·Ce / (1 + KL·Ce)"""
    return Qmax * KL * Ce / (1 + KL * Ce)

def double_langmuir(Ce, Q1, K1, Q2, K2):
    """Double Langmuir: sum of two Langmuir terms."""
    return Q1 * K1 * Ce / (1 + K1 * Ce) + Q2 * K2 * Ce / (1 + K2 * Ce)

def freundlich(Ce, KF, n_inv):
    """Freundlich: q = KF · Ce^(1/n)"""
    return KF * Ce**n_inv

def sips(Ce, Qmax, KS, m):
    """Sips (Langmuir–Freundlich): q = Qmax·(KS·Ce)^m / (1 + (KS·Ce)^m)"""
    x = (KS * Ce)**m
    return Qmax * x / (1 + x)

def toth(Ce, Qmax, b, t):
    """Tóth: q = Qmax·b·Ce / (1 + (b·Ce)^t)^(1/t)"""
    return Qmax * b * Ce / (1 + (b * Ce)**t)**(1.0 / t)

def jovanovic(Ce, Qmax, b):
    """Jovanovic: q = Qmax·(1 - exp(-b·Ce))"""
    return Qmax * (1 - np.exp(-b * Ce))

def temkin(Ce, aT, bT):
    """Temkin: q = (RT/bT)·ln(aT·Ce)"""
    RT = 2.478  # kJ/mol at 298 K
    return (RT / bT) * np.log(aT * Ce)

def unilan(Ce, Qmax, bmax, bmin):
    """UNILAN: q = Qmax/(2s)·ln((1 + bmax·Ce)/(1 + bmin·Ce)), s = 0.5·ln(bmax/bmin)"""
    s = 0.5 * np.log(bmax / bmin)
    return Qmax / (2 * s) * np.log((1 + bmax * Ce) / (1 + bmin * Ce))

def redlich_peterson(Ce, KRP, aRP, beta):
    """Redlich–Peterson: q = KRP·Ce / (1 + aRP·Ce^beta)"""
    return KRP * Ce / (1 + aRP * Ce**beta)

def koble_corrigan(Ce, A, B, n_inv):
    """Koble–Corrigan: q = A·Ce^(1/n) / (1 + B·Ce^(1/n))"""
    x = Ce**n_inv
    return A * x / (1 + B * x)

def radke_prausnitz(Ce, a, r, p):
    """Radke–Prausnitz: q = a·r·Ce / (a + r·Ce^(1-p))"""
    return a * r * Ce / (a + r * Ce**(1 - p))

def dubinin_ra(Ce, Qmax, Ea, nDA):
    """Dubinin–Astakhov (includes D-R when nDA=2): q = Qmax·exp(-(eps/Ea)^nDA)"""
    eps = 2.478 * np.log(1 + 1.0 / Ce)  # RT·ln(1 + 1/Ce) at 298 K
    return Qmax * np.exp(-(eps / Ea)**nDA)

def hill(Ce, Qmax, KD, nH):
    """Hill: q = Qmax·Ce^nH / (KD + Ce^nH)"""
    return Qmax * Ce**nH / (KD + Ce**nH)

# Dictionary of all models: name → (function, param_names, n_params)
MODELS = {
    'Langmuir':           (langmuir,          ['Qmax', 'KL'], 2),
    'Double Langmuir':    (double_langmuir,   ['Q1', 'K1', 'Q2', 'K2'], 4),
    'Freundlich':         (freundlich,         ['KF', '1/n'], 2),
    'Sips':               (sips,               ['Qmax', 'KS', 'm'], 3),
    'Toth':               (toth,               ['Qmax', 'b', 't'], 3),
    'Jovanovic':          (jovanovic,          ['Qmax', 'b'], 2),
    'Temkin':             (temkin,             ['aT', 'bT'], 2),
    'UNILAN':             (unilan,             ['Qmax', 'bmax', 'bmin'], 3),
    'Redlich-Peterson':   (redlich_peterson,   ['KRP', 'aRP', 'beta'], 3),
    'Koble-Corrigan':     (koble_corrigan,     ['A', 'B', '1/n'], 3),
    'Radke-Prausnitz':    (radke_prausnitz,    ['a', 'r', 'p'], 3),
    'D-R/D-A':            (dubinin_ra,         ['Qmax', 'Ea', 'nDA'], 3),
    'Hill':               (hill,               ['Qmax', 'KD', 'nH'], 3),
}


# =====================================================================
#  ERROR METRICS
# =====================================================================

def compute_SSE(q_exp, q_pred):
    return np.sum((q_exp - q_pred)**2)

def compute_R2(q_exp, q_pred):
    SSE = compute_SSE(q_exp, q_pred)
    SST = np.sum((q_exp - np.mean(q_exp))**2)
    return 1 - SSE / SST

def compute_R2adj(q_exp, q_pred, p):
    n = len(q_exp)
    R2 = compute_R2(q_exp, q_pred)
    return 1 - (n - 1) / (n - p - 1) * (1 - R2)

def compute_EABS(q_exp, q_pred):
    return np.sum(np.abs(q_exp - q_pred))

def compute_RESID(q_exp, q_pred):
    return np.mean(np.abs(q_exp - q_pred))

def compute_ARED(q_exp, q_pred):
    return 100.0 / len(q_exp) * np.sum(np.abs((q_exp - q_pred) / q_exp))

def compute_MPSED(q_exp, q_pred):
    return 100.0 * np.median(((q_exp - q_pred) / q_exp)**2)

def compute_HYBRID(q_exp, q_pred, p):
    n = len(q_exp)
    return 100.0 / (n - p) * np.sum((q_exp - q_pred)**2 / q_exp)

def all_error_metrics(q_exp, q_pred, p):
    """Compute all 8 error metrics. Returns a dict."""
    return {
        'SSE':    compute_SSE(q_exp, q_pred),
        'R2':     compute_R2(q_exp, q_pred),
        'R2adj':  compute_R2adj(q_exp, q_pred, p),
        'EABS':   compute_EABS(q_exp, q_pred),
        'RESID':  compute_RESID(q_exp, q_pred),
        'ARED':   compute_ARED(q_exp, q_pred),
        'MPSED':  compute_MPSED(q_exp, q_pred),
        'HYBRID': compute_HYBRID(q_exp, q_pred, p),
    }


# =====================================================================
#  INFORMATION CRITERIA
# =====================================================================

def compute_AIC(n, SSE, p):
    return n * np.log(SSE / n) + 2 * p

def compute_AICc(n, SSE, p):
    aic = compute_AIC(n, SSE, p)
    return aic + 2 * p * (p + 1) / (n - p - 1)

def compute_BIC(n, SSE, p):
    return n * np.log(SSE / n) + p * np.log(n)

def akaike_weights(AICc_values):
    """Compute Akaike weights from a list/array of AICc values."""
    delta = np.array(AICc_values) - np.min(AICc_values)
    rel_lik = np.exp(-delta / 2)
    return rel_lik / np.sum(rel_lik)


# =====================================================================
#  F-TEST FOR NESTED MODELS
# =====================================================================

def f_test(SSE1, p1, SSE2, p2, n, alpha=0.05):
    """
    F-test for nested models.
    Model 1: simpler (fewer params, higher SSE)
    Model 2: more complex (more params, lower SSE)
    Returns (F_stat, F_crit, p_value, significant).
    """
    df1 = p2 - p1
    df2 = n - p2
    F_stat = ((SSE1 - SSE2) / df1) / (SSE2 / df2)
    p_value = 1 - f_dist.cdf(F_stat, df1, df2)
    F_crit = f_dist.ppf(1 - alpha, df1, df2)
    return F_stat, F_crit, p_value, F_stat > F_crit


# =====================================================================
#  UNIVERSAL DESCRIPTOR EXTRACTION
# =====================================================================

def extract_descriptors(model_name, params, C0=1.0, T=298.0):
    """
    Extract {Qmax, K*aff, Eads, sigma_H} from fitted parameters.

    Parameters
    ----------
    model_name : str
    params : dict  (parameter name → value)
    C0 : float     standard-state concentration
    T : float      temperature in K

    Returns
    -------
    dict with keys 'Qmax', 'Kaff_star', 'Eads', 'sigma_E'
    """
    RT = 8.314e-3 * T  # kJ/mol
    sigma_T = np.pi * RT / np.sqrt(3)

    def thermal_corrected_width(apparent_width):
        """Remove the Langmuir thermal kernel from logistic-family widths."""
        if not np.isfinite(apparent_width):
            return apparent_width
        return np.sqrt(max(apparent_width**2 - sigma_T**2, 0.0))

    if model_name == 'Langmuir':
        Qmax = params['Qmax']
        KL = params['KL']
        Kaff = KL * C0
        sigma_E = 0.0
        sigma_H = 0.0

    elif model_name == 'Double Langmuir':
        Q1, Q2 = params['Q1'], params['Q2']
        K1, K2 = params['K1'], params['K2']
        Qmax = Q1 + Q2
        if Qmax > 0:
            # Effective total Langmuir constant from the global Henry slope.
            Ktot = (Q1 * K1 + Q2 * K2) / Qmax
            Kaff = Ktot * C0
            delta_E12 = RT * np.abs(np.log(K1 / K2))
            sigma_E = np.sqrt(Q1 * Q2) / Qmax * delta_E12
            sigma_H = sigma_E
        else:
            Kaff = np.nan
            sigma_E = np.nan
            sigma_H = np.nan

    elif model_name == 'Sips':
        Qmax = params['Qmax']
        KS = params['KS']
        m = params['m']
        Kaff = KS**(1.0 / m) * C0
        sigma_E = sigma_T / m
        sigma_H = thermal_corrected_width(sigma_E)

    elif model_name == 'Toth':
        Qmax = params['Qmax']
        b = params['b']
        Kaff = b * C0
        # No closed form; approximate numerically
        t = params['t']
        sigma_E = sigma_T / t  # rough apparent-width approximation
        sigma_H = np.nan  # no closed-form thermal correction

    elif model_name == 'Jovanovic':
        Qmax = params['Qmax']
        b = params['b']
        Kaff = b * C0
        sigma_E = np.pi * RT / np.sqrt(6)
        sigma_H = sigma_E

    elif model_name == 'Temkin':
        aT = params['aT']
        Kaff = aT * C0
        Qmax = np.nan  # Temkin has no intrinsic Qmax
        # sigma_E requires a declared effective Qmax or finite validity window.
        sigma_E = np.nan
        sigma_H = np.nan

    elif model_name == 'UNILAN':
        Qmax = params['Qmax']
        bmax = params['bmax']
        bmin = params['bmin']
        Kaff = np.sqrt(bmax * bmin) * C0
        sigma_E = RT / (2 * np.sqrt(3)) * np.log(bmax / bmin)
        sigma_H = sigma_E

    elif model_name == 'Hill':
        Qmax = params['Qmax']
        KD = params['KD']
        nH = params['nH']
        Kaff = KD**(-1.0 / nH) * C0
        sigma_E = sigma_T / nH
        sigma_H = thermal_corrected_width(sigma_E)

    elif model_name == 'Freundlich':
        Qmax = np.nan
        Kaff = np.nan
        sigma_E = np.inf  # unbounded distribution
        sigma_H = np.inf

    elif model_name == 'Redlich-Peterson':
        KRP = params['KRP']
        aRP = params['aRP']
        beta = params['beta']
        if np.isclose(beta, 1.0):
            Qmax = KRP / aRP
            Kaff = aRP * C0
        else:
            Qmax = np.nan
            Kaff = np.nan
        sigma_E = np.nan  # no closed-form distribution
        sigma_H = np.nan

    elif model_name == 'Koble-Corrigan':
        A = params['A']
        B = params['B']
        n_inv = params['1/n']
        Qmax = A / B
        if n_inv > 0:
            n = 1.0 / n_inv
            Kaff = B**n * C0
            sigma_E = sigma_T * n
            sigma_H = thermal_corrected_width(sigma_E)
        else:
            Kaff = np.nan
            sigma_E = np.nan

    elif model_name == 'Radke-Prausnitz':
        r = params['r']
        Qmax = np.nan  # no explicit saturation
        Kaff = r * C0  # effective low-concentration affinity
        sigma_E = np.nan  # non-standard distribution
        sigma_H = np.nan

    elif model_name == 'D-R/D-A':
        Qmax = params['Qmax']
        Ea = params['Ea']
        nDA = params['nDA']
        # C_1/2 from Ea: eps = Ea·(ln2)^(1/nDA) ≈ RT·ln(1+1/C_1/2)
        eps_half = Ea * np.log(2)**(1.0 / nDA)
        C_half = 1.0 / (np.exp(eps_half / RT) - 1)
        Kaff = C0 / C_half
        sigma_E = Ea * np.sqrt(
            gamma_fn(1 + 2.0 / nDA) - gamma_fn(1 + 1.0 / nDA)**2
        )
        sigma_H = sigma_E
    else:
        raise ValueError(f"Unknown model: {model_name}")

    if np.isfinite(Kaff) and Kaff > 0:
        Eads = RT * np.log(Kaff)
    else:
        Eads = np.nan

    return {
        'Qmax': Qmax,
        'Kaff_star': Kaff,
        'Eads': Eads,
        'sigma_E': sigma_E,
        'sigma_H': sigma_H,
        'sigma_T': sigma_T,
    }


# =====================================================================
#  ENERGY DISTRIBUTION FUNCTIONS f(E)
# =====================================================================

def fE_langmuir(E, Ec, Qmax):
    """Dirac delta at Ec (returns Qmax at E≈Ec, 0 elsewhere)."""
    # Approximate delta as narrow Gaussian for plotting
    sigma = 0.01  # very narrow
    return Qmax / (np.sqrt(2 * np.pi) * sigma) * np.exp(-0.5 * ((E - Ec) / sigma)**2)

def fE_sips(E, Ec, m, Qmax, T=298.0):
    """Sips: logistic density."""
    RT = 8.314e-3 * T
    scale = RT / m
    u = (E - Ec) / scale
    eu = np.exp(u)
    return Qmax / scale * eu / (1 + eu)**2

def fE_toth(E, Ec, t, Qmax, T=298.0):
    """Tóth: generalised logistic (type IV)."""
    RT = 8.314e-3 * T
    u = (E - Ec) / RT
    return Qmax / RT * np.exp(-u) / (1 + np.exp(-t * u))**((1 + t) / t)

def fE_jovanovic(E, Ec, Qmax, T=298.0):
    """Jovanovic: Gumbel (EV-I)."""
    RT = 8.314e-3 * T
    u = (E - Ec) / RT
    return Qmax / RT * np.exp(-u) * np.exp(-np.exp(-u))

def fE_temkin(E, Emin, Emax, Qmax):
    """Temkin: uniform on [Emin, Emax]."""
    out = np.zeros_like(E)
    mask = (E >= Emin) & (E <= Emax)
    out[mask] = Qmax / (Emax - Emin)
    return out

def fE_freundlich(E, n, K0, T=298.0):
    """Freundlich: power-law (unbounded)."""
    RT = 8.314e-3 * T
    return n / np.pi * np.sin(np.pi * n) * K0**n * np.exp(n * E / RT)

def fE_DA(eps, Qmax, Ea, nDA):
    """Dubinin–Astakhov: Weibull in Polanyi potential."""
    x = eps / Ea
    return Qmax * nDA / Ea * x**(nDA - 1) * np.exp(-x**nDA)

def fE_hill(E, Ec, nH, Qmax, T=298.0):
    """Hill: identical to Sips with scale 1/nH."""
    RT = 8.314e-3 * T
    u = (E - Ec) / (RT / nH)
    eu = np.exp(u)
    return Qmax * nH / RT * eu / (1 + eu)**2


# =====================================================================
#  OVERLAP COEFFICIENT (OVL)
# =====================================================================

def compute_OVL_numerical(E, fA, fB):
    """Numerical OVL from two distributions on a common E grid."""
    integrand = np.minimum(fA, fB)
    return np.trapz(integrand, E)

def compute_OVL_gaussian(Ec_A, sigma_A, Ec_B, sigma_B):
    """Gaussian approximation of OVL."""
    sigma_bar = np.sqrt(0.5 * (sigma_A**2 + sigma_B**2))
    return 2 * norm.cdf(-np.abs(Ec_A - Ec_B) / (2 * sigma_bar))


# =====================================================================
#  SYNTHETIC DATA GENERATION
# =====================================================================

def generate_synthetic_data(model_func, params, Ce_range=(0.1, 100),
                            n_points=20, noise_level=0.03, seed=42):
    """
    Generate synthetic q_e–C_e data from a model with Gaussian noise.

    Parameters
    ----------
    model_func : callable
    params : tuple of parameter values
    Ce_range : (min, max)
    n_points : int
    noise_level : float (fraction of q_e)
    seed : int

    Returns
    -------
    Ce, q_exp, q_true
    """
    rng = np.random.default_rng(seed)
    Ce = np.logspace(np.log10(Ce_range[0]), np.log10(Ce_range[1]), n_points)
    q_true = model_func(Ce, *params)
    noise = rng.normal(0, noise_level * q_true)
    q_exp = q_true + noise
    q_exp = np.maximum(q_exp, 0)  # ensure non-negative
    return Ce, q_exp, q_true


# Edit script for main.tex -- expand Section 4
filepath = "C:/Users/Eugenio/Dropbox/000My_Drafts/050-Isotherm_guidelines/main.tex"

with open(filepath, 'rb') as f:
    content = f.read()

lines = content.split(b'\n')
# Verify boundaries
print("Line 525:", repr(lines[524][:60]))
print("Line 597:", repr(lines[596][:60]))

T = b'\t'
R = b'\r'

def L(*args):
    """Build a line: join args as bytes, append \\r"""
    parts = []
    for a in args:
        if isinstance(a, str):
            a = a.encode('utf-8')
        parts.append(a)
    return b''.join(parts) + R

EM = '\xe2\x80\x94'.encode('utf-8')   # em dash

new_sec4 = [
    L(T, b'% ================================================================='),
    L(T, b'%  SECTION 4 ', EM, b' HETEROGENEITY: THE ENERGY DISTRIBUTION'),
    L(T, b'% ================================================================='),
    L(T, b'\\section{Quantifying surface heterogeneity: energy distributions}'),
    L(T, b'\\label{sec:heterogeneity}'),
    R,
    L(T, b'% --- 4.1  The condensation approximation ---'),
    L(T, b'\\subsection{From isotherms to energy distributions}'),
    L(T, b'\\label{sec:condensation}'),
    R,
    L(T, b'Real adsorbent surfaces are energetically heterogeneous: individual binding '
         b'sites differ in local chemistry, accessible geometry, and coordination '
         b'environment, producing a continuous distribution of adsorption energies rather '
         b'than a single value. A heterogeneous surface is modelled as an ensemble of '
         b'independent Langmuir-type patches, each characterised by its adsorption '
         b'energy~$E$. The macroscopic isotherm is the integral of the single-site '
         b'occupancy over the site-energy distribution $f(E)$:'),
    L(T, b'\\begin{equation}'),
    L(T,T, b'q_e = Q_{\\max} \\int_{0}^{\\infty}'),
    L(T,T, b'\\frac{K(E)\\, C_e}{1 + K(E)\\, C_e}\\; f(E)\\, \\mathrm{d}E,'),
    L(T,T, b'\\label{eq:heterogeneous_integral}'),
    L(T, b'\\end{equation}'),
    L(T, b'where $K(E) = K_0 \\exp(E/RT)$ is the local Langmuir affinity at energy~$E$ '
         b'and $f(E)$ is normalised to unity. Each choice of $f(E)$ generates a different '
         b'macroscopic isotherm; conversely, each isotherm model implies a specific '
         b'functional form for $f(E)$.'),
    R,
    L(T, b'The \\emph{condensation approximation} provides a practical route from any '
         b'empirical isotherm equation back to the underlying distribution. The Langmuir '
         b'kernel is replaced by a unit step at the \\emph{condensation energy}~$E_c$:'),
    L(T, b'\\begin{equation}'),
    L(T,T, b'\\frac{K(E)\\,C_e}{1+K(E)\\,C_e} \\;\\approx\\; \\Theta(E - E_c),'),
    L(T,T, b'\\qquad'),
    L(T,T, b'E_c = RT\\ln\\!\\left(\\frac{1}{K_0 C_e}\\right).'),
    L(T,T, b'\\label{eq:condensation_step}'),
    L(T, b'\\end{equation}'),
    L(T, b'Substituting $C_e = C^{\\ast}\\exp(-E/RT)$ and differentiating yields'),
    L(T, b'\\begin{equation}'),
    L(T,T, b'f(E) \\;=\\; -\\frac{1}{Q_{\\max}}\\frac{\\mathrm{d}q}{\\mathrm{d}E},'),
    L(T,T, b'\\label{eq:fE_general}'),
    L(T, b'\\end{equation}'),
    L(T, b'where $q$ is expressed as a function of $E$ via the substitution above. '
         b'Full derivations for all isotherm models are collected in '
         b'Section~\\ref{SI-sec:si_individual_distributions}.'),
    R,
    L(T, b'% --- 4.2  Energy-distribution families ---'),
    L(T, b'\\subsection{Energy-distribution families and $\\sigma_E$}'),
    L(T, b'\\label{sec:energy_families}'),
    R,
    L(T, b'Applying Eq.~\\eqref{eq:fE_general} to each isotherm yields the '
         b'energy-distribution families summarised in Table~\\ref{tab:energy_distributions}.'),
    R,
    L(T, b'\\begin{table}[H]'),
    L(T,T, b'\\small'),
    L(T,T, b'\\caption{Energy-distribution families and heterogeneity width $\\sigma_E$ '
            b'implied by each isotherm model. Parameter $m$ (Sips, Koble--Corrigan) is '
            b"the heterogeneity exponent; $t$ (T\\'{o}th) and $n_H$ (Hill) are the "
            b'respective shape parameters. $\\sigma_E$ is in units of '
            b'$RT$ ($RT\\approx 2.48$~kJ\\,mol$^{-1}$ at $298$~K). '
            b'Full derivations: Section~\\ref{SI-sec:si_individual_distributions}.}'),
    L(T,T, b'\\label{tab:energy_distributions}'),
    L(T,T, b'\\renewcommand{\\arraystretch}{1.4}'),
    L(T,T, b'\\begin{tabular}{@{} l l c l @{}}'),
    L(T,T,T, b'\\hline'),
    L(T,T,T, b'\\textbf{Model}'),
    L(T,T,T, b'& \\textbf{Distribution $f(E)$}'),
    L(T,T,T, b'& \\textbf{Symm.}'),
    L(T,T,T, b'& $\\boldsymbol{\\sigma_E/(RT)}$ \\\\'),
    L(T,T,T, b'\\hline'),
    L(T,T,T, b'Langmuir'),
    L(T,T,T, b'& Dirac $\\delta(E-E_c)$'),
    L(T,T,T, b'& ---'),
    L(T,T,T, b'& $0$ \\\\'),
    L(T,T,T, b'Double Langmuir'),
    L(T,T,T, b'& Two Dirac $\\delta$'),
    L(T,T,T, b'& ---'),
    L(T,T,T, b'& $\\tfrac{\\sqrt{Q_1 Q_2}}{Q_1+Q_2}\\tfrac{|\\Delta E_{12}|}{RT}$ \\\\'),
    L(T,T,T, b'Sips'),
    L(T,T,T, b'& Logistic (scale $RT/m$)'),
    L(T,T,T, b'& Yes'),
    L(T,T,T, b'& $\\pi/(m\\sqrt{3})$ \\\\'),
    L(T,T,T, b"T\\'{o}th"),
    L(T,T,T, b'& Gen.\\ logistic type IV'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& $>\\pi/\\sqrt{3}$\\;$(t<1)$; no closed form \\\\'),
    L(T,T,T, b'Jovanovic'),
    L(T,T,T, b'& Gumbel (EV-I)'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& $\\pi/\\sqrt{6}\\approx 1.28$ \\\\'),
    L(T,T,T, b'Temkin'),
    L(T,T,T, b'& Uniform'),
    L(T,T,T, b'& Yes'),
    L(T,T,T, b'& $b_T Q_{\\max}/(2\\sqrt{3}\\,RT)$ \\\\'),
    L(T,T,T, b'UNILAN'),
    L(T,T,T, b'& Uniform (exact kernel)'),
    L(T,T,T, b'& Yes'),
    L(T,T,T, b'& $\\ln(b_{\\max}/b_{\\min})/(2\\sqrt{3})$ \\\\'),
    L(T,T,T, b'Freundlich'),
    L(T,T,T, b'& Power law (unbounded)'),
    L(T,T,T, b'& ---'),
    L(T,T,T, b'& $\\infty$ \\\\'),
    L(T,T,T, b'Redlich--Peterson'),
    L(T,T,T, b'& Non-standard ($\\beta < 1$)'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& --- \\\\'),
    L(T,T,T, b'Koble--Corrigan'),
    L(T,T,T, b'& $\\equiv$ Sips'),
    L(T,T,T, b'& Yes'),
    L(T,T,T, b'& $\\pi/(m\\sqrt{3})$ \\\\'),
    L(T,T,T, b'Radke--Prausnitz'),
    L(T,T,T, b'& Non-standard'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& --- \\\\'),
    L(T,T,T, b'D-R ($n_{DA}=2$)'),
    L(T,T,T, b'& Rayleigh'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& $0.463\\,E_a/(RT)$ \\\\'),
    L(T,T,T, b'D-A (general)'),
    L(T,T,T, b'& Weibull (shape $n_{DA}$)'),
    L(T,T,T, b'& No'),
    L(T,T,T, b'& $(E_a/RT)\\sqrt{\\Gamma(1+2/n_{DA})-[\\Gamma(1+1/n_{DA})]^2}$ \\\\'),
    L(T,T,T, b'Hill'),
    L(T,T,T, b'& $\\equiv$ Sips (scale $RT/n_H$)'),
    L(T,T,T, b'& Yes'),
    L(T,T,T, b'& $\\pi/(n_H\\sqrt{3})$ \\\\'),
    L(T,T,T, b'\\hline'),
    L(T,T, b'\\end{tabular}'),
    L(T, b'\\end{table}'),
    R,
    L(T, b'Several physical patterns emerge from Table~\\ref{tab:energy_distributions}:'),
    L(T, b'\\begin{itemize}'),
    L(T,T, b'\\item \\textbf{Homogeneous limit.} The Langmuir model corresponds to a '
            b'single energy level ($\\sigma_E = 0$). Double Langmuir adds a second '
            b'discrete level; $\\sigma_E$ measures the energy separation weighted '
            b'by the site capacities $Q_1, Q_2$.'),
    R,
    L(T,T, b'\\item \\textbf{Symmetric logistic family.} Sips, Koble--Corrigan, and Hill '
            b'all imply a symmetric logistic distribution. The width '
            b'$\\sigma_E = \\pi RT/(m\\sqrt{3})$ increases as $m \\to 0$ (or $n_H \\to 0$), '
            b'recovering Freundlich-like behaviour in the limit.'),
    R,
    L(T,T, b"\\item \\textbf{Asymmetric distributions.} T\\'{o}th generates a distribution "
            b'skewed toward \\emph{low}-energy (weak-binding) sites, consistent with its '
            b'pronounced low-coverage tail. Jovanovic generates a Gumbel distribution '
            b'skewed toward \\emph{high}-energy sites, with a fixed intrinsic width '
            b'independent of the affinity parameter~$b$.'),
    R,
    L(T,T, b'\\item \\textbf{Uniform distributions.} Temkin and UNILAN both assume a flat '
            b'rectangular energy distribution. UNILAN retains the exact Langmuir integral; '
            b'Temkin uses the condensation approximation. Their $\\sigma_E$ is set entirely '
            b'by the half-width of the uniform energy band.'),
    R,
    L(T,T, b'\\item \\textbf{Divergent and non-analytical cases.} Freundlich has '
            b'$\\sigma_E = \\infty$, directly reflecting the absence of~$Q_{\\max}$. '
            b'Redlich--Peterson and Radke--Prausnitz yield empirical distributions '
            b'without closed-form variances.'),
    R,
    L(T,T, b'\\item \\textbf{Dubinin models.} D-R and D-A operate in the Polanyi '
            b'adsorption potential $\\varepsilon = RT\\ln(1+1/C_e)$. The distribution '
            b'in $\\varepsilon$ is Weibull; the D-R case ($n_{DA} = 2$) gives the '
            b'Rayleigh distribution with $\\sigma_\\varepsilon \\approx 0.463\\,E_a$.'),
    L(T, b'\\end{itemize}'),
    R,
    L(T, b'% --- 4.3  Physical interpretation of sigma_E ---'),
    L(T, b'\\subsection{Physical interpretation of $\\sigma_E$}'),
    L(T, b'\\label{sec:sigma_E}'),
    R,
    L(T, b'The standard deviation $\\sigma_E$ of the site-energy distribution is the third '
         b'universal descriptor. It is derived analytically from the same isotherm '
         b'parameters as $E_{\\mathrm{ads}}$, imposing no additional fitting burden. '
         b'A small $\\sigma_E \\ll RT$ indicates a nearly homogeneous surface; '
         b'$\\sigma_E \\sim RT$ corresponds to moderate heterogeneity; and '
         b'$\\sigma_E \\gg RT$ signals broad energetic diversity typical of activated '
         b'carbons, biochars, or disordered porous solids. At $T = 298$~K, the intrinsic '
         b'logistic width (Sips, $m = 1$) is $(\\pi/\\sqrt{3})\\,RT \\approx 4.5$~kJ\\,mol$^{-1}$; '
         b'surfaces below this threshold are practically indistinguishable from Langmuir '
         b'behaviour. Numerical $\\sigma_E$ values for representative parameter choices are '
         b'tabulated in Table~\\ref{SI-tab:si_sigma_numerical}.'),
    R,
    L(T, b'% --- 4.4  Universal descriptors ---'),
    L(T, b'\\subsection{A universal descriptor set for adsorption}'),
    L(T, b'\\label{sec:descriptors}'),
    L(T, b''),
    L(T, b'We propose that, for any adsorbent--adsorbate system, a minimal set of three '
         b'descriptors can enable consistent cross-study comparison:'),
    L(T, b'\\begin{equation}'),
    L(T,T, b'\\boxed{'),
    L(T,T,T, b'Q_{\\max}, \\qquad'),
    L(T,T,T, b'E_{\\mathrm{ads}} = RT\\ln K_{\\mathrm{aff}}^{\\ast}, \\qquad'),
    L(T,T,T, b'\\sigma_E.'),
    L(T,T, b'}'),
    L(T,T, b'\\label{eq:universal_descriptors}'),
    L(T, b'\\end{equation}'),
    L(T, b'Within this framework, $Q_{\\max}$ captures the total capacity, '
         b'$E_{\\mathrm{ads}}$ expresses the affinity on a common thermodynamic scale, '
         b'and $\\sigma_E$ quantifies the degree of surface heterogeneity. Taken together, '
         b'these quantities provide a model-agnostic descriptor set for comparing '
         b'adsorption performance across materials and contaminants.'),
    L(T, b''),
]

result = lines[:524] + new_sec4 + lines[597:]
with open(filepath, 'wb') as f:
    f.write(b'\n'.join(result))

print(f"main.tex written. Section 4 lines: {len(new_sec4)}. Total: {len(result)}")

%% plot_energy_distributions.m
%  Compute and plot the site-energy distribution f(E) for all isotherm
%  models covered in the guidelines document.
%
%  All distributions are plotted in reduced (dimensionless) energy
%  u = (E - Ec) / (RT), so that the thermal energy scale is unity.
%
%  Outputs:
%    fig_energy_distributions.pdf   -- comparative overlay of all f(E)
%    fig_energy_distributions_panel.pdf -- individual panels
%    energy_distributions_data.dat  -- numerical data for LaTeX pgfplots
%    energy_distributions_params.tex -- parameter table in LaTeX format
%
%  Reference: document_2026-02-12d.tex
%
%  E. [author], 2026-02-16

clear; close all; clc;

%% ========================================================================
%  Physical parameters
%  ========================================================================
R   = 8.314e-3;   % kJ/(mol K)
T   = 298;        % K
RT  = R * T;       % ~ 2.478 kJ/mol

%% ========================================================================
%  Common energy axis (reduced units u = (E - Ec)/RT)
%  ========================================================================
u = linspace(-8, 8, 1001)';   % column vector
Nu = length(u);

%% ========================================================================
%  1. LANGMUIR: Dirac delta -> approximate as very narrow Gaussian
%  ========================================================================
sigma_lang = 0.15;            % narrow Gaussian approximation
f_lang = (1/(sigma_lang*sqrt(2*pi))) * exp(-0.5*(u/sigma_lang).^2);
% Normalise to unit area
f_lang = f_lang / trapz(u, f_lang);

%% ========================================================================
%  2. SIPS (Logistic distribution)
%     f(u) = exp(u/n) / [n * (1 + exp(u/n))^2]
%     For n = 1 (Langmuir limit): scale = 1
%     Typical heterogeneous: n = 2, 3
%  ========================================================================
n_sips_values = [1.0, 1.5, 2.0, 3.0];
f_sips = zeros(Nu, length(n_sips_values));
sigma_sips = zeros(1, length(n_sips_values));

for k = 1:length(n_sips_values)
    n = n_sips_values(k);
    % In reduced units u = (E-Ec)/RT, scale parameter b = n (since b = nRT, b/RT = n)
    v = u / n;
    f_sips(:,k) = (1/n) * exp(v) ./ (1 + exp(v)).^2;
    sigma_sips(k) = pi * n / sqrt(3);   % sigma_E / RT
end

%% ========================================================================
%  3. TOTH (Generalised logistic, type IV)
%     f(u) = exp(-u) / [1 + exp(-t*u)]^((1+t)/t)
%     t = 1: Sips/Langmuir; t < 1: asymmetric
%  ========================================================================
t_toth_values = [1.0, 0.7, 0.5, 0.3];
f_toth = zeros(Nu, length(t_toth_values));

for k = 1:length(t_toth_values)
    t = t_toth_values(k);
    f_toth(:,k) = exp(-u) ./ (1 + exp(-t*u)).^((1+t)/t);
    % Normalise numerically
    area = trapz(u, f_toth(:,k));
    f_toth(:,k) = f_toth(:,k) / area;
end

%% ========================================================================
%  4. JOVANOVIC (Gumbel / Type I extreme-value)
%     f(u) = exp(-u) * exp(-exp(-u))
%  ========================================================================
f_jov = exp(-u) .* exp(-exp(-u));
f_jov = f_jov / trapz(u, f_jov);
sigma_jov = pi / sqrt(6);   % sigma_E / RT ~ 1.283

%% ========================================================================
%  5. TEMKIN / UNILAN (Uniform / rectangular)
%     f(u) = 1/(2*s_u) for |u| <= s_u, 0 otherwise
%     s_u = s / RT = half-width in reduced units
%  ========================================================================
s_u_values = [2, 3, 4];   % half-widths in RT units
f_temkin = zeros(Nu, length(s_u_values));
sigma_temkin = zeros(1, length(s_u_values));

for k = 1:length(s_u_values)
    s = s_u_values(k);
    mask = (u >= -s) & (u <= s);
    f_temkin(mask, k) = 1 / (2*s);
    sigma_temkin(k) = s / sqrt(3);
end

%% ========================================================================
%  6. FREUNDLICH (Power-law, truncated for visualisation)
%     f(u) = (n/pi) * sin(pi*n) * exp(n*u)   (in reduced units)
%     n < 1: more heterogeneous
%  ========================================================================
n_freund_values = [0.3, 0.5, 0.7, 0.9];
f_freund = zeros(Nu, length(n_freund_values));

for k = 1:length(n_freund_values)
    n = n_freund_values(k);
    f_freund(:,k) = (n/pi) * sin(pi*n) * exp(n * u);
end

%% ========================================================================
%  7. DUBININ-RADUSHKEVICH / DUBININ-ASTAKHOV (Weibull in epsilon)
%     f(eps) = (n/Ea) * (eps/Ea)^(n-1) * exp(-(eps/Ea)^n)
%     Use eps >= 0 axis; Ea_red = Ea/RT
%  ========================================================================
eps = linspace(0, 8, 1001)';   % Polanyi potential in RT units
Ea_red = 2.5;                  % Ea/RT
n_DA_values = [1.5, 2.0, 3.0, 4.0];   % n_DA = 2 is D-R
f_DA = zeros(length(eps), length(n_DA_values));
sigma_DA = zeros(1, length(n_DA_values));

for k = 1:length(n_DA_values)
    nDA = n_DA_values(k);
    x = eps / Ea_red;
    f_DA(:,k) = (nDA / Ea_red) * x.^(nDA-1) .* exp(-x.^nDA);
    % Normalise
    f_DA(:,k) = f_DA(:,k) / trapz(eps, f_DA(:,k));
    sigma_DA(k) = Ea_red * sqrt(gamma(1 + 2/nDA) - gamma(1 + 1/nDA)^2);
end

%% ========================================================================
%  8. HILL (identical to Sips, but with nH > 1 for cooperativity)
%     sigma_E / RT = pi / (sqrt(3) * nH)
%  ========================================================================
nH_values = [0.5, 1.0, 2.0, 4.0];
f_hill = zeros(Nu, length(nH_values));
sigma_hill = zeros(1, length(nH_values));

for k = 1:length(nH_values)
    nH = nH_values(k);
    bH = 1 / nH;   % scale = RT/nH, in reduced units = 1/nH
    v = u / bH;
    f_hill(:,k) = (1/bH) * exp(v) ./ (1 + exp(v)).^2;
    sigma_hill(k) = pi / (sqrt(3) * nH);
end

%% ========================================================================
%  9. REDLICH-PETERSON (non-standard family)
%     f(u) ~ exp(-u) * [1 + (1-beta)*exp(-beta*u)] / [1 + exp(-beta*u)]^2
%  ========================================================================
beta_RP_values = [1.0, 0.8, 0.6, 0.4];
f_RP = zeros(Nu, length(beta_RP_values));

for k = 1:length(beta_RP_values)
    beta = beta_RP_values(k);
    num = exp(-u) .* (1 + (1 - beta) * exp(-beta * u));
    den = (1 + exp(-beta * u)).^2;
    f_RP(:,k) = num ./ den;
    area = trapz(u, f_RP(:,k));
    if area > 0
        f_RP(:,k) = f_RP(:,k) / area;
    end
end

%% ========================================================================
%  FIGURE 1: Comparative overlay of representative distributions
%  ========================================================================
fig1 = figure('Name','Energy distributions -- overview','Color','w',...
    'Position',[100 100 800 500]);
hold on; box on;

% Select one representative per family
lw = 2.0;
co = lines(8);

% Langmuir (delta approx)
plot(u, f_lang, '-', 'LineWidth', lw, 'Color', co(1,:), ...
    'DisplayName', 'Langmuir ($\delta$-function)');

% Sips n=2
plot(u, f_sips(:,3), '-', 'LineWidth', lw, 'Color', co(2,:), ...
    'DisplayName', 'Sips ($n=2$, logistic)');

% Toth t=0.5
plot(u, f_toth(:,3), '-', 'LineWidth', lw, 'Color', co(3,:), ...
    'DisplayName', 'T\''oth ($t=0.5$, gen.\ logistic)');

% Jovanovic
plot(u, f_jov, '-', 'LineWidth', lw, 'Color', co(4,:), ...
    'DisplayName', 'Jovanovic (Gumbel)');

% Temkin s=3
plot(u, f_temkin(:,2), '-', 'LineWidth', lw, 'Color', co(5,:), ...
    'DisplayName', 'Temkin/Unilan ($s=3RT$, uniform)');

% Freundlich n=0.5 (truncated)
f_fr_plot = f_freund(:,2);
f_fr_plot(f_fr_plot > 1.5) = NaN;   % truncate for display
plot(u, f_fr_plot, '--', 'LineWidth', lw, 'Color', co(6,:), ...
    'DisplayName', 'Freundlich ($1/n=0.5$, power law)');

% Redlich-Peterson beta=0.6
plot(u, f_RP(:,3), '-.', 'LineWidth', lw, 'Color', co(7,:), ...
    'DisplayName', 'Redlich--Peterson ($\beta=0.6$)');

xlabel('$u = (E - E_c)\,/\,(RT)$', 'Interpreter','latex', 'FontSize',14);
ylabel('$\phi(u) = f(E)\,/\,Q_{\max}$ (normalised)', ...
    'Interpreter','latex', 'FontSize',14);
title('Normalised site-energy distributions for adsorption isotherms', ...
    'Interpreter','latex', 'FontSize',15);
legend('Interpreter','latex','Location','northwest','FontSize',10);
set(gca,'FontSize',12,'TickLabelInterpreter','latex');
ylim([0, 1.2]);
xlim([-8, 8]);
hold off;

% Save figure
exportgraphics(fig1, 'fig_energy_distributions.pdf', 'ContentType','vector');
fprintf('Saved fig_energy_distributions.pdf\n');

%% ========================================================================
%  FIGURE 2: Panel plot -- individual families with parameter variations
%  ========================================================================
fig2 = figure('Name','Energy distributions -- panels','Color','w',...
    'Position',[100 100 1200 900]);

% --- Panel (a): Sips ---
subplot(3,3,1); hold on; box on;
co_sub = lines(4);
for k = 1:length(n_sips_values)
    plot(u, f_sips(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$n = %.1f$', n_sips_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(a) Sips (logistic)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.5]); xlim([-8,8]);

% --- Panel (b): Toth ---
subplot(3,3,2); hold on; box on;
for k = 1:length(t_toth_values)
    plot(u, f_toth(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$t = %.1f$', t_toth_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(b) T\''oth (gen.\ logistic)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.5]); xlim([-8,8]);

% --- Panel (c): Jovanovic ---
subplot(3,3,3); hold on; box on;
plot(u, f_jov, 'LineWidth', 2, 'Color', co(4,:), ...
    'DisplayName', 'Gumbel');
% overlay Sips n=1 for comparison
plot(u, f_sips(:,1), '--', 'LineWidth', 1.5, 'Color', co(2,:), ...
    'DisplayName', 'Sips $n=1$ (Langmuir)');
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(c) Jovanovic (Gumbel)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.5]); xlim([-8,8]);

% --- Panel (d): Temkin / Unilan ---
subplot(3,3,4); hold on; box on;
for k = 1:length(s_u_values)
    plot(u, f_temkin(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$s = %d\\,RT$', s_u_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(d) Temkin/Unilan (uniform)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.35]); xlim([-8,8]);

% --- Panel (e): Freundlich ---
subplot(3,3,5); hold on; box on;
for k = 1:length(n_freund_values)
    f_tmp = f_freund(:,k);
    f_tmp(f_tmp > 2) = NaN;
    plot(u, f_tmp, 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$1/n = %.1f$', n_freund_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$f(u)$','Interpreter','latex','FontSize',11);
title('(e) Freundlich (power law)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northwest','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 2.0]); xlim([-8,8]);

% --- Panel (f): D-R / D-A (Weibull) ---
subplot(3,3,6); hold on; box on;
for k = 1:length(n_DA_values)
    plot(eps, f_DA(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$n_{DA} = %.1f$', n_DA_values(k)));
end
xlabel('$\varepsilon\,/\,(RT)$','Interpreter','latex','FontSize',11);
ylabel('$f(\varepsilon)$','Interpreter','latex','FontSize',11);
title('(f) D-R/D-A (Weibull)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.8]); xlim([0,8]);

% --- Panel (g): Hill ---
subplot(3,3,7); hold on; box on;
for k = 1:length(nH_values)
    plot(u, f_hill(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$n_H = %.1f$', nH_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(g) Hill ($\equiv$ Sips)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 1.0]); xlim([-8,8]);

% --- Panel (h): Redlich-Peterson ---
subplot(3,3,8); hold on; box on;
for k = 1:length(beta_RP_values)
    plot(u, f_RP(:,k), 'LineWidth', 1.8, 'Color', co_sub(k,:), ...
        'DisplayName', sprintf('$\\beta = %.1f$', beta_RP_values(k)));
end
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(h) Redlich--Peterson','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 0.5]); xlim([-8,8]);

% --- Panel (i): Langmuir (delta) ---
subplot(3,3,9); hold on; box on;
plot(u, f_lang, 'LineWidth', 2, 'Color', co(1,:), ...
    'DisplayName', '$\delta(E-E_c)$');
xlabel('$u$','Interpreter','latex','FontSize',11);
ylabel('$\phi(u)$','Interpreter','latex','FontSize',11);
title('(i) Langmuir ($\delta$-function)','Interpreter','latex','FontSize',12);
legend('Interpreter','latex','Location','northeast','FontSize',8);
set(gca,'FontSize',10,'TickLabelInterpreter','latex');
ylim([0, 3]); xlim([-3,3]);

% Save panel figure
exportgraphics(fig2, 'fig_energy_distributions_panel.pdf', 'ContentType','vector');
fprintf('Saved fig_energy_distributions_panel.pdf\n');

%% ========================================================================
%  FIGURE 3: sigma_E / RT as a function of heterogeneity parameter
%  ========================================================================
fig3 = figure('Name','sigma_E vs heterogeneity','Color','w',...
    'Position',[100 100 700 450]);
hold on; box on;

% Sips: sigma/RT = pi*n/sqrt(3)
n_ax = linspace(0.5, 5, 100);
sigma_sips_curve = pi * n_ax / sqrt(3);
plot(n_ax, sigma_sips_curve, '-', 'LineWidth', 2, 'Color', co(2,:), ...
    'DisplayName', 'Sips: $\sigma_E/RT = \pi n/\sqrt{3}$');

% Hill: sigma/RT = pi/(sqrt(3)*nH)
nH_ax = linspace(0.2, 5, 100);
sigma_hill_curve = pi ./ (sqrt(3) * nH_ax);
plot(nH_ax, sigma_hill_curve, '--', 'LineWidth', 2, 'Color', co(7,:), ...
    'DisplayName', 'Hill: $\sigma_E/RT = \pi/(\sqrt{3}\,n_H)$');

% Jovanovic: constant
yline(pi/sqrt(6), '-.', 'LineWidth', 1.5, 'Color', co(4,:), ...
    'DisplayName', sprintf('Jovanovic: $\\sigma_E/RT = \\pi/\\sqrt{6} \\approx %.2f$', pi/sqrt(6)));

% Langmuir: sigma = 0
yline(0, ':', 'LineWidth', 1.5, 'Color', co(1,:), ...
    'DisplayName', 'Langmuir: $\sigma_E = 0$');

% Thermal reference line
yline(1, '-', 'LineWidth', 1, 'Color', [0.5 0.5 0.5], ...
    'DisplayName', '$\sigma_E = RT$ (thermal scale)', ...
    'Alpha', 0.5);

xlabel('Heterogeneity parameter ($n$ for Sips, $n_H$ for Hill)', ...
    'Interpreter','latex', 'FontSize',13);
ylabel('$\sigma_E\,/\,(RT)$', 'Interpreter','latex', 'FontSize',13);
title('Energy distribution width vs.\ heterogeneity parameter', ...
    'Interpreter','latex', 'FontSize',14);
legend('Interpreter','latex','Location','north','FontSize',10);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
ylim([0, 10]);
hold off;

exportgraphics(fig3, 'fig_sigma_vs_heterogeneity.pdf', 'ContentType','vector');
fprintf('Saved fig_sigma_vs_heterogeneity.pdf\n');

%% ========================================================================
%  Export numerical data for LaTeX pgfplots inclusion
%  ========================================================================

% --- Overview data: representative distributions ---
fid = fopen('energy_distributions_data.dat', 'w');
fprintf(fid, '%% u = (E-Ec)/RT, phi_Langmuir, phi_Sips_n2, phi_Toth_t05, ');
fprintf(fid, 'phi_Jovanovic, phi_Temkin_s3, phi_Freundlich_n05, phi_RP_beta06\n');
fprintf(fid, '%% Generated by plot_energy_distributions.m on %s\n', datestr(now));

f_fr_export = f_freund(:,2);
f_fr_export(f_fr_export > 2) = 2;   % cap for clean data

data_overview = [u, f_lang, f_sips(:,3), f_toth(:,3), f_jov, ...
    f_temkin(:,2), f_fr_export, f_RP(:,3)];

for i = 1:Nu
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n', ...
        data_overview(i,:));
end
fclose(fid);
fprintf('Saved energy_distributions_data.dat\n');

% --- Sips family data ---
fid = fopen('energy_distributions_sips.dat', 'w');
fprintf(fid, '%% u, phi_n1.0, phi_n1.5, phi_n2.0, phi_n3.0\n');
for i = 1:Nu
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\t%.6f\n', u(i), f_sips(i,:));
end
fclose(fid);

% --- Toth family data ---
fid = fopen('energy_distributions_toth.dat', 'w');
fprintf(fid, '%% u, phi_t1.0, phi_t0.7, phi_t0.5, phi_t0.3\n');
for i = 1:Nu
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\t%.6f\n', u(i), f_toth(i,:));
end
fclose(fid);

% --- D-R/D-A family data ---
fid = fopen('energy_distributions_DA.dat', 'w');
fprintf(fid, '%% eps/RT, phi_nDA1.5, phi_nDA2.0, phi_nDA3.0, phi_nDA4.0\n');
for i = 1:length(eps)
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\t%.6f\n', eps(i), f_DA(i,:));
end
fclose(fid);

% --- Hill family data ---
fid = fopen('energy_distributions_hill.dat', 'w');
fprintf(fid, '%% u, phi_nH0.5, phi_nH1.0, phi_nH2.0, phi_nH4.0\n');
for i = 1:Nu
    fprintf(fid, '%.4f\t%.6f\t%.6f\t%.6f\t%.6f\n', u(i), f_hill(i,:));
end
fclose(fid);

% --- sigma_E data ---
fid = fopen('energy_distributions_sigma.dat', 'w');
fprintf(fid, '%% n_or_nH, sigma_Sips_over_RT, sigma_Hill_over_RT\n');
nn = linspace(0.2, 5, 50);
for i = 1:length(nn)
    fprintf(fid, '%.4f\t%.6f\t%.6f\n', nn(i), pi*nn(i)/sqrt(3), pi/(sqrt(3)*nn(i)));
end
fclose(fid);
fprintf('Saved all .dat files\n');

%% ========================================================================
%  Export parameter summary table as LaTeX
%  ========================================================================
fid = fopen('energy_distributions_params.tex', 'w');
fprintf(fid, '%% Auto-generated by plot_energy_distributions.m on %s\n', datestr(now));
fprintf(fid, '%% Energy distribution parameters for T = %d K, RT = %.3f kJ/mol\n\n', T, RT);
fprintf(fid, '\\begin{table}[htbp]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\small\n');
fprintf(fid, '\\caption{Energy-distribution families implied by each isotherm model.\n');
fprintf(fid, '  All distributions are expressed in the reduced energy\n');
fprintf(fid, '  $u = (E - E_c)/(RT)$.  The standard deviation $\\sigma_E$ is given\n');
fprintf(fid, '  in units of $RT$ (= %.3f~kJ/mol at $T = %d$~K).}\n', RT, T);
fprintf(fid, '\\label{tab:energy_dist_families}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{1.5}\n');
fprintf(fid, '\\begin{tabular}{llccc}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\textbf{Model} & \\textbf{Distribution family} & \\textbf{Symmetry}');
fprintf(fid, ' & $\\boldsymbol{\\sigma_E/(RT)}$ & \\textbf{Parameters from fit} \\\\\n');
fprintf(fid, '\\hline\n');

% Data rows
rows = {
    'Langmuir',           'Dirac $\\delta$',                  'N/A',       '$0$',                                        '$K_L$'
    'Double Langmuir',    'Two Dirac $\\delta$',              'N/A',       '$\\Delta E_{12}/RT$',                        '$K_1, K_2, Q_1, Q_2$'
    'Sips (L--F)',        'Logistic',                         'Symmetric', '$\\pi n/\\sqrt{3}$',                         '$K_S, n, Q_{\\max}$'
    'T\\''oth',           'Gen.\\ logistic (type IV)',        'Asymmetric','$> \\pi/\\sqrt{3}$ for $t<1$',               '$b, t, q_{\\max}$'
    'Jovanovic',          'Gumbel (extreme-value I)',         'Asymmetric','$\\pi/\\sqrt{6} \\approx 1.28$',             '$b, q_{\\max}$'
    'Temkin',             'Uniform (rectangular)',            'Symmetric', '$b_T Q_{\\max}/(2\\sqrt{3}\\,RT)$',           '$a_T, b_T$'
    'UNILAN',             'Uniform (rectangular)',            'Symmetric', '$\\ln(b_{\\max}/b_{\\min})/(2\\sqrt{3})$',    '$b_{\\max}, b_{\\min}, q_{\\max}$'
    'Freundlich',         'Power law (unbounded)',            'N/A',       '$\\infty$',                                   '$K_F, 1/n$'
    'Redlich--Peterson',  'Non-standard',                     'Asymmetric','---',                                         '$K_{RP}, a_{RP}, \\beta$'
    'Koble--Corrigan',    '$\\equiv$ Sips (logistic)',        'Symmetric', '$\\pi n/\\sqrt{3}$',                         '$A_{KC}, B_{KC}, 1/n$'
    'Radke--Prausnitz',   'Non-standard',                     'Asymmetric','---',                                         '$a_{RP}, r_{RP}, p$'
    'D-R',                'Rayleigh (Weibull, $n_{DA}\\!=\\!2$)','Asymmetric','$0.463\\,E_a/RT$',                        '$Q_{\\max}, E_a$'
    'D-A',                'Weibull',                          'Asymmetric','$E_a\\sqrt{\\Gamma(1+2/n)-\\Gamma(1+1/n)^2}/RT$','$Q_{\\max}, E_a, n_{DA}$'
    'Hill',               '$\\equiv$ Sips (logistic)',        'Symmetric', '$\\pi/(\\sqrt{3}\\,n_H)$',                   '$Q_{\\max}, K_D, n_H$'
};

for r = 1:size(rows,1)
    fprintf(fid, '%s & %s & %s & %s & %s \\\\\n', rows{r,:});
end

fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
fprintf('Saved energy_distributions_params.tex\n');

%% ========================================================================
%  Export numerical sigma_E values at T = 298 K
%  ========================================================================
fid = fopen('energy_distributions_sigma_values.tex', 'w');
fprintf(fid, '%% Numerical sigma_E values at T = %d K (RT = %.3f kJ/mol)\n\n', T, RT);
fprintf(fid, '\\begin{table}[htbp]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\small\n');
fprintf(fid, '\\caption{Numerical values of the energy-distribution width $\\sigma_E$\n');
fprintf(fid, '  at $T = %d$~K ($RT = %.3f$~kJ\\,mol$^{-1}$) for representative\n', T, RT);
fprintf(fid, '  parameter values.}\n');
fprintf(fid, '\\label{tab:sigma_numerical}\n');
fprintf(fid, '\\renewcommand{\\arraystretch}{1.3}\n');
fprintf(fid, '\\begin{tabular}{llcc}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\textbf{Model} & \\textbf{Parameter} & $\\boldsymbol{\\sigma_E/(RT)}$');
fprintf(fid, ' & $\\boldsymbol{\\sigma_E}$ (kJ/mol) \\\\\n');
fprintf(fid, '\\hline\n');

% Sips examples
for k = 1:length(n_sips_values)
    n = n_sips_values(k);
    s = pi*n/sqrt(3);
    fprintf(fid, 'Sips & $n = %.1f$ & %.2f & %.2f \\\\\n', n, s, s*RT);
end

% Toth: numerical from integration
for k = 2:length(t_toth_values)   % skip t=1 (same as Sips n=1)
    t = t_toth_values(k);
    % compute sigma numerically
    m1 = trapz(u, u .* f_toth(:,k));
    m2 = trapz(u, u.^2 .* f_toth(:,k));
    s = sqrt(m2 - m1^2);
    fprintf(fid, 'T\\''oth & $t = %.1f$ & %.2f & %.2f \\\\\n', t, s, s*RT);
end

% Jovanovic
fprintf(fid, 'Jovanovic & --- & %.2f & %.2f \\\\\n', sigma_jov, sigma_jov*RT);

% Temkin
for k = 1:length(s_u_values)
    s = s_u_values(k);
    sig = s / sqrt(3);
    fprintf(fid, 'Temkin/Unilan & $s = %d\\,RT$ & %.2f & %.2f \\\\\n', s, sig, sig*RT);
end

% Hill
for k = 1:length(nH_values)
    nH = nH_values(k);
    s = pi/(sqrt(3)*nH);
    fprintf(fid, 'Hill & $n_H = %.1f$ & %.2f & %.2f \\\\\n', nH, s, s*RT);
end

% D-R
Ea_example = 10;   % kJ/mol typical
s_DR = 0.4633 * Ea_example / RT;
fprintf(fid, 'D-R & $E_a = %d$ kJ/mol & %.2f & %.2f \\\\\n', Ea_example, s_DR, s_DR*RT);

fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
fprintf('Saved energy_distributions_sigma_values.tex\n');

%% Done
fprintf('\n=== All figures and data files generated ===\n');
fprintf('Files created:\n');
fprintf('  fig_energy_distributions.pdf\n');
fprintf('  fig_energy_distributions_panel.pdf\n');
fprintf('  fig_sigma_vs_heterogeneity.pdf\n');
fprintf('  energy_distributions_data.dat\n');
fprintf('  energy_distributions_sips.dat\n');
fprintf('  energy_distributions_toth.dat\n');
fprintf('  energy_distributions_DA.dat\n');
fprintf('  energy_distributions_hill.dat\n');
fprintf('  energy_distributions_sigma.dat\n');
fprintf('  energy_distributions_params.tex\n');
fprintf('  energy_distributions_sigma_values.tex\n');

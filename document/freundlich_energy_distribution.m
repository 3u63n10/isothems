%% freundlich_energy_distribution.m
%  Energy distribution of adsorption sites for the Freundlich isotherm
%
%  The Freundlich isotherm q_e = K_F * C^(1/n) arises from the
%  heterogeneous integral
%
%      q_e = Q_max * int_0^inf  [K(E)*C / (1 + K(E)*C)] * f(E) dE
%
%  when the site-energy distribution is the power law
%
%      f(E) = (n/pi) * sin(pi*n) * K0^n * exp(n*E/(RT))
%
%  with K(E) = K0 * exp(E/(RT))  the local Langmuir constant.
%
%  This script uses the reduced (dimensionless) energy  eps = E/(RT).
%
%  Reference: document_2026-02-10.tex, Sec. 2.5

clear; close all; clc;

%% Parameters
R     = 8.314e-3;          % kJ/(mol K)
T     = 298;               % K
RT    = R * T;             % kJ/mol  (~2.48)
K0    = 1;                 % pre-exponential factor (1/concentration units)
Qmax  = 100;              % mg/g  (arbitrary, for illustration)

n_values = [0.3, 0.5, 0.7, 0.9];   % Freundlich exponent 1/n: smaller n = more heterogeneous

colors = lines(length(n_values));

%% ======================================================================
%  Figure 1 : Site-energy distribution f(eps) for different n
%  ======================================================================
eps = linspace(-5, 10, 500);       % reduced energy E/(RT)

figure('Name','Energy distribution f(E)','Color','w',...
    'Position',[100 100 560 420]);
hold on; box on;

for k = 1:length(n_values)
    n = n_values(k);
    % f(eps) = (n/pi)*sin(pi*n) * exp(n*eps)   [per unit eps]
    f_eps = (n/pi) * sin(pi*n) * K0^n .* exp(n * eps);
    plot(eps, f_eps, 'LineWidth', 1.8, 'Color', colors(k,:), ...
        'DisplayName', sprintf('$1/n = %.1f$', n));
end

xlabel('$\varepsilon = E\,/\,(RT)$', 'Interpreter','latex', 'FontSize',13);
ylabel('$f(\varepsilon)$', 'Interpreter','latex', 'FontSize',13);
title('Site-energy distribution (Freundlich)', 'Interpreter','latex', 'FontSize',14);
legend('Interpreter','latex','Location','northwest','FontSize',11);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
ylim([0, 3]);
hold off;

%% ======================================================================
%  Figure 2 : Integrand  theta(eps,C) * f(eps)  for several C values
%  ======================================================================
n_fix = 0.5;                          % fix n for this figure
C_values = [0.01, 0.1, 1, 10, 100];  % equilibrium concentrations

figure('Name','Integrand: local coverage x f(E)','Color','w',...
    'Position',[200 100 560 420]);
hold on; box on;

cmap = parula(length(C_values));

for j = 1:length(C_values)
    Ce = C_values(j);
    K_eps  = K0 * exp(eps);                   % K(eps)
    theta  = K_eps * Ce ./ (1 + K_eps * Ce);  % local Langmuir coverage
    f_eps  = (n_fix/pi) * sin(pi*n_fix) * K0^n_fix .* exp(n_fix * eps);
    integrand = theta .* f_eps;

    plot(eps, integrand, 'LineWidth', 1.8, 'Color', cmap(j,:), ...
        'DisplayName', sprintf('$C_e = %g$', Ce));
end

xlabel('$\varepsilon = E\,/\,(RT)$', 'Interpreter','latex','FontSize',13);
ylabel('$\theta(\varepsilon,C_e)\,\cdot\,f(\varepsilon)$', ...
    'Interpreter','latex','FontSize',13);
title(sprintf('Integrand for $1/n = %.1f$', n_fix), ...
    'Interpreter','latex','FontSize',14);
legend('Interpreter','latex','Location','northwest','FontSize',11);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
hold off;

%% ======================================================================
%  Figure 3 : Numerical reconstruction of the Freundlich isotherm
%             q_e(C) = Q_max * int theta(E,C) f(E) dE
%             compared with the analytical  q_e = K_F * C^(1/n)
%  ======================================================================
Ce_vec = logspace(-3, 2, 200);      % concentration range
eps_int = linspace(-15, 25, 2000);  % wide energy range for integration

figure('Name','Isotherm reconstruction','Color','w',...
    'Position',[300 100 560 420]);
hold on; box on;

for k = 1:length(n_values)
    n = n_values(k);

    % --- Analytical Freundlich ---
    % From the derivation:  K_F = Q_max * K0^(1/n) * (pi/sin(pi/n))
    %                             ... but using 1/n = n here
    % More precisely, with our normalisation the prefactor that absorbs
    % everything is:  K_F = Q_max * (n/pi)*sin(pi*n) * (pi/sin(pi*n)) * K0^n
    %               = Q_max * n * K0^n   ... but this depends on the full
    % derivation.  We compute K_F from the numerical integral at C=1.
    % Instead, let's just compare shapes.

    % --- Numerical integration ---
    q_num = zeros(size(Ce_vec));
    f_eps = (n/pi) * sin(pi*n) * K0^n .* exp(n * eps_int);

    for j = 1:length(Ce_vec)
        Ce = Ce_vec(j);
        K_eps = K0 * exp(eps_int);
        theta = K_eps * Ce ./ (1 + K_eps * Ce);
        integrand = theta .* f_eps;
        q_num(j) = Qmax * trapz(eps_int, integrand);
    end

    % --- Analytical: fit K_F from the numerical result ---
    % At C=1:  q = K_F * 1^(1/n) = K_F
    % So K_F = q_num at C=1
    [~, idx1] = min(abs(Ce_vec - 1));
    K_F = q_num(idx1);
    q_analytical = K_F * Ce_vec.^n;

    % Plot
    plot(Ce_vec, q_num, '-', 'LineWidth', 2, 'Color', colors(k,:), ...
        'DisplayName', sprintf('Numerical, $1/n=%.1f$', n));
    plot(Ce_vec, q_analytical, '--', 'LineWidth', 1.2, 'Color', colors(k,:), ...
        'HandleVisibility','off');
end

set(gca, 'XScale','log','YScale','log');
xlabel('$C_e$', 'Interpreter','latex','FontSize',13);
ylabel('$q_e$', 'Interpreter','latex','FontSize',13);
title('Numerical vs.\ analytical Freundlich ($--$ dashed)', ...
    'Interpreter','latex','FontSize',14);
legend('Interpreter','latex','Location','southeast','FontSize',11);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
hold off;

%% ======================================================================
%  Figure 4 : Comparison of f(E) for Freundlich, Sips and Langmuir
%  ======================================================================
n_comp = 0.5;        % heterogeneity parameter
Ec     = 3;          % central energy for Sips (in units of RT)
b_sips = n_comp;     % scale = n*RT, in reduced units = n

eps_wide = linspace(-5, 15, 600);

% Freundlich power-law distribution
f_freundlich = (n_comp/pi) * sin(pi*n_comp) * K0^n_comp .* exp(n_comp * eps_wide);

% Sips logistic distribution (normalised)
u_sips = (eps_wide - Ec) / b_sips;
f_sips = (1/b_sips) * exp(u_sips) ./ (1 + exp(u_sips)).^2;

% Langmuir: Dirac delta at Ec (approximate as narrow Gaussian)
sigma_lang = 0.15;
f_langmuir = (1/(sigma_lang*sqrt(2*pi))) * exp(-0.5*((eps_wide - Ec)/sigma_lang).^2);

figure('Name','Comparison of energy distributions','Color','w',...
    'Position',[400 100 560 420]);
hold on; box on;

plot(eps_wide, f_freundlich, 'LineWidth', 2, 'Color', colors(1,:), ...
    'DisplayName', 'Freundlich (power law)');
plot(eps_wide, f_sips, 'LineWidth', 2, 'Color', colors(2,:), ...
    'DisplayName', sprintf('Sips (logistic, $E_c=%.0f$)', Ec));
plot(eps_wide, f_langmuir, 'LineWidth', 2, 'Color', colors(3,:), ...
    'DisplayName', sprintf('Langmuir ($\\delta$ at $E_c=%.0f$)', Ec));

xlabel('$\varepsilon = E\,/\,(RT)$','Interpreter','latex','FontSize',13);
ylabel('$f(\varepsilon)$','Interpreter','latex','FontSize',13);
title(sprintf('Energy distributions ($1/n = %.1f$)', n_comp), ...
    'Interpreter','latex','FontSize',14);
legend('Interpreter','latex','Location','northeast','FontSize',11);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
ylim([0, max(f_sips)*1.3]);
hold off;

%% ======================================================================
%  Figure 5 : SURF — Integrand  theta(eps,C) * f(eps)  over (eps, C)
%             Shows which energy sites contribute at each concentration.
%  ======================================================================
n_surf = 0.5;                                % fixed heterogeneity

eps_s  = linspace(-8, 12, 300);              % reduced energy
Ce_s   = logspace(-3, 2, 200);               % concentration (log-spaced)
[EPS, CE] = meshgrid(eps_s, Ce_s);

K_E       = K0 * exp(EPS);                   % local Langmuir constant
theta_mat = K_E .* CE ./ (1 + K_E .* CE);   % local coverage
f_mat     = (n_surf/pi) * sin(pi*n_surf) * K0^n_surf .* exp(n_surf * EPS);
Z         = theta_mat .* f_mat;              % integrand

% --- Transform to compress dynamic range ---
Zlog  = log10(Z + 1e-12);                   % log10 scale
Zsqrt = sqrt(Z);                            % sqrt scale

% --- Panel (a): log10 ---
figure('Name','Surf: site contributions','Color','w',...
    'Position',[500 100 1200 500]);

subplot(1,2,1);
surf(EPS, log10(CE), Zlog, 'EdgeColor','none');
xlabel('$\varepsilon = E/(RT)$','Interpreter','latex','FontSize',13);
ylabel('$\log_{10} C_e$','Interpreter','latex','FontSize',13);
zlabel('$\log_{10}(\theta \cdot f)$','Interpreter','latex','FontSize',13);
title(sprintf('log$_{10}$ scale ($1/n = %.1f$)', n_surf),...
    'Interpreter','latex','FontSize',14);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
colormap(gca, turbo);
cb1 = colorbar;
cb1.TickLabelInterpreter = 'latex';
set(cb1.Label, 'Interpreter','latex', 'String','$\log_{10}(\theta \cdot f)$');
view([-35, 30]);
shading interp;
clim([max(Zlog(:))-6, max(Zlog(:))]);       % show 6 decades

% --- Panel (b): sqrt ---
subplot(1,2,2);
surf(EPS, log10(CE), Zsqrt, 'EdgeColor','none');
xlabel('$\varepsilon = E/(RT)$','Interpreter','latex','FontSize',13);
ylabel('$\log_{10} C_e$','Interpreter','latex','FontSize',13);
zlabel('$\sqrt{\theta \cdot f}$','Interpreter','latex','FontSize',13);
title(sprintf('$\\sqrt{\\cdot}$ scale ($1/n = %.1f$)', n_surf),...
    'Interpreter','latex','FontSize',14);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
colormap(gca, turbo);
cb2 = colorbar;
cb2.TickLabelInterpreter = 'latex';
set(cb2.Label, 'Interpreter','latex', 'String','$\sqrt{\theta \cdot f}$');
view([-35, 30]);
shading interp;

%% ======================================================================
%  Figure 6 : CONTOUR — filled contour of log10(theta * f)
%             Top-down view of the surf, cleaner for publications.
%  ======================================================================
figure('Name','Contour: site contributions','Color','w',...
    'Position',[600 100 620 480]);

Zlog_clipped = Zlog;
Zlog_clipped(Zlog_clipped < max(Zlog(:))-6) = NaN;   % mask low decades

nlevels = 30;
contourf(eps_s, log10(Ce_s), Zlog_clipped, nlevels, 'LineStyle','none');
hold on;

% --- Ridge line: energy of maximum contribution at each C_e ---
[~, idx_max] = max(Z, [], 2);           % index of peak along eps for each C
eps_ridge = eps_s(idx_max);
plot(eps_ridge, log10(Ce_s), 'w-', 'LineWidth', 2, ...
    'DisplayName', 'Ridge (max contribution)');

xlabel('$\varepsilon = E\,/\,(RT)$','Interpreter','latex','FontSize',13);
ylabel('$\log_{10} C_e$','Interpreter','latex','FontSize',13);
title(sprintf('$\\log_{10}(\\theta \\cdot f)$ --- Freundlich, $1/n = %.1f$', n_surf),...
    'Interpreter','latex','FontSize',14);
set(gca,'FontSize',11,'TickLabelInterpreter','latex');
colormap(turbo);
cb3 = colorbar;
cb3.TickLabelInterpreter = 'latex';
set(cb3.Label, 'Interpreter','latex', 'String','$\log_{10}(\theta \cdot f)$', 'FontSize',12);
legend('Interpreter','latex','Location','southeast','FontSize',11,...
    'TextColor','w');
hold off;

fprintf('Done. Six figures generated.\n');

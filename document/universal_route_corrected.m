%% universal_route_corrected.m
%  CORRECTED implementation based on Universal_route_v3.tex
%  Improvements over the original:
%    1. Quantitative criteria for Henry/plateau region selection (F-test)
%    2. Convergence check for iterative Kp estimation
%    3. Tikhonov-regularized NNLS with L-curve for lambda selection
%    4. Bootstrap confidence intervals
%    5. Convergence diagnostics for K_H (first-moment finiteness)
%    6. Diagnostic plots saved to files for LaTeX inclusion
%
%  Figures saved:
%    fig_isotherms.pdf        -- Isotherms with Henry/plateau regions
%    fig_nnls_distributions.pdf -- NNLS recovered affinity distributions
%    fig_sensitivity.pdf      -- Sensitivity of Kaff to Henry region
%    fig_bootstrap.pdf        -- Bootstrap histograms for Qmax and Kaff
%    fig_lcurve.pdf           -- L-curve for regularization selection
%
%  Reference: Universal_route_v3.tex

clear; close all; clc;

%% =====================================================================
%  Output directory for figures
%  =====================================================================
fig_dir = pwd; 

%% =====================================================================
%  Section 1: Generate synthetic data from known models
%  =====================================================================

% --- Model A: Single Langmuir ---
Qmax_true_A = 100;    KL_true_A = 0.5;
Ce_A = logspace(-2, 2, 30)';
q_true_A = Qmax_true_A * KL_true_A * Ce_A ./ (1 + KL_true_A * Ce_A);

% --- Model B: Sips (Langmuir-Freundlich) ---
Qmax_true_B = 80;  Ks_true_B = 0.3;  m_true_B = 0.7;
Ce_B = logspace(-2, 2, 30)';
q_true_B = Qmax_true_B * (Ks_true_B * Ce_B).^m_true_B ...
           ./ (1 + (Ks_true_B * Ce_B).^m_true_B);

% --- Model C: Partition + Langmuir (PFAS-like) ---
Qmax_true_C = 50;  KL_true_C = 1.0;  Kp_true_C = 2.0;
Ce_C = logspace(-2, 2, 30)';
q_true_C = Kp_true_C * Ce_C ...
         + Qmax_true_C * KL_true_C * Ce_C ./ (1 + KL_true_C * Ce_C);

% --- Model D: Double Langmuir ---
Qmax1_D = 60;  K1_D = 5.0;
Qmax2_D = 40;  K2_D = 0.05;
Ce_D = logspace(-2, 2, 30)';
q_true_D = Qmax1_D * K1_D * Ce_D ./ (1 + K1_D * Ce_D) ...
         + Qmax2_D * K2_D * Ce_D ./ (1 + K2_D * Ce_D);
Qmax_true_D = Qmax1_D + Qmax2_D;
KH_true_D   = Qmax1_D * K1_D + Qmax2_D * K2_D;
Kaff_true_D  = KH_true_D / Qmax_true_D;

% Add noise (5% relative)
rng(42);
noise_level = 0.05;
add_noise = @(qt) max(qt + noise_level * qt .* randn(size(qt)), 0);
sigma_fn  = @(qt) max(noise_level * qt, 1e-6);

q_A = add_noise(q_true_A);  sigma_A = sigma_fn(q_true_A);
q_B = add_noise(q_true_B);  sigma_B = sigma_fn(q_true_B);
q_C = add_noise(q_true_C);  sigma_C = sigma_fn(q_true_C);
q_D = add_noise(q_true_D);  sigma_D = sigma_fn(q_true_D);

%% =====================================================================
%  Section 2: Run corrected workflow + bootstrap
%  =====================================================================

fprintf('============================================================\n');
fprintf(' CORRECTED METHOD (Universal_route_v3.tex)\n');
fprintf('============================================================\n\n');

models     = {'A: Langmuir', 'B: Sips', 'C: Partition+Langmuir', 'D: Double Langmuir'};
short_name = {'Langmuir', 'Sips', 'Partition+Langmuir', 'Double Langmuir'};
Ce_all     = {Ce_A, Ce_B, Ce_C, Ce_D};
q_all      = {q_A, q_B, q_C, q_D};
q_true_all = {q_true_A, q_true_B, q_true_C, q_true_D};
sig_all    = {sigma_A, sigma_B, sigma_C, sigma_D};
true_Qmax  = [Qmax_true_A, Qmax_true_B, Qmax_true_C, Qmax_true_D];
true_Kaff  = [KL_true_A, NaN, KL_true_C, Kaff_true_D];

results = struct();
all_CI  = struct();

for k = 1:4
    fprintf('--- Model %s ---\n', models{k});
    res = universal_route_corrected(Ce_all{k}, q_all{k}, sig_all{k});
    fprintf('  Qmax   = %.2f   (true: %.2f)\n', res.Qmax, true_Qmax(k));
    fprintf('  KH     = %.4f\n', res.KH);
    fprintf('  Kaff   = %.4f', res.Kaff);
    if ~isnan(true_Kaff(k))
        fprintf('   (true: %.4f)', true_Kaff(k));
    end
    fprintf('\n  Kp     = %.4f\n', res.Kp);
    fprintf('  Henry region: first %d points\n', res.n_henry);
    fprintf('  Plateau region: last %d points\n\n', res.n_plateau);

    % Suppress singular/near-singular warnings during bootstrap
    wstate1 = warning('off', 'MATLAB:singularMatrix');
    wstate2 = warning('off', 'MATLAB:nearlySingularMatrix');
    wstate3 = warning('off', 'MATLAB:illConditionedMatrix');
    CI = bootstrap_universal(Ce_all{k}, q_all{k}, sig_all{k}, 1000);
    warning(wstate1); warning(wstate2); warning(wstate3);
    fprintf('  Bootstrap 95%% CI:  Qmax [%.2f, %.2f],  Kaff [%.4f, %.4f]\n\n', ...
        CI.Qmax_lo, CI.Qmax_hi, CI.Kaff_lo, CI.Kaff_hi);

    results(k).res = res;
    results(k).CI  = CI;
end

%% =====================================================================
%  FIGURE 1: Isotherms with Henry and plateau regions highlighted
%  =====================================================================

colors_model = lines(4);

fig1 = figure('Name','Isotherms','Color','w','Position',[50 50 1400 900]);

for k = 1:4
    subplot(2,2,k);
    Ce = Ce_all{k};
    res = results(k).res;
    N  = length(Ce);

    % Sort for plotting
    [Ce_s, si] = sort(Ce);
    q_s     = q_all{k}(si);
    qt_s    = q_true_all{k}(si);

    % Reconstructed effective Langmuir
    Ce_fine = logspace(log10(min(Ce)), log10(max(Ce)), 300)';
    if res.Kp > 0
        q_recon = res.Kp * Ce_fine ...
                + res.Qmax * res.Kaff * Ce_fine ./ (1 + res.Kaff * Ce_fine);
    else
        q_recon = res.Qmax * res.Kaff * Ce_fine ./ (1 + res.Kaff * Ce_fine);
    end

    % Henry line
    q_henry_line = res.KH * Ce_fine;
    if res.Kp > 0
        q_henry_line = (res.KH + res.Kp) * Ce_fine;
    end

    % Highlight Henry region (shaded)
    I_henry  = 1:res.n_henry;
    I_plateau = (N - res.n_plateau + 1):N;

    hold on; box on;

    % Shaded regions
    xH = [Ce_s(I_henry(1)), Ce_s(I_henry(end)), Ce_s(I_henry(end)), Ce_s(I_henry(1))];
    yL_h = min(q_s)*0.5;  yH_h = max(q_s)*2;
    fill(xH, [yL_h yL_h yH_h yH_h], [0.85 0.92 1.0], ...
        'EdgeColor', 'none', 'HandleVisibility', 'off');

    xP = [Ce_s(I_plateau(1)), Ce_s(I_plateau(end)), Ce_s(I_plateau(end)), Ce_s(I_plateau(1))];
    fill(xP, [yL_h yL_h yH_h yH_h], [1.0 0.92 0.85], ...
        'EdgeColor', 'none', 'HandleVisibility', 'off');

    % True model
    loglog(Ce_s, qt_s, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.8, ...
        'DisplayName', 'True model');
    % Data
    loglog(Ce_s, q_s, 'ko', 'MarkerSize', 5, 'MarkerFaceColor', 'k', ...
        'DisplayName', 'Data');
    % Reconstruction
    loglog(Ce_fine, q_recon, 'r--', 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Recon ($K_{\\mathrm{aff}}=%.3f$)', res.Kaff));
    % Qmax line
    yline(res.Qmax, 'g-', 'LineWidth', 1.2, ...
        'DisplayName', sprintf('$\\hat{Q}_{\\max}=%.1f$', res.Qmax));
    % Henry line (only in low-C range)
    idx_low = Ce_fine < Ce_s(min(res.n_henry+2, N));
    loglog(Ce_fine(idx_low), q_henry_line(idx_low), 'b:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Henry ($K_H=%.2f$)', res.KH));

    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel('$C_e$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$q_e$', 'Interpreter', 'latex', 'FontSize', 12);
    title(short_name{k}, 'Interpreter', 'latex', 'FontSize', 13);
    legend('Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 8);
    set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
    ylim([max(min(q_s)*0.5, 1e-3), max(q_s)*2]);
    hold off;
end

% Add text annotations for shaded regions
annotation('textbox', [0.02 0.01 0.5 0.03], ...
    'String', 'Blue shading = Henry region $\mathcal{I}_0$, \quad Orange shading = Plateau region $\mathcal{I}_\infty$', ...
    'Interpreter', 'latex', 'FontSize', 10, 'EdgeColor', 'none', ...
    'HorizontalAlignment', 'left');

exportgraphics(fig1, fullfile(fig_dir, 'fig_isotherms.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_isotherms.pdf\n');

%% =====================================================================
%  FIGURE 2: NNLS recovered affinity distributions
%  =====================================================================

true_K_positions = {KL_true_A, NaN, KL_true_C, [K1_D, K2_D]};

fig2 = figure('Name','NNLS Distributions','Color','w','Position',[50 50 1400 400]);

nnls_results = struct();

for k = 1:4
    [Qmax_nn, KH_nn, Kaff_nn, Kj, qmj, lambda_opt] = ...
        nnls_tikhonov_lcurve(Ce_all{k}, q_all{k}, sig_all{k}, results(k).res.Kp);

    nnls_results(k).Kj = Kj;
    nnls_results(k).qmj = qmj;
    nnls_results(k).lambda = lambda_opt;
    nnls_results(k).Qmax = Qmax_nn;
    nnls_results(k).Kaff = Kaff_nn;

    fprintf('NNLS Model %s: Qmax=%.2f, Kaff=%.4f, lambda=%.2e\n', ...
        models{k}, Qmax_nn, Kaff_nn, lambda_opt);

    subplot(1,4,k);
    bar(log10(Kj), qmj, 1, 'FaceColor', [0.3 0.5 0.8], 'EdgeColor', 'none', ...
        'DisplayName', 'Recovered $\rho(K)$');
    hold on;
    Kpos = true_K_positions{k};
    if ~any(isnan(Kpos))
        for kk = 1:length(Kpos)
            xline(log10(Kpos(kk)), 'r--', 'LineWidth', 2, ...
                'DisplayName', sprintf('True $K=%.2f$', Kpos(kk)));
        end
    end
    % Mark Kaff
    xline(log10(Kaff_nn), 'k:', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('$K_{\\mathrm{aff}}=%.3f$', Kaff_nn));
    xlabel('$\log_{10} K$', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('$q_{m,j}$ (mg/g)', 'Interpreter', 'latex', 'FontSize', 11);
    title(short_name{k}, 'Interpreter', 'latex', 'FontSize', 12);
    legend('Interpreter', 'latex', 'Location', 'best', 'FontSize', 8);
    set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
    hold off;
end

exportgraphics(fig2, fullfile(fig_dir, 'fig_nnls_distributions.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_nnls_distributions.pdf\n');

%% =====================================================================
%  FIGURE 3: Sensitivity of Kaff to Henry region size
%  =====================================================================

fig3 = figure('Name','Sensitivity','Color','w','Position',[50 50 700 450]);
hold on; box on;

markers = {'o', 's', 'd', '^'};

for k = 1:4
    Ce = Ce_all{k};
    q_data = q_all{k};
    sig = sig_all{k};
    ww = 1 ./ sig.^2;
    N = length(Ce);
    [Ce_s, si] = sort(Ce);
    q_s = q_data(si);
    ww_s = ww(si);

    % Subtract Kp if present
    q_henry_data = q_s;
    if results(k).res.Kp > 0
        q_henry_data = q_s - results(k).res.Kp * Ce_s;
    end

    n_range = 3:min(15, floor(N/2));
    Kaff_sens = zeros(size(n_range));
    for ii = 1:length(n_range)
        I0 = 1:n_range(ii);
        KH_tmp = sum(ww_s(I0) .* Ce_s(I0) .* q_henry_data(I0)) ...
               / sum(ww_s(I0) .* Ce_s(I0).^2);
        Kaff_sens(ii) = KH_tmp / results(k).res.Qmax;
    end
    plot(n_range, Kaff_sens, ['-' markers{k}], 'LineWidth', 1.5, ...
        'MarkerSize', 6, 'Color', colors_model(k,:), ...
        'DisplayName', short_name{k});
    % Mark selected n_henry
    xline(results(k).res.n_henry, ':', 'Color', colors_model(k,:), ...
        'LineWidth', 1, 'HandleVisibility', 'off');
end

xlabel('Number of points in $\mathcal{I}_0$ (Henry region)', ...
    'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\hat{K}_{\mathrm{aff}}$', 'Interpreter', 'latex', 'FontSize', 12);
title('Sensitivity of $K_{\mathrm{aff}}$ to Henry region size', ...
    'Interpreter', 'latex', 'FontSize', 13);
legend('Interpreter', 'latex', 'Location', 'best', 'FontSize', 10);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

exportgraphics(fig3, fullfile(fig_dir, 'fig_sensitivity.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_sensitivity.pdf\n');

%% =====================================================================
%  FIGURE 4: Bootstrap histograms for Qmax and Kaff
%  =====================================================================

fig4 = figure('Name','Bootstrap','Color','w','Position',[50 50 1400 500]);

for k = 1:4
    % Re-run bootstrap storing full vectors
    Ce = Ce_all{k}; q_data = q_all{k}; sig = sig_all{k};
    N = length(Ce);
    B = 1000;
    Qb = zeros(B,1); Kb = zeros(B,1);
    % Suppress singular/near-singular warnings during bootstrap
    wstate1 = warning('off', 'MATLAB:singularMatrix');
    wstate2 = warning('off', 'MATLAB:nearlySingularMatrix');
    wstate3 = warning('off', 'MATLAB:illConditionedMatrix');
    for b = 1:B
        idx = randi(N, N, 1);
        try
            rb = universal_route_corrected(Ce(idx), q_data(idx), sig(idx));
            Qb(b) = rb.Qmax; Kb(b) = rb.Kaff;
        catch
            Qb(b) = NaN; Kb(b) = NaN;
        end
    end
    warning(wstate1); warning(wstate2); warning(wstate3);
    valid = ~isnan(Qb) & ~isnan(Kb);
    Qb = Qb(valid); Kb = Kb(valid);

    % Qmax histogram
    subplot(2,4,k);
    histogram(Qb, 30, 'FaceColor', [0.3 0.5 0.8], 'EdgeColor', 'w');
    hold on;
    xline(true_Qmax(k), 'r-', 'LineWidth', 2);
    xline(results(k).res.Qmax, 'k--', 'LineWidth', 1.5);
    xlabel('$\hat{Q}_{\max}$', 'Interpreter', 'latex', 'FontSize', 10);
    ylabel('Count', 'Interpreter', 'latex', 'FontSize', 10);
    title(sprintf('%s: $Q_{\\max}$', short_name{k}), ...
        'Interpreter', 'latex', 'FontSize', 11);
    set(gca, 'FontSize', 9, 'TickLabelInterpreter', 'latex');
    hold off;

    % Kaff histogram
    subplot(2,4,k+4);
    histogram(Kb, 30, 'FaceColor', [0.8 0.5 0.3], 'EdgeColor', 'w');
    hold on;
    if ~isnan(true_Kaff(k))
        xline(true_Kaff(k), 'r-', 'LineWidth', 2);
    end
    xline(results(k).res.Kaff, 'k--', 'LineWidth', 1.5);
    xlabel('$\hat{K}_{\mathrm{aff}}$', 'Interpreter', 'latex', 'FontSize', 10);
    ylabel('Count', 'Interpreter', 'latex', 'FontSize', 10);
    title(sprintf('%s: $K_{\\mathrm{aff}}$', short_name{k}), ...
        'Interpreter', 'latex', 'FontSize', 11);
    set(gca, 'FontSize', 9, 'TickLabelInterpreter', 'latex');
    hold off;
end

exportgraphics(fig4, fullfile(fig_dir, 'fig_bootstrap.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_bootstrap.pdf\n');

%% =====================================================================
%  FIGURE 5: L-curve for Model A (illustration of regularization)
%  =====================================================================

fig5 = figure('Name','L-curve','Color','w','Position',[50 50 600 450]);

% Recompute L-curve data for Model A
Ce = Ce_all{1}; q_data = q_all{1}; sig = sig_all{1};
ww = 1 ./ sig.^2;
N = length(Ce);
M = 50;
Kmin = 0.1 / max(Ce);  Kmax = 10 / min(Ce);
Kj = logspace(log10(Kmin), log10(Kmax), M)';
A = zeros(N, M);
for j = 1:M
    A(:,j) = Kj(j) * Ce ./ (1 + Kj(j) * Ce);
end
W_half = diag(sqrt(ww));
A_w = W_half * A;
q_w = W_half * q_data;

L_mat = zeros(M-2, M);
for i = 1:M-2
    L_mat(i, i) = 1; L_mat(i, i+1) = -2; L_mat(i, i+2) = 1;
end

lambdas = logspace(-6, 2, 60);
res_norm = zeros(size(lambdas));
sol_norm = zeros(size(lambdas));
for il = 1:length(lambdas)
    lam = lambdas(il);
    A_aug = [A_w; sqrt(lam) * L_mat];
    q_aug = [q_w; zeros(M-2, 1)];
    qmj_try = lsqnonneg(A_aug, q_aug);
    res_norm(il) = norm(A_w * qmj_try - q_w);
    sol_norm(il) = norm(L_mat * qmj_try);
end

% Find corner
lr = log10(res_norm + 1e-16);
ls = log10(sol_norm + 1e-16);
kappa = zeros(length(lambdas), 1);
for i = 2:length(lambdas)-1
    dx1 = lr(i) - lr(i-1); dx2 = lr(i+1) - lr(i);
    dy1 = ls(i) - ls(i-1); dy2 = ls(i+1) - ls(i);
    dx = (dx1+dx2)/2; dy = (dy1+dy2)/2;
    kappa(i) = abs(dx*(dy2-dy1) - dy*(dx2-dx1)) / (dx^2+dy^2)^1.5;
end
[~, idx_opt] = max(kappa);

hold on; box on;
plot(lr, ls, 'b-', 'LineWidth', 1.8);
plot(lr(idx_opt), ls(idx_opt), 'ro', 'MarkerSize', 12, 'LineWidth', 2, ...
    'MarkerFaceColor', 'r');
text(lr(idx_opt)+0.1, ls(idx_opt)+0.15, ...
    sprintf('$\\lambda^* = %.1e$', lambdas(idx_opt)), ...
    'Interpreter', 'latex', 'FontSize', 11, 'Color', 'r');
xlabel('$\log_{10} \| \mathbf{r} \|$ (residual norm)', ...
    'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\log_{10} \| \mathbf{L} \mathbf{q}_m \|$ (solution roughness)', ...
    'Interpreter', 'latex', 'FontSize', 12);
title('L-curve for regularization parameter selection (Model A)', ...
    'Interpreter', 'latex', 'FontSize', 13);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

exportgraphics(fig5, fullfile(fig_dir, 'fig_lcurve.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_lcurve.pdf\n');

fprintf('\nDone. Five figures saved as PDF.\n');

%% =====================================================================
%  FUNCTION: universal_route_corrected
%  =====================================================================
function res = universal_route_corrected(Ce, q, sigma)
    Ce = Ce(:); q = q(:); sigma = sigma(:);
    w = 1 ./ sigma.^2;
    N = length(Ce);
    [Ce, idx] = sort(Ce);
    q = q(idx); w = w(idx); sigma = sigma(idx);

    % ---- Step 1: Partition test ----
    % Use up to 12 high-C points for better statistical power
    m_high = min(12, max(5, floor(N/3)));
    I_high = (N-m_high+1):N;

    % Test A: OLS t-test on slope (unweighted -- crucial!)
    % WLS with sigma proportional to q downweights the highest-C points
    % where the partition signal is strongest, killing detection power.
    X_h = [ones(m_high,1), Ce(I_high)];
    XtX = X_h' * X_h;
    beta_h = pinv(XtX) * (X_h' * q(I_high));
    resid_h = q(I_high) - X_h * beta_h;
    s2_h = sum(resid_h.^2) / max(m_high - 2, 1);
    cov_h = s2_h * pinv(XtX);
    se_slope = sqrt(max(cov_h(2,2), 0));
    if se_slope > 0
        t_slope = beta_h(2) / se_slope;
    else
        t_slope = 0;
    end
    t_crit = t_critical_975(max(m_high-2, 1));
    use_partition_ttest = (t_slope > t_crit) && (beta_h(2) > 0);

    % Test B: ratio check (q/C at high C vs low C)
    ratio_high = q(I_high) ./ Ce(I_high);
    ratio_low = q(1:min(3,N)) ./ Ce(1:min(3,N));
    mean_ratio_high = mean(ratio_high);
    mean_ratio_low  = mean(ratio_low);
    use_partition_ratio = (mean_ratio_high > 0.10 * mean_ratio_low) ...
                        && (mean_ratio_high > 0);

    % Test C: numerical derivative constancy at high C
    % For partition models, dq/dC -> Kp (constant) at high C.
    % For Freundlich/power-law, dq/dC is monotonically decreasing.
    % Require BOTH: derivative above threshold AND approximately flat.
    n_pairs = min(6, m_high - 1);
    I_deriv = (N - n_pairs):N;
    dqdc = diff(q(I_deriv)) ./ diff(Ce(I_deriv));
    mean_dqdc = mean(dqdc);
    q_mid = q(round(N/2));
    C_mid = Ce(round(N/2));
    deriv_threshold = 0.02 * q_mid / C_mid;
    % Flatness check: compare median derivative of second half to first half
    % Partition: ratio ~ 1.  Freundlich: ratio < 0.7.
    if length(dqdc) >= 4
        half = floor(length(dqdc)/2);
        med_first  = median(dqdc(1:half));
        med_second = median(dqdc(half+1:end));
        deriv_ratio = med_second / max(med_first, 1e-10);
        deriv_is_flat = (deriv_ratio > 0.70);
    else
        deriv_is_flat = true;
    end
    use_partition_deriv = (mean_dqdc > deriv_threshold) && deriv_is_flat;

    use_partition = use_partition_ttest || use_partition_ratio ...
                  || use_partition_deriv;

    % ---- Step 2: Estimate Qmax ----
    if ~use_partition
        % No partition: find plateau region via t-test on log(C) trend
        n_plateau = 3;
        for m_try = 4:min(N-2, floor(N/2))
            I_try = (N-m_try+1):N;
            X_t = [ones(m_try,1), log(Ce(I_try))];
            W_t = diag(w(I_try));
            XWX_t = X_t' * W_t * X_t;
            beta_t = pinv(XWX_t) * (X_t' * W_t * q(I_try));
            resid_t = q(I_try) - X_t * beta_t;
            s2_t = sum(w(I_try) .* resid_t.^2) / max(m_try - 2, 1);
            cov_t = s2_t * pinv(XWX_t);
            se_lnC = sqrt(max(cov_t(2,2), 0));
            if se_lnC > 0
                t_lnC = abs(beta_t(2)) / se_lnC;
            else
                t_lnC = 0;
            end
            t_crit_plat = t_critical_975(max(m_try-2, 1));
            if t_lnC > t_crit_plat
                break;
            end
            n_plateau = m_try;
        end
        I_plat = (N-n_plateau+1):N;

        if n_plateau >= 3
            Qmax = sum(w(I_plat) .* q(I_plat)) / sum(w(I_plat));
        else
            n_ext = min(5, floor(N/2));
            I_ext = (N-n_ext+1):N;
            X_e = [ones(n_ext,1), 1./Ce(I_ext)];
            W_e = diag(w(I_ext));
            beta_e = pinv(X_e' * W_e * X_e) * (X_e' * W_e * q(I_ext));
            Qmax = beta_e(1);
            if beta_e(2) > 0
                warning('A1 < 0: 1/C extrapolation may be unreliable.');
            end
        end
        Kp = 0;
    else
        % Partition detected: jointly estimate Kp and Qmax
        % At high C: q ~ Kp*C + Qmax, so fit q vs C to get both
        n_ext = min(10, max(5, floor(N/3)));
        I_ext = (N-n_ext+1):N;

        % First estimate Kp from slope of q vs C at high concentrations
        X_lin = [ones(n_ext,1), Ce(I_ext)];
        W_lin = diag(w(I_ext));
        beta_lin = pinv(X_lin' * W_lin * X_lin) * (X_lin' * W_lin * q(I_ext));
        Kp = max(beta_lin(2), 0);
        Qmax_init = max(beta_lin(1), 0);

        % Iterative refinement: subtract Kp*C, fit 1/C extrapolation for Qmax
        Qmax = Qmax_init;
        for iter = 1:30
            q_sat = q - Kp * Ce;
            % 1/C extrapolation on saturated part
            X_e = [ones(n_ext,1), 1./Ce(I_ext)];
            W_e = diag(w(I_ext));
            beta_e = pinv(X_e' * W_e * X_e) * (X_e' * W_e * q_sat(I_ext));
            Qmax_new = max(beta_e(1), 0);

            % Update Kp: at high C, q - Qmax ~ Kp*C
            q_resid = q(I_high) - Qmax_new;
            Kp_new = sum(w(I_high) .* Ce(I_high) .* q_resid) ...
                   / sum(w(I_high) .* Ce(I_high).^2);
            Kp_new = max(Kp_new, 0);

            dKp = abs(Kp_new - Kp) / max(abs(Kp), 1e-10);
            dQmax = abs(Qmax_new - Qmax) / max(abs(Qmax), 1e-10);
            Kp = Kp_new; Qmax = Qmax_new;
            if max(dKp, dQmax) < 1e-4, break; end
        end

        % Determine plateau region (on q_sat = q - Kp*C)
        q_sat = q - Kp * Ce;
        n_plateau = 3;
        for m_try = 4:min(N-2, floor(N/2))
            I_try = (N-m_try+1):N;
            X_t = [ones(m_try,1), log(Ce(I_try))];
            W_t = diag(w(I_try));
            XWX_t = X_t' * W_t * X_t;
            beta_t = pinv(XWX_t) * (X_t' * W_t * q_sat(I_try));
            resid_t = q_sat(I_try) - X_t * beta_t;
            s2_t = sum(w(I_try) .* resid_t.^2) / max(m_try - 2, 1);
            cov_t = s2_t * pinv(XWX_t);
            se_lnC = sqrt(max(cov_t(2,2), 0));
            if se_lnC > 0
                t_lnC = abs(beta_t(2)) / se_lnC;
            else
                t_lnC = 0;
            end
            t_crit_plat = t_critical_975(max(m_try-2, 1));
            if t_lnC > t_crit_plat
                break;
            end
            n_plateau = m_try;
        end
    end

    % ---- Step 3: Estimate KH with F-test ----
    n_henry = 3;
    q_for_henry = q;
    if use_partition, q_for_henry = q - Kp * Ce; end

    for m_try = 3:min(N-2, floor(N/2))
        I_try = 1:m_try;
        q_h = q_for_henry(I_try); C_h = Ce(I_try); w_h = w(I_try);
        KH_lin = sum(w_h .* C_h .* q_h) / sum(w_h .* C_h.^2);
        resid_lin = q_h - KH_lin * C_h;
        SSE_lin = sum(w_h .* resid_lin.^2);
        if m_try >= 4
            X_q = [C_h, C_h.^2]; W_q = diag(w_h);
            beta_q = pinv(X_q' * W_q * X_q) * (X_q' * W_q * q_h);
            resid_q = q_h - X_q * beta_q;
            SSE_quad = sum(w_h .* resid_q.^2);
            df2 = m_try - 2;
            if SSE_quad > 0 && df2 > 0
                F_stat = ((SSE_lin - SSE_quad) / 1) / (SSE_quad / df2);
                F_crit = f_critical_95(1, df2);
                if F_stat > F_crit, break; end
            end
        end
        n_henry = m_try;
    end

    I_henry = 1:n_henry;
    q_h = q_for_henry(I_henry);
    KH = sum(w(I_henry) .* Ce(I_henry) .* q_h) ...
       / sum(w(I_henry) .* Ce(I_henry).^2);
    KH = max(KH, 0);

    Kaff = KH / max(Qmax, 1e-10);

    % Convergence diagnostic
    KH_3 = sum(w(1:3) .* Ce(1:3) .* q_for_henry(1:3)) ...
          / sum(w(1:3) .* Ce(1:3).^2);
    n_check = min(n_henry + 3, floor(N/2));
    KH_ext = sum(w(1:n_check) .* Ce(1:n_check) .* q_for_henry(1:n_check)) ...
           / sum(w(1:n_check) .* Ce(1:n_check).^2);
    relative_change = abs(KH_ext - KH_3) / max(KH_3, 1e-10);

    res.Qmax = Qmax; res.KH = KH; res.Kaff = Kaff; res.Kp = Kp;
    res.n_henry = n_henry; res.n_plateau = n_plateau;
    res.use_partition = use_partition; res.KH_sensitivity = relative_change;
    % if relative_change > 0.3
    %     warning('K_H varies >30%% with Henry region size. First moment may diverge.');
    % end
end

%% =====================================================================
%  FUNCTION: bootstrap_universal
%  =====================================================================
function CI = bootstrap_universal(Ce, q, sigma, B)
    Ce = Ce(:); q = q(:); sigma = sigma(:);
    N = length(Ce);
    Qb = zeros(B,1); Kb = zeros(B,1); Hb = zeros(B,1);
    for b = 1:B
        idx = randi(N, N, 1);
        try
            rb = universal_route_corrected(Ce(idx), q(idx), sigma(idx));
            Qb(b) = rb.Qmax; Kb(b) = rb.Kaff; Hb(b) = rb.KH;
        catch
            Qb(b) = NaN; Kb(b) = NaN; Hb(b) = NaN;
        end
    end
    valid = ~isnan(Qb) & ~isnan(Kb);
    CI.Qmax_lo = prctile(Qb(valid), 2.5);
    CI.Qmax_hi = prctile(Qb(valid), 97.5);
    CI.Kaff_lo = prctile(Kb(valid), 2.5);
    CI.Kaff_hi = prctile(Kb(valid), 97.5);
    CI.KH_lo   = prctile(Hb(valid), 2.5);
    CI.KH_hi   = prctile(Hb(valid), 97.5);
    CI.n_valid  = sum(valid);
end

%% =====================================================================
%  FUNCTION: nnls_tikhonov_lcurve
%  =====================================================================
function [Qmax, KH, Kaff, Kj, qmj, lambda_opt] = ...
    nnls_tikhonov_lcurve(Ce, q, sigma, Kp_fixed)

    Ce = Ce(:); q = q(:); sigma = sigma(:);
    w = 1 ./ sigma.^2; N = length(Ce);
    M = 50;
    Kmin = 0.1 / max(Ce); Kmax = 10 / min(Ce);
    Kj = logspace(log10(Kmin), log10(Kmax), M)';

    A = zeros(N, M);
    for j = 1:M
        A(:,j) = Kj(j) * Ce ./ (1 + Kj(j) * Ce);
    end
    q_sat = q - Kp_fixed * Ce;
    W_half = diag(sqrt(w));
    A_w = W_half * A; q_w = W_half * q_sat;

    L = zeros(M-2, M);
    for i = 1:M-2
        L(i, i) = 1; L(i, i+1) = -2; L(i, i+2) = 1;
    end

    lambdas = logspace(-6, 2, 50);
    rn = zeros(size(lambdas)); sn = zeros(size(lambdas));
    qm_all = zeros(M, length(lambdas));
    for il = 1:length(lambdas)
        lam = lambdas(il);
        A_aug = [A_w; sqrt(lam) * L];
        q_aug = [q_w; zeros(M-2, 1)];
        qm_try = lsqnonneg(A_aug, q_aug);
        qm_all(:,il) = qm_try;
        rn(il) = norm(A_w * qm_try - q_w);
        sn(il) = norm(L * qm_try);
    end

    lr = log10(rn + 1e-16); ls_ = log10(sn + 1e-16);
    kappa = zeros(length(lambdas), 1);
    for i = 2:length(lambdas)-1
        dx1 = lr(i)-lr(i-1); dx2 = lr(i+1)-lr(i);
        dy1 = ls_(i)-ls_(i-1); dy2 = ls_(i+1)-ls_(i);
        dx = (dx1+dx2)/2; dy = (dy1+dy2)/2;
        kappa(i) = abs(dx*(dy2-dy1)-dy*(dx2-dx1)) / (dx^2+dy^2)^1.5;
    end
    [~, idx_opt] = max(kappa);
    lambda_opt = lambdas(idx_opt);
    qmj = qm_all(:, idx_opt);
    Qmax = sum(qmj); KH = sum(Kj .* qmj);
    Kaff = KH / max(Qmax, 1e-10);
end

%% =====================================================================
%  HELPER: t_critical_975 -- without Statistics Toolbox
%  =====================================================================
function tc = t_critical_975(df)
    df_tab = [1  2  3  4  5  6  7  8  9  10  12  15  20  25  30  40  60  120  1e6];
    tc_tab = [12.706 4.303 3.182 2.776 2.571 2.447 2.365 2.306 2.262 ...
              2.228  2.179 2.131 2.086 2.060 2.042 2.021 2.000 1.980 1.960];
    if df >= 1e6, tc = 1.960;
    elseif df <= 1, tc = 12.706;
    else, tc = interp1(df_tab, tc_tab, df, 'linear', 1.960);
    end
end

%% =====================================================================
%  HELPER: f_critical_95 -- without Statistics Toolbox (df1=1 only)
%  =====================================================================
function fc = f_critical_95(~, df2)
    df2_tab = [1  2  3  4  5  6  7  8  9  10  12  15  20  25  30  40  60  120  1e6];
    fc_tab  = [161.4 18.51 10.13 7.709 6.608 5.987 5.591 5.318 5.117 ...
               4.965 4.747 4.543 4.351 4.242 4.171 4.085 4.001 3.920 3.841];
    if df2 >= 1e6, fc = 3.841;
    elseif df2 <= 1, fc = 161.4;
    else, fc = interp1(df2_tab, fc_tab, df2, 'linear', 3.841);
    end
end

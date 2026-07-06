%% universal_route_v4_limits.m
%  Numerical verification of convergence limits (Universal_route_v4.tex)
%
%  Tests 7 models: Langmuir, Double Langmuir, Sips, Toth, Temkin,
%                   Freundlich, Dual-mode (Partition+Langmuir)
%
%  Figures saved:
%    fig_v4_models.pdf       -- 2x4 panel: isotherms + error summary
%    fig_v4_convergence.pdf  -- Relative error vs noise level
%
%  Self-contained: includes universal_route_corrected as local function.

clear; close all; clc;

fig_dir =  pwd;

%% =====================================================================
%  Define 7 models with analytical invariants
%  =====================================================================

Ce_base = logspace(-2, 2, 40)';

% --- Model 1: Langmuir ---
M(1).name  = 'Langmuir';
M(1).Qmax  = 100;  M(1).Kaff = 0.5;  M(1).Kp = 0;
M(1).q_fn  = @(C) 100 * 0.5 * C ./ (1 + 0.5 * C);

% --- Model 2: Double Langmuir ---
Q1 = 60; K1 = 5.0; Q2 = 40; K2 = 0.05;
M(2).name  = 'Double Langmuir';
M(2).Qmax  = Q1 + Q2;
M(2).Kaff  = (Q1*K1 + Q2*K2) / (Q1+Q2);
M(2).Kp    = 0;
M(2).q_fn  = @(C) Q1*K1*C./(1+K1*C) + Q2*K2*C./(1+K2*C);

% --- Model 3: Sips (m = 0.7) ---
Qs = 80; Ks = 0.3; ms = 0.7;
M(3).name  = 'Sips ($m=0.7$)';
M(3).Qmax  = Qs;
M(3).Kaff  = NaN;   % first moment diverges
M(3).Kp    = 0;
M(3).q_fn  = @(C) Qs * (Ks*C).^ms ./ (1 + (Ks*C).^ms);

% --- Model 4: Toth (t = 0.6) ---
Qt = 90; Kt = 0.8; tt = 0.6;
M(4).name  = 'T\''oth ($t=0.6$)';
M(4).Qmax  = Qt;
M(4).Kaff  = Kt;    % K_aff = K_T for all t
M(4).Kp    = 0;
M(4).q_fn  = @(C) Qt * Kt * C ./ (1 + (Kt*C).^tt).^(1/tt);

% --- Model 5: Temkin ---
Qtem = 80; Kmax_tem = 100; Kmin_tem = 0.01;
Kaff_temkin = (Kmax_tem - Kmin_tem) / log(Kmax_tem / Kmin_tem);
M(5).name  = 'Temkin';
M(5).Qmax  = Qtem;
M(5).Kaff  = Kaff_temkin;
M(5).Kp    = 0;
M(5).q_fn  = @(C) Qtem / log(Kmax_tem/Kmin_tem) ...
              * (log(1 + Kmax_tem*C) - log(1 + Kmin_tem*C));

% --- Model 6: Freundlich ---
Kf = 20; nf = 0.6;
M(6).name  = 'Freundlich';
M(6).Qmax  = Inf;
M(6).Kaff  = Inf;
M(6).Kp    = 0;
M(6).q_fn  = @(C) Kf * C.^nf;

% --- Model 7: Dual-mode (Partition + Langmuir) ---
Qd = 50; Kd = 1.0; Kpd = 2.0;
M(7).name  = 'Dual-mode';
M(7).Qmax  = Qd;
M(7).Kaff  = Kd;
M(7).Kp    = Kpd;
M(7).q_fn  = @(C) Kpd*C + Qd*Kd*C./(1+Kd*C);

nModels = length(M);

%% =====================================================================
%  Run universal method on all models (5% noise)
%  =====================================================================

rng(42);
noise_level = 0.05;
sigma_fn = @(qt) max(noise_level * qt, 1e-6);

fprintf('================================================================\n');
fprintf(' CONVERGENCE VERIFICATION  (Universal_route_v4.tex)\n');
fprintf('================================================================\n\n');
fprintf('%-22s  %10s %10s  %10s %10s  %6s %6s\n', ...
    'Model', 'Qmax_true', 'Qmax_est', 'Kaff_true', 'Kaff_est', ...
    'errQ%', 'errK%');
fprintf('%s\n', repmat('-', 1, 80));

results = struct();
for k = 1:nModels
    Ce = Ce_base;
    q_true = M(k).q_fn(Ce);
    sigma  = sigma_fn(q_true);
    q_noisy = max(q_true + noise_level * q_true .* randn(size(q_true)), 0);

    % Suppress warnings during estimation
    ws1 = warning('off', 'MATLAB:singularMatrix');
    ws2 = warning('off', 'MATLAB:nearlySingularMatrix');
    ws3 = warning('off', 'MATLAB:illConditionedMatrix');
    res = universal_route_v4(Ce, q_noisy, sigma);
    warning(ws1); warning(ws2); warning(ws3);

    results(k).Ce      = Ce;
    results(k).q_true  = q_true;
    results(k).q_noisy = q_noisy;
    results(k).sigma   = sigma;
    results(k).res     = res;

    % Compute errors
    if isfinite(M(k).Qmax)
        errQ = abs(res.Qmax - M(k).Qmax) / M(k).Qmax * 100;
    else
        errQ = NaN;
    end
    if isfinite(M(k).Kaff)
        errK = abs(res.Kaff - M(k).Kaff) / M(k).Kaff * 100;
    else
        errK = NaN;
    end
    results(k).errQ = errQ;
    results(k).errK = errK;

    % Print
    if isfinite(M(k).Qmax)
        qstr = sprintf('%10.2f', M(k).Qmax);
    else
        qstr = sprintf('%10s', 'Inf');
    end
    if isfinite(M(k).Kaff)
        kstr = sprintf('%10.4f', M(k).Kaff);
    else
        kstr = sprintf('%10s', 'Inf');
    end
    if isfinite(errQ)
        eqstr = sprintf('%5.1f%%', errQ);
    else
        eqstr = '   N/A';
    end
    if isfinite(errK)
        ekstr = sprintf('%5.1f%%', errK);
    else
        ekstr = '   N/A';
    end
    fprintf('%-22s  %s %10.2f  %s %10.4f  %s %s\n', ...
        M(k).name, qstr, res.Qmax, kstr, res.Kaff, eqstr, ekstr);
end
fprintf('\n');

%% =====================================================================
%  FIGURE 1: 2x4 panel -- all models + error summary
%  =====================================================================

fig1 = figure('Name','V4 Models','Color','w','Position',[30 30 1600 800]);

for k = 1:nModels
    subplot(2, 4, k);
    Ce = results(k).Ce;
    q_t = results(k).q_true;
    q_n = results(k).q_noisy;
    res = results(k).res;

    Ce_fine = logspace(log10(min(Ce)), log10(max(Ce)), 300)';

    % Effective Langmuir reconstruction
    if res.Kp > 0
        q_recon = res.Kp * Ce_fine ...
                + res.Qmax * res.Kaff * Ce_fine ./ (1 + res.Kaff * Ce_fine);
    else
        q_recon = res.Qmax * res.Kaff * Ce_fine ./ (1 + res.Kaff * Ce_fine);
    end

    hold on; box on;
    loglog(Ce, q_t, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 2);
    loglog(Ce, q_n, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
    loglog(Ce_fine, q_recon, 'r--', 'LineWidth', 1.5);
    if isfinite(res.Qmax) && res.Qmax > 0 && res.Qmax < max(q_n)*5
        yline(res.Qmax, 'g-', 'LineWidth', 1.2);
    end
    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel('$C_e$', 'Interpreter', 'latex', 'FontSize', 10);
    ylabel('$q_e$', 'Interpreter', 'latex', 'FontSize', 10);
    title(M(k).name, 'Interpreter', 'latex', 'FontSize', 11);
    set(gca, 'FontSize', 9, 'TickLabelInterpreter', 'latex');
    ylim([max(min(q_n)*0.3, 1e-3), max(q_n)*3]);
    hold off;
end

% Panel 8: error summary bar chart
subplot(2, 4, 8);
% Only models with finite invariants
fin_idx = [];
fin_names = {};
errQ_vec = [];
errK_vec = [];
for k = 1:nModels
    if isfinite(results(k).errQ) && isfinite(results(k).errK)
        fin_idx(end+1) = k; %#ok
        fin_names{end+1} = M(k).name; %#ok
        errQ_vec(end+1) = results(k).errQ; %#ok
        errK_vec(end+1) = results(k).errK; %#ok
    end
end
nfin = length(fin_idx);
x = 1:nfin;
bar(x, [errQ_vec(:), errK_vec(:)], 'grouped');
set(gca, 'XTick', x, 'XTickLabel', fin_names, ...
    'XTickLabelRotation', 35, 'FontSize', 8, ...
    'TickLabelInterpreter', 'latex');
ylabel('Relative error (\%)', 'Interpreter', 'latex', 'FontSize', 10);
title('Estimation errors', 'Interpreter', 'latex', 'FontSize', 11);
legend({'$Q_{\max}$', '$K_{\mathrm{aff}}$'}, ...
    'Interpreter', 'latex', 'FontSize', 9, 'Location', 'northwest');
box on;

exportgraphics(fig1, fullfile(fig_dir, 'fig_v4_models.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_v4_models.pdf\n');

%% =====================================================================
%  FIGURE 2: Convergence with decreasing noise
%  =====================================================================

noise_levels = [0.20, 0.10, 0.05, 0.02, 0.01];
nNoise = length(noise_levels);
nMC = 20;  % Monte Carlo realisations per noise level

% Only test models with finite invariants
test_models = fin_idx;
nTest = length(test_models);

errQ_all = zeros(nNoise, nTest, nMC);
errK_all = zeros(nNoise, nTest, nMC);

fprintf('Running convergence study (%d noise levels x %d models x %d MC)...\n', ...
    nNoise, nTest, nMC);

ws1 = warning('off', 'MATLAB:singularMatrix');
ws2 = warning('off', 'MATLAB:nearlySingularMatrix');
ws3 = warning('off', 'MATLAB:illConditionedMatrix');

for in = 1:nNoise
    nl = noise_levels(in);
    for im = 1:nTest
        k = test_models(im);
        q_true_k = M(k).q_fn(Ce_base);
        sig_k = max(nl * q_true_k, 1e-6);
        for mc = 1:nMC
            q_mc = max(q_true_k + nl * q_true_k .* randn(size(q_true_k)), 0);
            try
                res_mc = universal_route_v4(Ce_base, q_mc, sig_k);
                errQ_all(in, im, mc) = abs(res_mc.Qmax - M(k).Qmax) ...
                                     / M(k).Qmax;
                errK_all(in, im, mc) = abs(res_mc.Kaff - M(k).Kaff) ...
                                     / M(k).Kaff;
            catch
                errQ_all(in, im, mc) = NaN;
                errK_all(in, im, mc) = NaN;
            end
        end
    end
    fprintf('  Noise = %.0f%% done.\n', nl*100);
end

warning(ws1); warning(ws2); warning(ws3);

% Compute medians and IQR
errQ_med = squeeze(median(errQ_all, 3, 'omitnan'));
errK_med = squeeze(median(errK_all, 3, 'omitnan'));
errQ_q25 = squeeze(prctile(errQ_all, 25, 3));
errQ_q75 = squeeze(prctile(errQ_all, 75, 3));
errK_q25 = squeeze(prctile(errK_all, 25, 3));
errK_q75 = squeeze(prctile(errK_all, 75, 3));

fig2 = figure('Name','Convergence','Color','w','Position',[50 50 1200 450]);
colors = lines(nTest);
markers = {'o','s','d','^','v'};

% Left: Qmax
subplot(1,2,1); hold on; box on;
for im = 1:nTest
    mk = markers{mod(im-1,5)+1};
    errorbar(noise_levels*100, errQ_med(:,im)*100, ...
        (errQ_med(:,im) - errQ_q25(:,im))*100, ...
        (errQ_q75(:,im) - errQ_med(:,im))*100, ...
        ['-' mk], 'Color', colors(im,:), 'LineWidth', 1.5, ...
        'MarkerSize', 7, 'MarkerFaceColor', colors(im,:), ...
        'DisplayName', fin_names{im});
end
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Noise level (\%)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Relative error in $\widehat{Q}_{\max}$ (\%)', ...
    'Interpreter', 'latex', 'FontSize', 12);
title('$Q_{\max}$ convergence', 'Interpreter', 'latex', 'FontSize', 13);
legend('Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 9);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

% Right: Kaff
subplot(1,2,2); hold on; box on;
for im = 1:nTest
    mk = markers{mod(im-1,5)+1};
    errorbar(noise_levels*100, errK_med(:,im)*100, ...
        (errK_med(:,im) - errK_q25(:,im))*100, ...
        (errK_q75(:,im) - errK_med(:,im))*100, ...
        ['-' mk], 'Color', colors(im,:), 'LineWidth', 1.5, ...
        'MarkerSize', 7, 'MarkerFaceColor', colors(im,:), ...
        'DisplayName', fin_names{im});
end
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Noise level (\%)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Relative error in $\widehat{K}_{\mathrm{aff}}$ (\%)', ...
    'Interpreter', 'latex', 'FontSize', 12);
title('$K_{\mathrm{aff}}$ convergence', 'Interpreter', 'latex', 'FontSize', 13);
legend('Interpreter', 'latex', 'Location', 'best', 'FontSize', 9);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

exportgraphics(fig2, fullfile(fig_dir, 'fig_v4_convergence.pdf'), ...
    'ContentType', 'vector', 'Resolution', 300);
fprintf('Saved: fig_v4_convergence.pdf\n');

fprintf('\nDone. Two figures saved as PDF.\n');

%% =====================================================================
%  FUNCTION: universal_route_v4  (same as universal_route_corrected)
%  =====================================================================
function res = universal_route_v4(Ce, q, sigma)
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
            if t_lnC > t_crit_plat, break; end
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
        end
        Kp = 0;
    else
        n_ext = min(10, max(5, floor(N/3)));
        I_ext = (N-n_ext+1):N;
        X_lin = [ones(n_ext,1), Ce(I_ext)];
        W_lin = diag(w(I_ext));
        beta_lin = pinv(X_lin' * W_lin * X_lin) * (X_lin' * W_lin * q(I_ext));
        Kp = max(beta_lin(2), 0);
        Qmax = max(beta_lin(1), 0);
        for iter = 1:30
            q_sat = q - Kp * Ce;
            X_e = [ones(n_ext,1), 1./Ce(I_ext)];
            W_e = diag(w(I_ext));
            beta_e = pinv(X_e' * W_e * X_e) * (X_e' * W_e * q_sat(I_ext));
            Qmax_new = max(beta_e(1), 0);
            q_resid = q(I_high) - Qmax_new;
            Kp_new = sum(w(I_high) .* Ce(I_high) .* q_resid) ...
                   / sum(w(I_high) .* Ce(I_high).^2);
            Kp_new = max(Kp_new, 0);
            dKp = abs(Kp_new - Kp) / max(abs(Kp), 1e-10);
            dQmax = abs(Qmax_new - Qmax) / max(abs(Qmax), 1e-10);
            Kp = Kp_new; Qmax = Qmax_new;
            if max(dKp, dQmax) < 1e-4, break; end
        end
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
            if t_lnC > t_crit_plat, break; end
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
    res.use_partition = use_partition;
    res.KH_sensitivity = relative_change;
end

%% =====================================================================
%  HELPER: t_critical_975
%  =====================================================================
function tc = t_critical_975(df)
    df_tab = [1 2 3 4 5 6 7 8 9 10 12 15 20 25 30 40 60 120 1e6];
    tc_tab = [12.706 4.303 3.182 2.776 2.571 2.447 2.365 2.306 2.262 ...
              2.228  2.179 2.131 2.086 2.060 2.042 2.021 2.000 1.980 1.960];
    if df >= 1e6, tc = 1.960;
    elseif df <= 1, tc = 12.706;
    else, tc = interp1(df_tab, tc_tab, df, 'linear', 1.960);
    end
end

%% =====================================================================
%  HELPER: f_critical_95 (df1=1 only)
%  =====================================================================
function fc = f_critical_95(~, df2)
    df2_tab = [1 2 3 4 5 6 7 8 9 10 12 15 20 25 30 40 60 120 1e6];
    fc_tab  = [161.4 18.51 10.13 7.709 6.608 5.987 5.591 5.318 5.117 ...
               4.965 4.747 4.543 4.351 4.242 4.171 4.085 4.001 3.920 3.841];
    if df2 >= 1e6, fc = 3.841;
    elseif df2 <= 1, fc = 161.4;
    else, fc = interp1(df2_tab, fc_tab, df2, 'linear', 3.841);
    end
end

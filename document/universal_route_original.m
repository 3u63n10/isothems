%% universal_route_original.m
%  Implementation of the ORIGINAL method from Universal_route.tex
%  "A Universal Route to Q_max and K_aff for PFAS Adsorption in Solids"
%
%  This script implements the 4-step workflow as described in the original
%  manuscript, plus the optional NNLS distribution universal-recovery.
%
%  It generates synthetic data from known models and demonstrates the
%  extraction of Q_max and K_aff.

clear; close all; clc;

%% =====================================================================
%  Section 1: Generate synthetic data from known models
%  =====================================================================

% --- Model A: Single Langmuir ---
Qmax_true_A = 100;           % mg/g
KL_true_A   = 0.5;           % L/mg
Ce_A = logspace(-2, 2, 30)';
q_true_A = Qmax_true_A * KL_true_A * Ce_A ./ (1 + KL_true_A * Ce_A);

% --- Model B: Sips (Langmuir-Freundlich) ---
Qmax_true_B = 80;            % mg/g
Ks_true_B   = 0.3;           % (L/mg)^m
m_true_B    = 0.7;           % heterogeneity index
Ce_B = logspace(-2, 2, 30)';
q_true_B = Qmax_true_B * (Ks_true_B * Ce_B).^m_true_B ...
           ./ (1 + (Ks_true_B * Ce_B).^m_true_B);

% --- Model C: Partition + Langmuir (PFAS-like) ---
Qmax_true_C = 50;            % mg/g
KL_true_C   = 1.0;           % L/mg
Kp_true_C   = 2.0;           % L/g  (partition coefficient)
Ce_C = logspace(-2, 2, 30)';
q_true_C = Kp_true_C * Ce_C ...
         + Qmax_true_C * KL_true_C * Ce_C ./ (1 + KL_true_C * Ce_C);

% Add noise (5% relative)
rng(42);
noise_level = 0.05;
sigma_A = noise_level * q_true_A;
sigma_B = noise_level * q_true_B;
sigma_C = noise_level * q_true_C;
q_A = q_true_A + sigma_A .* randn(size(q_true_A));
q_B = q_true_B + sigma_B .* randn(size(q_true_B));
q_C = q_true_C + sigma_C .* randn(size(q_true_C));
q_A = max(q_A, 0);
q_B = max(q_B, 0);
q_C = max(q_C, 0);

%% =====================================================================
%  Section 2: The original workflow (function defined below)
%  =====================================================================

fprintf('============================================================\n');
fprintf(' ORIGINAL METHOD (Universal_route.tex)\n');
fprintf('============================================================\n\n');

% --- Model A ---
[Qmax_A, KH_A, Kaff_A, Kp_A] = universal_route_original(Ce_A, q_A, sigma_A);
fprintf('Model A (Langmuir, true Qmax=%.1f, true K=%.3f):\n', Qmax_true_A, KL_true_A);
fprintf('  Qmax = %.2f,  KH = %.4f,  Kaff = %.4f,  Kp = %.4f\n', Qmax_A, KH_A, Kaff_A, Kp_A);
fprintf('  True Kaff (=KL) = %.4f\n\n', KL_true_A);

% --- Model B ---
[Qmax_B, KH_B, Kaff_B, Kp_B] = universal_route_original(Ce_B, q_B, sigma_B);
fprintf('Model B (Sips, true Qmax=%.1f, m=%.1f):\n', Qmax_true_B, m_true_B);
fprintf('  Qmax = %.2f,  KH = %.4f,  Kaff = %.4f,  Kp = %.4f\n', Qmax_B, KH_B, Kaff_B, Kp_B);
fprintf('  Note: for Sips with m<1, K_H diverges in the thermodynamic limit.\n');
fprintf('  The operational Kaff depends on the low-C window.\n\n');

% --- Model C ---
[Qmax_C, KH_C, Kaff_C, Kp_C] = universal_route_original(Ce_C, q_C, sigma_C);
fprintf('Model C (Partition+Langmuir, true Qmax=%.1f, true KL=%.3f, true Kp=%.3f):\n', ...
    Qmax_true_C, KL_true_C, Kp_true_C);
fprintf('  Qmax = %.2f,  KH = %.4f,  Kaff = %.4f,  Kp = %.4f\n\n', Qmax_C, KH_C, Kaff_C, Kp_C);

%% =====================================================================
%  Section 3: Optional NNLS distribution recovery
%  =====================================================================

fprintf('--- NNLS Distribution Recovery (Model A) ---\n');
[Qmax_nnls, KH_nnls, Kaff_nnls, Kj, qmj] = nnls_distribution(Ce_A, q_A, sigma_A, 0);
fprintf('  Qmax(NNLS) = %.2f,  KH(NNLS) = %.4f,  Kaff(NNLS) = %.4f\n\n', ...
    Qmax_nnls, KH_nnls, Kaff_nnls);

%% =====================================================================
%  Section 4: Plots
%  =====================================================================

figure('Name','Original Method Results','Color','w','Position',[100 100 1200 400]);

% --- Panel 1: Model A ---
subplot(1,3,1);
loglog(Ce_A, q_true_A, 'b-', 'LineWidth', 1.5); hold on;
loglog(Ce_A, q_A, 'ko', 'MarkerSize', 5);
yline(Qmax_A, 'r--', 'LineWidth', 1.2);
xlabel('$C_e$ (mg/L)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$q_e$ (mg/g)', 'Interpreter', 'latex', 'FontSize', 12);
title('Model A: Langmuir', 'Interpreter', 'latex', 'FontSize', 13);
legend({'True', 'Data', sprintf('$\\hat{Q}_{\\max}=%.1f$', Qmax_A)}, ...
    'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 10);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

% --- Panel 2: Model B ---
subplot(1,3,2);
loglog(Ce_B, q_true_B, 'b-', 'LineWidth', 1.5); hold on;
loglog(Ce_B, q_B, 'ko', 'MarkerSize', 5);
yline(Qmax_B, 'r--', 'LineWidth', 1.2);
xlabel('$C_e$ (mg/L)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$q_e$ (mg/g)', 'Interpreter', 'latex', 'FontSize', 12);
title('Model B: Sips', 'Interpreter', 'latex', 'FontSize', 13);
legend({'True', 'Data', sprintf('$\\hat{Q}_{\\max}=%.1f$', Qmax_B)}, ...
    'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 10);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

% --- Panel 3: Model C ---
subplot(1,3,3);
loglog(Ce_C, q_true_C, 'b-', 'LineWidth', 1.5); hold on;
loglog(Ce_C, q_C, 'ko', 'MarkerSize', 5);
plot(Ce_C, Kp_C * Ce_C + Qmax_C, 'r--', 'LineWidth', 1.2);
xlabel('$C_e$ (mg/L)', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$q_e$ (mg/g)', 'Interpreter', 'latex', 'FontSize', 12);
title('Model C: Partition+Langmuir', 'Interpreter', 'latex', 'FontSize', 13);
legend({'True', 'Data', sprintf('$K_p=%.2f$, $Q_{\\max}=%.1f$', Kp_C, Qmax_C)}, ...
    'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 10);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

% --- Figure 2: NNLS distribution ---
figure('Name','NNLS Distribution (Model A)','Color','w','Position',[100 550 560 420]);
bar(log10(Kj), qmj, 1, 'FaceColor', [0.3 0.5 0.8], 'EdgeColor', 'none');
hold on;
xline(log10(KL_true_A), 'r--', 'LineWidth', 2);
xlabel('$\log_{10} K$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$q_{m,j}$ (mg/g)', 'Interpreter', 'latex', 'FontSize', 12);
title('NNLS Distribution Recovery (Model A)', 'Interpreter', 'latex', 'FontSize', 13);
legend({'Recovered $\rho(K)$', sprintf('True $K_L=%.1f$', KL_true_A)}, ...
    'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 10);
set(gca, 'FontSize', 10, 'TickLabelInterpreter', 'latex');
hold off;

fprintf('Done. Figures generated.\n');

%% =====================================================================
%  FUNCTION: universal_route_original
%  Implements the original manuscript workflow (Steps 0-4)
%  =====================================================================
function [Qmax, KH, Kaff, Kp] = universal_route_original(Ce, q, sigma)
    % Inputs:
    %   Ce    - equilibrium concentrations (column vector)
    %   q     - equilibrium uptake (column vector)
    %   sigma - uncertainties (column vector)
    % Outputs:
    %   Qmax  - estimated saturation capacity
    %   KH    - estimated Henry constant (saturating fraction)
    %   Kaff  - effective affinity constant = KH/Qmax
    %   Kp    - partition coefficient (0 if not needed)

    Ce = Ce(:); q = q(:); sigma = sigma(:);
    w = 1 ./ sigma.^2;
    N = length(Ce);

    % Sort by concentration
    [Ce, idx] = sort(Ce);
    q = q(idx);
    w = w(idx);

    % --- Step 1: Decide partition ---
    m_high = min(5, floor(N/3));
    I_high = (N-m_high+1):N;
    % Fit q = beta0 + beta1*C over I_high
    X_h = [ones(m_high,1), Ce(I_high)];
    W_h = diag(w(I_high));
    beta_h = (X_h' * W_h * X_h) \ (X_h' * W_h * q(I_high));
    % t-test for slope
    resid_h = q(I_high) - X_h * beta_h;
    s2_h = sum(w(I_high) .* resid_h.^2) / (m_high - 2);
    cov_h = s2_h * inv(X_h' * W_h * X_h);  %#ok
    t_slope = beta_h(2) / sqrt(cov_h(2,2));

    if t_slope > 2.0  % approximate t-critical
        use_partition = true;
    else
        use_partition = false;
    end

    % --- Step 2: Estimate Qmax ---
    if ~use_partition
        % Case A: Try plateau average
        % Find plateau region: last m points where slope of q vs ln(C) ~ 0
        m_plateau = 3;
        for m_try = 4:min(N-2, floor(N/2))
            I_try = (N-m_try+1):N;
            X_t = [ones(m_try,1), log(Ce(I_try))];
            W_t = diag(w(I_try));
            beta_t = (X_t' * W_t * X_t) \ (X_t' * W_t * q(I_try));
            resid_t = q(I_try) - X_t * beta_t;
            s2_t = sum(w(I_try) .* resid_t.^2) / (m_try - 2);
            cov_t = s2_t * inv(X_t' * W_t * X_t);  %#ok
            t_lnC = abs(beta_t(2)) / sqrt(cov_t(2,2));
            if t_lnC > 2.0
                break;
            end
            m_plateau = m_try;
        end
        I_plat = (N-m_plateau+1):N;

        % Check if plateau is good or need 1/C extrapolation
        if m_plateau >= 3
            % Plateau average
            Qmax = sum(w(I_plat) .* q(I_plat)) / sum(w(I_plat));
        else
            % Case B: 1/C extrapolation
            I_ext = (N-4):N;
            X_e = [ones(length(I_ext),1), 1./Ce(I_ext)];
            W_e = diag(w(I_ext));
            beta_e = (X_e' * W_e * X_e) \ (X_e' * W_e * q(I_ext));
            Qmax = beta_e(1);
        end
        Kp = 0;
    else
        % Partition case: first rough Qmax from 1/C extrapolation
        % ignoring partition (will iterate)
        I_ext = (N-4):N;
        X_e = [ones(length(I_ext),1), 1./Ce(I_ext)];
        W_e = diag(w(I_ext));
        beta_e = (X_e' * W_e * X_e) \ (X_e' * W_e * q(I_ext));
        Qmax = beta_e(1);

        % Iterate Steps 2-3
        Kp = 0;
        for iter = 1:10
            % Estimate Kp
            q_high = q(I_high) - Qmax;
            Kp_new = sum(w(I_high) .* Ce(I_high) .* q_high) ...
                   / sum(w(I_high) .* Ce(I_high).^2);
            Kp_new = max(Kp_new, 0);

            % Subtract partition and re-estimate Qmax
            q_sat = q - Kp_new * Ce;
            q_sat_high = q_sat(I_ext);
            X_e2 = [ones(length(I_ext),1), 1./Ce(I_ext)];
            W_e2 = diag(w(I_ext));
            beta_e2 = (X_e2' * W_e2 * X_e2) \ (X_e2' * W_e2 * q_sat_high);
            Qmax_new = max(beta_e2(1), 0);

            if abs(Kp_new - Kp) < 1e-4 * max(Kp, 1e-10)
                Kp = Kp_new;
                Qmax = Qmax_new;
                break;
            end
            Kp = Kp_new;
            Qmax = Qmax_new;
        end
    end

    % --- Step 3: Estimate KH ---
    % Use lowest points where curvature is negligible
    m_henry = 3;
    for m_try = 3:min(N-2, floor(N/2))
        I_try = 1:m_try;
        if use_partition
            q_henry = q(I_try) - Kp * Ce(I_try);
        else
            q_henry = q(I_try);
        end
        % WLS: q = KH * C (no intercept)
        KH_try = sum(w(I_try) .* Ce(I_try) .* q_henry) ...
               / sum(w(I_try) .* Ce(I_try).^2);
        resid_lin = q_henry - KH_try * Ce(I_try);
        if m_try >= 4
            SSE_lin = sum(w(I_try) .* resid_lin.^2);
            % Quadratic: q = KH*C + alpha*C^2
            X_q = [Ce(I_try), Ce(I_try).^2];
            W_q = diag(w(I_try));
            beta_q = (X_q' * W_q * X_q) \ (X_q' * W_q * q_henry);
            resid_quad = q_henry - X_q * beta_q;
            SSE_quad = sum(w(I_try) .* resid_quad.^2);
            F_stat = (SSE_lin - SSE_quad) / (SSE_quad / (m_try - 2));
            if F_stat > 4.0  % approximate F-critical
                break;
            end
        end
        m_henry = m_try;
    end

    I_henry = 1:m_henry;
    if use_partition
        q_h = q(I_henry) - Kp * Ce(I_henry);
    else
        q_h = q(I_henry);
    end
    KH = sum(w(I_henry) .* Ce(I_henry) .* q_h) ...
       / sum(w(I_henry) .* Ce(I_henry).^2);
    KH = max(KH, 0);

    % --- Step 4: Compute Kaff ---
    Kaff = KH / max(Qmax, 1e-10);
end

%% =====================================================================
%  FUNCTION: nnls_distribution
%  Optional NNLS-based distribution recovery (Section 5 of manuscript)
%  =====================================================================
function [Qmax, KH, Kaff, Kj, qmj] = nnls_distribution(Ce, q, sigma, Kp_fixed)
    Ce = Ce(:); q = q(:); sigma = sigma(:);
    w = 1 ./ sigma.^2;
    N = length(Ce);

    % Log grid of affinities
    M = 50;
    Kmin = 0.1 / max(Ce);
    Kmax = 10  / min(Ce);
    Kj = logspace(log10(Kmin), log10(Kmax), M)';

    % Kernel matrix
    A = zeros(N, M);
    for j = 1:M
        A(:,j) = Kj(j) * Ce ./ (1 + Kj(j) * Ce);
    end

    % Subtract partition contribution
    q_sat = q - Kp_fixed * Ce;

    % Weight the system
    W_half = diag(sqrt(w));
    A_w = W_half * A;
    q_w = W_half * q_sat;

    % Simple NNLS (no regularization in original manuscript beyond
    % the basic nonneg constraint)
    qmj = lsqnonneg(A_w, q_w);

    % Recover invariants
    Qmax = sum(qmj);
    KH   = sum(Kj .* qmj);
    Kaff = KH / max(Qmax, 1e-10);
end

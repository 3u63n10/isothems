% plot_sips_energy.m
% 
% Generates and plots the Sips site energy distribution for various
% heterogeneity parameters 'n'. This script demonstrates how surface
% heterogeneity changes with the Sips exponent.

clear; clc; close all;

% --- Configuration ---
save_plot = true; % Set to true to save the plot, false otherwise
output_filename = 'sips_energy_distribution.png';

% --- Constants and Parameters ---
R = 8.314e-3;  % Universal gas constant in kJ mol^-1 K^-1
T = 298.15;    % Temperature in K

% Energy range for the plot (kJ/mol)
E_min = 0;
E_max = 25;
nE = 500;
E = linspace(E_min, E_max, nE); % Vector of energies

% Sips model parameters to compare
% E_m: Mean adsorption energy (kJ/mol)
% n: Heterogeneity parameter (0 < n <= 1). n=1 corresponds to a
%    homogeneous surface (Langmuir model).
E_m = 12.0;
n_list = [0.9, 0.8, 0.7, 0.6, 0.5, 0.4];

% --- Plotting Setup ---
figure('Position', [100, 100, 800, 600]); % Create a new figure window
hold on; % Hold the plot to overlay multiple lines
colors = RGB_interp(length(n_list),1); % Get colors from the 'viridis' colormap

% --- Calculation and Plotting Loop ---
for i = 1:length(n_list)
    n = n_list(i);

    % The Sips isotherm corresponds to a quasi-lognormal energy distribution.
    % f(E) = C / (cosh(n*(E-E_m)/(R*T)) + cos(n*pi))
    % where C is a normalization constant.
    % As n -> 1, the distribution sharpens into a Dirac delta function at E_m.

    % Calculate the distribution (element-wise for the vector E)
    x = n * (E - E_m) / (R * T);
    numerator = sin(n * pi) / (pi * R * T);
    denominator = cosh(x) + cos(n * pi);
    
    fE = numerator ./ denominator;

    % Normalize the distribution so that the area under the curve is 1
    area = trapz(E, fE);
    if area > 0
        fE_normalized = fE / area;
    else
        fE_normalized = fE;
    end

    % Plotting
    plot(E, fE_normalized, 'LineWidth', 2, 'Color', colors(i,:),...
         'DisplayName', sprintf('n = %.1f', n));
end

% --- Final Plot Adjustments ---
hold off; % Release the plot hold
xlabel('Adsorption Energy E (kJ mol^{-1})');
ylabel('Site Energy Distribution f(E)');
title(sprintf('Sips Site Energy Distribution at T = %.2f K', T));
legend('show', 'Location', 'best');
grid on;
box on;
xlim([E_min, E_max]);
ylim([0, inf]); % Set bottom y-limit to 0

% --- Save Plot ---
if save_plot
    saveas(gcf, output_filename);
    fprintf('Plot saved as %s\n', output_filename);
end

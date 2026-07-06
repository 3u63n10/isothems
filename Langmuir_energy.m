% plot_energy_distribution_examples.m
% Ejemplo de distribuciones de energia f(E;T) a diferentes temperaturas
% a partir de una distribucion lognormal en K_L.


clear; clc;

print = 1;


% Constantes y rangos
R  = 8.314e-3;         % kJ mol^-1 K^-1
C0 = 1.0;              % mol L^-1 (concentracion estandar)

% Rango de energias (kJ/mol)
E_min = 0;
E_max = 10;
nE    = 500;
E     = linspace(E_min, E_max, nE);  % vector de energias

% Temperaturas a comparar (K)
T_list = 30:20:300;

% Distribucion en K_L: lognormal g(K_L)
% g(K_L) = 1 / (K_L * sigma * sqrt(2*pi)) * exp( - (ln K_L - mu)^2 / (2 sigma^2) )
% Ajusta mu_lnK y sigma_lnK para cambiar la heterogeneidad

mu_lnK    = 2.0;   % promedio de ln(K_L)
sigma_lnK = 1.0;   % desviacion estandar de ln(K_L)

g_logK = @(K) (1 ./ (K * sigma_lnK * sqrt(2*pi))) .* ...
              exp( - (log(K) - mu_lnK).^2 ./ (2 * sigma_lnK^2) );

% Calculo de f(E;T) por cambio de variable
% E = R T ln(K_L C0)
% K_L(E,T) = (1/C0) * exp(E / (R T))
% dK_L/dE = K_L(E,T) / (R T)
% f(E;T) = g(K_L(E,T)) * dK_L/dE

Farbe = flipud(RGB_interp(length(T_list),1));

figure;
hold on;

for iT = 1:numel(T_list)
    T = T_list(iT);

    % K_L como funcion de E y T
    K = (1./C0) .* exp(E ./ (R * T));

    % Distribucion en K_L
    gK = g_logK(K);

    % Jacobiano dK_L/dE
    dK_dE = K ./ (R * T);

    % Distribucion de energias f(E;T)
    fE = gK .* dK_dE;

    % Normalizacion numerica para que el area sea 1
    area_f = trapz(E, fE);
    if area_f > 0
        fE = fE ./ area_f;
    end

    % Graficar
    plot(E, fE, 'LineWidth', 1.5,'Color',Farbe(iT,:));
    
end

hold off;
xlabel('E (kJ mol^{-1})');
ylabel('f(E;T) (a.u.)');
legend(arrayfun(@(T) sprintf('T = %d K', T), T_list, 'UniformOutput', false), ...
       'Location', 'best');
title('Energy distributions f(E;T) from a lognormal distribution in K_L');

if print
    saveas(gcf,'Langmuir_energy.jpg')
end
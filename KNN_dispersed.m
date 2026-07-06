% KNN visualization with more dispersed groups (export JPG/PNG)
% Same style/colors as KNN.m, but with more points and stronger separation.

% --- Setup ---
close all; clear; clc;

% --- Data (synthetic, more points and dispersion) ---
classA = [7.2 1.1; 8.0 1.6; 8.6 2.1; 7.6 2.8; 8.8 1.4; 7.9 2.2; 8.3 2.6; 7.4 1.3; 8.7 1.9; 7.1 2.0];
classB = [1.0 5.7; 2.0 6.4; 2.7 5.0; 1.5 4.6; 3.2 6.1; 2.2 4.8; 2.9 5.6; 1.6 5.2; 2.4 6.6; 1.2 5.9];
classC = [3.8 3.6; 4.6 4.4; 5.3 3.1; 4.2 4.9; 5.8 3.8; 3.5 3.4; 4.9 4.1; 4.1 3.9; 5.2 4.6; 3.9 4.2];
query  = [4.9 3.7];

% --- Plot ---
fig = figure('Color','w');
ax = axes(fig); hold(ax,'on');
axis(ax,[0 9.5 0 7.0]);
axis(ax,'equal');
box(ax,'off');
ax.TickDir = 'out';
ax.FontSize = 11;

% Points
scatter(classA(:,1), classA(:,2), 60, 'o', 'filled', 'MarkerFaceColor',[0.2 0.45 0.85], 'MarkerEdgeColor',[0.15 0.35 0.65]);
scatter(classB(:,1), classB(:,2), 60, 's', 'filled', 'MarkerFaceColor',[0.85 0.25 0.25], 'MarkerEdgeColor',[0.65 0.2 0.2]);
scatter(classC(:,1), classC(:,2), 70, '^', 'filled', 'MarkerFaceColor',[0.2 0.7 0.35], 'MarkerEdgeColor',[0.15 0.5 0.25]);
scatter(query(1), query(2), 120, 'p', 'filled', 'MarkerFaceColor',[0.95 0.8 0.1], 'MarkerEdgeColor','k');

% KNN circle (k = 5)
viscircles(query, 1.5, 'LineStyle','--', 'Color',[0.1 0.1 0.1]);
text(6.1, 4.8, 'k = 5 neighborhood', 'FontSize', 10);

% Dotted lines to nearest neighbors (illustrative)
neighbors = [4.6 4.4; 5.3 3.1; 5.8 3.8; 4.1 3.9; 4.2 4.9];
for i=1:size(neighbors,1)
    plot([query(1) neighbors(i,1)], [query(2) neighbors(i,2)], ':', 'Color',[0.3 0.3 0.3]);
end

% Axes labels
xlabel('Q_{max} (mg g^{-1})');
ylabel('ln K_{aff}^*');

% Legend-like annotations (keep, user will move if needed)
text(0.6, 0.35, 'High Q_{max}, low K_{aff}^*', 'FontSize', 9, 'Color',[0.2 0.45 0.85]);
text(3.2, 0.35, 'Low Q_{max}, high K_{aff}^*', 'FontSize', 9, 'Color',[0.85 0.25 0.25]);
text(6.6, 0.35, 'Moderate', 'FontSize', 9, 'Color',[0.2 0.7 0.35]);
text(0.6, 0.75, 'Query', 'FontSize', 9, 'Color',[0.3 0.3 0.3]);

% Tight layout
ax.Position = [0.12 0.12 0.82 0.82];

% --- Export ---
exportgraphics(fig, 'KNN_dispersed.png', 'Resolution', 300);
exportgraphics(fig, 'KNN_dispersed.jpg', 'Resolution', 300);


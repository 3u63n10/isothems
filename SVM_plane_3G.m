load fisheriris
load SVM_3G_3D.mat

X = meas(:,1:3);
Y = species;

% t = templateSVM('KernelFunction','rbf','Standardize',true);
% Mdl = fitcecoc(X, Y, 'Learners', t);

% --- Recuperar mu y sigma ---

% mu = []; sigma = [];
% for k = 1:numel(Mdl.BinaryLearners)
%     bl = Mdl.BinaryLearners{k};
%     if ~isempty(bl) && ~isempty(bl.SupportVectors)
%         mu    = bl.Mu;
%         sigma = bl.Sigma;
%         break
%     end
% end

% --- Des-estandarizar SVs ---

% SV_std = [];
% for k = 1:numel(Mdl.BinaryLearners)
%     bl = Mdl.BinaryLearners{k};
%     if ~isempty(bl) && ~isempty(bl.SupportVectors)
%         SV_std = [SV_std; bl.SupportVectors];
%     end
% end
% SV_std = unique(SV_std, 'rows');
% SV_raw = SV_std .* sigma + mu;

% --- Mapear a puntos reales de X por vecino más cercano ---
% knnsearch devuelve el índice del punto más cercano en X para cada SV

% idx_sv = knnsearch(X, SV_raw);       % índices en X
% SV = X(idx_sv, :);                   % coordenadas exactas del dataset
% SV = unique(SV, 'rows');

% --- Figura ---
figure; set(gcf,'Visible','on')

classNames = unique(Y);
colors = RGB_interp(7,7);
hData = gobjects(3,1);
for i = 1:3
    idx = strcmp(Y, classNames{i});
    hData(i) = scatter3(X(idx,1), X(idx,2), X(idx,3), 40, colors(i,:), 'filled');
    hold on
end

% xlabel('Sepal length'); ylabel('Sepal width'); zlabel('Petal length')
grid on; box on

% Support vectors — círculo negro sobre el punto del dataset
hSV = plot3(SV(:,1), SV(:,2), SV(:,3), ...
    'ko', 'MarkerSize', 8, 'LineWidth', 1);

% --- Fronteras (isosurface) ---
numGrid = 50;
[x1G,x2G,x3G] = meshgrid( ...
    linspace(min(X(:,1)), max(X(:,1)), numGrid), ...
    linspace(min(X(:,2)), max(X(:,2)), numGrid), ...
    linspace(min(X(:,3)), max(X(:,3)), numGrid));
xList   = [x1G(:), x2G(:), x3G(:)];
% predLbl = predict(Mdl, xList);

% predNum = zeros(size(predLbl,1),1);
% for i = 1:numel(classNames)
%     predNum(strcmp(predLbl, classNames{i})) = i;
% end
% predNumGrid = reshape(predNum, size(x1G));

% [f1,v1] = isosurface(x1G,x2G,x3G, predNumGrid, 1.5);
% [f2,v2] = isosurface(x1G,x2G,x3G, predNumGrid, 2.5);

hB1 = patch('Vertices',v1,'Faces',f1, ...
    'FaceColor',[0.9 0.3 0.3],'EdgeColor','none','FaceAlpha',0.18);
hB2 = patch('Vertices',v2,'Faces',f2, ...
    'FaceColor',[0.3 0.4 0.9],'EdgeColor','none','FaceAlpha',0.18);

view(-45, -10)   % equivalente explícito
lighting gouraud; material dull

set(gca,'YTickLabel',[],'XTickLabel',[],'ZTickLabel',[],'FontSize',14);

classNames = {'Group1';'Group2';'Group3'};

xlabel('Q_{max}');
ylabel('ln K^*_{aff}');
    zlabel('\sigma_E')

legend([hData; hSV; hB1; hB2], ...
    [classNames; {'Support vectors'}; {'Boundary 1-2'}; {'Boundary 2-3'}], ...
    'Location','best', 'NumColumns',2)
set(gca,'YTickLabel',[],'XTickLabel',[],'ZTickLabel',[],'FontSize',14);
% legend boxoff
grid off
grid on; box on
% title('SVM multiclase – Fisher Iris (RBF, ECOC)')

ax = gca;
ax.Box = 'off';           % quita la caja
ax.BoxStyle = 'full';     % solo las 3 líneas del fondo

    saveas(gcf,'SVM_3D.jpg')
    saveas(gcf,'SVM_3D.png')
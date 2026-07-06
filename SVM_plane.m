load fisheriris 
load SVM_3D.mat



classPick = ~strcmp(species,'virginica'); % the row of not-virginica has a value 1. 
X = meas(classPick,1:3);% extract the parameters of iris and versicolor
Y = species(classPick);% extract the label information
% SVMModel = fitcsvm(X,Y,'KernelFunction','rbf', ...
%     'Solver','SMO');% conduct the training of SVM
% SupportVector = SVMModel.SupportVectors;
figure
set(gcf,'Visible','on')
scatter3(X(:,1),X(:,2),X(:,3),10,categorical(Y),'filled','MarkerEdgeColor','r' )
xlabel('variable 1');ylabel('variable 2');zlabel('variable 3');
hold on
plot3(SupportVector(:,1),SupportVector(:,2),SupportVector(:,3),'ko','MarkerSize',10)
hold on

numGrid = 100;
[x1Grid,x2Grid,x3Grid] = meshgrid(linspace(min(X(:,1)),max(X(:,1)),numGrid),...
    linspace(min(X(:,2)),max(X(:,2)),numGrid),linspace(min(X(:,3)),max(X(:,3)),numGrid));
xList = [x1Grid(:),x2Grid(:),x3Grid(:)];
p=patch('Vertices', verts, 'Faces', faces, 'FaceColor','k','edgecolor', 'none', 'FaceAlpha', 0.5);
p.FaceColor = 'red';
grid on; box on





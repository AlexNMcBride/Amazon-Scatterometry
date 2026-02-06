set(groot , 'defaultAxesCreateFcn' , 'set(gca, ''Interactions'', [])')
set(gca,'FontSize',30,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',30,'fontWeight','bold')
hline = findobj(gcf, 'type', 'line');
set(hline,"LineWidth",4)
grid on
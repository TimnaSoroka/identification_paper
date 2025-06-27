function [ f ] = setFigureA4PDF( f,  figure_size_cm )
%SETFIGURETOPRINT Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    figure_size_cm = [21 24]; % ~A4 size
end
if nargin < 1
    f = figure;
end
figure(f);
% Some WYSIWYG options:
set(gcf,'DefaultAxesFontSize',7);
set(gcf,'DefaultAxesFontName','helvetica');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 figure_size_cm]);
set(gcf,'PaperOrientation','portrait');
set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[1 1 0 0]); % position on screen...
set(gcf, 'Renderer', 'painters');
% set(gcf, 'Renderer', 'zbuffer');
% set(gcf, 'Renderer', 'opengl');

end


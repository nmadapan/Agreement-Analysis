clear;
close all;
clc;

load('results_con_plus_mod.mat')
load('data', 'cmd_names', 'sd_names', 'modifier_indices', 'act_cols', 'reduced_command_ids')

cmd_names = {'Scroll';'Scroll Up';'Scroll Down';'Flip';'Flip Horizontal';'Flip Vertical';'Rotate';'Rotate CW';'Rotate CCW';'Zoom';'Zoom In';'Zoom Out';'Switch Panel';'Switch Panel Left';'Switch Panel Right';'Switch Panel Up';'Switch Panel Down';'Pan';'Pan Left ';'Pan Right';'Pan Up';'Pan Down';'Ruler';'Ruler Measure';'Ruler Delete';'Reference Lines';'Reference Lines On';'Reference Lines Off';'PIW';'Window Open';'Window Close';'Manual Contrast';'Contrast Increase';'Contrast Decrease';'Layout';'Layout 1 Panel';'Layout 2 Panels';'Layout 3 Panels';'Layout 4 Panels';'Layout 2 x 2 Panels';'Layout 2 x 3 Panels';'Contrast Presets';'Contrast Standard I';'Contrast Standard II';'Contrast Standard III';'Contrast Standard IV'}
cmd_names = cmd_names(modifier_indices(:,1));
cmd_names = cmd_names(reduced_command_ids);

sd_names = {'ND. Movement - Right';'ND. Movement - Up';'ND. Movement - Left';'ND. Movement - Down';'ND. Movement - Forward';'ND. Movement - Backward';'ND. Movement - CW';'ND. Movement - CCW';'ND. Movement - Iterative';'ND. Movement - Circle';'ND. Movement - Rectangle';'ND. Movement - Other';'Movement - Right';' Movement - Up';' Movement - Left';' Movement - Down';' Movement - Forward';' Movement - Backward';' Movement - CW';' Movement - CCW';' Movement - Iterative';' Movement - Circle';' Movement - Rectangle';' Movement - Other';'Comb. Movement - Circle';'Comb. Movement - Rectangle';'Inward flow';'Outward flow';'ND. orientation  - Right';'ND. orientation  - Up';'ND. orientation  - Left';'ND. orientation  - Down';'ND. orientation  - Forward';'ND. orientation  - Backward';'ND. orientation  - Other';' Orientation  - Right';' Orientation  - Up';' Orientation  - Left';' Orientation  - Down';' Orientation  - Forward';' Orientation  - Backward';' Orientation  - Other';'ND. Movement plane - Sagittal';'ND. Movement plane - Frontal';'ND. Movement plane - Transverse';'ND. Movement plane - None';'Movement plane - Sagittal';'Movement plane - Frontal';'Movement plane - Transverse';'Movement plane - None';'ND. state - Closed-0';'ND. state - 1';'ND. state - 2';'ND. state - 3';'ND. state - 4';'ND. state - 5';'ND. state - C';'ND. state - V';'State - 0';'State - 1';'State - 2';'State - 3';'State - 4';'State - 5';'State - C';'State - V';'PD Shift'}
sd_names = sd_names(act_cols);
sd_names = sd_names(left_right_indices);

Y = permute(mean(base_matrix, 1), [3, 2, 1]);
Y = Y(:, left_right_indices);

heatmap(Y, sd_names, cmd_names, [], 'Colormap', 'jet', 'ColorLevels', 64, 'ColorBar', true, ...
    'FontSize', 14, 'GridLines', '-', 'TickAngle', 45, 'ShowAllTicks', 1, 'TickFontSize', 12)

xlabel('Gesture Descriptors for Dominant Hand', 'FontSize', 14);
ylabel('Command Names of PACS', 'FontSize', 14);
% title('Visualization of popularity of descriptors', 'FontSize', 14);

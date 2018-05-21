clear; clc; close all;

load('data.mat', 'loa_data')

% fprintf('Context alone\n')
% load('data', 'rep_context_data');
% Y = rep_context_data(:,act_cols,:);
% context_sd_matrix = Y;
% save('PLOS_Data\semantic_description_matrix.mat', 'context_sd_matrix')
% 
% fprintf('Modifier alone\n')
% load('data', 'modifier_data');
% Y = modifier_data(:,act_cols,:);
% modifier_sd_matrix = Y;
% save('PLOS_Data\semantic_description_matrix.mat', 'modifier_sd_matrix', '-append')
% 
% fprintf('Modifier + context\n')
% load('data', 'modifier_data', 'rep_context_data');
% Y = modifier_data(:,act_cols,:);
% Y = bitor(Y,rep_context_data(:,act_cols,:));
% context_modifier_sd_matrix = Y;
% save('PLOS_Data\semantic_description_matrix.mat', 'context_modifier_sd_matrix', '-append')

level_of_agreement_soa = loa_data(:, :, 1);
mean_level_of_agreement_soa = mean(level_of_agreement_soa, 1);
std_level_of_agreement_soa = std(level_of_agreement_soa, [], 1);

level_of_agreement_sd = loa_data(:, :, 3);
mean_level_of_agreement_sd = mean(level_of_agreement_sd, 1);
std_level_of_agreement_sd = std(level_of_agreement_sd, [], 1);

clear('loa_data')


save('PLOS_Data\results.mat')


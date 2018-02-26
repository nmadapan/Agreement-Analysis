clear;
clc;

xls_file = 'Semantic_Descriptors_Final.xlsx';
sub_ids = (1:9); % Total number of subjects.
load('data')

num_cmd = numel(cmd_names);
num_sd = numel(sd_names);

if ~exist('data_final','var')
    X = zeros(num_cmd, num_sd, numel(sub_ids));
    
    for idx = 1 : numel(sub_ids)
        sub_idx = sub_ids(idx)
        [A, ~, ~] = xlsread(xls_file, sprintf('S (%d)',sub_idx));
        A = A(4:end,5:end);
        B = A(find(isnan(A)==0));
        X(:,:,idx) = reshape(B,[46,67]);
    end
    data_final = X;
    save('data','data_final','-append')
end

%% Data Extraction
%{
act_cols =[1:11,13:23,25:34,36:41,51:67]'; % This removes the 'other', 'motion_plane'
motion_cols = [1:11,13:23,25:28,67]'; % 'movements', 'flow', 'PD Shift'
orien_cols = [29:34,36:41]'; % 'orientation'
state_cols = (51:66)'; % 'state of hand'
context_data = data_final(context_indices,:,:);
modifier_data = data_final(modifier_indices(:,1),:,:);
rep_context_data = context_data(modifier_indices(:,2),:,:);
save('data','act_cols','motion_cols','orien_cols','state_cols','context_data','modifier_data','rep_context_data','-append')
%}

%% Metric
metric = 'jaccard';
% If there is atleast one zero vector - 'cosine' fails due to divide by zero.
% cosine has (divide by norm which is zero for zero vector)
% If there are atleast two zero vectors - 'jaccard'
% jaccard between these two zero vectors is NaN

col_names = {'motion_cols', 'orien_cols', 'state_cols'};
%col_names = {'motion_cols', 'orien_cols'};
%col_names = {'motion_cols', 'state_cols'};
%col_names = {'orien_cols', 'state_cols'};

col_names_cell = {{'motion_cols', 'orien_cols', 'state_cols'}, {'motion_cols', 'orien_cols'}, ...
                  {'motion_cols', 'state_cols'}, {'orien_cols', 'state_cols'} };

components = 1:5; % 1: Random, 2: context, 3: modifier, 4: c + m, 5: m - c
result_info = [];
full_loa_info = []; % num_commands x numel(components)

% sd_cols contains all the column indices to consider
sd_cols = [];
for name_idx = 1 : numel(col_names)
    sd_cols = [sd_cols, eval(genvarname(col_names{name_idx}))'];
end
sd_cols = sort(sd_cols);

% Y contains the actual data to process
for comp_idx = 1:numel(components)
    comp_idx
    switch components(comp_idx)
        case 1
            fprintf('Random data\n')
            Y = randi(2,size(modifier_data(:,sd_cols,:))) - 1;
        case 2
            fprintf('Context alone\n')
            Y = rep_context_data(:,sd_cols,:);
        case 3
            fprintf('Modifier alone\n')
            Y = modifier_data(:,sd_cols,:);
        case 4
            fprintf('Modifier + context\n')
            Y = modifier_data(:,sd_cols,:);
            Y = bitor(Y,rep_context_data(:,sd_cols,:));
        case 5
            fprintf('Modifier - context\n')
            Y = modifier_data(:,act_cols,:);
            Y = Y - Y.*rep_context_data(:,act_cols,:);
        otherwise
            fprintf('Error: wrong component\n')
    end
    ag_values = loa_pairwise(Y, metric);
    full_loa_info = [ full_loa_info, ag_values];
    temp = [mean(ag_values), std(ag_values)]
    result_info = [result_info; temp];
end

result_info

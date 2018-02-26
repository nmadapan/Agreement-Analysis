clear; clc; close all;

load('data')

sub_ids = (1:9); % Total number of subjects.
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

components = 1:5; % 1: Random, 2: context, 3: modifier, 4: c + m, 5: m - c

col_names = {'motion_cols', 'orien_cols', 'state_cols'};
% col_names = {'act_cols'};

% sd_cols contains all the column indices to consider
sd_cols = [];
for name_idx = 1 : numel(col_names)
    sd_cols = [sd_cols, eval(genvarname(col_names{name_idx}))'];
end
sd_cols = sort(sd_cols);

ag_values = zeros(34, 5, 3);
argmax_command_ids = zeros(34, 5);
metric = 'jaccard';

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
    
    % Size of Y - 34 x _ x 9. Next line changes the sizes. 
    Y = permute(Y, [3,2,1]); % 9 x 9 x 34 % Rows are semantic vectors
    
    for cmd_idx = 1 : size(Y, 3)
       sem_mat_cmd = Y(:,:,cmd_idx) ;
       [~, IA, IC] = unique(sem_mat_cmd, 'rows');
       array = sum(IC == (1:numel(IA)), 1);
       [~, temp] = max(array);
       argmax_command_ids(cmd_idx, comp_idx) = IA(temp);
       if array(temp) == 1
           argmax_command_ids(cmd_idx, comp_idx) = -1;
       end

       ag_values(cmd_idx, comp_idx, 1) = loa_wobbrock_2010(array);
       ag_values(cmd_idx, comp_idx, 2) = loa_wobbrock_2015(array);
       ag_values(cmd_idx, comp_idx, 3) = loa_semantics(sem_mat_cmd, metric);
    end
end

ag_values = permute(ag_values(reduced_command_ids,4,:), [1 3 2]);
argmax_command_ids = argmax_command_ids(reduced_command_ids,4);

clear; clc; close all;

%% Initialization
components = [4]; % 1: Random, 2: context, 3: modifier, 4: c + m, 5: m - c

col_names = {'motion_cols', 'orien_cols', 'state_cols'};
% col_names = {'act_cols'};

metric = 'jaccard';
%%
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

% sd_cols contains all the column indices to consider
sd_cols = [];
for name_idx = 1 : numel(col_names)
    sd_cols = [sd_cols, eval(genvarname(col_names{name_idx}))'];
end
sd_cols = sort(sd_cols);

% 3 methods
ag_values = zeros(num_cmd, numel(components), 3);
argmax_lexicon_ids = cell(num_cmd, numel(components));
popularity = zeros(num_cmd, numel(components));

for comp_idx = 1:numel(components)
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
    Y = permute(Y, [3,2,1]); % 9 x _ x 34 % Rows are semantic vectors
    
    for cmd_idx = 1 : size(Y, 3)
        % Extract semantic vectors of 9 gestures for one command
        sem_mat_cmd = Y(:,:,cmd_idx) ; % 9 gestures x numel(sd_cols)
        
        % Find unique vectors. This should be <= 9
        [~, IA, IC] = unique(sem_mat_cmd, 'rows');
        H = (IC == (1:numel(IA)));
        
        % Frequency of unique gestures
        freq_of_uniq_gestures = sum(H, 1);
        
        % Frequeny of the gesture that is repeated the most
        max_freq = max(freq_of_uniq_gestures);
        
        % Find all of the best lexicon ids 
        temp = find(freq_of_uniq_gestures == max_freq);
        [row_ids, ~] = find(H(:, temp));
        argmax_lexicon_ids{cmd_idx, comp_idx} = mat2str(sort(row_ids));
        
        % Percentage of subjects (9) that choose the gesture that repeated the most
        popularity(cmd_idx, comp_idx) = max_freq / size(H,1);

        % Compute agreement by three methods
        % Method 1 : Wobbrock paper in 2010
        ag_values(cmd_idx, comp_idx, 1) = loa_wobbrock_2010(freq_of_uniq_gestures);
        
        % Method 2 : Wobbrock paper in 2010
        ag_values(cmd_idx, comp_idx, 2) = loa_wobbrock_2015(freq_of_uniq_gestures);
        
        % Method 3 : CHI Paper (Our method)
        ag_values(cmd_idx, comp_idx, 3) = loa_semantics(sem_mat_cmd, metric);
    end
    
    % Finding the frequency of each descriptor for all commands
    freq = permute(sum(Y), [3, 2, 1]); % 34 x 55
    [max_freq, argmax_freq] = sort(freq, 2, 'descend');
    argmax_freq = argmax_freq(reduced_command_ids,1:10);
    argmax_sds = sd_names(act_cols(argmax_freq));
    max_freq = floor(100*max_freq(reduced_command_ids, 1:10)/9);
    
end

final_cell = cell(28,10);
for i = 1 : 28
   for j = 1 : 10
       final_cell{i,j} = strcat(num2str(max_freq(i, j)), ' - ', argmax_sds{i, j});
   end
end

% Extracting only the results for the following condition:
    % reduced command ids
    % context + modifier case
    % only method 1 and 2
% ag_values = permute(ag_values(reduced_command_ids, 4, :), [1,3,2]);
% argmax_lexicon_ids = argmax_lexicon_ids(reduced_command_ids, 4);
% popularity = popularity(reduced_command_ids, 4);

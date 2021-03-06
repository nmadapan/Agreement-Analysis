clear; clc; close all;

%% Global variables
component_idx = [4]; % 1: Random, 2: context, 3: modifier, 4: c + m, 5: m - c

col_names = {'motion_cols', 'orien_cols', 'state_cols'};
% col_names = {'act_cols'};

metric = 'jaccard';

num_top_descs = 10;

%%
load('data')
sd_names = {'ND. Movement - Right';'ND. Movement - Up';'ND. Movement - Left';'ND. Movement - Down';'ND. Movement - Forward';'ND. Movement - Backward';'ND. Movement - CW';'ND. Movement - CCW';'ND. Movement - Iterative';'ND. Movement - Circle';'ND. Movement - Rectangle';'ND. Movement - Other';'Movement - Right';' Movement - Up';' Movement - Left';' Movement - Down';' Movement - Forward';' Movement - Backward';' Movement - CW';' Movement - CCW';' Movement - Iterative';' Movement - Circle';' Movement - Rectangle';' Movement - Other';'Comb. Movement - Circle';'Comb. Movement - Rectangle';'Inward flow';'Outward flow';'ND. orientation  - Right';'ND. orientation  - Up';'ND. orientation  - Left';'ND. orientation  - Down';'ND. orientation  - Forward';'ND. orientation  - Backward';'ND. orientation  - Other';' Orientation  - Right';' Orientation  - Up';' Orientation  - Left';' Orientation  - Down';' Orientation  - Forward';' Orientation  - Backward';' Orientation  - Other';'ND. Movement plane - Sagittal';'ND. Movement plane - Frontal';'ND. Movement plane - Transverse';'ND. Movement plane - None';'Movement plane - Sagittal';'Movement plane - Frontal';'Movement plane - Transverse';'Movement plane - None';'ND. state - Closed-0';'ND. state - 1';'ND. state - 2';'ND. state - 3';'ND. state - 4';'ND. state - 5';'ND. state - C';'ND. state - V';'State - 0';'State - 1';'State - 2';'State - 3';'State - 4';'State - 5';'State - C';'State - V';'PD Shift'}

%% Initialization
num_cmd = size(modifier_data, 1); % No. of commands - 34
ag_values = zeros(num_cmd, 3); % Aggreement values - 34 x 3 {34: no. of commands,  3: no. of methods}
argmax_lexicon_ids = cell(num_cmd, 1); % Most popular lexicon ids - cell(34 x 1) - each element is of form '[1;3;5;7;9]'
popularity = zeros(num_cmd, 1); % popularity of most frequent gesture - floats b/w [0,100] - 34 x 1
sd_cols = gen_sd_cols(col_names); % sd_cols contains all the column indices to consider - 55 x 1
Y = get_base_matrix( component_idx , sd_cols); % 9 x _ x 34 {9: no. of lexicons, _: no. of elements in sd_cols}

%% Loop over command indices and compute: popularity, argmax_lexicon_ids, ag_values
for cmd_idx = 1 : size(Y, 3)
    %% Extract semantic vectors of 9 gestures for one command
    sem_mat_cmd = Y(:,:,cmd_idx) ; % 9 gestures x numel(sd_cols)

    %% Find popularity and argmax_lexicon_ids
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
    argmax_lexicon_ids{cmd_idx} = mat2str(sort(row_ids));
    % Percentage of subjects (9) that choose the gesture that repeated the most
    popularity(cmd_idx) = max_freq / size(H,1);

    %% Compute agreement by three methods
    % Method 1 : Wobbrock paper in 2010
    ag_values(cmd_idx, 1) = loa_wobbrock_2010(freq_of_uniq_gestures);
    % Method 2 : Wobbrock paper in 2010
    ag_values(cmd_idx, 2) = loa_wobbrock_2015(freq_of_uniq_gestures);
    % Method 3 : CHI Paper (Our method)
    ag_values(cmd_idx, 3) = loa_semantics(sem_mat_cmd, metric);
end

%% Find frequency and argmax frequency of top most frequent descriptors
freq = permute(sum(Y), [3, 2, 1]); % 34 x 55 % Finding the frequency of each descriptor for all commands
[max_freq, argmax_freq] = sort(freq, 2, 'descend');
argmax_freq = argmax_freq(reduced_command_ids,1:num_top_descs );

argmax_sds = sd_names(act_cols(argmax_freq));
max_freq = 100*max_freq(reduced_command_ids, 1:num_top_descs )/9;
popularity = 100*popularity(reduced_command_ids);

ag_values = ag_values(reduced_command_ids, :);
argmax_lexicon_ids = argmax_lexicon_ids(reduced_command_ids);

final_cell = cell(28,num_top_descs );
for i = 1 : 28
   for j = 1 : num_top_descs 
       final_cell{i,j} = strcat(num2str(max_freq(i, j)), ' - ', argmax_sds{i, j});
   end
end

base_matrix = Y(:, :, reduced_command_ids);
save('results_con_plus_mod', 'argmax_sds', 'max_freq', 'popularity', 'ag_values', 'argmax_lexicon_ids', 'final_cell', 'base_matrix', '-append')

function sd_cols = gen_sd_cols(col_names)
    % Inputs:
    % col_names (3 x 1) - cell array of one or more of these strings {'motion_cols', 'orien_cols', 'state_cols'}
    % Ex: col_names = {'motion_cols', 'orien_cols', 'state_cols'}; 
    %
    % Outputs:
    % sd_cols(_ x 1) - A list of semantic descriptor indices corresponding to all of the col_names

    sd_cols = []; % sd_cols contains all the column indices to consider
    for name_idx = 1 : numel(col_names)
        load('data', matlab.lang.makeValidName(col_names{name_idx}));
        sd_cols = [sd_cols, eval(matlab.lang.makeValidName(col_names{name_idx}))'];
    end
    sd_cols = sort(sd_cols); % 55 x 1
end

function base_matrix = get_base_matrix(comp_idx, sd_cols)
    % Inputs:
    % comp_idx (1 x 1) - % 1: Random, 2: context (c), 3: modifier (m), 4: c + m, 5: m - c
    % sd_cols (_ x 1) - {_: no. of descriptors that we want to consider}
    %
    % Outputs:
    % base_matrix(9 x _ x 34) - {9: no. of subjects, _: no. of descriptors, 34: no. of commands}

    switch comp_idx
        case 1
            fprintf('Random data\n')
            load('data', 'modifier_data');
            Y = randi(2,size(modifier_data(:,sd_cols,:))) - 1;
        case 2
            fprintf('Context alone\n')
            load('data', 'rep_context_data');
            Y = rep_context_data(:,sd_cols,:);
        case 3
            fprintf('Modifier alone\n')
            load('data', 'modifier_data');
            Y = modifier_data(:,sd_cols,:);
        case 4
            fprintf('Modifier + context\n')
            load('data', 'modifier_data', 'rep_context_data');
            Y = modifier_data(:,sd_cols,:);
            Y = bitor(Y,rep_context_data(:,sd_cols,:));
        case 5
            fprintf('Modifier - context\n')
            load('data', 'modifier_data', 'rep_context_data');
            Y = modifier_data(:,sd_cols,:);
            Y = Y - Y.*rep_context_data(:,sd_cols,:);
        otherwise
            fprintf('Error: wrong component\n')
    end
    
    % Size of Y - 34 x _ x 9. Next line changes the sizes. 
    base_matrix = permute(Y, [3,2,1]); % 9 x _ x 34 % Rows are semantic vectors
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STATISTICAL TESTS - THMS PAPER %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

%% Load data and Initialization
write_fname_prefix = 'thms_results_pariwise';
global test_type
test_type = 'ttest'; % ttest or signtest
load('data', 'reduced_command_ids', 'modifier_data', 'rep_context_data', 'cmd_names', 'modifier_indices');

%% Preprocessing
% Description vector is an logical or of description of context and its modifier
% Note that number of commands need to be reduced from 34 to 28
data_final = double(or(modifier_data, rep_context_data));
data_final = data_final(reduced_command_ids, :, :);
cmd_names = cmd_names(modifier_indices(:, 1));
cmd_names = cmd_names(reduced_command_ids);
% Other variables
num_subs = size(data_final, 3); % No. of subjects - 9
num_descs = size(data_final, 2); % No. of descriptors - 67
num_cmds = size(data_final, 1); % No. of commands - 28
num_combs = num_subs * (num_subs - 1) / 2; % No. of combinations 9*8/2 = 36
% Matrix to store agreement between all pairs of subjects for all commands.
pairwise_mat = zeros(num_subs, num_subs, num_cmds);

%% Computing the agreement between all pairs of subjects
for cmd_idx = 1 : num_cmds
    temp = data_final(cmd_idx,:, :);
    temp = permute(temp, [3, 2, 1]);
    loa = loa_semantics(temp, 'jaccard', 'full_mat', true);
    pairwise_mat(:, :, cmd_idx) = loa;
end

% Open the file with suffix as _ttest.csv if you want to perform ttest
if(strcmp(test_type, 'ttest'))
    fileID = fopen([write_fname_prefix, '_ttest.csv'], 'w');
end
% Open the file with suffix as _signtest.csv if you want to perform sign_test
if(strcmp(test_type, 'signtest'))
    fileID = fopen([write_fname_prefix, '_signtest.csv'], 'w');
end
% Each row in the file contains: command-name-1, command-name-2, p-value
formatSpec = '%s,%s,%s\n';
fprintf(fileID, formatSpec, 'Command-1', 'Command-2', 'P-Value');
p_value_list = [];
for cmd_idx1 = 1 : num_cmds
    for cmd_idx2 = cmd_idx1+1:num_cmds
        cmd_name1 = cmd_names{cmd_idx1};
        cmd_name2 = cmd_names{cmd_idx2};
        [H, P] = custom_ttest(pairwise_mat, cmd_idx1, cmd_idx2);
        % H - 1 ==> Null is rejected meaning there is a signification difference
        % H - 0 ==> Failed to reject Null. Meaning we can not say that there is a signification difference
        % Write only the command pairs where differene is significant
        if(H == 1)
            fprintf(fileID, formatSpec, cmd_name1, cmd_name2, num2str(P));
            p_value_list = [p_value_list; P];
        end
    end
end

fclose(fileID);

function [H, P] = custom_ttest(pairwise_mat, cmd_idx1, cmd_idx2)
    %%%%%%%%%%%%%%%
    % pairwise_mat - matrix of size num_subjects x num_subjects x num_commands
    % cmd_idx1 - a value between 1 and num_commands
    % cmd_idx2 - a value between 1 and num_commands
    %%%%%%%%%%%%%%%
    
    global test_type
    
    % Generate a mast to get only the upper triangle of a square matrix
    mask = triu(true([size(pairwise_mat, 1), size(pairwise_mat, 1)]), 1);
    % Note that idx2 should be greater than 1
    idx1 = min(cmd_idx1, cmd_idx2);
    idx2 = max(cmd_idx1, cmd_idx2);

    M1 = triu(pairwise_mat(:, :, idx1));
    M2 = triu(pairwise_mat(:, :, idx2));

    % Obtain upper triangle of the matrix as a vector
    var1 = M1(mask);
    var2 = M2(mask);

    if(strcmp(test_type, 'signtest'))
        [H,P] = signtest(var1, var2, 'tail', 'both');
    end
    
    if(strcmp(test_type, 'ttest'))
        [H,P] = ttest(var1, var2, 'tail', 'both');
    end
    
end
clear;
close all;
clc;

%% Conduct kruskalwallis statistical test

load('results_con_plus_mod.mat', 'base_matrix');

Y = base_matrix; % 9 x 55 x 28
num_subs = size(Y, 1);
num_descs = size(Y, 2);
num_cmds = size(Y, 3);
num_combs = nchoosek(num_subs, 2);

S = zeros(num_subs, num_subs, num_cmds); % Semantic matrix 9 x 9 x 28
R = zeros(size(S));
umask = triu(true(num_subs, num_subs), 1);

for cmd_idx = 1 : num_cmds
   sem_mat_cmd = Y(:,:,cmd_idx) ; % 9 gestures x numel(sd_cols)
   S(:,:,cmd_idx) = loa_semantics(sem_mat_cmd, 'jaccard', 'full_mat', true);
end

all_values = S(repmat(umask, 1, 1, num_cmds));

req_values = reshape(all_values(:), num_combs, num_cmds);
[p, tbl, stats] = kruskalwallis(req_values, [], 'on');
figure;
multcompare(stats);
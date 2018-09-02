clear; clc; close all;

load('data')

%% After reduction
context_indices_x = [context_indices(1:7); context_indices(9:end)];
modifier_indices_x = modifier_indices(reduced_command_ids, :);

context_data_x = data_final(context_indices_x, :, :);
modifier_data_x = data_final(modifier_indices_x(:, 1), :, :);


disp('No. of total gestures in: ')
for lex_idx = [2, 3, 6, 8]
   M = modifier_data_x(:,:,lex_idx);
   C = context_data_x(:,:,lex_idx);
   xm = numel(find(sum(M, 2) == 0 ));
   xc = numel(find(sum(C, 2) == 0 ));
   
   um = unique(M, 'rows');
   uc = unique(C, 'rows');
   num_unique = size(um, 1) + size(uc, 1);
   disp(sprintf('L%d: %d -- U: %d', lex_idx, (39-xm-xc), num_unique))
end
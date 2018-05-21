clear all; clc; close all;

load('data.mat', 'data_final', 'context_indices')

lexicon_id = 9;

context_desc = data_final(context_indices, :, lexicon_id );

find(sum(context_desc, 2) ~= 0)

numel(find(sum(context_desc, 2) ~= 0))
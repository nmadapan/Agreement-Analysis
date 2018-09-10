clear;
clc;

datapath = 'equivalence_clust_data';
filenames = {'DescriptorAnnotations_Naveen.xlsx', 'DescriptorAnnotations_Edgar.xlsx'};
num_subs = 9;

result = cell(numel(filenames), 2);

%% Analysis when N is a variable, only TWO groups
for idx_ = 1:numel(filenames)
    filename = filenames{idx_};
    A = xlsread(fullfile(datapath, filename));
    A = A(:, 3:end);

    ag_values = [];

    for idx = 1 : size(A, 1)
        inst = A(idx, :);
        clusters = inst(and(~isnan(inst), (~(inst == 1))));
        clusters = [clusters, ones(1, num_subs - sum(clusters))];
        ag_values = [ag_values, loa_wobbrock_2015(clusters)];
    end

    ag_values = ag_values';

%     sprintf('Aggrement: %f', mean(ag_values))
    result{idx_, 1} = filename;
    result{idx_, 2} = mean(ag_values);
end
result
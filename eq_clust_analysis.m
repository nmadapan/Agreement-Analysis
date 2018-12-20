clear;
clc;

datapath = 'equivalence_clust_data';
filenames = {'DescriptorAnnotations_Naveen.xlsx', 'DescriptorAnnotations_Edgar.xlsx', ...
            'DescriptorAnnotations_Rahul.xlsx', 'DescriptorAnnotations_Maru.xlsx', ...
            'DescriptorAnnotations_Ting.xlsx'};

num_subs = 9;

result = cell(numel(filenames), 2);

overall_ag_values = [];
overall_pop_values = [];

%% Analysis when N is a variable, only TWO groups
for idx_ = 1:numel(filenames)
    filename = filenames{idx_};
    A = xlsread(fullfile(datapath, filename));
    A = A(:, 3:end);

    ag_values = [];
    pop_values = [];

    for idx = 1 : size(A, 1)
        inst = A(idx, :);
        clusters = inst(and(~isnan(inst), (~(inst == 1))));
        clusters = [clusters, ones(1, num_subs - sum(clusters))];
        ag_values = [ag_values, loa_wobbrock_2015(clusters)];
        pop_values = [pop_values, max(clusters, [], 2)];
    end

    overall_ag_values = [overall_ag_values, ag_values'];
    overall_pop_values = [overall_pop_values, pop_values'];

%     sprintf('Aggrement: %f', mean(ag_values))
    result{idx_, 1} = filename;
    result{idx_, 2} = mean(ag_values);
end

result

mean_overall_ag_values = mean(overall_ag_values, 2);
std_overall_ag_values = std(overall_ag_values, [], 2);

mean_overall_pop_values = mean(overall_pop_values, 2);
std_overall_pop_values = std(overall_pop_values, [], 2);


clear;
clc;

%% Analysis when N is a variable, only TWO groups
% N = (5:50);
% K1 = 5; % First group has 5 identical gestures
% list = []
% for idx = N
%     K2 = idx - K1; % Rest of the gestures are consdered different
%     list = [list, loa_wobbrock_2015([K1, ones(1, K2)])];
% end
% 
% plot(N, list)

%% Analysis when N is fixed, variable no. of groups, FIXED no. of gestures in the each group 
N = 100; % Total no. of gestures for a command is 100
group_list = (2:10); % No. of groups can change
K = 8; % Each group has exactly 8 equivalent gestures. All the gestures in the last group are different. 

agg_values = [];
for num_groups = group_list
    list = K*ones(1,num_groups-1);
    list = [list, ones(1, N - sum(list))];
    agg_values = [agg_values, loa_wobbrock_2015(list)];
end

plot(group_list, agg_values)

% %% Analysis when N is fixed, variable no. of groups, RANDOM no. of gestures in each group
% N = 100; % Total no. of gestures for a command is 100
% group_list = (1:10); % No. of groups can change
% K = 10; % Max integer that randi can generate
% 
% num_iter = 11; % No. of times to run the loop. So we will get averaged results. 
% agg_values_list = [];
% for aa = 1:num_iter
%     agg_values = [];
%     for num_groups = group_list
%         list = randi([2, K], 1, num_groups-1);
%         list = [list, ones(1, N - sum(list))];
%         agg_values = [agg_values, loa_wobbrock_2015(list)];
%     end
%     agg_values_list = [agg_values_list; agg_values];
% end
% 
% plot(group_list, mean(agg_values_list, 1))
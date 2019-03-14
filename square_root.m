clear all;
clc;

N = 9;
agg_values = [];
k_values = [];
sq_values = []

for K = 0 : N
    temp = ones(1, N - K);
    temp = [K, temp];
    agg = loa_wobbrock_2015(temp);
    
    k_values = [k_values; K];
    agg_values = [agg_values; agg];
    sq_values = [sq_values; ((K)/N)^2]
end

plot(k_values, agg_values, 'LineWidth', 2)
hold on;
grid on;
plot(k_values, sq_values, 'LineWidth', 2)
xlabel('K - Number of identical gestures', 'FontSize', 14)
ylabel('Aggreement Value (Metric II) and ', 'FontSize', 14)
ll = legend({'Aggreement values AR', '(K/N)^2'});
set(ll,'FontSize',14);

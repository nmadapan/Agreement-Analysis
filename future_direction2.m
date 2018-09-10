clear;
clc;

N = 10; % No. of subjects
D = 20; % No. of descriptors

% M = zeros(N, D);

num_iter = 1e5;
num_bins = 100;

freqs = zeros(1, num_bins);
progressbar
for xx = 1:num_iter
   M = randi([0, 1], N, D);
   loa = loa_semantics(M, 'jaccard');
   freq_idx = ceil(num_bins * loa);
   if(freq_idx == 0) 
       freq_idx = 1;
   end
   freqs(freq_idx) = freqs(freq_idx) + 1;
   progressbar(xx/num_iter);
end

freqs = freqs / num_iter;

rem_ids = (freqs~=0);
freqs = freqs(rem_ids);
t = linspace(0, 1, num_bins);
t = t(rem_ids);

plot(t, freqs, 'LineWidth', 2)
% xlim([0, 1])
% ylim([0, 1])
grid on
xlabel('Agreement Rate', 'FontSize', 12)
ylabel('Normalized Frequency', 'FontSize', 12)
title('PDF', 'FontSize', 14)
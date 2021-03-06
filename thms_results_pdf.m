%%%%%%%%%%%%%%%%%%%%%%%%
%%% Results for THMS %%%
%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

%% Intialization Parameters
N = 9; % No. of subjects
D = 55; % No. of descriptors
num_iter = 1e7; % No. of iterations
num_bins = 100; % No. of bins for agreement values
use_custom_dist = 1; % 0 - False, 1 - True
global distribution 
distribution = [0.93, 0.07]; % discrete probabilities of 0 and 1
N_list = 3:12; % List of values of N
D_list = 5:10:100; % List of values of D
write_fname_prefix = 'thms_pdf'; % Name of the mat file

if(use_custom_dist == 0)
    write_fname = [write_fname_prefix, '_data.mat'];
else
    write_fname = [write_fname_prefix, '_cdist_data.mat'];
end

%% Varying number of subjects
if(exist(write_fname, 'file'))
    load(write_fname, 'x_list_vsub', 'y_list_vsub')
    x_list = x_list_vsub;
    y_list = y_list_vsub;
else
    [x_list, y_list] = get_pdf_loop_subjects(N_list, D, 'num_iter', num_iter, 'num_bins', num_bins, 'use_dist', use_custom_dist);
end
figure;
hold on;
g_colors_list = linspace(0.2, 1, numel(x_list));
legend_list = {};
for idx = 1:numel(x_list)
    plot(x_list{idx}, y_list{idx}, 'LineWidth', 2, 'Color', [g_colors_list(idx), 0.5, 0.4]);
    legend_list{end+1} = num2str(N_list(idx));
end
grid on;
xlabel('Agreement Rate', 'FontSize', 14)
ylabel('Normalized Frequency', 'FontSize', 14)
title('PDF - Varying no. of subjects', 'FontSize', 14)
ll = legend(legend_list);
set(ll, 'FontSize', 14);
hold off;
% Saving the files
x_list_vsub = x_list;
y_list_vsub = y_list;
if(exist(write_fname, 'file'))
    save(write_fname, 'x_list_vsub', 'y_list_vsub', '-append')
else
   save(write_fname, 'x_list_vsub', 'y_list_vsub')
end

%% Varying number of descriptors
if(exist(write_fname, 'file'))
    try
        load(write_fname, 'x_list_vdesc', 'y_list_vdesc')
        x_list = x_list_vdesc;
        y_list = y_list_vdesc;
    catch exp
        [x_list, y_list] = get_pdf_loop_descriptors(N, D_list, 'num_iter', num_iter, 'num_bins', num_bins, 'use_dist', use_custom_dist);
    end
else
    [x_list, y_list] = get_pdf_loop_descriptors(N, D_list, 'num_iter', num_iter, 'num_bins', num_bins, 'use_dist', use_custom_dist);
end
figure;
hold on;
g_colors_list = linspace(0.2, 1, numel(x_list));
legend_list = {};
for idx = 1:numel(x_list)
    plot(x_list{idx}, y_list{idx}, 'LineWidth', 2, 'Color', [g_colors_list(idx), 0.5, 0.4]);
    legend_list{end+1} = num2str(D_list(idx));
end
grid on;
xlabel('Agreement Rate', 'FontSize', 14)
ylabel('Normalized Frequency', 'FontSize', 14)
title('PDF - Varying no. of descriptors', 'FontSize', 14)
ll = legend(legend_list);
set(ll, 'FontSize', 14)
hold off;
% Saving the files
x_list_vdesc = x_list;
y_list_vdesc = y_list;
if(exist(write_fname, 'file'))
   save(write_fname, 'x_list_vdesc', 'y_list_vdesc', '-append')
else
   save(write_fname, 'x_list_vdesc', 'y_list_vdesc')
end

%% Get PDF - Loop over the number of subjects
function [x_list, y_list] = get_pdf_loop_subjects(N_list, D, varargin)
    parser = inputParser;
    addOptional(parser, 'num_iter', 1e4);
    addOptional(parser, 'num_bins', 1e2);
    addOptional(parser, 'disp_flag', 1);
    addOptional(parser, 'use_dist', 0);
    parse(parser, varargin{:})
    num_iter = parser.Results.num_iter;
    num_bins = parser.Results.num_bins;
    disp_flag = parser.Results.disp_flag;
    use_dist = parser.Results.use_dist;
    
    x_list = {};
    y_list = {};
    if(disp_flag) progressbar, end
    for idx = 1 : numel(N_list)
        N = N_list(idx);
        tic;
        [t, freqs] = get_pdf(N, D, 'num_iter', num_iter, 'num_bins', num_bins, 'disp_flag', 0, 'use_dist', use_dist);
        toc;
        x_list{end+1} = t;
        y_list{end+1} = freqs;
        if(disp_flag) progressbar(idx/numel(N_list)), end;
    end
end

%% Get PDF - Loop over the number of descriptors
function [x_list, y_list] = get_pdf_loop_descriptors(N, D_list, varargin)
    parser = inputParser;
    addOptional(parser, 'num_iter', 1e4);
    addOptional(parser, 'num_bins', 1e2);
    addOptional(parser, 'disp_flag', 1);
    addOptional(parser, 'use_dist', 0);
    parse(parser, varargin{:})
    num_iter = parser.Results.num_iter;
    num_bins = parser.Results.num_bins;
    disp_flag = parser.Results.disp_flag;
    use_dist = parser.Results.use_dist;

    x_list = {};
    y_list = {};
    if(disp_flag) progressbar, end;
    for idx = 1 : numel(D_list)
        D = D_list(idx);
        tic;
        [t, freqs] = get_pdf(N, D, 'num_iter', num_iter, 'num_bins', num_bins, 'disp_flag', 0, 'use_dist', use_dist);
        toc;
        x_list{end+1} = t;
        y_list{end+1} = freqs;
        if(disp_flag) progressbar(idx/numel(D_list)), end;
    end
end

%% Get PDF - basic function to get the PDF for a given N and D
function [t, freqs] = get_pdf(N, D, varargin)
    global distribution 
    parser = inputParser;
    addOptional(parser, 'num_iter', 1e4);
    addOptional(parser, 'num_bins', 1e2);
    addOptional(parser, 'disp_flag', 0);
    addOptional(parser, 'use_dist', 0);
    parse(parser, varargin{:})
    num_iter = parser.Results.num_iter;
    num_bins = parser.Results.num_bins;
    disp_flag = parser.Results.disp_flag;
    use_dist = parser.Results.use_dist;
    
    freqs = zeros(1, num_bins);
    if(disp_flag) progressbar, end
    for xx = 1:num_iter
       if(use_dist == 0)
           M = randi([0, 1], N, D);
       else
           M = gendist(distribution, N, D) - 1;
       end
       loa = loa_semantics(M, 'jaccard');
       freq_idx = ceil(num_bins * loa);
       if(freq_idx == 0) 
           freq_idx = 1;
       end
       freqs(freq_idx) = freqs(freq_idx) + 1;
       if(disp_flag) progressbar(xx/num_iter), end;
    end
    freqs = freqs / num_iter;
    rem_ids = (freqs~=0);
    freqs = freqs(rem_ids);
    t = linspace(0, 1, num_bins);
    t = t(rem_ids);
end
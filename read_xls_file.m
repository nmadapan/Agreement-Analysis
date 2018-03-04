% Read the semantic descriptors xls file

%%
load('data')

sub_ids = (1:9); % Total number of subjects.
num_cmd = numel(size(modifier_data, 1)); % 34
num_sd = numel(sd_names); % 67

if ~exist('data_final','var')
    X = zeros(num_cmd, num_sd, numel(sub_ids));
    for idx = 1 : numel(sub_ids)
        sub_idx = sub_ids(idx)
        [A, ~, ~] = xlsread(xls_file, sprintf('S (%d)',sub_idx));
        A = A(4:end,5:end);
        B = A(find(isnan(A)==0));
        X(:,:,idx) = reshape(B,[46,67]);
    end
    data_final = X;
    save('data','data_final','-append')
end
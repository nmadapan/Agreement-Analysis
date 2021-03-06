function loa = loa_semantics(Y, metric, varargin)

    % Parsing Inputs
    parser = inputParser;
    addOptional(parser, 'full_mat', false);
    
    % Parsing the optional arguments
    parse(parser,varargin{:});
    full_mat = parser.Results.full_mat;

    Y = pdist2(Y, Y, metric); % 'hamming', 'jaccard'
    Y = triu(Y,1);

    % NaN should be replaced by 1. 
    % NaN occurs when 0/0 i.e when two vectors are zero vectors. 
    % They shouldn't contribute to the similarity. 
    % Hence distance between two zero vectors is 1. 
    % This will make their contribution zero in the similarity.

%     if(sum(sum(isnan(Y))) ~= 0)
%         sprintf('NaNs (%d) replaced by 1 for command index', sum(sum(isnan(Y))))
%     end

    Y(isnan(Y)) = 1;
    if(~full_mat)
        loa = 1 - sum(sum(Y)) / ((numel(Y)-size(Y,1)) / 2.0);
    else
        loa = Y;
    end
end


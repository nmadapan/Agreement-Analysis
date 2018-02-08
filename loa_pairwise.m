function ag_values = loa_pairwise(Y, metric)
    ag_values = zeros(size(Y,1),1);
    for idx = 1 : size(Y,1)
        temp = reshape(Y(idx,:,:),[size(Y,2),size(Y,3)])'; 
        temp = pdist2(temp,temp, metric); % 'hamming', 'jaccard'
        temp = triu(temp,1);
        
        % NaN should be replaced by 1. NaN occurs when 0/0 i.e when two
        % vectors are zero vectors. They shouldn't contribute to the
        % similarity. Hence distance between two zero vectors is 1. This
        % will make their contribution zero in the similarity.

        if(sum(sum(isnan(temp))) ~= 0)
            sprintf('NaNs (%d) replaced by 1 for command index: %d',sum(sum(isnan(temp))), idx)
            temp(isnan(temp)) = 1; %%%%%%%%%%%%%%% Verify with Glebys.
        end
        
        temp = sum(sum(temp)) / ((numel(temp)-size(temp,1)) / 2.0);
        ag_values(idx) = 1 - temp;
    end
end


function ag_values = loa_pairwise(Y, metric)
    ag_values = zeros(size(Y,1),1);
    for idx = 1 : size(Y,1)
        temp = reshape(Y(idx,:,:),[size(Y,2),size(Y,3)])'; 
        ag_values(idx) = loa_semantics(temp, metric);
    end
end


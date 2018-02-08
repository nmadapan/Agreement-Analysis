function loa = loa_wobbrock_2010(array)
    % array is 1D vector. Order of numbers does not matter. 
    % Example: [1, 2, 3, 1, 1, 1] --> 9 subjects. 
    % 2 subjects have the same gesture. 3 have same gesture. 
    % Rest are different.
    
    array = array / sum(array);
    loa = sum(array .^ 2);
end


function loa = loa_wobbrock_2015(array)
    % array is 1D vector. Order of numbers does not matter. 
    % Example: [1, 2, 3, 1, 1, 1] --> 9 subjects. 
    % 2 subjects have the same gesture. 3 have same gesture. 
    % Rest are different.

    N = sum(array);
    loa = sum(array .* (array-1)) / (N*(N-1));
end
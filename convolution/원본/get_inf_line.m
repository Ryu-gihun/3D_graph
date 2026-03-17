fig = openfig('ber_t3.fig', 'invisible');
axesHandles = findall(fig, 'type', 'axes');

for ax = axesHandles'
    lineObjs = findall(ax, 'type', 'line');
    for i = 1:length(lineObjs)
        colorVal = get(lineObjs(i), 'Color');
        fprintf('Line %d color: [%.4f %.4f %.4f]\n', i, colorVal);
    end
end

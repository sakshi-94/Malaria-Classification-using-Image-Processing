clc;
clear all;
close all;

% Define the path to the single image file
imagePath = 'C:/Users/Sakshi Singh/Downloads/Malaria/LP/232.bmp';

% Conversion factor from pixels to micrometers
pixelToUmFactor = 0.126;

% Area thresholds for each category (upper and lower bounds)
thresholds = struct( ...
    'Normal', struct('Area', [54.07 - 3.43, 54.07 + 3.43], 'Perimeter', [25.05 - 2.29, 25.05 + 2.29], ...
                     'FormFactor', [0.98 - 0.18, 0.98 + 0.18], 'CirculatoryFactor', [1.06 - 0.07, 1.06 + 0.07], ...
                     'DeviationFactor', [0.02 - 0.002, 0.02 + 0.002]), ...
    'LP', struct('Area', [54.19 - 9.48, 54.19 + 9.48], 'Perimeter', [34.73 - 5.82, 34.73 + 5.82], ...
                 'FormFactor', [1.83 - 0.18, 1.83 + 0.18], 'CirculatoryFactor', [1.16 - 0.12, 1.16 + 0.12], ...
                 'DeviationFactor', [0.021 - 0.0039, 0.021 + 0.0039]), ...
    'MP', struct('Area', [55.04 - 3.71, 55.04 + 3.71], 'Perimeter', [34.26 - 5.61, 34.26 + 5.61], ...
                 'FormFactor', [1.82 - 0.57, 1.82 + 0.57], 'CirculatoryFactor', [1.24 - 0.11, 1.24 + 0.11], ...
                 'DeviationFactor', [0.0242 - 0.0048, 0.0242 + 0.0048]), ...
    'HP', struct('Area', [58.06 - 6.41, 58.06 + 6.41], 'Perimeter', [39.04 - 5.26, 39.04 + 5.26], ...
                 'FormFactor', [2.12 - 0.5, 2.12 + 0.5], 'CirculatoryFactor', [1.34 - 0.25, 1.34 + 0.25], ...
                 'DeviationFactor', [0.0244 - 0.0053, 0.0244 + 0.0053]) ...
);

% Read the image
img = imread(imagePath);

% Convert the image to grayscale
grayImg = rgb2gray(img);

% Apply a median filter to reduce noise
filteredImg = medfilt2(grayImg);

% Perform edge detection using the Canny edge detector
edges = edge(filteredImg, 'canny');

% Fill gaps in edges using morphological operations
filledEdges = imfill(edges, 'holes');

% Label connected components (cells) in the image
[labels, num] = bwlabel(filledEdges);

% Measure properties of the labeled regions (cells)
stats = regionprops(labels, 'Area', 'BoundingBox');

% Initialize counters for each category
countNormal = 0;
countLP = 0;
countMP = 0;
countHP = 0;

% Display the original image with boundaries of cells based on classification
figure, imshow(img), title('Classified Cells with Area Ranges');
hold on;

% Loop through all cells and classify based on area
fprintf('Area of all detected cells:\n');
for k = 1:num
    % Calculate area in micrometers
    areaUm = stats(k).Area * (pixelToUmFactor^2);
    bbox = stats(k).BoundingBox;
    
    % Classify the cell based on area ranges from thresholds
    if areaUm >= thresholds.HP.Area(1) && areaUm <= thresholds.HP.Area(2)
        countHP = countHP + 1;
        rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 1.5); % HP in red
    elseif areaUm >= thresholds.MP.Area(1) && areaUm <= thresholds.MP.Area(2)
        countMP = countMP + 1;
        rectangle('Position', bbox, 'EdgeColor', 'g', 'LineWidth', 1.5); % MP in green
    elseif areaUm >= thresholds.LP.Area(1) && areaUm <= thresholds.LP.Area(2)
        countLP = countLP + 1;
        rectangle('Position', bbox, 'EdgeColor', 'b', 'LineWidth', 1.5); % LP in blue
    elseif areaUm >= thresholds.Normal.Area(1) && areaUm <= thresholds.Normal.Area(2)
        countNormal = countNormal + 1;
        rectangle('Position', bbox, 'EdgeColor', 'y', 'LineWidth', 1.5); % Normal in yellow
    end
    
    % Display area for each cell in the command window
    fprintf('Cell %d: Area = %.2f µm²\n', k, areaUm);
end

hold off;

% Display counts for each category
fprintf('\nNumber of cells in each category:\n');
fprintf('HP (High): %d\n', countHP);
fprintf('MP (Medium): %d\n', countMP);
fprintf('LP (Low): %d\n', countLP);
fprintf('Normal: %d\n', countNormal);

% Determine the predicted malaria type based on priority rules
if countHP > 0
    malariaType = 'HP';
elseif countMP > 0
    malariaType = 'MP';
elseif countLP > 0
    malariaType = 'LP';
else
    malariaType = 'Normal';
end

% Output the final prediction based on priority rules
fprintf('\nPredicted Malaria Type based on priority: %s\n', malariaType);

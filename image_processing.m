clc;
clear all;
close all;

% Define the folder containing the images
imageFolder = 'C:/Users/Sakshi Singh/Downloads/Malaria/HP';

% Define the pixel-to-micrometer conversion factor (based on your calibration)
pixelToUmFactor = 0.126; % 1 pixel = 0.126 µm

% Get a list of all BMP files in the folder
imageFiles = dir(fullfile(imageFolder, '*.bmp'));

% Initialize a table to store results
resultsTable = table();

% Loop through each image in the folder
for imgIdx = 1:length(imageFiles)
    % Read the image
    imgPath = fullfile(imageFolder, imageFiles(imgIdx).name);
    img = imread(imgPath);

    % Display the original image
    figure, imshow(img);
    title(['Original Image: ', imageFiles(imgIdx).name]);

    % Convert to grayscale
    grayImg = rgb2gray(img);

    % Display the grayscale image
    figure, imshow(grayImg);
    title(['Grayscale Image: ', imageFiles(imgIdx).name]);

    % Apply a median filter to reduce noise
    filteredImg = medfilt2(grayImg);

    % Display the filtered image
    figure, imshow(filteredImg);
    title(['Median Filtered Image: ', imageFiles(imgIdx).name]);

    % Perform edge detection using Canny edge detector
    edges = edge(filteredImg, 'canny');

    % Display the edge-detected image
    figure, imshow(edges);
    title(['Edges (Canny): ', imageFiles(imgIdx).name]);

    % Use morphological operations to fill gaps in the edges
    filledEdges = imfill(edges, 'holes');

    % Display the filled edges image
    figure, imshow(filledEdges);
    title(['Filled Edges: ', imageFiles(imgIdx).name]);

    % Label connected components (cells) in the image
    [labels, num] = bwlabel(filledEdges);

    % Measure properties of the labeled regions (cells)
    stats = regionprops(labels, 'Area', 'Perimeter', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');

    % Define area and perimeter range for perfect cells (adjust these thresholds based on your output)
    minArea = 2600;  % Lower bound for area (in pixels)
    maxArea = 4000;  % Upper bound for area (in pixels)
    minPerimeter = 50;  % Lower bound for perimeter (in pixels)
    maxPerimeter = 400;  % Upper bound for perimeter (in pixels)

    % Filter cells based on both area and perimeter range
    filteredCells = find([stats.Area] > minArea & [stats.Area] < maxArea & ...
                         [stats.Perimeter] > minPerimeter & [stats.Perimeter] < maxPerimeter);

    % Create a mask for the selected cells
    cellMasks = ismember(labels, filteredCells);

    % Fill the selected cells with a color (e.g., green [0, 255, 0])
    colorFilledImg = img; % Copy of the original image
    colorFilledImg(:,:,1) = colorFilledImg(:,:,1) .* uint8(~cellMasks); % Red channel
    colorFilledImg(:,:,2) = colorFilledImg(:,:,2) .* uint8(~cellMasks) + uint8(cellMasks) * 255; % Green channel
    colorFilledImg(:,:,3) = colorFilledImg(:,:,3) .* uint8(~cellMasks); % Blue channel

    % Display the final highlighted cells image
    figure, imshow(colorFilledImg);
    title(['Selected Cells Highlighted: ', imageFiles(imgIdx).name]);

    % Append cell data to the results table
    if ~isempty(filteredCells)
        for i = 1:length(filteredCells)
            cellIndex = filteredCells(i);

            % Calculate Form Factor (FF)
            FF = (stats(cellIndex).Perimeter^2) / (4 * pi * stats(cellIndex).Area);

            % Calculate Circularity Factor (CF)
            CF = stats(cellIndex).MajorAxisLength / stats(cellIndex).MinorAxisLength;

            % Calculate Deviation Factor (DF)
            DF = CF / stats(cellIndex).Area;

            % Append results
            resultsTable = [resultsTable; table({imageFiles(imgIdx).name}, ...
                                                cellIndex, ...
                                                stats(cellIndex).Area, ...
                                                stats(cellIndex).Area * pixelToUmFactor^2, ...
                                                stats(cellIndex).Perimeter, ...
                                                stats(cellIndex).Perimeter * pixelToUmFactor, ...
                                                FF, CF, DF, ...
                                                'VariableNames', {'ImageName', 'CellIndex', 'Area_Pixels', 'Area_um', 'Perimeter_Pixels', 'Perimeter_um', 'FormFactor', 'CircularityFactor', 'DeviationFactor'})];
        end
    end
end

% Display the results table and calculate statistics
disp(resultsTable);

% Calculate mean and standard deviation
numericColumns = {'Area_um', 'Perimeter_um', 'FormFactor', 'CircularityFactor', 'DeviationFactor'};
for i = 1:length(numericColumns)
    columnData = resultsTable.(numericColumns{i});
    fprintf('%s: Mean = %.2f, Std Dev = %.2f\n', numericColumns{i}, mean(columnData), std(columnData));
end

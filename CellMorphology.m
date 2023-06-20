clear all; close all; clc;

% Check if file is located in the computer
baseFileName = 'CellImage.tif'; %change '...' to search for file
folder = fileparts(which(baseFileName)); % Determine where demo folder is.
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	% Search for file if it doesn't exist in the current folder.
	if ~exist(baseFileName, 'file')
		% If cannot find file then doesn't exist on the search path either.
		% Alert user that we can't find the image file.
		warningMessage = sprintf('Error: the input image file\n%s\nwas not found.\nClick OK to exit the demo.', fullFileName);
		uiwait(warndlg(warningMessage));
		fprintf(1, 'Finished running MastCellMorpholoy.m.\n');
		return;
	end
	% If the file is found in the search path.  Construct the file name.
	fullFileName = baseFileName;
end

% Read image from desktop file and add original image to plot
I = imread(fullFileName);
subplot(3,3,1);
imshow(I);

% Image title
title('Mast Cells');

% Detecting cell and converting to gray scale
% Binary image
I=rgb2gray(I);
[~,threshold] = edge(I,'canny');
fudgeFactor = 0.5;
BWs = edge(I,'canny',threshold * fudgeFactor);

% Add binary image on plot
subplot(3,3,2);
imshow(BWs);
title('Binary Gradiest Image');
axis image; 

% Dilate Image
% High contrast image for outlining the object (cell)
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

% Dilate the binary cell
BWsdil = imdilate(BWs, [se90 se0]);

% Add dilated image to plot
subplot(3,3,3);
imshow(BWsdil);
title('Dilated test');
axis image; 

% Fill Cell for total size
BWdfill = imfill(BWsdil, 'holes');

% Add processed image to plot
subplot(3,3,4);
imshow(BWdfill);
title('Dilated with filled holes');
axis image; 

% Removing Connected objects
BWnoborder = imclearborder(BWdfill, 1);

% Adding processed image to plot
subplot(3,3,5);
imshow(BWnoborder);
title('Cleared Border');
axis image; 

% Smooth Cell border to filter more noise.
seD = strel('diamond',1);
BWfinal = imerode(BWnoborder,seD);
BWfinal = imerode(BWfinal,seD);

% Adding smooth cell images to plot
subplot(3,3,6);
imshow(BWfinal);
title('Smooth Cell Test');
axis image; 

% Visualizing Segmentation
subplot(3,3,7);
imshow(labeloverlay(I,BWfinal));
title('Mast Cell Overlay Image');
axis image; 

% Outlining cell while also measureing values of each outline.
filteredImage = bwlabel(BWfinal, 8);

% Taking measuremenst of cell for morphology analysis
cell_Measurements = regionprops('table', filteredImage, I, 'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength'); 
cell_MeasurementsReduced = cell_Measurements(cell_Measurements.Area >= 2000, :); %adjust '2000' value based on noise values to include more or less cells
subplot(3, 3, 8);
imshow(I);
title('outlines', 'FontSize', 14);
axis image;
hold on;
boundaries = bwboundaries(BWfinal);
colors = ['r'; 'g'; 'b'; 'y'; 'm'; 'c']; %need to adjust color value based on # of cells in image.
numberOfBoundaries = size(boundaries, 1);
n = 1;
for k = 1 : numberOfBoundaries
    if cell_Measurements.Area(k) >= 2000
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), colors(n), 'LineWidth', 2);
        n = n + 1;
    end 
end
legend(string(cell_MeasurementsReduced.Area))
hold off;

cell_Measurements(cell_Measurements.Area <= 2000, :) = [];

% Produces data table in command window
cellTable = table(cell_Measurements)

% Maximize window size of images in 3x3
set(gcf, 'units','normalized','outerposition',[0 0 0.75 0.75]);



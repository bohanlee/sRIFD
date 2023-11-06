function pts = detectFASTFeatures(I, varargin)
% detectFASTFeatures Find corners using the FAST algorithm
%   points = detectFASTFeatures(I) returns a cornerPoints object,
%   points, containing information about the feature points detected in a
%   2-D grayscale image I. detectFASTFeatures uses the Features from
%   Accelerated Segment Test (FAST) algorithm to find feature points.
%
%   points = detectFASTFeatures(I,Name,Value) specifies additional
%   name-value pair arguments described below:
%
%   'MinQuality'   A scalar Q, 0 <= Q <= 1, specifying the minimum accepted
%                  quality of corners as a fraction of the maximum corner
%                  metric value in the image. Larger values of Q can be
%                  used to remove erroneous corners.
%
%                  Default: 0.1
%
%   'MinContrast'  A scalar T, 0 < T < 1, specifying the minimum intensity
%                  difference between a corner and its surrounding region,
%                  as a fraction of the maximum value of the image class.
%                  Increasing the value of T reduces the number of detected
%                  corners.
%
%                  Default: 0.2
%
%   'ROI'          A vector of the format [X Y WIDTH HEIGHT], specifying
%                  a rectangular region in which corners will be detected.
%                  [X Y] is the upper left corner of the region.
%
%                 Default: [1 1 size(I,2) size(I,1)]
%
% Class Support
% -------------
% The input image I can be logical, uint8, int16, uint16, single, or
% double, and it must be real and nonsparse.
%
% Example
% -------
% % Find and plot corner points in the image.
% I = imread('cameraman.tif');
% corners = detectFASTFeatures(I);
% imshow(I)
% hold on
% plot(corners.selectStrongest(50))
%
% See also cornerPoints, detectHarrisFeatures, detectMinEigenFeatures,
%          detectBRISKFeatures, detectSURFFeatures, detectMSERFeatures,
%          detectORBFeatures, extractFeatures, matchFeatures

% Reference
% ---------
% E. Rosten and T. Drummond. "Fusing Points and Lines for High
% Performance Tracking." Proceedings of the IEEE International
% Conference on Computer Vision Vol. 2 (October 2005): pp. 1508?1511.

% Copyright  The MathWorks, Inc.

%#codegen
%#ok<*EMCA>

% Check the input image and convert it to the range of uint8.

params = parseInputs(I, varargin{:});

I_u8 = im2uint8(I);

[I_u8c, expandedROI] = vision.internal.detector.fast.cropImage(I_u8, params);

% Convert the minContrast property to the range of unit8.
minContrast = im2uint8(params.MinContrast);

% Find corner locations by using OpenCV.
if isSimMode()
    rawPts = ocvDetectFAST(I_u8c, minContrast);
else
    [rawPts_loc,  rawPts_metric] = vision.internal.buildable.detectFASTBuildable.detectFAST_uint8(I_u8c, minContrast);
    rawPts.Location = rawPts_loc;
    rawPts.Metric = rawPts_metric;
end

[locations, metricValues] = vision.internal.detector.applyMinQuality(rawPts, params);

if params.usingROI
    % Because the ROI was expanded earlier, we need to exclude corners
    % which are outside the original ROI.
    [locations, metricValues] ...
        = vision.internal.detector.excludePointsOutsideROI(...
        params.ROI, expandedROI, locations, metricValues);
end

% Pack the output into a cornerPoints object.
pts = cornerPoints(locations, 'Metric', metricValues);

%==========================================================================
function params = parseInputs(I,varargin)
if isSimMode()
    params = vision.internal.detector.fast.parseInputs(I, varargin{:});
else
    params = parseInputs_cg(I,varargin{:});
end

%==========================================================================
function params = parseInputs_cg(I,varargin)

vision.internal.inputValidation.validateImage(I, 'I', 'grayscale');

imageSize = size(I);

% Optional Name-Value pair: 3 pairs (see help section)
defaults = vision.internal.detector.fast.getDefaultParameters(imageSize);
defaultsNoVal = getDefaultParametersNoVal();
properties    = getEmlParserProperties();

optarg = eml_parse_parameter_inputs(defaultsNoVal, properties, varargin{:});
params.MinQuality = (eml_get_parameter_value( ...
        optarg.MinQuality, defaults.MinQuality, varargin{:}));
params.MinContrast = (eml_get_parameter_value( ...
    optarg.MinContrast, defaults.MinContrast, varargin{:}));
ROI = (eml_get_parameter_value( ...
    optarg.ROI, defaults.ROI, varargin{:}));

usingROI = ~(optarg.ROI==uint32(0));

if usingROI
    params.usingROI = true;
    vision.internal.detector.checkROI(ROI, imageSize);
else
    params.usingROI = false;
end

params.ROI = vision.internal.detector.roundAndCastToInt32(ROI);

vision.internal.detector.checkMinQuality(params.MinQuality);
vision.internal.detector.checkMinContrast(params.MinContrast);

%==========================================================================
function defaultsNoVal = getDefaultParametersNoVal()

defaultsNoVal = struct(...
    'MinQuality', uint32(0), ...
    'MinContrast', uint32(0), ...
    'ROI', uint32(0));

%==========================================================================
function properties = getEmlParserProperties()

properties = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', false);

%==========================================================================
function flag = isSimMode()

flag = isempty(coder.target);




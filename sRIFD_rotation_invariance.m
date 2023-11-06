% This is a samplest implementation of the proposed sRIFD algorithm. In this implementation,...
% rotation invariance part and corner point detection are not included.

function [des_m1,des_m2,or1,or2] = sRIFD_rotation_invariance(im1,im2,s,o)

% m1 and m2 are the maximum moment maps;
% eo1{s,o} = convolution result for scale s and orientation o.
% The real part is the result of convolving with the even symmetric filter,
% the imaginary part is the result from convolution with the odd symmetric filter.

[m1,M1,or1,~,~,eo1,~] = phasecong3(im1,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
[m2,M2,or2,~,~,eo2,~] = phasecong3(im2,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);



a=max(m1(:)); b=min(m1(:)); m1=(m1-b)/(a-b);
a=max(m2(:)); b=min(m2(:)); m2=(m2-b)/(a-b);

a=max(M1(:)); b=min(M1(:)); M1=(M1-b)/(a-b);
a=max(M2(:)); b=min(M2(:)); M2=(M2-b)/(a-b);

% FAST detector on the maximum moment maps to extract edge feature points.
m1_points = detectFASTFeatures(m1,'MinContrast',0.0001,'MinQuality',0.0001);
m2_points = detectFASTFeatures(m2,'MinContrast',0.0001,'MinQuality',0.0001);


m1_points=m1_points.selectStrongest(5000);   %number of keypoints can be set by users
m2_points=m2_points.selectStrongest(5000);


M1_points = detectFASTFeatures(M1,'MinContrast',0.0001,'MinQuality',0.0001);
M2_points = detectFASTFeatures(M2,'MinContrast',0.0001,'MinQuality',0.0001);

M1_points=M1_points.selectStrongest(1);   %number of keypoints can be set by users
M2_points=M2_points.selectStrongest(1);



% RIFT descriptor
im11=imrotate(im1,15);
im22=imrotate(im2,15);

[m1,~,or1,~,~,eo11,~] = phasecong3(im11,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
[m2,~,or2,~,~,eo22,~] = phasecong3(im22,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);



pt1=[m1_points.Location;M1_points.Location];
pt2=[m2_points.Location;M2_points.Location];

des_m1 = fct_calc_log_sRIFD_no_dominant(im1, pt1,eo1,  s,o);
des_m2 = fct_calc_log_sRIFD_no_dominant(im2, pt2,eo2, s,o);






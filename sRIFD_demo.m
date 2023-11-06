% % This is a simplest implementation of the proposed sRIFD algorithm. In this implementation,...
% % rotation invariance part and corner point detection are not included.
% % created by Bohan Li
% % 09/23/2023
clc;clear;close all;
warning('off')
tic;
addpath LC09  % type of multi-modal data
%
str1='D:\华为云盘\sRIFD\LC09\2_RGB.tif';   % image pair
str2='D:\华为云盘\sRIFD\LC09\2_B10.tif';
im1 = im2uint8(imread(str1));
im2 = im2uint8(imread(str2));
% im1=imresize(im1,[512,512]);
% im2=imresize(im2,[512,512]);
deg=0;
%im2=imrotate(im2,deg,'crop');
if size(im1,3)==1
    temp=im1;
    im1(:,:,1)=temp;
    im1(:,:,2)=temp;
    im1(:,:,3)=temp;
end

if size(im2,3)==1
    temp=im2;
    im2(:,:,1)=temp;
    im2(:,:,2)=temp;
    im2(:,:,3)=temp;
end

disp('sRIFD feature detection and description')
tic;
% sRIFD feature detection and description
[des_m1,des_m2,or1,or2] =  sRIFD_rotation_invariance(im1,im2,4,12);

disp('nearest matching')
temp=0



for ii=1:24
    % nearest matching
    des1=des_m1.des(1,:,:);
    des1=squeeze(des1)';
    des2=des_m2.des(ii,:,:);
    des2=squeeze(des2)';

    [indexPairs,matchmetric] = matchFeatures(des1,des2,'MaxRatio',1,'MatchThreshold', 100);
    matchedPoints1 = des_m1.kps(indexPairs(:, 1), :);
    matchedPoints2 = des_m2.kps(indexPairs(:, 2), :);
    [matchedPoints2,IA]=unique(matchedPoints2,'rows');
    matchedPoints1=matchedPoints1(IA,:);

    disp('outlier removal')
    %outlier removal
    H=FSC(matchedPoints1,matchedPoints2,'affine',2);
    Y_=H*[matchedPoints1';ones(1,size(matchedPoints1,1))];
    Y_(1,:)=Y_(1,:)./Y_(3,:);
    Y_(2,:)=Y_(2,:)./Y_(3,:);
    E=sqrt(sum((Y_(1:2,:)-matchedPoints2').^2));
    inliersIndex=E<3;

    if sum(inliersIndex)>temp
        temp=sum(inliersIndex)
        finInliners=inliersIndex;
        finalMatchedPoints1=matchedPoints1;
        finalMatchedPoints2=matchedPoints2;
        finalH=H;
    end
end



cleanedPoints1 = finalMatchedPoints1(finInliners, :);
cleanedPoints2 = finalMatchedPoints2(finInliners, :);
disp('Show matches')
% orn=zeros(length(cleanedPoints1),2);
% for i =1:length(c`leanedPoints1)
%     orn(i,1)=or1(cleanedPoints1(i,1),cleanedPoints1(i,2))
%     orn(i,2)=or1(cleanedPoints2(i,1),cleanedPoints1(2,2))
% end
endtime=toc;
disp(['运行时间：', num2str(endtime), ' 秒']);
% Show results
figure; showMatchedFeatures(im1, im2, cleanedPoints1, cleanedPoints2, 'montage');

disp('registration result')
% registration
image_fusion(im2,im1,double(finalH));


function [ des_out ] = fct_calc_log_sRIFD_no_dominant( im,kps,eo,s,o )

[yim,xim,~] = size(im);
KPS=kps';



CS = zeros(yim, xim, o); %convolution sequence
for j=1:o
    for i=1:s
        CS(:,:,j)=CS(:,:,j)+abs(eo{i,j});
    end
end
[~, MIM] = max(CS,[],3); % MIM maximum index map
[x_MIM,y_MIM]=size(MIM);
MIM2=zeros(size(MIM));


for i=1:x_MIM
    for j=1:y_MIM
        MIM2(i,j)=floor(MIM(i,j)/2);
        if(MIM2(i,j)==0)
            MIM2(i,j)=6;
        end
    end
end

for i=1:x_MIM
    for j=1:y_MIM
        MIM(i,j)=ceil(MIM(i,j)/2);

    end
end




num_mag_bin = 2;
num_ori_bin = 12;
num_ori_per_block = 6;

des_len = (num_ori_bin  * num_mag_bin + 1) * num_ori_per_block;
des_out = zeros( num_ori_per_block*4, des_len, size(KPS,2) );

kps_to_ignore=zeros( 1, size(kps,1) );

hist_ary = zeros(num_ori_per_block, num_ori_bin, num_mag_bin);


desPca=zeros(size(KPS,2),18);

radius=round(min(26*1.8510,min(yim,xim)/3));
r1=log2(radius*0.73*0.25)
r2=log2(radius*0.73)

[XX,YY] = meshgrid( -1 * radius:1:radius, -1 * radius:1:radius );
log_angle=atan2(YY,XX);
log_angle=log_angle/pi * 180;
log_angle = mod( log_angle, 360 );


c_rot=XX;
r_rot=YY;
% e.g., [-15, 15] -> 0, [15, 45] -> 1x
angle_block = log_angle + 360/num_ori_bin * 1/2;

log_angle=round(log_angle*12/360);

log_angle(log_angle<=0)=log_angle(log_angle<=0)+12;
log_angle(log_angle>12)=log_angle(log_angle>12)-12;

log_amplitude=log2(sqrt(c_rot.^2+r_rot.^2));
log_amplitude(log_amplitude<=r1)=1;
log_amplitude(log_amplitude>r1 & log_amplitude<=r2)=2;
log_amplitude(log_amplitude>r2)=3;




log_angle1=atan2(YY,XX);
log_angle1=log_angle1/pi * 180+15;
log_angle1 = mod( log_angle1, 360 );
% e.g., [-15, 15] -> 0, [15, 45] -> 1x


log_angle1=round(log_angle1*12/360);

log_angle1(log_angle1<=0)=log_angle1(log_angle1<=0)+12;
log_angle1(log_angle1>12)=log_angle1(log_angle1>12)-12;



r=yim;
c=xim;
degree=15;

nH=round(r*abs(cosd(degree))+c*abs(sind(degree)));                    %旋转图像后得到的新高度，“round()函数四舍五入“
nW=round(c*abs(cosd(degree))+r*abs(sind(degree)));                    %旋转图像后得到的新宽度
                                                 %定义生成目标图像的行列以及通道数
% M1=[1 0 0;0 -1 0;-0.5*nW 0.5*nH 1 ];                                  %坐标系变换矩阵M1
% M2=[cosd(degree) -sind(degree) 0;sind(degree) cosd(degree) 0;0 0 1];  %角度旋转变换矩阵M2，我用的是顺时针方向
% M3=[1 0 0;0 -1 0;0.5*c 0.5*r 1]; 




for k=1:size(KPS,2)
    
    
    idx = round( kps(k, 1) );
    idy = round( kps(k, 2) );
    
    left_border = idx - radius;
    right_border = idx + radius;
    up_border = idy - radius;
    down_border = idy + radius;
    
    
    
    
    
    
    
    
    center_x=idx-left_border+1;
    center_y=idy-up_border+1;
    if left_border<1 || right_border>=xim ||up_border<1 || down_border>=yim
        kps_to_ignore(k)=1; % kps_to_ignore(i)=1;
        continue;
    end
    
    sub_gradient=MIM(up_border: down_border, left_border:right_border);
    
    
    
    temp_hist=zeros(1,(2*12+1)*6);
    
    hist_ary = zeros(num_ori_per_block, num_ori_bin, num_mag_bin);
    center_circ = zeros(num_ori_per_block,1);
    [row,col]=size(log_angle);
    
    inner_ary=zeros(num_ori_per_block,num_ori_bin);
    
    for i=1:1:row
        for j=1:1:col
            if(((i-center_y)^2+(j-center_x)^2)<=radius^2)
                angle_bin=log_angle(i,j);
                amplitude_bin=log_amplitude(i,j);
                bin_vertical=sub_gradient(i,j);
                Mag=sub_gradient(i,j);
                
                if(amplitude_bin==1)
                    inner_ary((angle_bin-1)*6+bin_vertical)=1+inner_ary((angle_bin-1)*6+bin_vertical);
                    temp_hist(bin_vertical)=temp_hist(bin_vertical)+1;
                    center_circ( bin_vertical ) = center_circ( bin_vertical ) + 1;
                else

                    
                    temp_hist(((amplitude_bin-2)*12+angle_bin-1)*6+bin_vertical+6)=...
                        temp_hist(((amplitude_bin-2)*12+angle_bin-1)*6+bin_vertical+6)+1;
                    
                    
                    hist_ary(bin_vertical ,angle_bin,amplitude_bin-1) = ...
                        hist_ary(bin_vertical ,angle_bin,amplitude_bin-1) + 1;
                end
            end
        end
    end
    

    
    idx1=idx;
    idy1=idy;
    
    
    
     left_border1 = idx1 - radius;
    right_border1 = idx1 + radius;
    up_border1 = idy1 - radius;
    down_border1 = idy1 + radius;
    
    
    
    
    
    
    
    
    center_x1=idx1-left_border1+1;
    center_y1=idy1-up_border1+1;

    sub_gradient1=MIM2(up_border1: down_border1, left_border1:right_border1);
    
    
    
    temp_hist1=zeros(1,(2*12+1)*6);
    
    hist_ary1 = zeros(num_ori_per_block, num_ori_bin, num_mag_bin);
    center_circ1 = zeros(num_ori_per_block,1);
    [row,col]=size(log_angle);
    
    for i=1:1:row
        for j=1:1:col
            if(((i-center_y1)^2+(j-center_x1)^2)<=radius^2)
                angle_bin=log_angle1(i,j);
                amplitude_bin=log_amplitude(i,j);
                bin_vertical=sub_gradient1(i,j);
                Mag=sub_gradient1(i,j);
                
                if(amplitude_bin==1)
                    temp_hist1(bin_vertical)=temp_hist1(bin_vertical)+1;
                    center_circ1( bin_vertical ) = center_circ1( bin_vertical ) + 1;
                else

                    
                    temp_hist1(((amplitude_bin-2)*12+angle_bin-1)*6+bin_vertical+6)=...
                        temp_hist1(((amplitude_bin-2)*12+angle_bin-1)*6+bin_vertical+6)+1;
                    
                    
                    hist_ary1(bin_vertical ,angle_bin,amplitude_bin-1) = ...
                        hist_ary1(bin_vertical ,angle_bin,amplitude_bin-1) + 1;
                end
            end
        end
    end
    
    des_rotate = zeros(num_ori_bin*2, des_len ) ;
            des_temp = [  center_circ(:);hist_ary(:)];
         des_temp = des_temp/norm(des_temp);
         des_temp (des_temp > 0.2) = 0.2;
         des_temp = des_temp/norm(des_temp);
        des_rotate(1,:) = des_temp;
     
    for ii = 2:12 
        hist_ary = circshift(hist_ary, [-1, +1]);
        center_circ = circshift ( center_circ, -1 );

         des_temp = [  center_circ(:);hist_ary(:)];
         des_temp = des_temp/norm(des_temp);
         des_temp (des_temp > 0.2) = 0.2;
         des_temp = des_temp/norm(des_temp);
        des_rotate(ii,:) = des_temp;
    end
    
    des_temp = [  center_circ1(:);hist_ary1(:)];
         des_temp = des_temp/norm(des_temp);
         des_temp (des_temp > 0.2) = 0.2;
         des_temp = des_temp/norm(des_temp);
        des_rotate(13,:) = des_temp;
     
    for ii = 13:24

        hist_ary1 = circshift(hist_ary1, [-1, +1]);
        center_circ1 = circshift ( center_circ1, -1 );
         des_temp = [  center_circ1(:);hist_ary1(:)];
         des_temp = des_temp/norm(des_temp);
         des_temp (des_temp > 0.2) = 0.2;
         des_temp = des_temp/norm(des_temp);
        des_rotate(ii,:) = des_temp;
    end
    
    
    
    %des_rotate(1,:)=temp_hist;
    des_out(:,:, k)=des_rotate;
end

des_out = struct('kps', KPS(:,kps_to_ignore ==0)', 'des', des_out(:,:,kps_to_ignore==0));
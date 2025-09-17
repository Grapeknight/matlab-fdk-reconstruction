% 1. **图像预处理**：提取每张图像中的物体轮廓。
% 2. **形状从轮廓重建**：利用轮廓在 3D 空间中生成视觉体素。
% 3. **后处理**：从体素生成3D表面，并进行优化。

% 假设你有图像保存在一个文件夹中
clear all
close all
image_folder = uigetdir();
image_files = dir(fullfile(image_folder, '*.TIF')); % 更换为你的图像格式

[~, order] = sort({image_files.date});
sortedFiles = image_files(order);
num_images = length(image_files);
    img = imread(fullfile(image_folder, image_files(num_images).name));
    imgsize=size(img,[1 2])
figure,imshow(img)
    gray_img = rgb2gray(img);
    Bw_image=gray_img>40;
    Bw_image_c=imclose(bwareaopen(Bw_image,30000),strel('disk',600));
    Bw_image_ce=imerode(Bw_image_c,strel('disk',50));
figure,imshow(Bw_image_ce&gray_img<50)
figure,imshow(Bw_image_ce)
ROI=Bw_image_ce;
ROIrect=regionprops(ROI,'BoundingBox');

ROIrect=ROIrect.BoundingBox;
ROI_roi=imcrop(ROI,ROIrect);



volume_size = [imgsize(2),imgsize(2), imgsize(1)]; % 调整以你的具体需求

volume_img=uint8(volume_size);

% 创建高斯滤波器
h = fspecial('gaussian', [15 15], 1); % 5x5的窗口，sigma的高斯核


% 初始化，存储所有轮廓
contours = cell(num_images, 1);

for k = 1:num_images
    i=order(k);
    img = imread(fullfile(image_folder, image_files(i).name));
    ROI_img=imcrop(img,ROIrect);
    ROI_img(:,:,1)=max(median(ROI_img(:,:,1),'all').*uint8(~ROI_roi),ROI_img(:,:,1));
    ROI_img(:,:,2)=max(median(ROI_img(:,:,2),'all').*uint8(~ROI_roi),ROI_img(:,:,2));
    ROI_img(:,:,3)=max(median(ROI_img(:,:,3),'all').*uint8(~ROI_roi),ROI_img(:,:,3));

ROI_img=imfilter(ROI_img,h);

scal=0.2;
% figure,imshow(rgb2gray(imresize(ROI_img,scal))<60)
% figure,imshow(imresize(ROI_img,scal))
    [centersDark, radiiDark] =imfindcircles(~bwareaopen(rgb2gray(imresize(ROI_img,scal))<50,4000)&rgb2gray(imresize(ROI_img,scal))<50,[150*scal/2 270*scal/2],'ObjectPolarity','bright');%,'Method','TwoStage','Sensitivity',0.9

    viscircles(centersDark, radiiDark,'Color','b');
centersDark_A{i}=centersDark;
radiiDark_A{i}=radiiDark;

    % % 边缘检测，例如使用Canny
    % edges = edge(gray_img, 'canny');
    % % 找到轮廓
    % contours{i} = edges;
end
ball_cen=[];
figure,imshow(imresize(ROI_img,scal))
hold on
for i = 1:num_images
if ~isempty(centersDark_A{i})
plot(centersDark_A{i}(:,1),centersDark_A{i}(:,2),'go')
ball_cen=[ball_cen;centersDark_A{i}];
end
end
%寻找旋转轴
[idx, C] = kmeans(ball_cen, 2);

a=median(ball_cen(find(idx==1),:));
b=median(ball_cen(find(idx==2),:));

% angle=atan((C(1,1)-C(2,1))/(C(1,2)-C(2,2))).*180/pi
 angle=atan((a(1)-b(1))/(a(2)-b(2))).*180/pi



centersDark_A=[];
for k = 1:num_images
        i=order(k);

    img = imread(fullfile(image_folder, image_files(i).name));
    ROI_img=imcrop(img,ROIrect);
    ROI_img(:,:,1)=max(median(ROI_img(:,:,1),'all').*uint8(~ROI_roi),ROI_img(:,:,1));
    ROI_img(:,:,2)=max(median(ROI_img(:,:,2),'all').*uint8(~ROI_roi),ROI_img(:,:,2));
    ROI_img(:,:,3)=max(median(ROI_img(:,:,3),'all').*uint8(~ROI_roi),ROI_img(:,:,3));

ROI_img=imrotate(imfilter(ROI_img,h),-angle) ;

scal=0.2;
% figure,imshow(rgb2gray(imresize(ROI_img,scal))<80)
 % figure,imshow(imresize(ROI_img,scal))
    [centersDark, radiiDark] =imfindcircles(rgb2gray(imresize(ROI_img,scal))<80,[170*scal/2 250*scal/2],'ObjectPolarity','bright');%,'Method','TwoStage','Sensitivity',0.9

    % viscircles(centersDark, radiiDark,'Color','b');
centersDark_A{i}=centersDark;
radiiDark_A{i}=radiiDark;

    % % 边缘检测，例如使用Canny
    % edges = edge(gray_img, 'canny');
    % % 找到轮廓
    % contours{i} = edges;
end
ball_cen1=[];
figure,imshow(imresize(ROI_img,scal))
hold on
for i = 1:num_images
    if ~isempty(centersDark_A{i})
plot(centersDark_A{i}(:,1),centersDark_A{i}(:,2),'go')
ball_cen1=[ball_cen1;centersDark_A{i}];
    end

end

[idx, C] = kmeans(ball_cen1, 2);

acen=ball_cen1(find(idx==1),:);
bcen=ball_cen1(find(idx==2),:);
figure,imshow(imresize(ROI_img,scal))
hold on
plot(acen(:,1),acen(:,2),'go')
plot(bcen(:,1),bcen(:,2),'g*')


a=median(ball_cen1(find(idx==1),:));
b=median(ball_cen1(find(idx==2),:));
plot(a(1),a(2),'r+')
plot(b(1),b(2),'y+')


t_Raxis=(a(1)+b(1))/2/scal;
ROIrect;
r_Raxis=-angle;
[m,n]=size(ROI_img,[1 2]);
round(t_Raxis-min(n-t_Raxis,t_Raxis))
range=[round(t_Raxis-(min(n-t_Raxis,t_Raxis)-1100)): round(t_Raxis+(min(n-t_Raxis,t_Raxis)-1100))];








image_folder = uigetdir();
image_files = dir(fullfile(image_folder, '*.TIF')); % 更换为你的图像格式

[~, order] = sort({image_files.date});
sortedFiles = image_files(order);
num_images = length(image_files);
image_IR=[];
for i = 1:num_images
    img = imread(fullfile(image_folder, image_files(i).name));
    imgRoi=imcrop(img,ROIrect);
    imgRoiGray=rgb2gray(imgRoi);
    imgRoiGray(~ROI_roi)=nan;
    imgRoiGrayRote=imrotate(imgRoiGray,r_Raxis);

    image_IR(:,:,i)=imgRoiGrayRote(:,range);

end
figure,imshow(imgRoiGrayRote)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   IMPLEMENT SIMPLE BACKPROJECTION, i.e. 
%                PRODUCE LAMINOGRAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
image_IR0=imresize3(image_IR,[512 512 size(image_IR,3)]);
Data3D=[];
for sz=1:size(image_IR0,1)
na=num_images;
sinogram=double(image_IR0(sz,:,:));
nx=size(sinogram,2);
ny=size(sinogram,2);
c=reshape(sinogram,size(sinogram,[2 3]));
clear lamin
 disp('Simple backprojection')
 Radius=600;
 lamin = ifanbeam(c,Radius,'FanRotationIncrement',2.5,'FanSensorGeometry' ,'line');  %/180*pi
 laminx=lamin;
figure(66),imshow(laminx,[])
% if 1~=exist('lamin')
% 
%   lamin = zeros(nx,ny);  
%   laminX=[];
%   for ia = 1:na
%     disp(sprintf('angle %g of %g', ia, na));   
%     projection_ia=c(:,ia);   %each angle projection
%     projection_smear=reshape(repmat (projection_ia,1,nx),[nx ny]);  %smear current angle in 128*128
%    rot= imrotate(projection_smear', ia*180/2.5, 'bicubic','crop');  %256 projections correspond to 180 deg. Hence ia*180/256 for current projection angle
% 
%     lamin=lamin+rot;     %lamin needs to be 128*128 = so 1st arg in imrotate should be same dimension
%     laminX(:,:,ia)=rot;
%   end
%   laminx=median(laminX,3);
% 
% end
Data3D(:,:,sz)=lamin;
median(Data3D(:))
Data3Dmedian(:,:,sz)=laminx;
end
[N,val]=hist(double(Data3D(:)),256)
v=find((N/sum(N))>0.0015)
figure,plot(N/sum(N))
Data3Dx=Data3D;
Data3Dx(Data3Dx<val(v(1)))=val(v(1));
Data3Dx(Data3Dx>val(v(end)))=val(v(end));

Img_3D=uint16(((Data3Dx-min(Data3Dx(:)))/(max(Data3Dx(:))-min(Data3Dx(:))))*256*256);
for i=1:size(Data3D,3)
imwrite(Img_3D(:,:,i),['./res/' num2str(i,'%03d') '.png'])
im=Img_3D(:,:,i);
im3(:,:,1)=im;

im3(:,:,2)=im;
im3(:,:,3)=im;

    [I,map]=rgb2ind(im3,256); % 将RGB图像frame转换为索引图像I，map为关联颜色图

    if i==1
        % 第一张直接保存到视频目录下
        imwrite(I,map,strcat('/0.gif'),'gif','Loopcount',inf,'DelayTime',0.01);
    else
        % 剩下的每张图续接上一个图，每张图间隔为与视频中的一致（0.067s，帧率为30）
        imwrite(I,map,strcat('/0.gif'),'gif','WriteMode','Append','DelayTime',0.01);
    end

end

% 
% 
% Img_3D=uint8((Data3Dmedian/max(Data3Dmedian(:)))*256);
% for i=1:size(Data3D,3)
% imwrite(Img_3D(:,:,i),['./res2/' num2str(i,'%03d') '.png'])
% 
% 
% end
% Img_3Dx=Img_3D;
% Img_3Dx(~imclearborder(Img_3Dx<80))=255;
% figure,imshow(Img_3Dx(:,:,150),[])
% for i=1:size(Img_3Dx,3)
% imwrite(Img_3Dx(:,:,i),['./res2/' num2str(i,'%03d') '.png'])
% 
% 
% end

st=91
ed=436
for i=1:size(Img_3D,3)
    if i>st&&i<ed
       Img_3DN(:,:,i-st)=Img_3D(31:302,31:302,i-st);


    end
figure,imshow(Img_3D(:,:,436),[])
figure,imshow(Img_3D(:,:,250),[])

end
figure
N=hist(double(Img_3D(:)),256)
figure,plot(N)
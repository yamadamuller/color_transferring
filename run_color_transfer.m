clc, clear, close all

%Lê as imagens
path_ref = 'images/refs/';
img_ref = imread(string(path_ref)+'paper_1.jpg');
img_ref = im2double(img_ref);
ref_gs = rgb2gray(img_ref); %imagem de referência grayscale
ref_gs = im2double(ref_gs); %autocontraste
path_target = 'images/target/';
img_target = imread(string(path_target)+'paper_1.jpg'); %imagem target grayscale
img_target = rgb2gray(img_target); %grayscale
img_target = im2double(img_target); %autcontraste

%Roda o algoritmo de color transferring
color_target = framework.color_transferring(img_ref, ref_gs, img_target);

%plots
figure(1)
subplot(1,3,1)
imshow(img_ref)
title('Referência')
subplot(1,3,2)
imshow(img_target)
title('Target')
subplot(1,3,3)
imshow(color_target)
title('Transferência de Cor')
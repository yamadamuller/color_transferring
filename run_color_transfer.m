clc, clear, close all

%Lê as imagens
path_ref = 'images/refs/';
img_ref = imread(string(path_ref)+'aris.png');
img_ref = im2double(img_ref);
ref_gs = rgb2gray(img_ref); %imagem de referência grayscale
ref_gs = im2double(ref_gs); %autocontraste
path_target = 'images/target/';
img_target = imread(string(path_target)+'aris2.png'); %imagem target grayscale
img_target = rgb2gray(img_target); %grayscale
img_target = im2double(img_target); %autcontraste

%Roda o algoritmo de color matching
tic
color_target = framework.color_matching(img_ref, ref_gs, img_target, 'jitter');
toc

%plots
figure(1)
subplot(1,3,1)
imshow(img_ref)
title('Reference')
subplot(1,3,2)
imshow(img_target)
title('Target')
subplot(1,3,3)
imshow(color_target)
title('Color matching')

figure(2)
imshow(color_target)



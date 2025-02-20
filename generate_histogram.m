clc, clear all, close all
%Lê as imagens
path_ref = 'images/refs/';
img_ref = imread(string(path_ref)+'aris.png');
img_ref = im2double(img_ref);
ref_gs_og = rgb2gray(img_ref); %imagem de referência grayscale
ref_gs_og = im2double(ref_gs_og); %autocontraste
path_target = 'images/target/';
img_target = imread(string(path_target)+'aris_smile.jpg'); %imagem target grayscale
img_target = rgb2gray(img_target); %grayscale
img_target = im2double(img_target); %autcontraste

ref_img = rgb2lab(img_ref); %converte a imagem rgb para lab
ref_img_remap = framework.luminance_remapping(img_ref(:,:,1), img_target); %luminance remapping
ref_img(:,:,1) = ref_img_remap; %altera a luminância e mantém a cromaticidade (a e b) 
ref_gs = framework.luminance_remapping(ref_gs_og, img_target); %luminance remapping para ref gs

img_target = im2uint8(img_target);
ref_gs_og = im2uint8(ref_gs_og);
ref_gs = im2uint8(ref_gs);

figure
subplot(2,3,1), imshow(img_target), title('Objetivo')
subplot(2,3,4), imhist(img_target), title('Histograma')
axis tight % para não cortar y

subplot(2,3,2), imshow(ref_gs_og), title('Sem remapeamento')
subplot(2,3,5), imhist(ref_gs_og), title('Histograma')
axis tight % para não cortar y

subplot(2,3,3),imshow(ref_gs), title('Com remapeamento')
subplot(2,3,6),imhist(ref_gs), title('Histograma')
axis tight % para não cortar y
# About the repository
The color_transferring repo contains an implementation of the color transferring algorithm proposed by Tomihisa Welsh in [[1]](https://dl.acm.org/doi/10.1145/566654.566576). The method consists of matching the pixels from a grayscale image with the pixels from a colored image. The similarities are computed based on the luminance channel of the images and the standart deviation of a 5x5 pixel neighborhood. Then, from these statistical values, a weighted sum is applied to find the index of the pixel that has the most resemblance between the two images.

# Running the code
The project is organized as a library, and all the functions can be called from the static class "framework". However, if you require only the color transferring task, simply run the "run_color_transfer.m" script. It is encouraged to try the algorithm with different images. To achieve that, add the reference coloured image to the "images/refs/" path and the target one to 'images/target/'. Next, change the file names in lines (5,10) and run the script.

# Examples
The following example is based on Figures of the original paper

## Figure 1
![benchmark1](https://github.com/user-attachments/assets/bc655b46-2892-4c47-a736-b8f4303bfa9f)

## Figure 3(d)
![paper_3_d](https://github.com/user-attachments/assets/9dc22b73-ab7f-4691-b03a-93d99ae02540)

## Figure 3(f)
![paper_3_f](https://github.com/user-attachments/assets/667ba8e0-e592-4cb0-aa9d-e29279874dc2)

## Good luck amigo
hey alright

![aris](https://github.com/user-attachments/assets/5c99505a-4990-4cb7-a438-220ba78b4bfd)

 ![aris_color2](https://github.com/user-attachments/assets/55f41cab-8e8f-4d83-8152-fa6bd7f134d6)


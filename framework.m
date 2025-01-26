classdef framework
    methods (Static)
        function color_target = color_matching(ref_img, ref_gs, target_img, varargin)
            %%--- Argumentos da função----------------------------------------
            %ref_img: a matriz da imagem de referência
            %ref_gs: imagem de referência grayscale
            %target_img: a matriz da imagem grayscale que se deseja transferir a cromaticidade
            %varargin: argumento opcional que define se a busca por matches será brute force ou random jitter
            %retorna: a imagem grayscale com a cromaticidade transferida
            %-----------------------------------------------------------------
            %Acessa o argumento opcional para definir o tipo da imagem
            ref_img = rgb2lab(ref_img); %converte a imagem rgb para lab
            ref_img_remap = framework.luminance_remapping(ref_img(:,:,1), target_img); %luminance remapping
            ref_img(:,:,1) = ref_img_remap; %altera a luminância e mantém a cromaticidade (a e b) 
            ref_gs = framework.luminance_remapping(ref_gs, target_img); %luminance remapping para ref gs
            
            %Acessa o argumento opcional para definir o tipo do matching
            if ~isempty(varargin)
                if varargin{1} == 'jitter'
                    color_target = framework.jitter_matching(ref_img, ref_gs, target_img, 200); %define o tipo do algoritmo como o argumento
                elseif varargin{1} == 'global'
                    color_target = framework.global_matching(ref_img, ref_gs, target_img); %define o tipo do algoritmo como o argumento
                else
                    error('[framework.color_matching] Apenas "global" e "jitter" disponíveis!')
                end
            else
                color_target = framework.global_matching(ref_img, ref_gs, target_img); %global matching como defeito
            end
            
            color_target = lab2rgb(color_target); %converte lab para rgb
        end
        
        function std_img = std_filter2D(img, mask_size)
            %%--- Argumentos da função----------------------------------------
            %img: a matriz da imagem que se deseja aplicar o filtro do desvio padrão
            %mask_size: tamanho da máscara de convolução 
            %retorna: a imagem com filtro do desvio padrão para a máscara de tamanho "mask_size"
            %-----------------------------------------------------------------
            img = im2double(img); %converte a imagem para double para operação de filtragem
            [img_zp, pad] = framework.zero_padding(img, mask_size); %nova matriz que contém as bordas tratadas com zero padding
            
            %operação do filtro mediana
            std_img = zeros(size(img)); %a matriz final deve ter o tamanho da original
            %pixels (linha) da imagem original que serão tratados
            pxl_i = size(img,1); %linha
            pxl_j = size(img,2); %coluna
            for i = 1:pxl_i
                for j = 1:pxl_j
                    %pixels na matriz com zero padding que contemplam a operação atual
                    sub_idx_i = i:i+2*pad; %linha
                    sub_idx_j = j:j+2*pad; %coluna
                    sub_mtx = img_zp(sub_idx_i,sub_idx_j); %sub-matriz com os elementos que contemplam a operação atual
                    std_img(i,j) = std(sub_mtx(:)); %para [i,j] o pixel é o desvio padrão da sub-matriz
                end
            end
        end

        function [img_zp, pad] = zero_padding(img, mask_size)
            %%--- Argumentos da função----------------------------------------
            %img: a matriz da imagem que se deseja aplicar o zero padding
            %mask_size: tamanho da máscara de convolução para definir como será o padding
            %retorna: a imagem original com zero padding dada a dimensão da máscara e a constante de padding
            %-----------------------------------------------------------------
            pad = (mask_size-1)/2; %constante para aumentar o tamanho da matriz original 
            img_zp = padarray(img, [pad, pad]); %matriz com o zero padding na imagem original
        end
        
        function ref_remap = luminance_remapping(img_ref_lum, img_tar_lum)
            %%--- Argumentos da função----------------------------------------
            %img_ref_lum: o canal de luminância da imagem referência no domínio lab
            %img_tar_lum: o canal de luminância da imagem grayscale no domínio lab
            %retorna: o canal l da imagem referência remapeado com base na luminância da imagem grayscale
            %-----------------------------------------------------------------
            mu_ref = mean(img_ref_lum(:)); %média da luminância ref
            sigma_ref = std(img_ref_lum(:)); %desvio padrão ref
            mu_tar = mean(img_tar_lum(:)); %média da luminância gs
            sigma_tar = std(img_tar_lum(:)); %desvio padrão ref
            ref_remap = (sigma_tar/sigma_ref)*(img_ref_lum-mu_ref) + mu_tar; %luminance remapping
        end
        
        function img_match = global_matching(ref_img, ref_gs, target_img)
            %%--- Argumentos da função----------------------------------------
            %ref_img: a matriz da imagem de referência com lum. remapping
            %ref_gs: grayscale da imagem de referência com lum. remapping
            %target_img: a matriz da imagem grayscale que se deseja transferir a cromaticidade
            %retorna: a imagem target com a transferência em todos os pixels
            %-----------------------------------------------------------------
            sigma_filt_ref_gs = framework.std_filter2D(ref_gs, [5 5]); %filtro desvio padrão 5x5 img ref
            sigma_filt_tar = framework.std_filter2D(target_img, [5 5]); %filtro desvio padrão 5x5 img target
            
            %criar vetores para armazenar as luminâncias e os stds
            ref_gs_mat = [ref_gs(:), sigma_filt_ref_gs(:)]; %referencia gray
            tar_mat = [target_img(:), sigma_filt_tar(:)]; %target
            img_match = zeros([size(target_img),3]); %vetor que armazena as transferências (3 canais para LAB)
            img_match(:,:,1) = target_img*100;
            
            %Tranferência de cor bruta
            [tar_i, tar_j] = size(target_img); %linhas e colunas da imagem target
            for i = 1:tar_i
               for j = 1:tar_j
                  curr_idx = (i-1)+(j-1)*tar_i+1;
                  curr_match = framework.compare_pxl(tar_mat(curr_idx,:), ref_gs_mat); %busca pelo pixel equivalente
                  [ref_i, ref_j] = ind2sub(size(ref_img(:,:,1)), curr_match);
                  img_match(i,j,2:3) = ref_img(ref_i, ref_j, 2:3); %atualiza a cromaticidade para o pixel
               end
            end
        end
        
        function pxl_match = compare_pxl(target_mat, ref_mat)
            %%--- Argumentos da função----------------------------------------
            %target_pxl
            %ref_gs: grayscale da imagem de referência com lum. remapping
            %sigma_tar: os desvios padrões 5x5 do pixel atual da imagem tar
            %sigma_tar: os desvios padrões 5x5 do pixel atual da imagem ref gs
            %retorna: o pixel que representa a match entre as duas imagens
            %-----------------------------------------------------------------
            [ref_i, ~] = size(ref_mat); %linhas e colunas da imagem ref
            diff_mat = repmat(target_mat, ref_i, 1); %vetor composto i*j vezes pelos valores
            l2_norm = (diff_mat - ref_mat).^2; %norma L2
            weight_sum = 0.5*l2_norm(:,1) + 0.5*l2_norm(:,2); %soma ponderada
            [~, pxl_match] = min(weight_sum); %busca o índice de menor valor
        end
        
        function img_match = jitter_matching(ref_img, ref_gs, target_img, n_samples)
            %%--- Argumentos da função----------------------------------------
            %ref_img: a matriz da imagem de referência com lum. remapping
            %ref_gs: grayscale da imagem de referência com lum. remapping
            %target_img: a matriz da imagem grayscale que se deseja transferir a cromaticidade
            %retorna: a imagem target com a transferência em todos os pixels
            %-----------------------------------------------------------------
            %Estatística de desvio padrão baseado em vizinhança
            sigma_filt_ref_gs = framework.std_filter2D(ref_gs, [5 5]); %filtro desvio padrão 5x5 img ref
            sigma_filt_tar = framework.std_filter2D(target_img, [5 5]); %filtro desvio padrão 5x5 img target
            
            %criar vetores para armazenar as luminâncias e os stds
            tar_mat = [target_img(:), sigma_filt_tar(:)]; %target
            img_match = zeros([size(target_img),3]); %vetor que armazena as transferências (3 canais para LAB)
            img_match(:,:,1) = target_img*100;

            %Tranferência de cor baseada em jitter grid
            jitter_grid = framework.generate_jitter_grid(ref_gs, sigma_filt_ref_gs, n_samples); %gera a jitter grid com n_samples
            [tar_i, tar_j] = size(target_img); %linhas e colunas da imagem target
            for i = 1:tar_i
               for j = 1:tar_j
                  curr_idx = (i-1)+(j-1)*tar_i+1;
                  curr_match = framework.compare_jitter_pxl(tar_mat(curr_idx,:), jitter_grid); %busca pelo pixel equivalente   
                  img_match(i,j,2:3) = ref_img(curr_match(1), curr_match(2), 2:3); %atualiza a cromaticidade para o pixel
               end
            end
        end
        
        function jitter_grid = generate_jitter_grid(ref_gs, sigma_ref, n_samples)
            %%--- Argumentos da função----------------------------------------
            %ref_gs: grayscale da imagem de referência com lum. remapping
            %sigma_ref: matriz com os desvios padrões 5x5 da imagem de referência
            %n_samples: número de amostras utilizadas para a jitter grid
            %retorna: pixels da jitter grid da referência para realizar a busca
            %-----------------------------------------------------------------
            n = sqrt(n_samples); %divide as n_samples em uma grid quadrada
            [ref_i, ref_j] = size(ref_gs);
            passo_i = floor(ref_i/n); %passo no eixo x
            passo_j = floor(ref_j/n); %passo no eixo y
            jitter_samp = randi([1, passo_i*passo_j], 1, n_samples*2); %amostras aleatórias entre 1 e passo_i*passo_j
            jitter_grid = zeros([n_samples, 4]); %vetor para armazenar as pontos da jitter grid e os valores
            idx = 1;
            for i = 1:passo_i:ref_i-passo_i+1
                for j = 1:passo_j:ref_j-passo_j
                    curr_jitter = jitter_samp(idx); %índice atual da jitter grid
                    jit_j = ceil(curr_jitter/passo_i);%índice eixo x
                    jit_i = curr_jitter-(jit_j-1)*passo_i; %índice eixo y
                    jit_i = i+jit_i; %espalha em relação aos pixels da ref
                    jit_j = j+jit_j; %espalha em relação aos pixels da ref
                    jitter_grid(idx, :) = [ref_gs(jit_i, jit_j), sigma_ref(jit_i, jit_j), jit_i, jit_j]; %registra valores e indices
                    idx = idx + 1; %atualiza o índice de varredura
                end
            end 
            
            jitter_grid = jitter_grid(1:idx-1,:); %retira o último índice
        end
        
        function pxl_match = compare_jitter_pxl(target_mat, jitter_grid)
            %%--- Argumentos da função----------------------------------------
            %target_pxl
            %ref_gs: grayscale da imagem de referência com lum. remapping
            %sigma_tar: os desvios padrões 5x5 do pixel atual da imagem tar
            %sigma_tar: os desvios padrões 5x5 do pixel atual da imagem ref gs
            %retorna: o pixel que representa a match entre as duas imagens
            %-----------------------------------------------------------------
            [ref_i, ~] = size(jitter_grid); %linhas e colunas da jitter grid
            diff_mat = repmat(target_mat, ref_i, 1); %vetor composto i*j vezes pelos valores
            l2_norm = (diff_mat - jitter_grid(:,1:2)).^2; %norma L2
            weight_sum = 0.5*l2_norm(:,1) + 0.5*l2_norm(:,2); %soma ponderada
            [~, idx_match] = min(weight_sum); %busca o índice de menor valor
            pxl_match = jitter_grid(idx_match,3:4); %registra os pixels da imagem original
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                        PROGRAM K MEANS CLUSTERING                               %%
% CARA MENGGUNAKAN                                                                                  %
% 1 Pilih matfile citra                                                                             %
% 2 Lakukan cropping citra dengan memposisikan garis berhimpit dan tidak memotong dengan epicardial % 
% 3 Double klik pada ROI citra hasil cluster  untuk mendapatkan jumlah pixel                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;
%% MEMBUKA GAMBAR
[filename, pathname] = uigetfile;
load (fullfile(pathname, filename));
figure, imshow (pic,[]); 
title ('citra awal')
%% melakukan cropping
[x1,y1] = getline(); % klik kiri untuk membuat garis, klik kanan untuk mengakhiri (total ada 6 koord untuk persegi panjang)
[y2, x2] = meshgrid(1:size(pic,1), 1:size(pic,2)); %memperoleh koordinat citra awal
crop = inpolygon(x2, y2, x1, y1); %membuat koordinat hasil crop sama dengan koordinat citra awal
crop=crop'; %transpose crop
hold on;
plot(x1,y1,'r');

%% mencari koordinat dalam cropping bentuk persegi panjang

[y3,x3] = find(crop==1); %membuat hasil crop bernilai 1

for j = 1:length(x3)
    signal_crop(1,j) = pic(y3(j),x3(j));
end
image_crop=zeros(size(pic)); %membuaut citra hitam atau kosong seukuran citra awal
for j=1:length(x3)
    image_crop(y3(j),x3(j))=signal_crop(j);
end

figure;imshow(image_crop,[]);
title ('citra terpilih')
%% PENGOLAHAN MENGGUNAKAN K MEANS CLUSTERING

k=3; %jumlah cluster
max_iter=25; %iterasi maksimal
data = double(image_crop(:)); %mengubah dimensi citra ke satu dimensi
min_pix = min(data); % nilai pixel terkecil
max_pix = max(data); %nilai pixel terbesar
data = (data-min_pix)+1; % pengkondisian agar tidak ada nilai nol dan min
data = repmat(data,[1,k]); %replikasi nilai matriks sebanyak k
panjang = length(data); 
centroid = (1:k).* max_pix/(k+1); %inisiasi centroid
iter = 0;
while(true)
    iter = iter +1;%jumlah iterasi
centroid_awal = centroid; %menyimpan centroid iterasi sebelumnya

%MENGHITUNG JARAK TIAP PIXEL TERHADAP CENTROID
jarak = zeros(panjang, k);
for i = 1: panjang;
    jarak(i,:) = abs (data(i, :) - centroid);
end

%MEMASUKAN NILAI PIXEL KE CLUSTER TERDEKAT
[~, maskv] = min(jarak,[],2);

%UPDATE CENTROID
for i=1:k;
    index = (maskv==i);
    centroid(:,i) = sum(data(index))/length(find(index));
end

%HENTIKAN PROSES SAAT NILAI CENTROID TIDAK BERUBAH ATAU SAAT ITERASI
%MAKSIMAL

if centroid == centroid_awal | iter > max_iter
    break
end
end
seg = reshape(maskv, size(image_crop)); %hasil segmentasi

%% MENAMPIKAN CITRA HASIL CLUSTER
image_clus = zeros(panjang,k); 
for i=1:k
    image_clus(:,i) = (maskv==i);
end
segs = reshape(image_clus, [size(image_crop) k]);
figure()
imshow(seg, []);
title (['Hasil Segmentasi, k = ' num2str(k)]);
   for i = 1:k
        figure ()
        imshow(segs(:,:,i), [])
        title(['cluster ke-' num2str(i)])
   end
ROI= bwselect; %memilih ROI 
LV_KM = imfill(ROI, 'holes'); %memasukkan papilari
figure()
imshow(LV_KM, []);
title ('ROI LV K MEANS');
[y4,x4] = find(LV_KM==1); %mencari koordinat LV
for j = 1:length(x4)
    signal_LV_KM(1,j) = pic(y4(j),x4(j));
end

%% MEMPERSIAPKAN DSC
for j = 1:length(x4)
signal_DSC_LV_KM(j) = signal_LV_KM(1,j);
end
for j = 1:length(x4)
    if signal_DSC_LV_KM(j)>0;
        signal_DSC_LV_KM(j)=200;
    end
end
DSC_LV_KM = zeros(size(LV_KM)); 
for j = 1:length(x4)
    DSC_LV_KM(y4(j),x4(j)) = signal_DSC_LV_KM(j);
end
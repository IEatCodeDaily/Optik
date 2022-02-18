imgFolder = "Data Laser\";
img = dir(imgFolder +"*.jpg");
nfiles = length(img);

for i=1:nfiles
   currentfilename = imgPath + img(i).name;
   currentimage = imread(currentfilename);
   sample{i} = currentimage;
end

kernelsize = [3,15,55];

sampleNo = 1;
for i=1:nfiles
    %[img_crop,rect] = imcrop(sample{1});
    img_crop=imcrop(sample{i},[1200 1300 2000 400]);

    %%
    for j=1:length(kernelsize)
        img_filter = imboxfilt(img_crop,kernelsize(j));
        img_hsv = rgb2hsv(img_filter);
        img_sat = img_hsv(:,:,2);

    
        %%
        t = graythresh(img_sat);
        bintik = (img_sat>t);
        imshow(bintik);

        %%
       
        [centers,radii] = imfindcircles(bintik,[10 20],'ObjectPolarity','dark','Sensitivity',0.9);
        
        if isempty(centers) == 0
            centersX = centers(:,1);
            centersY = centers(:,2);
            viscircles(centers,radii);
        end
          
        f = getframe();
        imwrite(f.cdata,"Result\data"+i+"_mean_"+kernelsize(j)+".jpg");
        

    end
end
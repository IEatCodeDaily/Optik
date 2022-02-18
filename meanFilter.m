imgFolder = "Data Laser\";
img = dir(imgFolder +"*.jpg");
nfiles = length(img);

for i=1:nfiles
   currentfilename = imgFolder + img(i).name;
   currentimage = imread(currentfilename);
   sample{i} = currentimage;
end

kernelsize = [3,15,55];

sampleNo = 1;
for i=1:nfiles
    %[img_crop,rect] = imcrop(sample{1});
    img_crop=imcrop(sample{i},[1200+((nfiles-i)*125) 1300 2000-((5-i)*200) 400]);
    imshow(img_crop)
    %%
    for j=1:length(kernelsize)
    disp("data"+i+"_"+kernelsize);
        img_filter = imboxfilt(img_crop,kernelsize(j));
        img_hsv = rgb2hsv(img_filter);
        img_sat = img_hsv(:,:,2);

    
        %%
        t = graythresh(img_sat);
        bintik = (img_sat>t);
        imshow(bintik);

        %%
        
        [centers,radii] = imfindcircles(bintik,[10 20],'ObjectPolarity','dark','Sensitivity',0.9);
        for inc=1:10
            for base=10:20
                if size(centers,1) >= 2 || sum(pdist(centers)>50*i) >= 1
                    [tempcenters,tempradii] = imfindcircles(bintik,[base base+inc],'ObjectPolarity','dark','Sensitivity',0.9);
                if (2 <= size(tempcenters,1)) && size(tempcenters,1) <= size(centers,1)
                    centers = tempcenters;
                    radii = tempradii;
                end
                end
            end
        end
        ncircle = size(centers,1);
        if isempty(centers) == 0
            centersX = centers(:,1);
            centersY = centers(:,2);
            for icircle=1:ncircle
            viscircles(centers(icircle,:),radii(icircle),'color',[icircle/(ncircle/2)*(icircle<=(ncircle/2)) 0 (icircle-(ncircle/2))/(ncircle/2)*(icircle>=(ncircle/2))]);
            end
            distance = pdist(centers);
            distance = [distance; nan(abs(size(centers,1)-size(distance,1)), 1)];
            T = table(centersX,centersY,radii,distance);
            writetable(T,"Result\csv\data"+i+"_mean_"+kernelsize(j)+".csv")
        end
        
        
        
        f = getframe();
        imwrite(f.cdata,"Result\data"+i+"_mean_"+kernelsize(j)+".jpg");
        

    end
end
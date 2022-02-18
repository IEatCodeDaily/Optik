imgFolder = "Data Laser\";
img = dir(imgFolder +"*.jpg");
nfiles = length(img);

for i=1:nfiles
   currentfilename = imgFolder + img(i).name;
   currentimage = imread(currentfilename);
   sample{i} = currentimage;
end

kernelsize = [3,15,55];
estMinDist = [150,300,500,850,1450];

for i=1:nfiles
    %[img_crop,rect] = imcrop(sample{1});
    img_crop=imcrop(sample{i},[1200+((nfiles-i)*125) 1300 2000-((5-i)*200) 400+((i-1)*50)]);
    imshow(img_crop)
    %%
    for j=1:length(kernelsize)
    disp("data"+i+"_"+kernelsize(j));
        img_filter = imboxfilt(img_crop,kernelsize(j));
        img_hsv = rgb2hsv(img_filter);
        img_sat = img_hsv(:,:,2);

    
        %%
        t = graythresh(img_sat);
        bintik = (img_sat>t);
        imshow(bintik);

        %%
        
        [centers,radii] = imfindcircles(bintik,[15 40],'ObjectPolarity','dark','Sensitivity',0.9);
        
        for inc=3:20
            for base=10:40
                if size(centers,1) >= 2 || sum(pdist(centers)>50*i) == 0
                    [tempcenters,tempradii] = imfindcircles(bintik,[base base+inc],'ObjectPolarity','dark','Sensitivity',0.9);
                if (2 <= size(tempcenters,1)) && (size(tempcenters,1) <= size(centers,1)) && (sum(abs(pdist(tempcenters)-estMinDist(i)) <= 100) >= 1 ) 
                    centers = tempcenters;
                    radii = tempradii;
                end
                end
                if (size(centers,1) <= 3) && (sum(abs(pdist(tempcenters)-estMinDist(i)) <= 100) >= 1)
                    break
                end
            end
        end
        
        imshow(bintik);
        ncircle = size(centers,1);
        if isempty(centers) == 0
            centersX = centers(:,1);
            centersY = centers(:,2);
            for icircle=1:ncircle
            viscircles(centers(icircle,:),radii(icircle),'color',[icircle/(ncircle/2)*(icircle<=(ncircle/2)) 0 (icircle-(ncircle/2))/(ncircle/2)*(icircle>=(ncircle/2))]);
            end
            distance = pdist(centers);
            
            if ncircle == 2
                distance = [distance; nan(abs(size(centers,1)-size(distance,1)), 1)];
                T = table(centersX,centersY,radii,distance);
            elseif ncircle == 3
                T = table(centersX,centersY,radii,distance.');
            else
                T = table(centersX,centersY,radii);
            end
            writetable(T,"Result\mean\csv\data"+i+"_mean_"+kernelsize(j)+".csv")
        end
        
        
        
        f = getframe();
        imwrite(f.cdata,"Result\mean\data"+i+"_mean_"+kernelsize(j)+".jpg");
        

    end
end
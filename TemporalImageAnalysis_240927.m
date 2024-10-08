
close all
clc
warning('on','all')
%% Basis Image Center & Radius 
tic

%defines image directory
%set file path to '' if you only want to select images in the folder this
%code file is in
filepath = 'C:\Users\mmani\University of Michigan Dropbox\Matthew Manion\Temporal-Image-Analysis';
% filepath = '';
imagepath = [filepath  '\*.png'];
% imagepath = [filepath  '\ConcentricSquare.jpg'];
imagefiles = dir(imagepath);
num_images = length(imagefiles);


%if you want 3 images as basis for circle center & radius, put 4
basismax = 4;
radius_mm = 3;
% draw = false;
% cir = false;
% rect = false;
% drawrect = false;



countt = 1;

prompt = 'do you need a basis image & circle + radius? (yes or no): ';
boolbasis = input(prompt,'s');
i = 1;
if isequal(boolbasis,'yes')
    draw = false;
    cir = false;
    rect = false;
    keletonbool = false;
    drawrect = false;
    prompt = 'do you want to do automatic circle detection? (yes or no): ';
    boolbase = input(prompt,'s');
    if isequal(boolbase, 'yes')
        centers = zeros(basismax-1,2);
        radiis = zeros(basismax-1,1);
        basisindex = zeros(basismax-1,1);
        metrics = zeros(basismax-1,1);
        i = 1;
        while i < 8
            rng("default");
            BasisImage = [imagefiles(i).folder '\' imagefiles(i).name];
            basis_tiff_stack = imadjust(im2gray(imread(BasisImage)),[0,1]);
            basis_tiff_stack_crop = basis_tiff_stack;
            %imshow(basis_tiff_stack_crop);
            [center, radii, metric] = imfindcircles(basis_tiff_stack_crop,[600 1200],'ObjectPolarity','bright','Sensitivity',0.99);
        
            if isempty(center)
                disp('Null Result')
            else
                centers(countt,:) = center;
                radiis(countt,:) = radii; 
                basisindex(countt,:) = i; 
                metrics(countt,:) = metric;
                countt = countt + 1;
                disp("Found Circle")
            end
        
            if countt == basismax
                break 
            end
            i = i + 1;
        
        end
    else
        BasisImage = [imagefiles(i).folder '\' imagefiles(i).name];
        basis_tiff_stack = imadjust(im2gray(imread(BasisImage)),[0,1]);
        basis_tiff_stack_crop = basis_tiff_stack;
        [row,col] = size(basis_tiff_stack_crop);
        center = [col/2,row/2];
        radii = row/2;
        centers = center;
        radiis = radii;
        metrics = 0;
        basisindex = 1;
    end


    if ~any(centers,'all')
        [row,col] = size(basis_tiff_stack_crop);
        center = [col/2,row/2];
        radii = row/2;
        basisindex(1) = 1;
    else


        cmask = centers>0;
        centers = centers(cmask);
        centers = reshape(centers,[sum(cmask(:,1)),2]);
        rmask = radiis>0;
        radiis = radiis(rmask);
        radiis = reshape(radiis,[sum(rmask(:,1)),1]);
        mmask = metrics>0;
        metrics = metrics(mmask);
        metrics = reshape(metrics,[sum(mmask(:,1)),1]);
        
        center = [mean(centers(:,1)),mean(centers(:,2))];
        radii = mean(radiis);
        metric = mean(metrics);

    end
    %basisImage = imadjust(im2gray(imread(imagefiles(basisindex(1)).name))); [imagefiles(i).folder imagefiles(i).name];
    basisImage = imadjust(im2gray(imread([imagefiles(basisindex(1)).folder '\' imagefiles(basisindex(1)).name])));
    crop = basisImage;
    imshow(crop);
    viscircles(center, radii,'Color','b');
    
    prompt = 'does this circle look adequate? (yes or no): ';
    verify = input(prompt,'s');
    if isequal(verify,'no')
        prompt = 'do you want to specify coordinates, estimate as the center of the image, manually set values, or draw? \n (reply spec, est, manu, or draw): ';
        boolcord = input(prompt,'s');
        if isequal(boolcord,'est')
            [row,col] = size(basis_tiff_stack_crop);
            center = [col/2,row/2];
            radii = row/2;
            %basisindex(1) = 1;
        elseif isequal(boolcord,'spec')
            prompt = 'The image dimensions are 836x720. enter the pixel coordinates as [x,y] with the brackets: ';
            center = input(prompt);
            prompt = 'enter the radius as a pixel number: ';
            radii = input(prompt);
            metric = 1;
        elseif isequal(boolcord,'manu')
            close all
            %hWaitbar = waitbar(0, 'Iteration 1', 'Name', 'Solving problem','CreateCancelBtn','delete(gcbf)');

            circ = viscircles(center, radii,'Color','b');
            
            xdata = circ.Children.XData;
            ydata = circ.Children.YData;
            
            
            hFig = figure;
            

            %basisImage = imadjust(im2gray(imread(imagefiles(end).name))); [imagefiles(i).folder imagefiles(i).name]
            basisImage = imadjust(im2gray(imread([imagefiles(end).folder '\' imagefiles(end).name])));
            crop = basisImage;
            imshow(crop);
            
            xdata = circ.Children.XData;
            ydata = circ.Children.YData;
            hold on
            % txt = text(1,20,'0');
            plot(xdata,ydata,'LineWidth',4,'Color','r');
            disp('Use arrow keys to move the circle, w increases radius, s decreases radius');
            disp('You must have the figure with the red circle open to adjust the circle')
            set(hFig,'KeyPressFcn',{@KeyPressCb,1,xdata,ydata,center,radii});
            % txt = text(1,20,'0');
            hWaitbar = waitbar(0, 'Hit Cancel When Your Circle Is Good', 'Name', 'Hit Cancel When The Circle Is Good','CreateCancelBtn','delete(gcbf)');
            while true
                

                
                if ~ishandle(hWaitbar)
                    % Stop the if cancel button was pressed
                    disp('Stopped by user');
                    break;
                else
                    % Update the wait bar
                    waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                    % area = polyarea(xdata,ydata);

                    % set(txt,'String',['Pixel Area: ' num2str(area)]);
                end
                
                
                drawnow
            

           


            end
            hold off
            obj = hFig.Children.Children;
            x = obj(1).XData;
            y = obj(1).YData;
            radii = (x(1) - min(x))/2;
            x_cen = min(x) + radii;
            y_cen = min(y) + radii;
            center = [x_cen,y_cen];
            close all
        else
            prompt = 'What shape do you want to draw? \n (reply rect, poly, free, assist, line, circ): ';
            booldraw = input(prompt,'s');
            if isequal(booldraw,'free')

                hFig = figure;
                
    
                %basisImage = imadjust(im2gray(imread(imagefiles(end).name))); [imagefiles(i).folder imagefiles(i).name]
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawfreehand();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Drawing Is Good', 'Name', 'Hit Cancel When The Drawing Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
    
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = polyarea(shape.Position(:,1),shape.Position(:,2));

                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
    
               
    
    
                end



                mask = createMask(shape);
                pos = shape.Position;
                pos = interppolygon(pos,360,'linear');
                draw = true;
            elseif isequal(booldraw,'rect')
                hFig = figure;
                
    
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawrectangle();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Rectangle Is Good', 'Name', 'Hit Cancel When The Rectangle Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
    
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = shape.Position(3)*shape.Position(4);

                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
    
               
    
    
                end
                mask = createMask(shape);
                pos = shape.Position;
                x_corn = pos(1);
                y_corn = pos(2);
                wid = pos(3);
                hei = pos(4);
                x_cen = x_corn + wid/2;
                y_cen = y_corn + hei/2;
                center = [x_cen,y_cen];
                radii = sqrt((x_cen-x_corn)^2+(y_cen-y_corn)^2);
                pos = [x_corn,y_corn;x_corn+wid,y_corn;x_corn+wid,y_corn+hei;x_corn,y_corn+hei;x_corn,y_corn];
                pos = interppolygon(pos,360,'linear');
                

                draw = false;
                rect = true;
                
            elseif isequal(booldraw,'poly')
                hFig = figure;
                
    
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawpolygon();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Drawing Is Good', 'Name', 'Hit Cancel When The Drawing Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
    
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = polyarea(shape.Position(:,1),shape.Position(:,2));

                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
    
               
    
    
                end



                mask = createMask(shape);
                pos = shape.Position;
                % [~,indx,ic] = unique(pos(:,1));
                pos = interppolygon(pos,360,'linear');
                draw = true;
            elseif isequal(booldraw,'assist')
                hFig = figure;
                
    
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawassisted();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Drawing Is Good', 'Name', 'Hit Cancel When The Drawing Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
    
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = polyarea(shape.Position(:,1),shape.Position(:,2));

                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
    
               
    
    
                end
                mask = createMask(shape);
                pos = shape.Position;
                % [posx,~,ic] = unique(pos(:,1));
                % posx = posx(ic);
                % [posy,~,ic] = unique(pos(:,2));
                % posy = posy(ic);
                % pos = [posx,posy];
                pos = interppolygon(pos,360,'spline');
                draw = true;
            elseif isequal(booldraw,'line')
                hFig = figure;
                
    
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawline();
                mask = createMask(shape);
                pos = shape.Position;
                pos = interppolygon(pos,360,'linear');
                draw = true;
            % elseif isequal(booldraw,'pline')
            %     hFig = figure;
            % 
            % 
            %     basisImage = imadjust(im2gray(imread(imagefiles(end).name)));
            %     crop = basisImage;
            %     imshow(crop);
            %     shape = drawpolyline();
            %     mask = createMask(shape);
            %     pos = shape.Position;
            %     pos = interppolygon(pos,360,'linear');
            %     draw = true;

            elseif isequal(booldraw,'circ')
                hFig = figure;
                
    
                basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
                crop = basisImage;
                imshow(crop);
                shape = drawcircle();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Drawing Is Good', 'Name', 'Hit Cancel When The Drawing Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
    
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = polyarea(shape.Vertices(:,1),shape.Vertices(:,2));

                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
    
               
    
    
                end



                mask = createMask(shape);
                pos = shape.Vertices;
                pos = interppolygon(pos,360,'linear');
                draw = true;




            end
           


        end
    end
end
close all
%change this to be more "firstimage" and use current image in loop
BasisImage = imread([imagefiles(basisindex(1)).folder '\' imagefiles(basisindex(1)).name]);


% if channelid == '1'
basis_tiff_stack = imadjust(im2gray(BasisImage),[0,1]);
%imshow(basis_tiff_stack)

basis_tiff_stack_crop = basis_tiff_stack;
%imshow(basis_tiff_stack_crop);

% [centers, radii, metric] = imfindcircles(basis_tiff_stack_crop,[600 2000],'ObjectPolarity','bright','Sensitivity',0.99);
if rect
    nanmask = isnan(pos);
    if any(nanmask)
        pos(nanmask) = pos(1,:);
    end

    
    %mask = createMask(r);
    alphamat = imguidedfilter(single(mask),basis_tiff_stack_crop,'NeighborhoodSize',[3,3],'DegreeOfSmoothing',2);
    % alphamat = imguidedfilter(basis_tiff_stack_crop,single(mask));
    imshow(uint8(single(basis_tiff_stack_crop).*alphamat))
    
    dataOutput_immediate = [center radii];
    %circrect = false;
    cir = false;
    draw = true;

elseif draw
    %mask = createMask(shape);
    nanmask = isnan(pos);
    if any(nanmask)
        pos(nanmask) = pos(1,:);
    end
    x_cen = mean(pos(:,1));
    y_cen = mean(pos(:,2));
    center = [x_cen,y_cen];
    radii = 1;
    alphamat = imguidedfilter(single(mask),basis_tiff_stack_crop,'DegreeOfSmoothing',2);
    imshow(uint8(single(basis_tiff_stack_crop).*alphamat))
    dataOutput_immediate = [center radii];

else
    %circ = viscircles(center, radii,'Color','b');

    hFig = figure;
    basisImage = imadjust(im2gray(imread( [imagefiles(end).folder '\' imagefiles(end).name])));
    basis_tiff_stack_crop = basisImage;
    imshow(basis_tiff_stack_crop);

    circ = drawcircle('Center',[center(1),center(2)],'Radius',radii);
    mask = createMask(circ);
    pos = circ.Vertices;
    pos = interppolygon(pos,360,'linear');

    dataOutput_immediate = [center radii metric];
    alphamat = imguidedfilter(single(mask),basis_tiff_stack_crop,'DegreeOfSmoothing',2);
    imshow(uint8(single(basis_tiff_stack_crop).*alphamat))
    cir = true;
    rect = false;
    draw = false;
end
disp('Basis Circle Center & Radius Calculation Time')
toc

%% Data Generation


%defines image directory
% imagefiles = dir('*.png');
% num_images = length(imagefiles);

prompt = 'Do you want to make an new ROI centerline?: \nSay no to reuse centerline/skeleton \n(yes or no) ';
skelbool = input(prompt,'s');


if isequal(skelbool,'yes')

    prompt = 'Auto or manual skeleton?: (auto or man) ';
    bwbool = input(prompt,'s');
    if isequal(bwbool,'man')

        binaryROI = imbinarize(single(basis_tiff_stack_crop+1).*mask);
        alphaROI = single(basis_tiff_stack_crop).*alphamat;
        [skeleton,minBranch,zoomBounds] = imskel(binaryROI);
        [skeldist,skelidx] = bwdist(~binaryROI);
        centerToEdge = skeldist .* single(skeleton);
        skelfig = figure;
        subplot(2, 2, 1);
        dispimage = uint8(single(basis_tiff_stack_crop).*alphamat);
        imshow(dispimage(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        fontSize = 20;
        title('Original Grayscale Image', 'FontSize', fontSize);
        % Enlarge figure to full screen.
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        % Give a name to the title bar.
        set(gcf,'numbertitle','off') 
        % fontSize = 20;
        subplot(2, 2, 2);
        imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        title('Skeletonized Image', 'FontSize', fontSize);
        subplot(2, 2, 3);
        imshow(skeldist(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        title('Euclidean Distance Transform', 'FontSize', fontSize);
        subplot(2, 2, 4);
        imshow(centerToEdge(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        title('Distance From Edge', 'FontSize', fontSize);

        prompt = 'Do you want to remove skeleton points?: (yes or no) ';
        skelbool = input(prompt,'s');
        skeletonbool = true;
        looper = false;
        
        if isequal(skelbool,'yes')
            looper = true;
        end
        while looper
        
            if isequal(skelbool,'yes')
                
    
                hFig = figure;
                        
            
                imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)));
                shape = drawrectangle();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Rectangle Is Good', 'Name', 'Hit Cancel When The Rectangle Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
        
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = shape.Position(3)*shape.Position(4);
        
                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
        
               
        
        
                end
        
                % mask = createMask(shape);
                erasepos = shape.Position;
                x_corne = erasepos(1);
                y_corne = erasepos(2);
                wide = erasepos(3);
                heie = erasepos(4);
                skeleton = imerase(double(skeleton),[round(x_corne),round(y_corne),round(wide),round(heie)]);
                close
                skeleton = logical(skeleton);
                centerToEdge(~skeleton) =0;
                subplot(2, 2, 2);
                imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
                title('Skeletonized Image', 'FontSize', fontSize);
                subplot(2, 2, 4);
                imshow(centerToEdge(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
                title('Distance From Edge', 'FontSize', fontSize);

            end
            prompt = 'Do you want to remove more skeleton points?: (yes or no) ';
            removebool = input(prompt,'s');
            if isequal(removebool,'yes')
                
            else
                looper = false;
            end



            % x_cen = x_corn + wid/2;
            % y_cen = y_corn + hei/2;
            % center = [x_cen,y_cen];
            % radii = sqrt((x_cen-x_corn)^2+(y_cen-y_corn)^2);
            % pos = [x_corn,y_corn;x_corn+wid,y_corn;x_corn+wid,y_corn+hei;x_corn,y_corn+hei;x_corn,y_corn];
            % pos = interppolygon(pos,360,'linear');
        end

    else
        binaryROI = (single(basis_tiff_stack_crop+1).*alphamat);
        skeleton = bwmorph(binaryROI,'skel',inf);
        [skeldist,skelidx] = bwdist(~binaryROI);
        centerToEdge = skeldist .* single(skeleton);

        [srow,scol] = size(binaryROI);
        % [lrow,lcol] = find(image,1,'last');
        colvals = sum(binaryROI,1);
        rowvals = sum(binaryROI,2);
        [lrow,~] = find(rowvals,1,'last');
        [~,lcol] = find(colvals,1,'last');
        % [frow,fcol] = find(image,1,'first');
        [frow,~] = find(rowvals,1);
        [~,fcol] = find(colvals,1);
        % [k] = find(threshWord,1,'last');
        pad = 50;
        zoomBounds = [max(1,frow-pad),max(1,fcol-pad);min(lrow+pad,srow),min(lcol+pad,scol)];

        skelfig = figure;
        subplot(2, 2, 1);
        dispimage = uint8(single(basis_tiff_stack_crop).*alphamat);
        imshow(dispimage(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        fontSize = 20;
        title('Original Grayscale Image', 'FontSize', fontSize);
        % Enlarge figure to full screen.
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        % Give a name to the title bar.
        set(gcf,'numbertitle','off') 
        % fontSize = 20;
        subplot(2, 2, 2);
        imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        skeleton = logical(skeleton);
        title('Skeletonized Image', 'FontSize', fontSize);
        subplot(2, 2, 3);
        imshow(skeldist(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        title('Euclidean Distance Transform', 'FontSize', fontSize);
        subplot(2, 2, 4);
        imshow(centerToEdge(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
        title('Distance From Edge', 'FontSize', fontSize);



        prompt = 'Do you want to remove skeleton points?: (yes or no) ';
        skelbool = input(prompt,'s');
        skeletonbool = true;
        
        if isequal(skelbool,'yes')
            looper = true;
        end
        while looper
        
            if isequal(skelbool,'yes')
                
    
                hFig = figure;
                        
            
                imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)));
                shape = drawrectangle();
                txt = text(1,20,'0');
                hWaitbar = waitbar(0, 'Hit Cancel When Your Rectangle Is Good', 'Name', 'Hit Cancel When The Rectangle Is Good','CreateCancelBtn','delete(gcbf)');
                while true
                    
        
                    
                    if ~ishandle(hWaitbar)
                        % Stop the if cancel button was pressed
                        disp('Stopped by user');
                        break;
                    else
                        % Update the wait bar
                        waitbar(i/5,hWaitbar, ['Iteration ' num2str(i)]);
                        area = shape.Position(3)*shape.Position(4);
        
                        set(txt,'String',['Pixel Area: ' num2str(area)]);
                        
                    end
                    
                    
                    drawnow
                
        
               
        
        
                end
        
                % mask = createMask(shape);
                erasepos = shape.Position;
                x_corne = erasepos(1);
                y_corne = erasepos(2);
                wide = erasepos(3);
                heie = erasepos(4);
                skeleton = imerase(double(skeleton),[round(x_corne),round(y_corne),round(wide),round(heie)]);
                close
                skeleton = logical(skeleton);
                centerToEdge(~skeleton) =0;
                subplot(2, 2, 2);
                imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
                title('Skeletonized Image', 'FontSize', fontSize);
                subplot(2, 2, 4);
                imshow(centerToEdge(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
                title('Distance From Edge', 'FontSize', fontSize);

            end
            prompt = 'Do you want to remove more skeleton points?: (yes or no) ';
            removebool = input(prompt,'s');
            if isequal(removebool,'yes')
                
            else
                looper = false;
            end
        end
        skeletonbool = true;

    end

else


end

prompt = 'Do you want to use the skeleton in the active workspace for line analysis?: (yes or no) ';
skelbool = input(prompt,'s');


if isequal(skelbool,'yes')
    close
    skelfig = figure;
    subplot(2, 2, 1);
    dispimage = uint8(single(basis_tiff_stack_crop).*alphamat);
    % imshow(dispimage(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
    imshow(dispimage, []);
    fontSize = 20;
    title('Original Grayscale Image', 'FontSize', fontSize);
    % Enlarge figure to full screen.
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    % Give a name to the title bar.
    set(gcf,'numbertitle','off') 
    % fontSize = 20;
    subplot(2, 2, 2);
    % imshow(skeleton(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
    imshow(skeleton, []);
    skeleton = logical(skeleton);
    title('Skeletonized Image', 'FontSize', fontSize);
    subplot(2, 2, 3);
    % imshow(skeldist(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
    imshow(skeldist, []);
    title('Euclidean Distance Transform', 'FontSize', fontSize);
    subplot(2, 2, 4);
    % imshow(centerToEdge(zoomBounds(1,1):zoomBounds(2,1),zoomBounds(1,2):zoomBounds(2,2)), []);
    imshow(centerToEdge, []);
    title('Distance From Edge', 'FontSize', fontSize);
    skeletonbool = true;


    [skrow,skcol] = size(skeleton);
    I = uint16(1:skcol);
    B = zeros(size(skeleton),'uint16');
    for i =1:skrow
        currRow = I(skeleton(i,:));
        B(i,1:length(currRow)) = currRow;
    
    
    end
    numskel = sum(skeleton,'all');
    spos = zeros(numskel,2);
    i = 1;
    rowind = 1;
    while i <= numskel
        crow = B(rowind,:);
        rmask = crow>0;
        if sum(rmask) > 0
            spos(i:i+sum(rmask)-1,:) = [crow(rmask)', ones(sum(rmask),1)*rowind];
            i = i + sum(rmask);
        end
        rowind = rowind + 1;
    
    
    end

    colvals = sum(skeleton,1);
    rowvals = sum(skeleton,2);
    [lrow,~] = find(rowvals,1,'last');
    [~,lcol] = find(colvals,1,'last');
    % [frow,fcol] = find(image,1,'first');
    [frow,~] = find(rowvals,1);
    [~,fcol] = find(colvals,1);
    % [k] = find(threshWord,1,'last');
    % pad = 50;
    endrow = [frow,lrow];
    endcol = [lrow,lcol];

    skelends = bwmorph(skeleton,'endpoints');
    [endcol,endrow] = find(skelends);

    if length(endrow) > 1
        skelstart = [endrow(1) endcol(1)];
        skelend = [endrow(2), endcol(2)];
    else
        skelstart = [endrow(1) endcol(1)];
        skelend = skelstart;
    end

    spos = [spos; spos(1,:)];
    spos(1,:) = skelstart;
    
    yIdx = [1,nan(size(spos(:,2))-1)]; 
    xyTemp = [spos(:,1), spos(:,2)]; 
    xyTemp(1,:) = NaN; 
    idx = [1, nan(1, numel(spos(:,1))-1)]; 
    counter = 0;
    
    while any(isnan(idx))
        counter = counter+1; 
        % find closest coordinate to (x(i),y(i)) that isn't already taken
        [~, idx(counter+1)] = min(pdist2(xyTemp,[spos(idx(counter),1), spos(idx(counter),2)])); 
        % Eliminate that from the pool
        xyTemp(idx(counter+1),:) = NaN; 
    end
    
    spos = [spos(idx,1),spos(idx,2)];
    spos(1,:) = [];
    
    % spos = interppolygon(spos,720,'nearest');
    % outerpoints = max(720,length(spos(:,1)));
    outerpoints = 720;
    % outerpoints = 
    pos = interppolygon(pos,outerpoints,'linear');
    nanmask = isnan(pos);
    if any(nanmask)
        pos(nanmask) = pos(1,:);
    end
    subplot(2, 2, 2);
    hold on
    scatter(spos(:,1),spos(:,2));
    
    
    magsmat = zeros(length(spos(:,1)),length(pos(:,1)));
    for m = 1:length(spos(:,1))
        for n = 1:length(pos(:,1))
            magsmat(m,n) = norm(spos(m,:)-pos(n,:));
    
    
    
        end
    
    end
    [minind,valind] = min(magsmat,[],1);
    % [~,svalind] = min(magsmat,[],2);
    %the row number of magsmat is the skeleton point that is closest to the
    %corresponding valind value
    % magsmattemp = magsmat;
    skelline = 0;
    
    for i = 1:length(pos(:,1))
        % line([pos(i,1) spos(valind(i),1)],[pos(i,2) spos(valind(i),2)])
        line([spos(valind(i),1) pos(i,1)],[spos(valind(i),2) pos(i,2)])
        skelline = skelline + 1;
        if i == length(pos(:,1))
             for q = [valind(i),valind(1)]
                 line([spos(q,1) pos(i,1)],[spos(q,2) pos(i,2)])
                 skelline = skelline + 1;
             end
        else
            start = min(valind(i),valind(i+1));
            stop = max(valind(i),valind(i+1));
            for q = start+1:stop-1
                line([spos(q,1) pos(i,1)],[spos(q,2) pos(i,2)])
                skelline = skelline + 1;

            end

        end
        
    
    end
    
    skelmags = zeros(skelline,1);
    skellineind = 1;
    for i = 1:length(pos(:,1))
        % line([pos(i,1) spos(valind(i),1)],[pos(i,2) spos(valind(i),2)])
        edgep = [pos(i,1) pos(i,2)];
        centerp = [spos(valind(i),1) spos(valind(i),2)];
        skelmags(skellineind) = norm(edgep-centerp);
        skellineind = skellineind + 1;
        
        if i == length(pos(:,1))
             for q = [valind(i),valind(1)]
                 % line([pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)])
                edgep = [pos(i,1) pos(i,2)];
                centerp = [spos(q,1) spos(q,2)];
                skelmags(skellineind) = norm(edgep-centerp);
                skellineind = skellineind + 1;
                 
             end
        else
            start = min(valind(i),valind(i+1));
            stop = max(valind(i),valind(i+1));
            
            for q = start+1:stop-1
                % line([pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)])
                edgep = [pos(i,1) pos(i,2)];
                centerp = [spos(q,1) spos(q,2)];
                skelmags(skellineind) = norm(edgep-centerp);
                skellineind = skellineind + 1;
                
    
            end
            
        end
        
    
    end
    
    
    scatter(pos(:,1),pos(:,2));
else
    skeletonbool = false;

end




prompt = 'Do you want to threshold your data?: (auto, yes, or no) ';
thrbool = input(prompt,'s');

threshbool = false;
if isequal(thrbool,'yes')
    prompt = 'Do you want to keep bright or dark objects?: (b or d)';
    objbool = input(prompt,'s');
    if isequal(objbool,'b')
        objbool = true;
    else
        objbool = false;
    end

    [imgrow,imgcol] = size(basis_tiff_stack_crop);
    mask_image_data = zeros(imgrow,imgcol,num_images);
    thresh = 0;
    for i = 1:num_images
        imag = im2gray(imread( [imagefiles(i).folder '\' imagefiles(i).name]));
        imagmasked = uint8(single(imag).*alphamat);
        
        [imgmask, thresh] = make_mask(imagmasked,i,thresh);
        if ~objbool
            imgmask = ~imgmask;
        end

        imagmasked(~imgmask) = 0;

        imag2 = im2gray(imread( [imagefiles(i).folder '\' imagefiles(i).name]));
        imagmasked2 = uint8(single(imag2).*alphamat);
        imagmasked(imgmask) = imagmasked2(imgmask);
        mask_image_data(:,:,i) = imagmasked;
    
    end
    threshbool = true;
elseif isequal(thrbool,'auto')
    prompt = 'Do you want to keep bright or dark objects?: (b or d)';
    objbool = input(prompt,'s');
    if isequal(objbool,'b')
        objbool = true;
    else
        objbool = false;
    end


    [imgrow,imgcol] = size(basis_tiff_stack_crop);
    mask_image_data = zeros(imgrow,imgcol,num_images);
    thresh = 0;
    for i = 1:num_images
        imag = im2gray(imread( [imagefiles(i).folder '\' imagefiles(i).name]));
        imagmasked = uint8(single(imag).*alphamat);
        if i == 1
            [~, thresh] = make_mask(imagmasked,i,thresh);
        end
        saumask = sauvola(imag,[3,3],thresh);
        if ~objbool
            saumask = ~saumask;
        end
        %imagmasked = uint8(single(imag).*alphamat);
        imagmasked(~saumask) = 0;

        
        imag2 = im2gray(imread( [imagefiles(i).folder '\' imagefiles(i).name]));
        imagmasked2 = uint8(single(imag2).*alphamat);
        imagmasked(saumask) = imagmasked2(saumask);
        mask_image_data(:,:,i) = imagmasked;
    
    end
    threshbool = true;


end
% figure
% imshow(uint8(mask_image_data(:,:,1)));
if skeletonbool
    mags = skelmags;
else
    mags = ones(length(pos(:,1)),1);
    for posi = 1:length(pos(:,1))
        mags(posi) = norm(center-pos(posi,:));
    
    
    end
end
normmags = mags/max(mags);

if draw && ~skeletonbool
    num_points = round(normmags*900);
elseif skeletonbool
    num_points = round(normmags*900);
else
    num_points = 900;

end
%num_images = 62;
if draw && ~skeletonbool
    num_lines = length(pos(:,1));
elseif skeletonbool
    num_lines = skelline;
else
    num_lines = 360;
end


basisImage = uint8(single(basis_tiff_stack_crop).*alphamat);
% binaryBasisImage = imbinarize(single(basis_tiff_stack_crop).*alphamat);
binaryBasisImage = mask;
disp('Warning: Corner Detection Only Works with Polygons')
prompt = 'Do you want to detect ROI corners? (yes or no): ';
boolcorner = input(prompt,'s');
scorebool = false;
if isequal(boolcorner,'yes')
    prompt = 'Select Algorithm: MinEigen, Harris, ORB, BRISK, Combo:  ';
    boolalg = input(prompt,'s');
    if isequal(boolalg,'MinEigen')
        corners = detectMinEigenFeatures(binaryBasisImage);
        cornerPoints = corners.Location;
        cornerCount = corners.Count;
        cornerMetric = corners.Metric;
    elseif isequal(boolalg,'Harris')
        corners = detectHarrisFeatures(binaryBasisImage);
        cornerPoints = corners.Location;
        cornerCount = corners.Count;
        cornerMetric = corners.Metric;
    elseif isequal(boolalg,'ORB')
        corners = detectORBFeatures(binaryBasisImage);
        cornerPoints = corners.Location;
        cornerCount = corners.Count;
        cornerMetric = corners.Metric;
    elseif isequal(boolalg,'BRISK')
        corners = detectBRISKFeatures(binaryBasisImage);
        cornerPoints = corners.Location;
        cornerCount = corners.Count;
        cornerMetric = corners.Metric;
    elseif isequal(boolalg,'Combo')
        corners1 = detectMinEigenFeatures(binaryBasisImage);
        corners2 = detectHarrisFeatures(binaryBasisImage);
        corners3 = detectORBFeatures(binaryBasisImage);
        corners4 = detectBRISKFeatures(binaryBasisImage);
        counts = [corners1.Count,corners2.Count,corners3.Count,corners4.Count];
        cornerPoints = [corners1.Location;corners2.Location;corners3.Location;corners4.Location];
        cornerCount = mean(counts);
        cornerMetric = [corners1.Metric;corners2.Metric;corners3.Metric;corners4.Metric];
        scorebool = true;

    else
        corners = detectMinEigenFeatures(binaryBasisImage);
        cornerPoints = corners.Location;
        cornerCount = corners.Count;
        cornerMetric = corners.Metric;


    end
    cornerFig = tiledlayout(2,2);
    cornerFig.Padding = 'compact';
    cornerFig.TileSpacing = 'compact';

    nexttile
    imshow(basisImage)
    fontSize = 20;
    title('Image ROI','FontSize',fontSize);
    nexttile
    % subplot(1,3,1);
    imshow(binaryBasisImage);
    title('Identified Corner, Edge, & Center','FontSize',fontSize);
    hold on;
    if scorebool
        plot(corners1.selectStrongest(length(corners1)));
        hold on
        plot(corners2.selectStrongest(length(corners2)));
        plot(corners3.selectStrongest(length(corners3)));
        plot(corners4.selectStrongest(length(corners4)));
    else
        prompt = input('How many corners are you expecting: ','s');
        strongCorner = corners.selectStrongest(str2double(prompt));
        strongCorners = round(strongCorner.Location);
        % plot(corners.selectStrongest(str2double(prompt)));
        plot(corners.selectStrongest(length(corners)));
    end
    cornerCounts = strcat('Corner Num = ', num2str(cornerCount));
    % text(-50,-50,cornerCounts);
    [corow,cocol] = size(strongCorners);
    % midpoints = zeros(100,cocol);

    xcombo = combinations(strongCorners(:,1),strongCorners(:,1));
    xcombo = table2array(xcombo);
    ycombo = combinations(strongCorners(:,2),strongCorners(:,2));
    ycombo = table2array(ycombo);
    midpoints = zeros(size(ycombo));

    for i = 1:length(xcombo(:,1))
        
        if xcombo(i,1)+ycombo(i,1) == xcombo(i,2)+ycombo(i,2)
            continue
        else
            midpoints(i,1) = round(mean(xcombo(i,:)));
            midpoints(i,2) = round(mean(ycombo(i,:)));
        end
        
    end
    [~,ic,~] = unique(mean(midpoints,2));
    midpoints = midpoints(ic,:);
    if any(sum(midpoints,2) == 0)
        midmask = sum(midpoints,2) == 0;
        midpoints(midmask,:) = [];
    end
    if any(sum(midpoints,2) == sum([round(mean(midpoints(:,1))),round(mean(midpoints(:,2)))]))
        centermask = sum(midpoints,2) == sum([round(mean(midpoints(:,1))),round(mean(midpoints(:,2)))]);
        midpoints(centermask,:) = [];

    end
    center = [round(mean(midpoints(:,1))),round(mean(midpoints(:,2)))];
    text(center(1)-200,center(2)+200,cornerCounts);

    scatter(midpoints(:,1),midpoints(:,2),'r','filled');
    scatter(center(1),center(2),'b','filled');
    
    if rect
        gridPoints = 100;
        xp = round(linspace(min(xcombo,[],'all'),max(xcombo,[],'all'),100));
        yp = round(linspace(min(ycombo,[],'all'),max(ycombo,[],'all'),100));
        [X,Y] = meshgrid(xp,yp);
    else
        % polytest = polygrid(pos(:,1),pos(:,2),0.000224871879); %gives 100 total points
        polytest = polygrid(pos(:,1),pos(:,2),0.005);
        xp = round(polytest(:,1));
        yp = round(polytest(:,2));
        [X,Y] = meshgrid(xp,yp);
    end
    % figure
    % scatter(xp,yp)
    % plot(X,Y,'.r')
    % hold off
    [Xr,Xc] = size(X);

    %generates a matrix of the magnitudes between each point in the grid
    %defined above and each midpoint

    midMags = zeros(Xr,Xc,length(midpoints(:,1)));
    for q = 1:length(midpoints(:,1))
        for n = 1:length(midMags(:,1,1))
    
            for m = 1:length(midMags(1,:,1))
                if [X(n,m),Y(n,m)] - midpoints(q,:) == 0
                    midMags(n,m,q) = 0;
                else
                    midMags(n,m,q) = norm([X(n,m),Y(n,m)] - midpoints(q,:));
                end
    
            end
    
    
        end

    end

    cornerMags = zeros(Xr,Xc,length(strongCorners(:,1)));
    for q = 1:length(strongCorners(:,1))
        for n = 1:length(cornerMags(:,1,1))
    
            for m = 1:length(cornerMags(1,:,1))
                if [X(n,m),Y(n,m)] - strongCorners(q,:) == 0
                    cornerMags(n,m,q) = 0;
                else
                    cornerMags(n,m,q) = norm([X(n,m),Y(n,m)] - strongCorners(q,:));
                end
    
            end
    
    
        end

    end

    centerMags = zeros(Xr,Xc,length(center(:,1)));
    for q = 1:length(center(:,1))
        for n = 1:length(centerMags(:,1,1))
    
            for m = 1:length(centerMags(1,:,1))
                if [X(n,m),Y(n,m)] - center(q,:) == 0
                    centerMags(n,m,q) = 0;
                else
                    centerMags(n,m,q) = norm([X(n,m),Y(n,m)] - center(q,:));
                end
    
            end
    
    
        end

    end

    cornerMags = min(cornerMags,[],3);
    midMags = min(midMags,[],3);
    imidMags = 1./(midMags);
    icornerMags = 1./(cornerMags);
    icenterMags = 1./(centerMags);
    imidMags(imidMags == Inf) = 0;
    icornerMags(icornerMags == Inf) = 0;
    icenterMags(icenterMags == Inf) = 0;
    midMax = max(imidMags,[],'all');
    cornerMax = max(icornerMags,[],'all');
    centerMax = max(icenterMags,[],'all');
    imidMags(imidMags == 0) = midMax;
    icornerMags(icornerMags == 0) = cornerMax;
    icenterMags(icenterMags == 0) = centerMax;


    A = cat(3,imidMags,icornerMags,icenterMags);
    Amax = max(A,[],3);
    nMidMags = imidMags;
    nCornerMags = icornerMags;
    nCenterMags = icenterMags;

    for n = 1:Xr

        for m = 1:Xc
            nMidMags(n,m) = imidMags(n,m)/Amax(n,m)*255;
            nCornerMags(n,m) = icornerMags(n,m)/Amax(n,m)*255;
            nCenterMags(n,m) = icenterMags(n,m)/Amax(n,m)*255;

        end
    end

    % absmax = max([midMax,cornerMax,centerMax]);
    % nMidMags = imidMags./absmax.*255;
    % nCornerMags = icornerMags./absmax.*255;
    % nCenterMags = icenterMags./absmax.*255;

    c = uint8(cat(3,nMidMags,nCornerMags,nCenterMags));

    rgb = zeros(length(nMidMags),3);

    for i = 1:Xr*Xc
        rgb(i,:) = [nMidMags(i),nCornerMags(i),nCenterMags(i)];
    end

    % heatFig = figure;
    % imshow(mask);
    % hold on
    % pcolor(X,Y,rgb)
    % Xvec = reshape(X,1,[])';
    % Yvec = reshape(Y,1,[])';
    % Xvecd = Xvec(1:100:end);
    % Yvecd = Yvec(1:100:end);
    % rgbd = rgb(1:100:end,:);
    % scatter(Xvecd,Yvecd,[],rgbd)
    % set(gcf,'Renderer','painters')
    Z = ones(size(X));
    % subplot(1,3,2);
    nexttile
    % heatm = surf(X,Y,Z,c,'EdgeColor','interp','FaceColor','interp');
    imshow(c)
    title('ROI Point Classification','FontSize',fontSize);
    subtitle('Red = Edge, Green = Corner, Blue = Center','FontSize',fontSize);
    % view(-90,90)
    % direction = [0 0 1];
    % rotate(heatm,direction,90)


    r2 = zeros(size(X));
    g2 = r2;
    b2 = r2; 
    for n = 1:length(X(:,1))

        for m = 1:length(X(1,:))
            
            if midMags(n,m) < cornerMags(n,m) && centerMags(n,m) > midMags(n,m)
                % r2(n,m) = max([nMidMags(n,m),nCornerMags(n,m),nCenterMags(n,m)]);
                r2(n,m) = 255;
                g2(n,m) = 0;
                b2(n,m) = 0;
            elseif midMags(n,m) > cornerMags(n,m) && centerMags(n,m) > cornerMags(n,m)
                r2(n,m) = 0;
                % g2(n,m) = max([nMidMags(n,m),nCornerMags(n,m),nCenterMags(n,m)]);
                g2(n,m) = 255;
                b2(n,m) = 0;
            else
                r2(n,m) = 0;
                g2(n,m) = 0;
                % b2(n,m) = max([nMidMags(n,m),nCornerMags(n,m),nCenterMags(n,m)]);
                b2(n,m) = 255;
            end


        end

    end
    c2 = cat(3,r2,g2,b2);


    % heatFig2 = figure;
    % subplot(1,3,3);
    nexttile
    imshow(c2)
    title('Thresholded ROI Point Classification','FontSize',fontSize);
    subtitle('Red = Edge, Green = Corner, Blue = Center')
    % heatm2 = surf(X,Y,Z,c2,'EdgeColor','interp','FaceColor','interp');
    % view(2)





else


end


prompt = 'Do you need to generate lineplot data for your images? (yes or no): ';
booldata = input(prompt,'s');
tic
if isequal(booldata,'yes')



linevalues_cumulative = zeros(max(num_points),num_lines,num_images);
wellradius_guess = floor(dataOutput_immediate(1,3));

 


    for ii = 1:num_images
        
        if threshbool
            tiff_stack = uint8(mask_image_data(:,:,ii));

        else
            %add in loop over images to change currentImage
            currentImage = [imagefiles(ii).folder '\' imagefiles(ii).name];
            %tiff_stack1 = imread(currentImage, "tiff");
            %tiff_stack = imadjust(imread(currentImage, "tiff"));
            tiff_stack = im2gray(imread(currentImage));
            tiff_stack = uint8(single(tiff_stack).*alphamat);
            % imshow(tiff_stack);
        end

        %mean(tiff_stack,'all')
        lineind = 1;
        for anglevalue = 0:1:num_lines-1

            if lineind > num_lines
                break
            end
            
            if radii ~= 0 && ~draw
                linevalues_output = improfile(tiff_stack,[dataOutput_immediate(1,1) dataOutput_immediate(1,1)+(wellradius_guess*cosd(anglevalue))],[dataOutput_immediate(1,2) dataOutput_immediate(1,2)+(wellradius_guess*sind(anglevalue))],num_points);
                % line([dataOutput_immediate(1,1) dataOutput_immediate(1,1)+(wellradius_guess*cosd(anglevalue))],[dataOutput_immediate(1,2) dataOutput_immediate(1,2)+(wellradius_guess*sind(anglevalue))]);

                % linemin = min(linevalues_output);
                % linemax = max(linevalues_output);
                % linevalues_output = linevalues_output/
                % linevalues_template = zeros(900,1);
            % elseif circrect
            %     linevalues_output = improfile(tiff_stack,[dataOutput_immediate(1,1) dataOutput_immediate(1,1)+(wellradius_guess*cosd(anglevalue))],[dataOutput_immediate(1,2) dataOutput_immediate(1,2)+(wellradius_guess*sind(anglevalue))],num_points);
            
            elseif draw && ~skeletonbool
                linevalues_output = improfile(tiff_stack,[x_cen,pos(anglevalue+1,1)],[y_cen,pos(anglevalue+1,2)],num_points(anglevalue+1));

                fix = length(linevalues_output);
                fixr = 900-fix;
                if fixr > 0
                    apend = -1*ones(1,fixr)';
                    linevalues_output = [linevalues_output; apend];
                end
                % line([x_cen,pos(anglevalue+1,1)],[y_cen,pos(anglevalue+1,2)])
            elseif skeletonbool
                for i = 1:length(pos(:,1))
                    % line([pos(i,1) spos(valind(i),1)],[pos(i,2) spos(valind(i),2)])
                    %edge to center
                    % linevalues_output = improfile(tiff_stack,[pos(i,1) spos(valind(i),1)],[pos(i,2) spos(valind(i),2)],num_points(lineind));
                    %center to edge
                    linevalues_output = improfile(tiff_stack,[spos(valind(i),1) pos(i,1)],[spos(valind(i),2) pos(i,2)],num_points(lineind));
                    % lineind = lineind + 1;
                    fix = length(linevalues_output);
                    fixr = 900-fix;
                    if fixr > 0
                        apend = -1*ones(1,fixr)';
                        linevalues_output = [linevalues_output; apend];
                    end
                    if any(isnan(linevalues_output))
                        nanimask = isnan(linevalues_output);
                        linevalues_output(nanimask) = 0;
                    end
                    linevalues_cumulative(:,lineind,ii) = linevalues_output;
                    lineind = lineind + 1;

                if i == length(pos(:,1))
                     for q = [valind(i),valind(1)]
                         % line([pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)])
                        % linevalues_output = improfile(tiff_stack,[pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)],num_points(lineind));
                        linevalues_output = improfile(tiff_stack,[spos(q,1) pos(i,1)],[spos(q,2) pos(i,2)],num_points(lineind));
                        % lineind = lineind + 1;
                        fix = length(linevalues_output);
                        fixr = 900-fix;
                        if fixr > 0
                            apend = -1*ones(1,fixr)';
                            linevalues_output = [linevalues_output; apend];
                        end
                        if any(isnan(linevalues_output))
                            nanimask = isnan(linevalues_output);
                            linevalues_output(nanimask) = 0;
                        end
                        linevalues_cumulative(:,lineind,ii) = linevalues_output;
                        lineind = lineind + 1;
                     end
                else
                    start = min(valind(i),valind(i+1));
                    stop = max(valind(i),valind(i+1));
                    for q = start+1:stop-1
                        % line([pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)])
                        % linevalues_output = improfile(tiff_stack,[pos(i,1) spos(q,1)],[pos(i,2) spos(q,2)],num_points(lineind));
                        linevalues_output = improfile(tiff_stack,[spos(q,1) pos(i,1)],[spos(q,2) pos(i,2)],num_points(lineind));
                        fix = length(linevalues_output);
                        fixr = 900-fix;
                        if fixr > 0
                            apend = -1*ones(1,fixr)';
                            linevalues_output = [linevalues_output; apend];
                        end
                        if any(isnan(linevalues_output))
                            nanimask = isnan(linevalues_output);
                            linevalues_output(nanimask) = 0;
                        end
                        linevalues_cumulative(:,lineind,ii) = linevalues_output;
                        lineind = lineind + 1;
            
                    end
        
                end
    

                end
            end
            
            if ~skeletonbool
                if any(isnan(linevalues_output))
                    nanimask = isnan(linevalues_output);
                    linevalues_output(nanimask) = 0;
    
    
                end
    
                %colLength = size(linevalues_output());
        
                %linevalues_output(numel(linevalues_template)) = 0;
        
                %line([dataOutput_immediate(1,1) dataOutput_immediate(1,1)+(wellradius_guess*cosd(anglevalue))],[dataOutput_immediate(1,2) dataOutput_immediate(1,2)+(wellradius_guess*sind(anglevalue))]);
        
                %linevalues_cumulative = horzcat([linevalues_cumulative linevalues_output]);
                linevalues_cumulative(:,anglevalue+1,ii) = linevalues_output;
            end
    
        end
    end

else

end

%removes points that change from less than 5% of their starting value

prompt = 'Do you want to set points that dont change by >5% to 0? ';
bool5p = input(prompt,'s');
if isequal(bool5p,'yes')
    for q=1:num_lines
    
           single_lineplot = linevalues_cumulative(:,q,:);
           negmask = linevalues_cumulative >= 0;
    
           single1 = single_lineplot(:,1,1);
           single2 = single_lineplot(:,1,end);
           change = single2(negmask(:,q,1))-single1(negmask(:,q,1));
           nmask = abs(change) > single1(negmask(:,q,1)).*.05;
           fix = length(negmask);
           fixr = 900-fix;
           if fixr > 0
               apend = ones(1,fixr)';
               nmask = [nmask; apend];
           end
           linevalues_cumulative(~nmask,q,:) = 0;
    
    
    
    end
else

end

linevalues_cumulative_c = linevalues_cumulative;

r_values = linspace(0,1,max(num_points))*radius_mm;
prompt = 'How many radial sections? ';
section_num = input(prompt);
step = floor(num_points./section_num); 

%% Binning of Data
binned_vals = zeros(section_num,num_images);
std_binned_vals = binned_vals;
line_std_vals = binned_vals; 
r_section = zeros(section_num+1,1,num_images);

for i = 1:num_images
    temp = 0;
    ind = 1;


    if ~draw
        while temp < num_points && ind <= section_num
            if temp == 0
                temp = 1;
            end
            
    
            if temp+step > num_points
                leap = num_points;
            else
                leap = temp + step;
            end
    
            line_std_vals(ind,i) = mean(std(linevalues_cumulative(temp:leap,:,i),0,1));
            linevalues_cumulative_c(temp:leap,:,i) = 30*ind;
            binned_vals(ind,i) = mean(linevalues_cumulative(temp:leap,:,i),'all');
            std_binned_vals(ind,i) = std(linevalues_cumulative(temp:leap,:,i),[],'all');
            r_section(ind,1,i) = r_values(temp);
            %r_section(ind,2,i) = r_values(temp+step);
    
            if ind == 1
                temp = 0;
            end
    
            ind = ind + 1;
            temp = temp +step; 
    
        end
        r_section(ind,1,i) = radius_mm;
    else
         temp = ones(length(mags),1);
         while any(temp < num_points) && ind <= section_num
            if temp == 0
                temp = 1;
            end
            
    
            if any(temp+step>num_points)
                leap = num_points+1;
                temp = temp + 1;
            else
                leap = temp + step;
            end

            section = linevalues_cumulative(1:max(leap)-1,:,i);
            %section = linevalues_cumulative(min(num_points):900,:,i);
            secmask = section>=0;
            %section = linevalues_cumulative(temp:leap,:,i);
            totalp = sum(step);
            tstor = zeros(1,totalp);
            stdstor = zeros(1,length(step));
            tsum = 1;

            if any(step > length(section(:,1)))
                smask = step > length(section(:,1));
                step(smask) = length(section(:,1));
            end

            for qw = 1:length(step)
                tstor(tsum:tsum+length(section(temp(qw):leap(qw)-1,qw))-1) = section(temp(qw):leap(qw)-1,qw);
                linevalues_cumulative_c(temp(qw):leap(qw)-1,qw,i) = 30*ind;
                stdstor(qw) = std(section(temp(qw):leap(qw)-1,qw));
                if any(stdstor > 1)
                    pause = 1;


                end
                tsum = tsum+step(qw);
                

            end


            line_std_vals(ind,i) = mean(stdstor);
            binned_vals(ind,i) = mean(tstor,'all');
            std_binned_vals(ind,i) = std(tstor,[],'all');
            %r_section(ind,1,i) = r_values(temp);
            %r_section(ind,2,i) = r_values(temp+step);
    
            % if ind == 1
            %     temp = 0;
            % end
    
            ind = ind + 1;
            temp = temp +step; 
    
        end
        %r_section(ind,1,i) = radius_mm;



    end
end

if section_num*step < num_points
    diff = num_points - section_num*step;
    disp('Number of points excluded near the edge: ');
    disp(diff);
    disp('All sections have the same number of points. Points excluded because section_num/num_points is not integer.');
end

norm_binned_vals = binned_vals; 
norm_std_vals = binned_vals; 
[row,col] = size(binned_vals);
for qq = 1:row
    normfac = mean(binned_vals(qq,:));
    initialval = binned_vals(qq,1);

    norm_binned_vals(qq,:) = binned_vals(qq,:)/initialval;
    norm_std_vals(qq,:) = std_binned_vals(qq,:)/initialval;

end






disp("Data Generation Time");
toc
%% Plotting & Data Writing
tic 

timevec = linspace(0,1,num_images);

fig1 = figure;
for n = 1:section_num
    plot(timevec,norm_binned_vals(n,:))
    hold on 

end
hold off

xlabel('Normalized Time');
ylabel('Normalized Intensity');
fig1.Color = 'w';

 Legend=cell(section_num,1);
 for iter=1:section_num
   Legend{iter}=strcat('r', num2str(iter));
 end
 legend(Legend);


disp("Plotting time");
toc

figx = figure;
imshow(uint8(linevalues_cumulative_c(:,:,1)))
xlabel('Line Index (X)','FontSize',20);
ylabel('Point Distance Magntidue','FontSize',20);
title('Center Point','FontSize',20);
figx.Color = 'w';



prompt = 'What output file name do you want? (type none if you dont want an output file): ';
filename_output = input(prompt,'s');

if isequal(filename_output,'none')
      
else
    %filename_output = input(prompt,'s');
    names = string(Legend);
    stdnames = names+"std";
    normnames = names+"norm";
    nstdnames = names+"stdnorm";
    lineplotstd = names+"lineplot std"; 

    
    wordformat = string('');
    numformat = string('');

    for i = 1:length(names)
        wordformat = wordformat + '%s ';
    end
    wordformat = wordformat + '\r\n';

    for i = 1:length(names)
        numformat = numformat + '%.2f ';
    end
    numformat = numformat + '\r\n';


    fileID = fopen(filename_output,'w');
    fprintf(fileID,wordformat,names);
    fprintf(fileID,numformat,binned_vals);
    fprintf(fileID,wordformat,stdnames);
    fprintf(fileID,numformat,std_binned_vals);
    fprintf(fileID,wordformat,normnames);
    fprintf(fileID,numformat,norm_binned_vals);
    fprintf(fileID,wordformat,nstdnames);
    fprintf(fileID,numformat,norm_std_vals);
    fprintf(fileID,wordformat,lineplotstd);
    fprintf(fileID,numformat,line_std_vals);
    fclose(fileID);
end


prompt = 'What position file name do you want? (type none if you dont want an output file): ';
filename_output = input(prompt,'s');

if isequal(filename_output,'none')
      
else
    % filename_output = input(prompt,'s');
    % names = ['ROI Position','ROI Center'];
    % stdnames = names+"std";
    % normnames = names+"norm";
    % nstdnames = names+"stdnorm";
    % lineplotstd = names+"lineplot std"; 

    names = {'ROI x Position', 'ROI y Position'};
    names = string(names);
    roicenter = string({'ROI x Center','ROI y Center'});
    wordformat = string('');
    numformat = string('');

    for i = 1:length(names)
        wordformat = wordformat + '%s ';
    end
    wordformat = wordformat + '\r\n';

    for i = 1:length(names)
        numformat = numformat + '%.2f ';
    end
    numformat = numformat + '\r\n';


    fileID = fopen(filename_output,'w');
    fprintf(fileID,wordformat,names);
    fprintf(fileID,numformat,pos);
    fprintf(fileID,wordformat,roicenter);
    fprintf(fileID,numformat,center);
    
    fclose(fileID);
end

% imagefiles = dir('*.png');
% num_images = length(imagefiles);
warning('off','all')

prompt = 'Do you want gifs of the ROI image? (yes or no): ';
boolgif = input(prompt,'s');
[irow,icol] = size(tiff_stack);

if isequal(boolgif,'yes')
    imagedata = ones(irow,icol,num_images);
    for i = 1:num_images
        tiff_stack2 = im2gray(imread([imagefiles(i).folder '\' imagefiles(i).name]));
        imagedata(:,:,i) = imadjust(uint8(single(tiff_stack2).*alphamat));
        
    
    end
    M = squeeze(mat2cell(imagedata,1440,1920,ones(1,num_images)));
    %M = squeeze(mat2cell((rand(20,20,100) > 0.5)*2-1, 20, 20, ones(1,100)));
    % mstart = M{1};
    % for i = 1:num_images
    %     M{i} = 255 - imadjust(M{i}); 
    %     bricktest = 2;
    % 
    % end
    
    outFilename = 'ImageBWROIgif.gif';
    fig = figure();
    ax = axes();
    colormap([0 0 0; 1 1 1]);
    %colormap('gray');
    for i=1:num_images
        imagesc(ax, M{i});
        %ax = imshow(M{i});
        img = getframe(ax);
        img = rgb2gray(img.cdata);
        if i==1
            imwrite(img, outFilename, 'gif', 'LoopCount', inf, 'DelayTime', 0.05)
        else
            imwrite(img, outFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
        end
    end
    
    
    outFilename = 'ImageROIgif.gif';
    fig = figure();
    ax = axes();
    %colormap([0 0 0; 1 1 1]);
    %colormap('gray');
    for i=1:num_images
        imagesc(ax, M{i});
        %ax = imshow(M{i});
        img = getframe(ax);
        img = rgb2gray(img.cdata);
        if i==1
            imwrite(img, outFilename, 'gif', 'LoopCount', inf, 'DelayTime', 0.05)
        else
            imwrite(img, outFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
        end
    end

else



end


prompt = 'Do you want gifs of the ROI matrix? (yes or no): ';
boolgif = input(prompt,'s');
[lcrow,lccol,~] = size(linevalues_cumulative);

if isequal(boolgif,'yes')
    imagedata = ones(lcrow,lccol,num_images);
    for i = 1:num_images
        imagedata(:,:,i) = uint8(linevalues_cumulative(:,:,i));
    
    end
    M = squeeze(mat2cell(imagedata,lcrow,lccol,ones(1,num_images)));
    %M = squeeze(mat2cell((rand(20,20,100) > 0.5)*2-1, 20, 20, ones(1,100)));
    % mstart = M{1};
    % for i = 1:num_images
    %     M{i} = 255 - imadjust(M{i}); 
    %     bricktest = 2;
    % 
    % end
    
    outFilename = 'ROIBWgif.gif';
    fig = figure();
    ax = axes();
    colormap([0 0 0; 1 1 1]);
    %colormap('gray');
    for i=1:num_images
        %imagesc(ax, M{i});
        img = imagedata(:,:,i);
        ax = imshow(img);
        %img = getframe(ax);
        %img = rgb2gray(img.cdata);
        
        if i==1
            imwrite(img, outFilename, 'gif', 'LoopCount', inf, 'DelayTime', 0.05)
        else
            imwrite(img, outFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
        end
    end
    
    
    outFilename = 'ROIgif.gif';
    fig = figure();
    ax = axes();
    %colormap([0 0 0; 1 1 1]);
    %colormap('gray');
    for i=1:num_images
        img = imagedata(:,:,i);
        ax = imshow(img);
        % imagesc(ax, M{i});
        % %ax = imshow(M{i});
        % img = getframe(ax);
        % img = rgb2gray(img.cdata);
        if i==1
            imwrite(img, outFilename, 'gif', 'LoopCount', inf, 'DelayTime', 0.05)
        else
            imwrite(img, outFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
        end
    end

else



end



%% Function Headers

function KeyPressCb(src,evnt,change,ogx,ogy,ogc,ogr)
    key = evnt.Key;
    %fprintf('key pressed: %s\n',evnt.Key);
    obj = src.Children;
    dataObjs = obj.Children;
    y = dataObjs(1).YData;
    x = dataObjs(1).XData;
    
    if strcmp(key,'rightarrow')
        delta = x + change.*ones(1,length(x));
        dataObjs(1).XData = delta;
    elseif strcmp(key,'leftarrow')
        delta = x - change.*ones(1,length(x));
        dataObjs(1).XData = delta; 
    elseif strcmp(key,'uparrow')
        delta = y - change.*ones(1,length(y));
        dataObjs(1).YData = delta;
    elseif strcmp(key,'downarrow')
        delta = y + change.*ones(1,length(y));
        dataObjs(1).YData = delta;
    elseif strcmp(key,'w')
        radius = (x(1) - min(x))/2;
        x_cen = min(x) + radius;
        y_cen = min(y) + radius;
        thetas = 0:360;
        deltay = y_cen + (radius+change).*sind(thetas);
        deltax = x_cen + (radius+change).*cosd(thetas);
        dataObjs(1).YData = real(deltay);
        dataObjs(1).XData = real(deltax);
    elseif strcmp(key,'s')
        radius = (x(1) - min(x))/2;
        x_cen = min(x) + radius;
        y_cen = min(y) + radius;
        thetas = acosd((x-x_cen)./radius);
        thetas = 0:360;
        deltay = y_cen + (radius-change).*sind(thetas);
        deltax = x_cen + (radius-change).*cosd(thetas);
        dataObjs(1).YData = real(deltay);
        dataObjs(1).XData = real(deltax);

    % elseif strcmp(key,'r')
    % %     fe = figure;
    %     radius = (x(1) - min(x))/2;
    %     x_cen = min(x) + radius;
    %     y_cen = min(y) + radius;
    %     %r = rectangle('Position',[x_cen,y_cen,radius,radius]);
    %     x_corn = x_cen-x_cen/2;
    %     y_corn = y_cen-y_cen/2;
    %     topx = [x_corn:2:x_cen+x_cen/2];
    %     botx = flip(topx);
    %     sidey1 = [y_corn:2:y_cen+y_cen/2];
    %     sidey2 = flip(sidey1);
    %     topy = y_corn*ones(1,length(topx));
    %     boty = (y_cen+y_corn)*ones(1,length(botx));
    %     leftx = x_corn*ones(1,length(sidey1));
    %     rightx = (x_cen+x_corn)*ones(1,length(sidey1));
    %     xdata = [topx,rightx,botx,leftx];
    %     ydata = [topy,sidey1,boty,sidey2];
    % 
    %     dataObjs(1).XData = xdata;
    %     dataObjs(1).YData = ydata;
    % 
    elseif strcmp(key,'c')
    %     fe = figure;
        radius = ogr;
        x_cen = ogc(1);
        y_cen = ogc(2);
        thetas = 0:360;
        deltay = y_cen + (radius).*sind(thetas);
        deltax = x_cen + (radius).*cosd(thetas);
        dataObjs(1).YData = real(deltay);
        dataObjs(1).XData = real(deltax);
    % elseif strcmp(key,'l')
    %     lengthh = (max(x)-x(1))/2;
    %     widthh = (max(y)-y(1))/2;
    %     x_cen = min(x) + lengthh/2;
    %     y_cen = min(y) + widthh/2;
    %     %r = rectangle('Position',[x_cen,y_cen,radius,radius]);
    %     x_corn = x_cen-x_cen/2;
    %     y_corn = y_cen-y_cen/2;
    %     topx = [x_corn+1:2:x_corn+lengthh*2-1];
    %     botx = flip(topx);
    %     sidey1 = [y_corn+1:2:y_corn+widthh*2-1];
    %     sidey2 = flip(sidey1);
    %     topy = y_corn+1*ones(1,length(topx));
    %     boty = (y_cen+y_corn-1)*ones(1,length(botx));
    %     leftx = x_corn+1*ones(1,length(sidey1));
    %     rightx = (x_cen+x_corn-1)*ones(1,length(sidey1));
    %     xdata = [topx,rightx,botx,leftx];
    %     ydata = [topy,sidey1,boty,sidey2];
    % 
    %     dataObjs(1).XData = xdata;
    %     dataObjs(1).YData = ydata;
    
    
    
    end



end

% function value = KeyPressCb(src,evnt,change,handles)
%     fprintf('key pressed: %s\n',evnt.Key);
%     handles = guidata(src);
%     lineobject = src.Children.Children;
%     x = lineobject.XData;
%     y = lineobject.YData;
%     theta = acos(x./handles.radii);
%     changes = change.*ones(length(theta));
% 
%     % [x - cord, y - cord, radius]
%     if strcmp(evnt.Key, 'rightarrow')
%         x = x + changes;
%         handles.center(1) =  handles.center(1) + change;
%         lineobject = [x;y];
%         guidata(src,handles);
%         myfun1(src,evnt,handles);
%         handles = guidata(src);
%     elseif strcmp(evnt.Key, 'leftarrow')
%         x = x - changes;
%         handles.center(1) =  handles.center(1) - change;
%         lineobject = [x;y];
%         guidata(src,handles);
%     elseif strcmp(evnt.Key, 'uparrow')
%         lineobject.YData = y + change;
%         handles.center(2) =  handles.center(2) + change;
%         lineobject = [x;y];
%         guidata(src,handles);
%     elseif strcmp(evnt.Key,'downarrow')
%         lineobject.YData = y - change; 
%         handles.center(2) =  handles.center(2) - change;
%         lineobject = [x;y];
%         guidata(src,handles);
%     elseif strcmp(evnt.Key, 'w')
%         handles.radii = handles.radii + change;
%         lineobject.XData = handles.radii.*cos(theta);
%         lineobject.YData = handles.radii.*sin(theta);
%         lineobject = [x;y];
%         guidata(src,handles);
%     elseif strcmp(evnt.Key,'s')
%         handles.radii = handles.radii - change;
%         lineobject.XData = handles.radii.*cos(theta);
%         lineobject.YData = handles.radii.*sin(theta);
%         lineobject = [x;y];
%         guidata(src,handles);
%     elseif strcmp(evnt.Key,'f')
%         handles.bool = 1;
%     end
%     lineobject = [x;y];
%     guidata(src,handles);
% 
% 
% 
% 
% 
% 
%     %src.Children.Children = viscircles(centers, radii,'Color','b');
% end

% function pushbutton1_Callback(hObject, eventdata, handles)
% handles.A = 1;
% guidata(hObject, handles);   % Store changed struct inGUI
% myfun1(hObject, eventdata, handles);
% handles = guidata(hObject);  % <-- obtain changed struct from GUI
% disp(handles.A)

% function handles = myfun1(src, evnt, handles)
%     handles.A = 20;
%     guidata(src, handles);  % Store changed struct in GUI
% end

function varargout = interppolygon(X,N,method)
% INTERPPOLYGON  Interpolates a polygon.
%
%   Y = INTERPPOLYGON(X,N) interporpolates a polygon whose coordinates are
%   given in X over N points, and returns it in Y.
%
%   The polygon X can be of any dimension (2D, 3D, ...), and coordinates
%   are exected to be along columns. For instance, if X is 10x2 matrix (2D
%   polygon of 10 points), then Y = INTERPPOLYGON(X,50) will return a
%   50x2 matrix.
%
%   INTERPPOLYGON uses interp1 for interpolation. The interpolation method
%   can be specified as 3rd argument, as in Y=INTERPPOLYGON(X,N,'method').
%   Allowed methods are 'nearest', 'linear', 'spline' (the default),
%   'pchip', 'cubic' (see interp1).
%
%   ALGORITHM
%   The point to point distance array is used to build a metric, which will
%   be interpolated by interp1 over the given number of points.
%   Interpolated points are thus equally spaced only in the linear case,
%   not in other cases where interpolated points do not lie on the initial
%   polygon. If this is an issue, try caalling INTERPPOLYGON twice, as in:
%   >> Y = INTERPPOLYGON(X,50); % Make a spline interpolation%   
%   >> Z = INTERPPOLYGON(Y,50); % Will correct for uneven space between points
%
%   OUTPUT
%   On top of the interpolated polygon, [Y M] = INTERPPOLYGON(X,N) will
%   return in M the metric of the original polygon.
%
%   EXAMPLE
%   X = rand(5,2);
%   Y = interppolygon(X,50);
%   figure, hold on
%   plot(X(:,1),X(:,2),'ko-')
%   plot(Y(:,1),Y(:,2),'r.-')

% ------------------ INFO ------------------
%   Authors: Jean-Yves Tinevez 
%   Work address: Max-Plank Institute for Cell Biology and Genetics, 
%   Dresden,  Germany.
%   Email: tinevez AT mpi-cbg DOT de
%   January 2009
%   Permission is given to distribute and modify this file as long as this
%   notice remains in it. Permission is also given to write to the author
%   for any suggestion, comment, modification or usage.
% ------------------ BEGIN CODE ------------------

    if nargin < 3
        method = 'spline';
    end
    if nargin < 2 || N < 2
        N = 2;
    end

    % 1. Build metric
    [pl bl]         = polygonlength(X);
    orig_metric     = [   0 ;  cumsum(bl/pl) ];
    
    % 2. Interpolate
    interp_metric   = ( 0 : 1/(N-1) : 1)';
    Y               = interp1( ...
        orig_metric,...
        X,...
        interp_metric,...
        method);
    
    % 3. Ouputs
    varargout{1} = Y;
    if nargout > 1
        varargout{2} = orig_metric;
    end
    
    %% Subfunction
    % Calculate the point to point distanceof each polygon point
    function varargout = polygonlength(X)
        
        n_dim       = size(X,2);
        delta_X     = 0;
        for dim = 1 : n_dim
            delta_X = delta_X + ...
                diff(X(:,dim)).^2 ;
        end
        
        branch_lengths  = sqrt( delta_X );
        pl              = sum( branch_lengths );
        
        varargout{1}    = pl;
        if nargout > 1
            varargout{2} = branch_lengths;
        end
        
    end

end


%SAUVOLA local thresholding.
%   BW = SAUVOLA(IMAGE) performs local thresholding of a two-dimensional 
%   array IMAGE with Sauvola algorithm.
%      
%   BW = SAUVOLA(IMAGE, [M N], THRESHOLD, PADDING) performs local 
%   thresholding with M-by-N neighbourhood (default is 3-by-3) and 
%   threshold THRESHOLD between 0 and 1 (default is 0.34). 
%   To deal with border pixels the image is padded with one of 
%   PADARRAY options (default is 'replicate').
%       
%   Example
%   -------
%       imshow(sauvola(imread('eight.tif'), [150 150]));
%
%   See also PADARRAY, RGB2GRAY.

%   For method description see:
%       http://www.dfki.uni-kl.de/~shafait/papers/Shafait-efficient-binarization-SPIE08.pdf
%   Contributed by Jan Motl (jan@motl.us)
%   $Revision: 1.1 $  $Date: 2013/03/09 16:58:01 $

function output=sauvola(image, varargin)
    % Initialization
    numvarargs = length(varargin);      % only want 3 optional inputs at most
    if numvarargs > 3
        error('myfuns:somefun2Alt:TooManyInputs', ...
         'Possible parameters are: (image, [m n], threshold, padding)');
    end
     
    optargs = {[3 3] 0.34 'replicate'}; % set defaults
     
    optargs(1:numvarargs) = varargin;   % use memorable variable names
    [window, k, padding] = optargs{:};
    
    if ndims(image) ~= 2
        error('The input image must be a two-dimensional array.');
    end
    
    % Convert to double
    image = double(image);
    
    % Mean value
    mean = averagefilter(image, window, padding);
    
    % Standard deviation
    meanSquare = averagefilter(image.^2, window, padding);
    deviation = (meanSquare - mean.^2).^0.5;
    
    % Sauvola
    R = max(deviation(:));
    threshold = mean.*(1 + k * (deviation / R-1));
    output = (image > threshold);

end

function image=averagefilter(image, varargin)
    %AVERAGEFILTER 2-D mean filtering.
    %   B = AVERAGEFILTER(A) performs mean filtering of two dimensional 
    %   matrix A with integral image method. Each output pixel contains 
    %   the mean value of the 3-by-3 neighborhood around the corresponding
    %   pixel in the input image. 
    %
    %   B = AVERAGEFILTER(A, [M N]) filters matrix A with M-by-N neighborhood.
    %   M defines vertical window size and N defines horizontal window size. 
    %   
    %   B = AVERAGEFILTER(A, [M N], PADDING) filters matrix A with the 
    %   predefinned padding. By default the matrix is padded with zeros to 
    %   be compatible with IMFILTER. But then the borders may appear distorted.
    %   To deal with border distortion the PADDING parameter can be either
    %   set to a scalar or a string: 
    %       'circular'    Pads with circular repetition of elements.
    %       'replicate'   Repeats border elements of matrix A.
    %       'symmetric'   Pads array with mirror reflections of itself. 
    %
    %   Comparison
    %   ----------
    %   There are different ways how to perform mean filtering in MATLAB. 
    %   An effective way for small neighborhoods is to use IMFILTER:
    %
    %       I = imread('eight.tif');
    %       meanFilter = fspecial('average', [3 3]);
    %       J = imfilter(I, meanFilter);
    %       figure, imshow(I), figure, imshow(J)
    %
    %   However, IMFILTER slows down with the increasing size of the 
    %   neighborhood while AVERAGEFILTER processing time remains constant.
    %   And once one of the neighborhood dimensions is over 21 pixels,
    %   AVERAGEFILTER is faster. Anyway, both IMFILTER and AVERAGEFILTER give
    %   the same results.
    %
    %   Remarks
    %   -------
    %   The output matrix type is the same as of the input matrix A.
    %   If either dimesion of the neighborhood is even, the dimension is 
    %   rounded down to the closest odd value. 
    %
    %   Example
    %   -------
    %       I = imread('eight.tif');
    %       J = averagefilter(I, [3 3]);
    %       figure, imshow(I), figure, imshow(J)
    %
    %   See also IMFILTER, FSPECIAL, PADARRAY.
    
    %   Contributed by Jan Motl (jan@motl.us)
    %   $Revision: 1.2 $  $Date: 2013/02/13 16:58:01 $
    
    
    % Parameter checking.
    numvarargs = length(varargin);
    if numvarargs > 2
        error('myfuns:somefun2Alt:TooManyInputs', ...
            'requires at most 2 optional inputs');
    end
     
    optargs = {[3 3] 0};            % set defaults for optional inputs
    optargs(1:numvarargs) = varargin;
    [window, padding] = optargs{:}; % use memorable variable names
    m = window(1);
    n = window(2);
    
    if ~mod(m,2) m = m-1; end       % check for even window sizes
    if ~mod(n,2) n = n-1; end
    
    if (ndims(image)~=2)            % check for color pictures
        display('The input image must be a two dimensional array.')
        display('Consider using rgb2gray or similar function.')
        return
    end
    
    % Initialization.
    [rows columns] = size(image);   % size of the image
    
    % Pad the image.
    imageP  = padarray(image, [(m+1)/2 (n+1)/2], padding, 'pre');
    imagePP = padarray(imageP, [(m-1)/2 (n-1)/2], padding, 'post');
    
    % Always use double because uint8 would be too small.
    imageD = double(imagePP);
    
    % Matrix 't' is the sum of numbers on the left and above the current cell.
    t = cumsum(cumsum(imageD),2);
    
    % Calculate the mean values from the look up table 't'.
    imageI = t(1+m:rows+m, 1+n:columns+n) + t(1:rows, 1:columns)...
        - t(1+m:rows+m, 1:columns) - t(1:rows, 1+n:columns+n);
    
    % Now each pixel contains sum of the window. But we want the average value.
    imageI = imageI/(m*n);
    
    % Return matrix in the original type class.
    image = cast(imageI, class(image));

end

function A = concentricsquare(sz,difference)
    nestedMat = (sz-difference*2):-difference*2:0;
    layers = arrayfun(@(m){padarray(ones(m),(sz-m)*[.5,.5])},nestedMat);
    A = mod(sum(cat(3,layers{:}),3),2);
    
    % Plot it
    % imagesc(A)
    % axis equal
    
    % sz = 20;         % matrix size, square, positive integer
    % difference = 1;  % width of bands, positive integer 1 <= x <= (sz/2)-1
end

function [threshImage, threshVal] = imthresh(image)

%Set inital guess threshold with Otsu method
threshVal = graythresh(image);

%SHOW ORIGINAL AND THRESHOLDED IMAGES
threshImage = im2bw(image,threshVal);
threshWord = strcat('Threshold = ', num2str(threshVal));
% txt = text(-10,-10,threshWord);
FigHandle = figure('Position', [100, 100, 1600, 800]);
subplot(1,2,1), imshow(image);
subplot(1,2,2), imshow(threshImage), text(-10,-10,threshWord);

%MANUALLY ADJUST THRESHOLD VALUE
button = 1;
    while isempty(button) ~= 1
           
         [x,y,button] = ginput(1);
    
        % arrow keys to adjust threshold value
        if button == 30 % up arrow
            threshVal = threshVal + .01;
            if threshVal > 1
                threshVal = .99;
            end
        end
        if button == 31 % down arrow
            threshVal = threshVal - .01;
            if threshVal <= 0
                threshVal = 0.01;
            end
        end
        if button == 28 % left arrow
            threshVal = threshVal - .005;
            if threshVal <= 0
                threshVal = 0.01;
            end
        end
        if button == 29 % right arrow
            threshVal = threshVal + .005;
             if threshVal > 1
                threshVal = .99;
            end
        end
        
        threshVal;
        button;
        threshImage = im2bw(image,threshVal);
        threshWord = strcat('Threshold = ', num2str(threshVal));
        imshow(threshImage);
        text(-10,-10,threshWord);
    end
    close
end


%Make Mask
%Bobby Kent
%9/20/24
%
%Funciton that makes a mask from an image of a cell stain.
%
%Takes an image stored as a matrix variable as an input and outputs mask as
%a binary matrix.
%
%Email bobbykent14@gmail.com with questions.

function [mask, thresh] = make_mask(input_img,loop_index,threshin);

%Get threshold
if loop_index == 1
    [~, thresh] = imthresh(input_img);
else
    thresh = threshin;
end
mask_temp = im2bw(input_img,thresh);
mask_temp = bwmorph(mask_temp, 'close');
mask_temp = bwareaopen(mask_temp,10); % remove clusters smaller than 10 pixels
mask = bwmorph(mask_temp, 'spur');

end



function [threshImage, threshVal,zoomExtent] = imskel(image)

%Set inital guess threshold with Otsu method
% threshVal = graythresh(image);
threshVal = 0;

%SHOW ORIGINAL AND THRESHOLDED IMAGES
% threshImage = im2bw(image,threshVal);
% image = imbinarize(image);
threshImage = bwskel(image,"MinBranchLength",threshVal);
% threshImage = bwmorph(image,'skeleton',inf);
threshWord = strcat('MinBranchLength = ', num2str(threshVal));
% txt = text(-10,-10,threshWord);
FigHandle = figure('Position', [100, 100, 1600, 800]);
[srow,scol] = size(image);
% [lrow,lcol] = find(image,1,'last');
colvals = sum(image,1);
rowvals = sum(image,2);
[lrow,~] = find(rowvals,1,'last');
[~,lcol] = find(colvals,1,'last');
% [frow,fcol] = find(image,1,'first');
[frow,~] = find(rowvals,1);
[~,fcol] = find(colvals,1);
% [k] = find(threshWord,1,'last');
pad = 50;
zoomExtent = [max(1,frow-pad),max(1,fcol-pad);min(lrow+pad,srow),min(lcol+pad,scol)];

subplot(1,2,1), imshow(image(max(1,frow-pad):min(lrow+pad,srow),max(1,fcol-pad):min(lcol+pad,scol)));
subplot(1,2,2), imshow(threshImage(max(1,frow-pad):min(lrow+pad,srow),max(1,fcol-pad):min(lcol+pad,scol))), text(-20,-20,threshWord);


%MANUALLY ADJUST THRESHOLD VALUE
button = 1;
    while isempty(button) ~= 1
           
         [x,y,button] = ginput(1);
    
        % arrow keys to adjust threshold value
        if button == 30 % up arrow
            threshVal = threshVal + 10;
            % if threshVal > 1
            %     threshVal = .99;
            % end
        end
        if button == 31 % down arrow
            threshVal = threshVal - 10;
            if threshVal <= 0
                threshVal = 0;
            end
        end
        if button == 28 % left arrow
            threshVal = threshVal - 1;
            if threshVal <= 0
                threshVal = 0;
            end
        end
        if button == 29 % right arrow
            threshVal = threshVal + 1;
            %  if threshVal > 1
            %     threshVal = .99;
            % end
        end
        
        threshVal;
        button;
        % threshImage = im2bw(image,threshVal);
        threshImage = bwskel(image,"MinBranchLength",threshVal);
        % threshImage = bwmorph(image,'skeleton',inf);
        threshWord = strcat('MinBranchLength = ', num2str(threshVal));
        imshow(threshImage(max(1,frow-pad):min(lrow+pad,srow),max(1,fcol-pad):min(lcol+pad,scol)));
        text(-20,-20,threshWord);
    end
    close
end

%inPoints = getPolygonGrid(xv,yv,ppa) returns points that are within a 
%concave or convex polygon using the inpolygon function.

%xv and yv are columns representing the vertices of the polygon, as used in
%the Matlab function inpolygon

%ppa refers to the points per unit area you would like inside the polygon. 
%Here unit area refers to a 1.0 X 1.0 square in the axes. 

%Example: 
% L = linspace(0,2.*pi,6); xv = cos(L)';yv = sin(L)'; %from the inpolygon documentation
% inPoints = getPolygonGrid(xv, yv, 10^5)
% plot(inPoints(:, 1),inPoints(:,2), '.k');

function [inPoints] = polygrid( xv, yv, ppa)

	N = sqrt(ppa);
%Find the bounding rectangle
	lower_x = min(xv);
	higher_x = max(xv);

	lower_y = min(yv);
	higher_y = max(yv);
%Create a grid of points within the bounding rectangle
	inc_x = 1/N;
	inc_y = 1/N;
	
	interval_x = lower_x:inc_x:higher_x;
	interval_y = lower_y:inc_y:higher_y;
	[bigGridX, bigGridY] = meshgrid(interval_x, interval_y);
	
%Filter grid to get only points in polygon
	in = inpolygon(bigGridX(:), bigGridY(:), xv, yv);
%Return the co-ordinates of the points that are in the polygon
	inPoints = [bigGridX(in), bigGridY(in)];

end

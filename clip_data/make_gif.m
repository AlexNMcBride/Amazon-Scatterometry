function make_gif(filename,output)
% filename accepts any of deforestation or scatterometer clip array';
% output is some gif filename. Name it well!
    load(filename);
    files = size(clips);
    dims = size(clips(1).img);

    for n=1:files(2)
        img = clips(n).img;
        imagesc(img)
        title(string(clips(n).date))
        drawnow
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if n == 1
            imwrite(imind,cm,output,'gif','Loopcount',inf);
        else
            imwrite(imind,cm,output,'gif','WriteMode','append');
        end
    end
end
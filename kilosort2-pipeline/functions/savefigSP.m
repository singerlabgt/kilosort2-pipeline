function savefigSP(dayindex, datadir, figname, iden)
%makes figure directory and saves a png and matlab fig
%SP 4.27.18

if ~exist(datadir)
    mkdir(datadir);
end

filename = [datadir figname iden num2str(dayindex(1)) '_' num2str(dayindex(2))];
saveas(gcf,filename,'png');
saveas(gcf,filename,'fig');
    
end
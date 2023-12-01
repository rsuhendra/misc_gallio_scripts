hs_cytobands2 = cytobandread('cytoBand.txt');
hs_cytobands2 = cytobandread('test.txt');
counter = 0;
for i = 1:80
    if hs_cytobands2.BandEndBPs(i) ~= hs_cytobands2.BandStartBPs(i+1) && hs_cytobands2.BandStartBPs(i+1) ~=0 
        disp(i)
        counter = counter+1;
    end
    if hs_cytobands2.BandEndBPs(i+1)==0
        disp('test')
    end
end
chromosomeplot(hs_cytobands2, );
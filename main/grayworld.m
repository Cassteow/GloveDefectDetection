function out = grayworld(I)
linearA = rgb2lin(I);
percentiles = 10;
illuminant = illumgray(linearA,percentiles);

if(isequal(illuminant, [0 0 0]))
    out = I;
else
    linearB = chromadapt(linearA,illuminant,ColorSpace="linear-rgb");
    out = lin2rgb(linearB);
end

end
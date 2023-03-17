function out = grayworld(I)
linearA = rgb2lin(I);
percentiles = 10;
illuminant = illumgray(linearA,percentiles);

linearB = chromadapt(linearA,illuminant,ColorSpace="linear-rgb");
out = lin2rgb(linearB);
end
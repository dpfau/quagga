imSz = [512,512,725];
patchSz = [40,40];
loader = @sofroniewLoader;

% Laundry list of things that need to be standardized across data sets, or set based on data-specific parameters:
% average size of neurons, affects:
% 	optimal patch size (about twice the average neuron size makes sense)
%	surface-area-to-volume ratio cutoff (since surface area is multiplied by pixel width)
% range used to measure fluoresence intensity (can vary dramatically from data set to data set), affects:
%	reasonable sparsity parameter for sparse PCA
%	percentile cutoff for deciding if there is any actiivity in a patch (though the average SNR for the given data set matters too)
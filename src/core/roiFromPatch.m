function [ROI,junk,patch,patchRng] = roiFromPatch(ind, config, debug)

% to compile: /usr/local/matlab-2010a/bin/mcc -R -singleCompThread -C -m ~/github/quagga/src/core/roiFromPatch.m -a ~/github/quagga/ -a ~/Dropbox/helper-matlab/external/spams-matlab/

% debug flags:
%  0 - no debugging
%  1 - outputs junk ROIs along with good ROIs
%  2 - loads fixed patch from current directory instead of using loader

if nargin < 3, debug = 0; end
if ischar(ind)
    ind = str2num(ind); % Sometimes has to be passed as a string because of the way arguments are passed to compiled matlab
end

% if nargin < 2 % default settings for Ahrens group data
%     imSz = [1472,2048,41,1000];
%     patchSz = [64,64,4];
%     neuronSz = [15,15,2];
%     savePath = '/groups/freeman/freemanlab/Janelia/quagga/test/'; % can change this as desired
%     loader = @ahrensLoader;
%     stdThresh = 0.07;
%     stdPrctile = 99;
%     dff = false;
%     saveROI = true;
% else
if ischar(config) 
    % occasionally when running this on a cluster, we have to pass things around by saving them
    % and having individual nodes loading them. This would be so much easier on Hadoop or Spark.
    load(config)
end
imSz = config.imSz;
neuronSz = config.neuronSz;
if isfield(config,'patchSz')
    patchSz = config.patchSz;
else
    patchSz = 2*config.neuronSz;
    if imSz(3) == 1
        patchSz(3) = 1;
    end
end
savePath = config.savePath;
loader = config.patchLoader;
stdThresh = config.stdThresh;
stdPrctile = config.stdPrctile;
dff = config.dff;
saveROI = config.saveROI;
if isfield(config,'spamsPath')
    addpath(genpath(config.spamsPath));
end
% end

if isfield(config,'inds')
    ind = config.inds(ind); % reindex if we're working with a subset of patches
end

if patchSz(3) > 1
	numPC = 15; % number of sparse PCs to look at in patch
else
	numPC = 5;
end
sparseWeight = 0.3; % weight on the sparse penalty for patch

% Load patch from data file
if debug == 2
    load patch.mat
    patchRng = {[1001,1064],[1001,1064],[25,28]}; % fake range, doesn't matter
else
    [patch,patchRng] = loadPatch(ind,imSz,patchSz,loader);
end
truePatchSz = cellfun(@(x) diff(x)+1, patchRng); % If the patch goes over the edge of the image, this is the actual patch size

patch = reshape(patch,prod(truePatchSz),imSz(end));
if prctile(std(patch,[],2),stdPrctile) > stdThresh % threshold to decide there is more than noise in this patch
	% Run sparse PCA on data in patch
    tic
	% patch = bsxfun(@minus,patch,mean(patch,2)); % sparsePCA has subtraction already. This should be redundant.
    if dff
        fprintf('Computing df/f\n');
        patch = bsxfun(@(x,y) (x-y)./y, patch, mean(patch,2));
    end
    if isempty(config.spamsPath) % The SPAMS implementation is much faster, but is tricky to get working with compiled MATLAB
        [W,H] = sparsePCA(patch,sparseWeight,numPC,false);
    else
	   [W,H] = sparsePCAspams(patch,sparseWeight,numPC,false); % don't clutter the terminal with objective values
    end
	% Split ROI in the same sparse PC that aren't connected, and merge ROI that are
	% in different sparse PCs but significantly overlap in space. This is all within
	% one patch. This will be followed by a step that merges ROIs across different
	% patches
	if debug == 1
		[ROI, junk] = segregateComponents(reshape(W,[truePatchSz,numPC]),truePatchSz,neuronSz);
		ROI  = cellfun(@(x) local2global(x,imSz(1:3),patchRng), ROI,  'UniformOutput', 0);
		junk = cellfun(@(x) local2global(x,imSz(1:3),patchRng), junk, 'UniformOutput', 0);
	else
		ROI = cellfun(@(x) local2global(x,imSz(1:3),patchRng),...
	          	     segregateComponents(reshape(W,[truePatchSz,numPC]),truePatchSz,neuronSz),...
	           	     'UniformOutput', 0);
    end
    
    if saveROI
        if debug == 1
            save(fullfile(savePath,['patch_' num2str(ind)]), 'ROI', 'junk','W','H')
        else
            save(fullfile(savePath,['patch_' num2str(ind)]), 'ROI')
        end
    end
    toc
else
	fprintf('not enough activity in patch\n')
	ROI = {};
    if saveROI
    	if debug
    		junk = {};
            save(fullfile(savePath,['patch_' num2str(ind)]), 'ROI', 'junk')
        else
            save(fullfile(savePath,['patch_' num2str(ind)]), 'ROI')
    	end
    end
end
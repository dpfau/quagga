%% Load relevant data
files = dir(fullfile(dataPath,dataset));
imlen = 0;
imheight = 512;
imwidth = 512; % default, but we check anyway
for i = 1:length(files)
	if ~isempty(strfind(files(i).name,'.tif'))
		info = imfinfo(fullfile(dataPath,dataset,files(i).name));
		imlen = imlen + length(info);
		imheight = info(1).Height;
		imwidth = info(1).Width;
	end
end

%% Put finishing touches on configuration struct and save
config.imSz = [imheight,imwidth,1,imlen];
config.savePath = fullfile(resultPath,dataset);
configPath = fullfile(resultPath,dataset,'config.mat');
save(configPath,'config'); % save the config struct so that it can be loaded by nodes on the cluster

%% Iterate over patches and send everything to the cluster
nPatches = numPatch(config.imSz(1:end-1),config.patchSz);
patchExpr = fullfile(resultPath,dataset,'patch_*.mat');
system(sprintf('rm %s',patchExpr)); % remove results of previous run
system(sprintf('rm %s',fullfile(logPath,'*'))); % remove logs from previous run
system(sprintf('qsub roiFromPatch.sh -t 1-%d -v config_path=%s',nPatches,configPath)); % send new run to the cluster

%% Ping the cluster once every 10 seconds until all patches have finished running
fprintf('Jobs submitted to cluster...\n')
tic
nFinished = 0;
while nFinished < nPatches
	pause(10)
	try
		patchFiles = ls(patchExpr,'-1');
		logFiles = ls(fullfile(logPath,'stdout.txt-*'),'-1'); % used to check for patches that crash for unexpected reasons, then resubmit them.
		nFinished = length(strfind(patchFiles,sprintf('\n')));
		% this is a hack, but it counts the number of newlines returns by 'ls patch_*.mat' in the folder the results are saved in

		% I also continue to run into a problem on the cluster where one or two jobs will crash for no good reason (usually some standard
		% MATLAB function suddenly can't be found). This finds any jobs that quit without saving a patch_<jobID>.mat file, deletes the log
	    % files and resubmits.
		logBreaks = strfind(logFiles,sprintf('\n'));
		if nFinished < length(logBreaks)
			logBreaks = [0 logBreaks];
			for i = 2:length(logBreaks)
				logFile = logFiles(logBreaks(i-1)+1:logBreaks(i)-1); % tokenize
				jobID = logFile(strfind(logFile,'stdout.txt-')+11:end);
				if ~exist(fullfile(resultPath,dataset,sprintf('patch_%s.mat',jobID)),'file')
					system(sprintf('rm %s%s',fullfile(logPath,'std*.txt-'),jobID));
					system(sprintf('qsub roiFromPatch.sh -t %s -v config_path=%s',jobID,configPath)); % resubmit job to the cluster
				end
			end
		end
	catch
		nFinished = 0;
	end
	fprintf('%d/%d patches complete\n',nFinished,nPatches)
end
toc
system(sprintf('rm %s',configPath));
fprintf('Merging across patches...\n')
mergePatches(1:nPatches,config.imSz,config.patchSz,config.savePath);
fprintf('Finished!\n')
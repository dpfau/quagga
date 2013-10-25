%% Iterate over patches and send everything to the cluster
if config.slice
	config.inds = getPatchSlice([0 0 config.slice],config.imSz(1:end-1),config.patchSz);
	nPatches = length(config.inds);
else
	nPatches = numPatch(config.imSz(1:end-1),config.patchSz);
end
patchExpr = fullfile(resultPath,dataset,'patch_*.mat');
system(sprintf('rm %s',patchExpr)); % remove results of previous run
system(sprintf('rm %s',fullfile(logPath,'*'))); % remove logs from previous run
system(sprintf('qsub -t 1-%d -pe batch 1 -N ''quagga'' -j y -o /dev/null -b y -cwd -V ''/groups/freeman/home/freemanj11/compiled/quagga/roiFromPatch ${SGE_TASK_ID} %s > /groups/freeman/freemanlab/Janelia/quagga/logs/${SGE_TASK_ID}.log''',nPatches,configPath)); % send new run to the cluster

% not tested yet...

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
mergePatchesFromFile(1:nPatches,config.imSz,config.patchSz,config.savePath);
fprintf('Finished!\n')
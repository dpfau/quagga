load twoNeuronPatch
addpath /Users/pfau/Documents/Code/Ncut_9

figure;
set(gcf,'Position',[0,200,1400,600])
for i = 1:3
    subplot(3,7,1+7*(i-1));
    I = reshape(W(:,i),40,40);
    imagesc(I); axis image; axis off
    title(['Sparse PC ' num2str(i)])
    [SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,~,imageEdges]= NcutImage(I,10);
    for j = 1:5
        subplot(3,7,1+j+7*(i-1));
        imagesc(reshape(NcutEigenvectors(:,j),40,40)); axis image; axis off;
        title(['NCut Eigenvector ' num2str(j)])
    end
    subplot(3,7,7*i);
    bw = edge(SegLabel,0.01);
    J1=showmask(I,bw);
    imagesc(J1); axis image; axis off
    title('NCut Segmentation')
end

figure;
set(gcf,'Position',[0,200,1400,600])
for i = 1:3
    subplot(3,7,1+7*(i-1));
    I = reshape(u(:,i),40,40);
    imagesc(I); axis image; axis off
    title(['PC ' num2str(i)])
    [SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,~,imageEdges]= NcutImage(I,10);
    for j = 1:5
        subplot(3,7,1+j+7*(i-1));
        imagesc(reshape(NcutEigenvectors(:,j),40,40)); axis image; axis off;
        title(['NCut Eigenvector ' num2str(j)])
    end
    subplot(3,7,7*i);
    bw = edge(SegLabel,0.01);
    J1=showmask(I,bw);
    imagesc(J1); axis image; axis off
    title('NCut Segmentation')
end
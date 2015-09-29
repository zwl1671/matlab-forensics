AlgorithmName='04';

Datasets=load('../Datasets_Linux.mat');


% dimension of statistics
Nb = [2, 8];
% number of cumulated bloks
Ns = 1;

InputOrigRoot='/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/';
OutputRoot='/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/';

Folders=dir(Datasets.MarkRealWorldSplices);
Folders=Folders(3:end);

for Folder=1:length(Folders)
    
    InputFolder=Folders(Folder).name;
    disp(InputFolder)
    
    OutDir=strrep([Datasets.MarkRealWorldSplices '/' Folders(Folder).name], InputOrigRoot, [OutputRoot AlgorithmName '/']);
    mkdir(OutDir);
    FileList=[];
    for fileExtension={'*.jpg','*.jpeg','*.png','*.gif','*.tif','*.bmp'}
        FileList=[FileList;dir([Datasets.MarkRealWorldSplices '/' Folders(Folder).name '/' fileExtension{1}])];
    end
    
    FileList=FileList(3:end);
    for fileInd=1:length(FileList)
        InputFileName=[Datasets.MarkRealWorldSplices '/' InputFolder '/' FileList(fileInd).name];
        OutputName=[strrep(InputFileName,InputOrigRoot,[OutputRoot AlgorithmName '/']) '.mat'];
        if ~exist(OutputName)
            Salvaged=[OutputRoot  AlgorithmName '/RW/' FileList(fileInd).name '.mat'];
            if exist(Salvaged)
                Salv=load(Salvaged);
                Salv.Name=strrep(InputFileName,InputOrigRoot,'');
                save(OutputName, '-struct','Salv');
            else
                
                ImageIn=CleanUpImage(InputFileName);
                toCrop=mod(size(ImageIn),2);
                ImageIn=ImageIn(1:end-toCrop(1),1:end-toCrop(2),:);                
                [bayer, F1]=GetCFASimple(ImageIn);
                for j = 1:2
                    [Result{j}, stat{j}] = CFAloc(ImageIn, bayer, Nb(j),Ns);
                end
                Name=strrep(InputFileName,InputOrigRoot,'');
                save(OutputName,'AlgorithmName','Result','bayer','F1','Nb','Ns','Name','-v7.3');
            end
            if mod(fileInd,15)==0
                disp(fileInd)
            end
        end
    end
end

%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%本程序生成编码图像所需的声音，并保存至mat文件之中

function   AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio) 

DataPureTone = zeros(2,numel(MatrixFreq),TimeCodedSound*SampleRateAudio);


% SmoothCosFreq = 1/(TimeCodedSound*0.2) ;

% SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeCodedSound*0.1,TimeCodedSound*0.1,TimeCodedSound*0.2*SampleRateAudio))+1);
% SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
%                   ones(1,TimeCodedSound*SampleRateAudio-numel(SmoothSequence)),...
%                   SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
              

for i =1:1:numel(MatrixFreq)
DataPureTone(1,i,:) = MatrixLeftAmp(i)*sin(2*pi*MatrixFreq(i)*linspace(0,TimeCodedSound,TimeCodedSound*SampleRateAudio));

DataPureTone(2,i,:) = MatrixRightAmp(i)*sin(2*pi*MatrixFreq(i).*linspace(0,TimeCodedSound,TimeCodedSound*SampleRateAudio));


% DataPureTone(1,i,:) = reshape(DataPureTone(1,i,:),1,TimeCodedSound*SampleRateAudio).*SmoothSequence;
% DataPureTone(2,i,:) = reshape(DataPureTone(2,i,:),1,TimeCodedSound*SampleRateAudio).*SmoothSequence;

DataPureTone(1,i,:) = reshape(DataPureTone(1,i,:),1,TimeCodedSound*SampleRateAudio);
DataPureTone(2,i,:) = reshape(DataPureTone(2,i,:),1,TimeCodedSound*SampleRateAudio);


end



MatrixFreq_mat = MatrixFreq;
SampleRateAudio_mat =SampleRateAudio;
TimeCodedSound_mat = TimeCodedSound;
MatrixLeftAmp_mat = MatrixLeftAmp;
MatrixRightAmp_mat = MatrixRightAmp;

save DataPureTone.mat DataPureTone MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

end
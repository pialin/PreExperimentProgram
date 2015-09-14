%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%本程序生成编码图像所需的声音，并保存至mat文件之中

function   AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,AudioSampleRate) 

DataPureTune = zeros(2,numel(MatrixFreq),TimeCodedSound*AudioSampleRate);


SmoothCosFreq = 1/(TimeCodedSound*0.2) ;
SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeCodedSound*0.1,TimeCodedSound*0.1,TimeCodedSound*0.2*AudioSampleRate))+1);
SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
                  ones(1,TimeCodedSound*AudioSampleRate-numel(SmoothSequence)),...
                  SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
              

for i =1:1:numel(MatrixFreq)
DataPureTune(1,i,:) = MatrixLeftAmp(i)*sin(2*pi*MatrixFreq(i)*linspace(0,TimeCodedSound,TimeCodedSound*AudioSampleRate));

DataPureTune(2,i,:) = MatrixRightAmp(i)*sin(2*pi*MatrixFreq(i).*linspace(0,TimeCodedSound,TimeCodedSound*AudioSampleRate));


DataPureTune(1,i,:) = reshape(DataPureTune(1,i,:),1,TimeCodedSound*AudioSampleRate).*SmoothSequence;
DataPureTune(2,i,:) = reshape(DataPureTune(2,i,:),1,TimeCodedSound*AudioSampleRate).*SmoothSequence;


end



MatrixFreq_mat = MatrixFreq;
AudioSampleRate_mat =AudioSampleRate;
TimeCodedSound_mat = TimeCodedSound;
MatrixLeftAmp_mat = MatrixLeftAmp;
MatrixRightAmp_mat = MatrixRightAmp;

save DataPureTune.mat DataPureTune MatrixFreq_mat AudioSampleRate_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

end
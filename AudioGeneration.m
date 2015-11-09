%音频数据生成程序

%软件环境
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%本程序生成编码图像所需的声音，并保存至mat文件之中

function   AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio) 

DataPureTone = zeros(2,numel(MatrixFreq),TimeCodeSound*SampleRateAudio);


SmoothCosFreq = 1/(TimeCodeSound*0.2) ;

SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeCodeSound*0.1,TimeCodeSound*0.1,TimeCodeSound*0.2*SampleRateAudio))+1);
SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
                  ones(1,TimeCodeSound*SampleRateAudio-numel(SmoothSequence)),...
                  SmoothSequence(round(numel(SmoothSequence)/2+1):end)];



for i =1:1:numel(MatrixFreq)
DataPureTone(1,i,:) = MatrixLeftAmp(i)*sin(2*pi*MatrixFreq(i)*linspace(0,TimeCodeSound,TimeCodeSound*SampleRateAudio));

DataPureTone(2,i,:) = MatrixRightAmp(i)*sin(2*pi*MatrixFreq(i).*linspace(0,TimeCodeSound,TimeCodeSound*SampleRateAudio));


DataPureTone(1,i,:) = reshape(DataPureTone(1,i,:),1,TimeCodeSound*SampleRateAudio).*SmoothSequence;
DataPureTone(2,i,:) = reshape(DataPureTone(2,i,:),1,TimeCodeSound*SampleRateAudio).*SmoothSequence;



% DataPureTone(1,i,:) = reshape(DataPureTone(1,i,:),1,TimeCodeSound*SampleRateAudio);
% DataPureTone(2,i,:) = reshape(DataPureTone(2,i,:),1,TimeCodeSound*SampleRateAudio);



end

%生成白噪声
DataWhiteNoise = randn(1,TimeWhiteNoise*SampleRateAudio);

SmoothCosFreq = 1/(TimeWhiteNoise*0.2) ;

SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeWhiteNoise*0.1,TimeWhiteNoise*0.1,TimeWhiteNoise*0.2*SampleRateAudio))+1);
SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
                  ones(1,TimeWhiteNoise*SampleRateAudio-numel(SmoothSequence)),...
                  SmoothSequence(round(numel(SmoothSequence)/2+1):end)];

DataWhiteNoise = DataWhiteNoise.*SmoothSequence;

DataWhiteNoise = mapminmax(DataWhiteNoise);


MatrixFreq_last = MatrixFreq;
SampleRateAudio_last =SampleRateAudio;
TimeCodeSound_last = TimeCodeSound;
TimeWhiteNoise_last = TimeWhiteNoise;
MatrixLeftAmp_last = MatrixLeftAmp;
MatrixRightAmp_last = MatrixRightAmp;

save .\DataAudio\AudioGeneration.mat DataPureTone DataWhiteNoise MatrixFreq_last SampleRateAudio_last TimeCodeSound_last TimeWhiteNoise_last MatrixLeftAmp_last MatrixRightAmp_last;

end
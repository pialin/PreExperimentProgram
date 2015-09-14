%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


%%
%此程序设置实验主程序的一些参数


%%
%基本参数设置
%编码点数

NumCodedDot = 3;

%Trial数 （白噪->编码声音->无声 为一个Trail）
NumTrial = 10;


%%
%时间参数设置

%准备时长(包括倒计时时长)
TimePrepare = 10; 

%倒计时秒数
TimeCountdown = 3; 

%白噪声呈现时长（单位：秒）
TimeWhiteNoise = 1;

%编码声音呈现时长（单位：秒/点）
TimeCodedSound = 1;

%无声时长(单位：秒)
TimeSilence = 2;




%%
%显示参数设置

%屏幕底色（缺省值为黑色，可选颜色为black，white,red,green,blue,gray,或者可以用
%一个三维向量直接指定红绿蓝三原色比例,在此均为这三个元素均应为0-1之间的数值，下同）
ColorBackground = black;
%方块个数（每行/列的方块个数的平方）
NumSquare = 9;

%方块颜色(缺省值为白色,即[1,1,1])
ColorSquare = white;

%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = ;
% WidthGap = ;

%圆点颜色(缺省值为红色,即[1,0,0])
ColorDot  = red;

%圆点大小（默认直径为方块边长的0.7）
% SizeDot = ;


%%
%音频参数设置

%编码声音频率
MatrixFreq = [  800 1008 1267
                400  504  635 
                200  252  317  ];
            
MatrixLeftAmp = [ 0.8 0.5 0.2
                  0.8 0.5 0.2
                  0.8 0.5 0.2 ];

MatrixRightAmp = [ 0.2 0.5 0.8
                   0.2 0.5 0.8
                   0.2 0.5 0.8 ];          



%音频采样率（默认为44100Hz,单位：Hz）
SampleRateAudio = 44100;

load DataPureTune.mat;
if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
        SampleRateAudio==SampleRateAudio_mat &&...
        TimeCodedSound == TimeCodedSound_mat &&...
        isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
        isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
    clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

else
    
     AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,AudioSampleRate) 
     
     load DataPureTune.mat DataPureTune


end

DataWhiteNoise = randn(2,TimeWhiteNoise*AudioSampleRate);

DataWhiteNoise = DataWhiteNoise/max(abs(DataWhiteNoise(:)));
        



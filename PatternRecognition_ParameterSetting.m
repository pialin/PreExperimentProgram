%此程序进行图案探索实验的参数设置
%软件环境：
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64


%%
%基本实验参数设置
%trial数（一个trial对应一个图案的探索,trial数应为4的整数倍）
NumTrial = 20;



%%
%时间参数设置
%准备时长(包括倒计时时长，单位：秒)
TimePrepare = 10; 

%倒计时秒数（单位：秒）
TimeCountdown = 5.2; 

%实验结束显示时长（单位：秒）
TimeMessageFinish =1;

%编码声音呈现时长
TimeCodeSound = 1;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 1;

TimeWhiteNoise = 2;


%%
%阈值设定

%每次移动光标等待时长（超过时长自动退出程序,单位：秒）
TimeWaitPerMove = 100;

%一个图案最多花费的时间
TimeMaxPerPattern = 200;

%一个图案最多探索步数
MaxNumStep = 500;


%%
%显示设置

%屏幕底色（缺省值为黑色，可选颜色为black，white,red,green,blue,gray,或者可以用
%一个三维向量直接指定红绿蓝三原色比例,在此均为这三个元素均应为0-1之间的数值，下同）
ColorBackground = black;

%方块颜色(缺省值为白色,即[1,1,1])
ColorSquare = white;
%总方块数
NumSquare=81;


%根据方块计算每一行/列的方块数目
NumSquarePerRow = sqrt(NumSquare);

%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
% GapWidth = 0.1* SizeSquare;

SizeSquareFrame =  SizeScreenY/(NumSquarePerRow+2);
SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;

%圆点大小（默认直径为方块边长乘以0.6）
SizeDot = 0.6* SizeSquare ;

%九宫格边框的颜色
ColorSquareFrame = red;


%九宫格和图案重合点的颜色
ColorInterDot = red;
%图案与九宫格未重合点的颜色
ColorDiffDot = black;

%字体名称
NameFont = '微软雅黑';
%字体大小
SizeFont = 50;
%字体颜色
ColorFont = white;



%%
%图案相关设置

%图案个数
NumPattern = 20;

%每个图案对应的点序列
SequencePatternDot=...
    {
    39:43;
    23:9:59;
    [21:25,57:61];
    [21:9:57,25:9:61];
    
    [21:9:57,58:61];
    [25:9:61,57:60];
    [21:9:57,22:25];
    [21:25,34:9:61];
    [21:25,32:9:59];
    [23:9:50,57:61];
    [21:9:57,40:43];
    [39:42,25:9:61];
    
    [21:9:48,25:9:52,57:61];
    [21:9:57,22:25,58:61];
    [21:24,57:60,25:9:61];
    [21:25,30:9:57,34:9:61];
    
    [21:24,39:42,57:60,25:9:61];
    [21:9:48,23:9:50,25:9:52,57:61];
    [21:9:57,22:25,40:43,58:61];
    [30:9:57,32:9:59,34:9:61,21:25];

%     14:9:68;%1
%     [12:16,25,34,39:43,48,57,66:70];%2
%     [12:16,25,34,39:43,52,61,66:70];%3
%     [11:9:38,14:9:41,47:52,59,68];%4
%     [12:16,21,30,39:43,52,61,66:70];%5
%     [12:16,21,30,39:43,48,57,52,61,66:70];%6
%     [12:15,24:9:69];%7
%     [12:16,21,30,25,34,39:43,48,57,52,61,66:70];%8
%     [12:16,21,30,25,34,39:43,52,61,66:70];%9
%     [12:16,21:9:57,25:9:61,66:70];%0
    };

    

%%
%音频参数设置

%音频音量设置
AudioVolume = 0.5;


%修改工作路径至当前M文件所在目录
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(1:PosFileSep(end)));


%加载提示音数据
if exist('.\DataAudio\DataHintAudio.mat','file')
    load .\DataAudio\DataHintAudio.mat;
else
 
    
    AudioDataHit = audioread('.\DataAudio\Hit.wav')';
    TimeHit = length(AudioDataHit)/SampleRateAudio;
    SmoothCosFreq = 1/(TimeHit*0.2) ;
    
    SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeHit*0.1,TimeHit*0.1,TimeHit*0.2*SampleRateAudio))+1);
    SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
        ones(1,length(AudioDataHit)-numel(SmoothSequence)),...
        SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
    
    AudioDataHit = mapminmax(AudioDataHit.*SmoothSequence);
    
    AudioDataOut = audioread('.\DataAudio\Out.wav')';
    
    TimeOut = length(AudioDataOut)/SampleRateAudio;
    SmoothCosFreq = 1/(TimeOut*0.2) ;
    
    SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeOut*0.1,TimeOut*0.1,TimeOut*0.2*SampleRateAudio))+1);
    SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
        ones(1,length(AudioDataOut)-numel(SmoothSequence)),...
        SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
    
    AudioDataOut = mapminmax(AudioDataOut.*SmoothSequence);
    
    AudioDataRoll = audioread('.\DataAudio\Roll.wav')';
    AudioDataRoll = AudioDataRoll(1:8000);
    TimeRoll = length(AudioDataRoll)/SampleRateAudio;
    SmoothCosFreq = 1/(TimeRoll*0.2) ;
    
    SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeRoll*0.1,TimeRoll*0.1,TimeRoll*0.2*SampleRateAudio))+1);
    SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
        ones(1,length(AudioDataRoll)-numel(SmoothSequence)),...
        SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
    
    AudioDataRoll = mapminmax(AudioDataRoll.*SmoothSequence)*0.6;
    
    
    AudioDataPass = audioread('.\DataAudio\Pass.wav')';
    
    TimePass = length(AudioDataPass)/SampleRateAudio;
    SmoothCosFreq = 1/(TimePass*0.2) ;
    
    SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimePass*0.1,TimePass*0.1,TimePass*0.2*SampleRateAudio))+1);
    SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
        ones(1,length(AudioDataPass)-numel(SmoothSequence)),...
        SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
    
    AudioDataPass = mapminmax(AudioDataPass.*SmoothSequence);
    
    AudioDataFinish = audioread('.\DataAudio\Finish.wav')';
    
     TimeFinish = length(AudioDataFinish)/SampleRateAudio;
    SmoothCosFreq = 1/(TimeFinish*0.2) ;
    
    SmoothSequence = 0.5*(cos(2*pi*SmoothCosFreq*linspace(-1*TimeFinish*0.1,TimeFinish*0.1,TimeFinish*0.2*SampleRateAudio))+1);
    SmoothSequence = [SmoothSequence(1:round(numel(SmoothSequence)/2)),...
        ones(1,length(AudioDataFinish)-numel(SmoothSequence)),...
        SmoothSequence(round(numel(SmoothSequence)/2+1):end)];
    
    AudioDataFinish = mapminmax(AudioDataFinish.*SmoothSequence);
    

    save .\DataAudio\DataHintAudio.mat  AudioDataHit AudioDataOut AudioDataRoll AudioDataPass AudioDataFinish;
end

%美尔刻度
SequenceMel = [900 1000 1100  600  700  800 300  400  500];

%编码声音频率
MatrixFreq = reshape (700*(10.^(SequenceMel/2595)-1),3,3);
            
MatrixLeftAmp = [ 0.8 0.5 0.2
                  0.8 0.5 0.2
                  0.8 0.5 0.2 ];

MatrixRightAmp = [ 0.2 0.5 0.8
                   0.2 0.5 0.8
                   0.2 0.5 0.8 ];  
               
MatrixLeftAmp =MatrixLeftAmp';
MatrixRightAmp = MatrixRightAmp';

%音频采样率（默认为48Hz,单位：Hz）
SampleRateAudio = 48000;

%音频数据生成部分
%检查声音数据是否存在
if exist('.\DataAudio\AudioGeneration.mat','file')
    %若存在，则读取数据
    load .\DataAudio\AudioGeneration.mat;
    %并将频率、采样率、编码时长、左右耳强度与数据文件进行对比，若一致，则无需重新生成数据文件
    if  isequal(MatrixFreq,MatrixFreq_last)  &&...
            SampleRateAudio == SampleRateAudio_last &&...
            TimeCodeSound == TimeCodeSound_last &&...
            TimeWhiteNoise == TimeWhiteNoise_last &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_last) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_last) 
        
        clear MatrixFreq_last SampleRateAudio_last TimeCodeSound_last TimeWhiteNoise_last MatrixLeftAmp_last MatrixRightAmp_last;
    %若不一致则重新生成数据文件，并读取该文件
    else
        
        AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\DataAudio\AudioGeneration.mat DataPureTone;
        disp('音频数据已更新!')
        
    end
%若数据文件不存在，则直接生成数据文件，并读取该文件
else
    
    AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\DataAudio\AudioGeneration.mat DataPureTone;
    
    disp('生成音频数据!')
     
end


%%
%提示信息

MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);
MessageCountdown = double('即将开始...');
MessageFinish = double('实验结束：)');


%%
%其他

%并口地址设置
LPTAddress = 53264;

%并口标记含义说明
%1-200:表示标记点有方向键按下，数字代表按键次数（每个图案分别计数）
%201-240:表示标记点处更新目标点位置，实际数字为Trial数+200
%241-249:暂时保留
%250:表示因探索时间过长而自动转向下一目标点
%251:表示实验开始（准备阶段开始）
%252:表示实验长时间(TimeWaitPerMove)未检测到键盘输入而中止
%253:表示实验因Esc键按下而中止
%254:表示实验正常结束




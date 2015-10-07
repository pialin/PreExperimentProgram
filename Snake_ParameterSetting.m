%此程序用于方位辨识实验的参数设置

%基本参数设置
%Trial数（到达一个给定的目标点为一个Trial）
NumTrial = 3;

%编码声音呈现时长（A编码方案表示每个点的编码声音时长，B编码方案指每个图案编码的声音时长）
TimeCodedSound = 1;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 2;



%%
%时间参数设置

%准备时长(包括倒计时时长，单位：秒)
TimePrepare = 10; 

%倒计时秒数（单位：秒）
TimeCountdown = 6; 

%实验结束显示时长（单位：秒）
TimeMessageFinish =1;

%%
%阈值设定

%每次移动光标等待时长（超过时长自动退出程序,单位：秒）
TimeWaitPerMove = 100;

%整个Trial最多花费的时间
TimeMaxPerTrial = 200;

%一个图案最多探索步数
MaxNumStep = 500;


%%
%显示参数设定

%屏幕底色（缺省值为黑色，可选颜色为black，white,red,green,blue,gray,或者可以用
%一个三维向量直接指定红绿蓝三原色比例,在此均为这三个元素均应为0-1之间的数值，下同）
ColorBackground = black;

%方块颜色(缺省值为白色,即[1,1,1])
ColorSquare = white;
%总方块数
NumSquare=81;

%根据方块计算每一行/列的方块数目
NumSquarePerRow = sqrt(NumSquare);


%下一个目标点的出现范围限定
%即将下一个目标点相对于原目标点的横/纵向偏移限制在RangeNextTarget之内
%默认值为ceil(NumSquarePerRow/2)
RangeNextTarget = ceil(NumSquarePerRow/2);

%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
% GapWidth = 0.2* SizeSquare;

SizeSquareFrame =  SizeScreenY/(NumSquarePerRow+2);
SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;

%圆点颜色(用户所控制的点缺省值为红色,即[1,0,0])
%未到达目标点时
ColorDot = red;

%目标点颜色
ColorTarget =black;

%圆点大小（默认直径为方块边长乘以0.6）
SizeDot = 0.6* SizeSquare ;

%连线颜色和宽度
ColorLine = red;
WidthLine = 7;%已经最大

%字体名称
NameFont = '微软雅黑';
%字体大小
SizeFont = 50;
%字体颜色
ColorFont = white;



%提示信息
MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);

MessageCountdown = double('即将开始...');

MessageFinish = double('实验结束：)');
%%
%音频参数设定

%最小音量设置（即光标与目标点距离最远时的音量大小）
MinAudioVolume = 0.2;

%提示音音量设置
VolumeHint = 0.8;

%修改工作路径至当前M文件所在目录
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(1:PosFileSep(end)));



%加载提示音数据
if exist('.\HintSound\DataHintAudio.mat','file')
    load .\HintSound\DataHintAudio.mat;
else
    AudioDataHit = audioread('.\HintSound\Hit.wav')';
    AudioDataHit = AudioDataHit/max(abs(AudioDataHit(:)));
    
    AudioDataOut = audioread('.\HintSound\Out.wav')';
    AudioDataOut = AudioDataOut/max(abs(AudioDataOut(:)));
    
    AudioDataRoll = audioread('.\HintSound\Roll.wav')';
    AudioDataRoll = AudioDataRoll/max(abs(AudioDataRoll(:)));
    AudioDataRoll = AudioDataRoll(1:8000)*0.6;
    
    AudioDataPass = audioread('.\HintSound\Pass.wav')';
    AudioDataPass = AudioDataPass/max(abs(AudioDataPass(:)));
    
    AudioDataFinish = audioread('.\HintSound\Finish.wav')';
    AudioDataFinish = AudioDataFinish/max(abs(AudioDataFinish(:)));

    save .\HintSound\DataHintAudio.mat SampleRateAudio AudioDataHit AudioDataOut AudioDataRoll AudioDataPass AudioDataFinish;
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
%检查编码声音数据是否存在
if exist('.\CodeSound\DataPureTone.mat','file')
    %若存在，则读取数据
    load .\CodeSound\DataPureTone.mat;
    %并将频率、采样率、编码时长、左右耳强度与数据文件进行对比，若一致，则无需重新生成数据文件
    if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
            SampleRateAudio==SampleRateAudio_mat &&...
            TimeCodedSound == TimeCodedSound_mat &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
        clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;
    %若不一致则重新生成数据文件，并读取该文件
    else
        
        AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\CodeSound\DataPureTone.mat DataPureTone;
        disp('DataPureTone已经更新!')
        
    end
%若数据文件不存在，则直接生成数据文件，并读取该文件
else
    
    AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\CodeSound\DataPureTone.mat DataPureTone;
    
    disp('生成DataPureTone!')
    
end


%%
%其他

%并口地址设置
LPTAddress = 53264;

%并口标记含义说明
%1-200:表示标记点有方向键按下，数字代表按键次数（每个目标点分别计数）
%201-240:表示标记点处更新目标点位置，实际数字为Trial数+200
%241-249:暂时保留
%250:表示因探索时间过长而自动转向下一目标点
%251:表示实验开始（准备阶段开始）
%252:表示实验长时间(TimeWaitPerMove)未检测到键盘输入而中止
%253:表示实验因Esc键按下而中止
%254:表示实验正常结束





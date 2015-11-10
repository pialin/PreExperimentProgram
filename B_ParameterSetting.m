%此程序设置B编码实验主程序的一些参数
%软件环境：
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%基本参数设置
%编码点数
NumCodeDot = 2;

%音频重放次数
AudioCompetition = 4;

%Trial数 （白噪->编码声音->无声 为一个Trail）
NumTrial = 3;




%%
%时间参数设置

%准备时长
TimePrepare = 3; 



%白噪声呈现时长（单位：秒）
TimeWhiteNoise = 2;

%编码声音呈现时长（A编码方案表示每个点的编码声音时长，B编码方案指每个图案编码的声音时长）
TimeCodeSound = 1;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 1;

%编码声音循环次数
AudioRepetition = 3;



%实验结束显示时长（单位：秒）
TimeMessageFinish =1;




%%
%显示参数设置

%屏幕底色（缺省值为黑色，可选颜色为black，white,red,green,blue,gray,或者可以用
%一个三维向量直接指定红绿蓝三原色比例,在此均为这三个元素均应为0-1之间的数值，下同）
ColorBackground = black;
%方块个数（每行/列的方块个数的平方）
NumSquare = 9;
%根据方块计算每一行/列的方块数目
NumSquarePerRow = sqrt(NumSquare);

%方块颜色(缺省值为白色,即[1,1,1])
ColorSquare = white;

%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.2;
% GapWidth = 0.2* SizeSquare;

SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;


%圆点颜色(缺省值为红色,即[1,0,0])
ColorDot  = red;



%圆点大小（默认直径为方块边长乘以0.6）
SizeDot = 0.6* SizeSquare ;


%用于训练程序的圆点颜色
ColorDotUncoded = blue; 
ColorDotCoded = red;

%用于训练的连线颜色和宽度
ColorLine = red;
WidthLine = 7;%已经最大

%训练程序的最大限制点数
NumDotLimit = 4;

%字体名称
NameFont = '微软雅黑';
%字体大小
SizeFont = 50;
%字体颜色
ColorFont = white;


%%
%音频参数设置

%音频音量设置
AudioVolume = 0.5;

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
        
        load .\DataAudio\AudioGeneration.mat DataPureTone DataWhiteNoise;
        disp('音频数据已更新!')
        
    end
%若数据文件不存在，则直接生成数据文件，并读取该文件
else
    
    AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\DataAudio\AudioGeneration.mat DataPureTone DataWhiteNoise;
    
    disp('生成音频数据!')
     
end




        
%提示信息
MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);
MessageRefSound = double('参考音...');
MessageWhiteNoise1 = double('白噪声...');
MessageWhiteNoise2 = double('请用笔在纸上记录你的答案...'); 
MessageFinish = double('实验结束：)');

%%
%其他

%并口地址设置
LPTAddress = 53264;

%并口标记含义说明
%1-200:表示每个trial的开始
%201-250:保留
%251:表示实验开始(准备阶段开始)
%252：保留
%253：表示实验因为ESC键被按下而中止
%254:表示实验正常结束















%一个图案最多花费的时间
TimeMaxPerPattern = 200;

%九宫格边框的颜色
ColorSquareFrame = red;

ColorInterDot = red;
ColorDiffDot = black;

NumPattern = 2;

SequencePatternDot={[38:44];[14:9:68]};
    

MaxNumStep = 100;

%基本参数设置
%Trial数（到达一个给定的目标点为一个Trial）
NumTrial = 3;

%编码声音呈现时长（A编码方案表示每个点的编码声音时长，B编码方案指每个图案编码的声音时长）
TimeCodedSound = 1;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 1;



%%
%音频参数设置

%音频音量设置
AudioVolume = 0.5;

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
               
MatrixFreq= MatrixFreq';
MatrixLeftAmp =MatrixLeftAmp';
MatrixRightAmp = MatrixRightAmp';

%音频采样率（默认为48Hz,单位：Hz）
SampleRateAudio = 48000;

%音频数据生成部分
load DataPureTone.mat;

if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
        SampleRateAudio==SampleRateAudio_mat &&...
        TimeCodedSound == TimeCodedSound_mat &&...
        isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
        isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
    clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

else
    
     AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio); 
     
     load DataPureTone.mat DataPureTone;


end

%加载提示音数据
load DataHintAudio.mat;


%字体名称
NameFont = '微软雅黑';
%字体大小
SizeFont = 50;
%字体颜色
ColorFont = white;



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




%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
% GapWidth = 0.1* SizeSquare;

SizeSquareFrame =  SizeScreenY/(NumSquarePerRow+2);
SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;


%圆点大小（默认直径为方块边长乘以0.5）
SizeDot = 0.5* SizeSquare ;


%%
%阈值设定

%每次移动光标等待时长（超过时长自动退出程序,单位：秒）
TimeWaitPerMove = 100;
%一个Trial最多允许的步数（超过自动退出程序）
NumMaxStepPerTrial=100;


%%
%时间参数设置

%准备时长(包括倒计时时长，单位：秒)
TimePrepare = 10; 

%倒计时秒数（单位：秒）
TimeCountdown = 5.2; 

%实验结束显示时长（单位：秒）
TimeMessageFinish =2;


MessageCountdown = double('即将开始...');

%提示信息
MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);

MessageFinish = double('实验结束：)');


LPTAddress = 53264;




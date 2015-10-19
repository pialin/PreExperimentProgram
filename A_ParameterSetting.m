%此程序设置A编码实验主程序的一些参数
%软件环境：
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%基本参数设置
%编码点数
NumCodedDot = 2;
%音频重放次数
AudioCompetition = 4;

%Trial数 （白噪->编码声音->无声 为一个Trail）
NumTrial = 3;




%%
%时间参数设置

%准备时长(包括倒计时时长)
TimePrepare = 10; 

%倒计时秒数
TimeCountdown = 5.2; 

%白噪声呈现时长（单位：秒）
TimeWhiteNoise = 2;

%编码声音呈现时长（A编码方案表示每个点的编码声音时长，B编码方案指每个图案编码的声音时长）
TimeCodedSound = 1;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 1;

%编码声音循环次数
AudioRepetition = 3;


%无声时长(Trial之间的休息时间 单位：秒)
TimeBreak = 3;

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

%编码声音频率

%美尔刻度
SequenceMel = [900 1000 1100  600  700  800 300  400  500];

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

DataWhiteNoise = randn(2,TimeWhiteNoise*SampleRateAudio);

DataWhiteNoise = DataWhiteNoise/max(abs(DataWhiteNoise(:)));
        
%提示信息
MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);
MessageCountdown = double('即将开始...');
MessageWhiteNoise = double('现在播放的是白噪声...'); 
MessageSilence = double('请用小键盘记录你听到的图案...'); 
MessageFinish = double('实验结束：)');

%%
%其他

%并口地址设置
LPTAddress = 53264;

%并口标记含义说明
%1-200:表示每个图案（trial）声音呈现的开始和结束
%201:表示播放高斯白噪声
%202-250:暂时保留
%251:表示实验开始（准备阶段开始）
%252:保留
%253:实验因为ESC键被按下而中止
%254:表示实验正常结束




% %%
% %参数验证部分：
% 
% %%
% %基本参数 
% if isscalar(NumCodedDot)  && isnumeric(NumCodedDot) &&  fix(NumCodedDot)==NumCodedDot && NumCodedDot <= NumSquare && NumCodedDot>0
%     
% else   
%     
%     errordlg('NumCodedDot设置有误','参数设置错误');
%     return;
%     
% end
% 
% if isscalar(NumTrial)  && isnumeric(NumTrial) &&  fix(NumTrial)==NumTrial && NumTrial>0
%     
% else   
%     
%     errordlg('NumTrial设置有误','参数设置错误');
%     return;
%     
% end
% 
% 
% 
% %时间参数设置
% if isscalar(TimePrepare)  && isnumeric(TimePrepare) &&  TimePrepare>= TimeCountdown && TimePrepare >0
%     
% else
%      errordlg('TimePrepare设置有误','参数设置错误');
%      return;
%      
% end
% 
% if isscalar(TimeCountdown)  && isnumeric(TimeCountdown) &&  TimeCountdown<= TimeCountdown && TimeCountdown >0
%      
% else
%     
%      errordlg('TimeCountdown设置有误','参数设置错误');
%      return;
%      
% end
% 
% 
% if isscalar(TimeWhiteNoise)  && isnumeric(TimeWhiteNoise) &&  TimeWhiteNoise>0
%     
% else
%     
%      errordlg('TimeWhiteNoise设置有误','参数设置错误');
%      return;
%      
% end
% 
% if isscalar(TimeCodedSound)  && isnumeric(TimeCodedSound) &&  TimeCodedSound>0
%     
% else
%     
%      errordlg('TimeCodedSound设置有误','参数设置错误');
%      return;
%      
% end
% 
% if isscalar(TimeBreak)  && isnumeric(TimeBreak) &&  TimeBreak>0
%     
% else
%     
%      errordlg('TimeSilence设置有误','参数设置错误');
%      return;
%      
% end
% 
% 
% %显示参数设置
% 
% if (isscalar(ColorBackground) || numel(ColorBackground) == 3) && isnumeric(ColorBackground) && ...
%       all(ColorBackground>=0)  && all(ColorBackground<=1) 
% 
% else
%      errordlg('ColorBackground设置有误','参数设置错误');
%      return;
%    
% end
% 
% if isscalar(NumSquare) && isnumeric(NumSquare) && NumSquare>0 && fix(NumSquarePerRow) == NumSquarePerRow 
% 
% else
%      errordlg('NumSquare设置有误','参数设置错误');
%      return;
%    
% end
% 
% if (isscalar(ColorSquare) || numel(ColorSquare) == 3) && isnumeric(ColorSquare) && ...
%       all(ColorSquare>=0)  && all(ColorSquare<=1)
% 
% else
%      errordlg('ColorSquare设置有误','参数设置错误');
%      return;
%    
% end
% 
% 
% if isscalar(SizeSquare) &&  isnumeric(SizeSquare) && SizeSquare>0  && SizeSquare <=SizeScreenY/NumSquarePerRow 
% 
% else
%     errordlg('SizeSquare设置有误','参数设置错误'); 
%     return;
%     
% end
% 
% if isscalar(GapWidth) &&  isnumeric(GapWidth) && GapWidth>0  && GapWidth <=SizeSquare 
% 
% else
%     errordlg('GapWidth设置有误','参数设置错误');
%     return;
%     
% end
% 
% 
% 
% if (isscalar(ColorDot) || numel(ColorDot) == 3) && isnumeric(ColorDot) && ...
%     all(ColorDot>=0)  && all(ColorDot<=1) 
% 
% else
%      errordlg('ColorDot设置有误','参数设置错误');
%      return;
%    
% end
% 
% 
% if isscalar(SizeDot) &&  isnumeric(SizeDot) && SizeDot>0  && SizeDot <=SizeSquare 
% 
% else
%     errordlg('SizeDot设置有误','参数设置错误'); 
%     return;
%     
% end
% 
% if (isscalar(ColorDotUncoded) || numel(ColorDotUncoded) == 3) && isnumeric(ColorDotUncoded) && ...
%     all(ColorDotUncoded>=0)  && all(ColorDotUncoded<=1) 
% 
% else
%      errordlg('ColorDotUncoded设置有误','参数设置错误');
%      return;
%    
% end
% 
% 
% if (isscalar(ColorDotCoded) || numel(ColorDotCoded) == 3) && isnumeric(ColorDotCoded) && ...
%     all(ColorDotCoded>=0)  && all(ColorDotCoded<=1)
% 
% else
%      errordlg('ColorDotCoded设置有误','参数设置错误');
%      return;
%    
% end
% 
% if (isscalar(ColorLine) || numel(ColorLine) == 3) && isnumeric(ColorLine) && ...
%     all(ColorLine>=0)  && all(ColorLine<=1) 
% 
% else
%      errordlg('ColorLine设置有误','参数设置错误');
%      return;
%    
% end
% 
% if isscalar(WidthLine) &&  isnumeric(WidthLine) && WidthLine>0  && WidthLine<=WidthLine && fix(WidthLine) == WidthLine
% 
% else
%     errordlg('WidthLine设置有误','参数设置错误'); 
%     return;
%     
% end
% 
% 
% if isscalar(NumDotLimit)  && isnumeric(NumDotLimit) &&  fix(NumDotLimit)==NumDotLimit && NumDotLimit <= NumSquare && NumDotLimit>0
%     
% else   
%     
%     errordlg('NumDotLimit设置有误','参数设置错误');
%     return;
%     
% end
% 
% 
% if isscalar(SizeFont) && isnumeric(SizeFont) && SizeFont>0 && fix(SizeFont) ==SizeFont
% 
% else
%     errordlg('SizeFont设置有误','参数设置错误');
%     return;
%     
% end
% 
% if (isscalar(ColorFont) || numel(ColorFont) == 3) && isnumeric(ColorFont) && ...
%     all(ColorFont>=0)  && all(ColorFont<=1) 
% 
% else
%      errordlg('ColorFont设置有误','参数设置错误');
%      return;
%    
% end
% 
% 
% %音频参数验证
% 
% if isscalar(AudioVolume) && isnumeric(AudioVolume)&& AudioVolume>=0 && AudioVolume<=1
%     
% else
%       errordlg('AudioVolume设置有误','参数设置错误');
%       return;
% end
% 
% if ismatrix(MatrixFreq) && isnumeric(MatrixFreq) && numel(MatrixFreq)== NumSquare && all(MatrixFreq(:)>0)
%     
% else
%       errordlg('MatrixFreq设置有误','参数设置错误');
%       return;
% 
% end
% 
% if ismatrix(MatrixLeftAmp) && isnumeric(MatrixLeftAmp) && numel(MatrixLeftAmp)== NumSquare && all(MatrixLeftAmp(:)>=0)  && all(MatrixLeftAmp(:) <=1)
%     
% else
%       errordlg('MatrixLeftAmp设置有误','参数设置错误');
%       return;
% 
% end
% 
% if ismatrix(MatrixRightAmp) && isnumeric(MatrixRightAmp) && numel(MatrixRightAmp)== NumSquare && all(MatrixRightAmp(:)>=0)  && all(MatrixRightAmp(:) <=1)
%     
% else
%       errordlg('MatrixRightAmp设置有误','参数设置错误');
%       return;
% 
% end
% 
% 
% if isscalar(SampleRateAudio) && isnumeric(SampleRateAudio) && SampleRateAudio>0
% 
% else
%     errordlg('SampleRateAudio设置有误','参数设置错误');
%     return;
% end
% 
% 










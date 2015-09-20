%编码方式A实验程序
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

%修改工作路径至当前M文件所在目录
cd mfilename('fullpath');

%%
%随机数生成器状态设置
rng('shuffle');%Matlab R2012之后版本
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012之前版本


%%
%显示部分设置

%执行默认设置2
%相当于执行了以下三条语句：
%“AssertOpenGL;”%确保Screen函数被正确安装
%“KbName('UnifyKeyNames');”%根据当前操作系统给出KeyCode（按键码）和KeyName（按键名）的对应
%在创建窗口后立刻执行“Screen('ColorRange', PointerWindow, 1, [],1);”将颜色的设定方式由3个
%8位无符号组成的三维向量改成3个0到1的浮点数三维向量，目的是为了同时兼容不同颜色位数的显示器（比如16位显示器）
PsychDefaultSetup(2);

%获取所有显示器的序号
AllScreen = Screen('Screens');
%若有外接显示器，保证呈现范式所用的显示器为外接显示器
ScreenNumber = max(AllScreen);

%获取黑白对应的颜色设定值并据此计算其他一些颜色的设定值
white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);
gray = white/2;
red = [white,black,black];
green = [black,white,black];
blue = [black,black,white];


%try catch语句保证在程序执行过程中出错可以及时关闭创建的window和PortAudio对象，正确退出程序
try

%创建一个窗口对象，返回对象指针PointerWindow
[PointerWindow,~] = PsychImaging('OpenWindow', ScreenNumber, black);

%获取每次帧刷新之间的时间间隔
TimePerFlip = Screen('GetFlipInterval', PointerWindow);
%计算每秒刷新的帧数
FramePerSecond = 1/TimePerFlip;

%获取可用的优先级？？
LevelTopPriority = MaxPriority(PointerWindow);

%获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
[SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);

%调用ParameterSetting.m设置相应参数
ParameterSetting;

%字体和大小设定
Screen('TextFont',PointerWindow, NameFont);
Screen('TextSize',PointerWindow, SizeFont);
%设置Alpha-Blending相应参数
Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%等待帧数设定，后面用于保证准确的帧刷新时序
FrameWait = 1;




%方块坐标计算：XSquareCenter, YSquareCenter分别保存方块中心点的X坐标和Y坐标
if NumSquare == 1
    XSquareCenter = 0;
    YSquareCenter = 0;
else
    [XSquareCenter,YSquareCenter]= meshgrid(linspace(-1*(NumSquarePerRow-1)/2,(NumSquarePerRow-1)/2,NumSquarePerRow));
end


%将方块中心点的X坐标和Y坐标转成一个一维向量并加上偏置使坐标移至屏幕中心
XSquareCenter = reshape(XSquareCenter',1,NumSquare);
XSquareCenter = round(XSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);

YSquareCenter = reshape(YSquareCenter',1,NumSquare);
YSquareCenter = round(YSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);

%基准方块
RectBaseSquare = [0,0,round(SizeSquare),round(SizeSquare)];
%根据基准方块和方块中心点坐标计算出所有方块的范围（四维向量，格式：[左上角X坐标,左上角X坐标,右下角X坐标，右下角Y坐标]）
RectSquare = CenterRectOnPointd(RectBaseSquare,XSquareCenter',YSquareCenter')';
%基准圆点
RectBaseDot = [0,0,round(SizeDot),round(SizeDot)];
%根据基准圆点和方块中心点坐标计算出所有圆点的范围，格式同上
RectDot = CenterRectOnPointd(RectBaseDot,XSquareCenter',YSquareCenter')';

    

%%
%音频设置

%开启低延迟模式
EnableAudioLowLatencyMode = 1; 
InitializePsychSound(EnableAudioLowLatencyMode);

%设置音频声道数为2，即左右双声道立体声
NumAudioChannel = 2;

%PsyPortAudio('Start',...)语句执行后立刻开始播放声音
AudioStartTime = 0;
%等待声音真正播放后退出语句执行下面语句
WaitUntilDeviceStart = 1;
%音频重放次数，仅需播放一次
AudioRepetition = 1;


% 创建PortAudio对象，对应的参数如下
% (1) [] ,调用默认的
% (2) 1 ,仅进行声音播放（不进行声音录制）
% (3) 1 , 默认延迟模式
% (4) SampleRateAudio,音频采样率
% (5) 2 ,输出声道数为2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);

%播放音量设置
PsychPortAudio('Volume', HandlePortAudio, AudioVolume);

%新建一个Buffer存放白噪声数据，HandleNoiseBuffer为此Buffer的指针
HandleNoiseBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,DataWhiteNoise);

%优先级设置
Priority(LevelTopPriority);
%进行第一次帧刷新获取基准时间
vbl = Screen('Flip', PointerWindow);

%%
%等待阶段
%时长为准备时长减去倒计时时长
for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
    %绘制提示语
    DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
    %提示程序所有内容已绘制完成
    Screen('DrawingFinished', PointerWindow);
    
    %读取键盘输入，若Esc键被按下则立刻退出程序
    [IsKeyDown,~,KeyCode] = KbCheck;
    if IsKeyDown && KeyCode(KbName('ESCAPE'))
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
%             clear HandlePortAudio ;
        end
        Priority(0);
        sca;
        return;
    end
    
    %帧刷新
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end

%%
%倒计时阶段

for frame =1:round(TimeCountdown*FramePerSecond)
    %计算倒计时剩余时间
    TimeLeft = (TimeCountdown*FramePerSecond-frame)/FramePerSecond;
    %绘制倒计时数字
    DrawFormattedText(PointerWindow,num2str(ceil(TimeLeft)),'center', 'center', ColorFont);
    Screen('DrawingFinished', PointerWindow);
    
    %扫描键盘，如果Esc键被按下则退出程序
    [IsKeyDown,~,KeyCode] = KbCheck;
    if IsKeyDown && KeyCode(KbName('ESCAPE'))
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
%             clear HandlePortAudio ;
        end
        Priority(0);
        sca;
        return;
        
    end
    
    
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end

%%
%编码阶段
%重复次数由ParameterSetting中的NumTrial决定
for trial =1:NumTrial
    
    %随机获取进行声音编码的点
    SequenceCodedDot = randperm(NumSquare,NumCodedDot);
    
    %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
    AudioDataLeft = reshape(DataPureTone(1,SequenceCodedDot,1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
    AudioDataLeft = reshape(AudioDataLeft',1,[]);

    
    AudioDataRight = reshape(DataPureTone(2,SequenceCodedDot,1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
    AudioDataRight = reshape(AudioDataRight',1,[]);
    
    %归一化
    MaxAmp = max([MatrixLeftAmp(IndexPressedSquare), MatrixRightAmp(IndexPressedSquare)]);
    AudioDataRight =  AudioDataRight/MaxAmp;
    AudioDataLeft =  AudioDataLeft/MaxAmp;
            

    
    
    %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleNoiseBuffer);
    
    %播放白噪声
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
    
%%
%白噪声呈现阶段
%时长由ParameterSetting中的TimeWhiteNoise决定
    for Frame =1:round(TimeWhiteNoise*FramePerSecond)
         
        DrawFormattedText(PointerWindow,MessageWhiteNoise,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
           
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            if exist('HandlePortAudio','var')
                PsychPortAudio('Stop', HandlePortAudio);
                PsychPortAudio('Close', HandlePortAudio);
%                 clear HandlePortAudio ;
            end
            Priority(0);
            sca;
            return;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    %停止声音播放
    PsychPortAudio('Stop', HandlePortAudio);
    
    %将编码声音数据填充入Buffer中
    PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
    %播放编码声音
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
%%
%编码声音呈现阶段
    for dot = 1:NumCodedDot
        
        for frame=1:round(TimeCodedSound*FramePerSecond)
            %绘制方块和圆点
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodedDot(1:dot)),SizeDot+1);
            
            if dot > 1
                XLine = reshape(repmat(XSquareCenter((SequenceCodedDot(1:dot))),2,1),1,[]);
                
                YLine = reshape(repmat(YSquareCenter((SequenceCodedDot(1:dot))),2,1),1,[]);
                
                
                if dot ~= NumCodedDot
                    
                    Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
                    
                else
                    %如果到了最后一个方块，还需补充一条由初始点到终点的连线
                    Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
                    
                end
                
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
                if exist('HandlePortAudio','var')
                    PsychPortAudio('Stop', HandlePortAudio);
                    PsychPortAudio('Close', HandlePortAudio);
%                     clear HandlePortAudio ;
                end
                Priority(0);
                sca;
                return;
                
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
        end
    end
    
    PsychPortAudio('Stop', HandlePortAudio);
%%
%静音阶段（Trial之间的休息时间）
    for frame = 1:round(TimeSilence*FramePerSecond)
        
        if trial ~= NumTrial
            DrawFormattedText(PointerWindow,MessageSilence,'center', 'center', ColorFont);
            
        else
            
            DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
            
        end
        
        Screen('DrawingFinished', PointerWindow);
           
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            if exist('HandlePortAudio','var')
                PsychPortAudio('Stop', HandlePortAudio);
                PsychPortAudio('Close', HandlePortAudio);
%                 clear HandlePortAudio ;
            end
            Priority(0);
            sca;
            return;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
        
    end
    
end

%恢复显示优先级
Priority(0);
%关闭PortAudio对象
PsychPortAudio('Close', HandlePortAudio);
% clear HandlePortAudio ;

close all;
% clear;
%关闭窗口对象
sca;

%如果程序执行出错则执行下面程序
catch Error

    if exist('HandlePortAudio','var')

        %关闭PortAudio对象
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close', HandlePortAudio);
        
%         clear HandlePortAudio ;

    end
    %恢复屏幕显示优先级
    Priority(0);
    %关闭所有窗口对象  
    sca;
    %在命令行输出前面的错误提示信息
    rethrow(Error);


end





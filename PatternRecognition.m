%编码方式B图案感知程序
%环境
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
close all;
clear;
sca;

%修改工作路径至当前M文件所在目录
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(1:PosFileSep(end)));

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

%键盘响应设置
%Matlab命令行窗口停止响应键盘字符输入（按Crtl-C可以取消这一状态）
% ListenChar(2);
%限制KbCheck响应的按键范围（只有Esc键及上下左右方向键可以触发KbCheck）
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow'),KbName('space')]);

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
    
    %获取可用的屏幕显示优先级？？
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %调用PatternRecognitionParameterSetting.m设置相应参数
    PatternRecognitionParameterSetting;
    
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
        [MatrixXSquareCenter,MatrixYSquareCenter]= meshgrid(linspace(-1*(NumSquarePerRow-1)/2,(NumSquarePerRow-1)/2,NumSquarePerRow));
    end
    
    
    %将方块中心点的X坐标和Y坐标加上偏置使坐标移至屏幕中心并转成一维向量
    MatrixXSquareCenter =  round(MatrixXSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);
    MatrixYSquareCenter =  round(MatrixYSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);
    
    SequenceXSquareCenter = reshape(MatrixXSquareCenter',1,NumSquare);
    SequenceYSquareCenter = reshape(MatrixYSquareCenter',1,NumSquare);
    
    
    %基准方块
    RectBaseSquareFrame = [0,0,round(3*SizeSquare+4*GapWidth),round(3*SizeSquare+4*GapWidth)];
    
    RectBaseSquare = [0,0,round(SizeSquare),round(SizeSquare)];
    %根据基准方块和方块中心点坐标计算出所有方块的范围（四维向量，格式：[左上角X坐标,左上角X坐标,右下角X坐标，右下角Y坐标]）
    RectSquare = CenterRectOnPointd(RectBaseSquare,SequenceXSquareCenter',SequenceYSquareCenter')';
    %基准圆点
    RectBaseDot = [0,0,round(SizeDot),round(SizeDot)];
    %根据基准圆点和方块中心点坐标计算出所有圆点的范围，格式同上
    RectDot = CenterRectOnPointd(RectBaseDot,SequenceXSquareCenter',SequenceYSquareCenter')';
    
    
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
    %音频重放次数，无限重放直到执行 PsychPortAudio('Stop',...)
    AudioRepetition = 0;
    
    
    % 创建PortAudio对象，对应的参数如下
    % (1) [] ,调用默认的
    % (2) 1 ,仅进行声音播放（不进行声音录制）
    % (3) 1 , 默认延迟模式
    % (4) SampleRateAudio,音频采样率
    % (5) 2 ,输出声道数为2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    
    %新建Buffer用于存放提示音数据
    
    HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
    HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
    
    %%
    %开始
   
    
    %首次调用耗时较长的函数
    KbCheck;
    KbWait([],1);
   
    
    
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
    
            %恢复键盘设定
            ListenChar(0);
            RestrictKeysForKbCheck([]);
            return;
        end
    
        %帧刷新
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
    end
    
    %%

    %倒计时阶段
    
    %倒计时提示音
    AudioDataLeft = reshape(DataPureTone(1,5,1:round(SampleRateAudio)),1,[]);
    AudioDataRight = reshape(DataPureTone(2,5,1:round(SampleRateAudio)),1,[]);
   
    %归一化
    
    MaxAmp = max([MatrixLeftAmp(5), MatrixRightAmp(5)]);
    
    AudioDataLeft =  AudioDataLeft/MaxAmp;
    AudioDataRight =  AudioDataRight/MaxAmp;

    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,repmat([zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight],1,3));
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    

    for frame =1:round(TimeCountdown*FramePerSecond)

       
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
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
    
            %恢复键盘设定
            ListenChar(0);
            RestrictKeysForKbCheck([]);
            return;
    
        end
    
    
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
    end
    

    PsychPortAudio('Stop', HandlePortAudio);

    
    for trial = 1:NumTrial
        
        pattern = randi([1,NumPattern]);
        
        PosCursor = zeros (1,MaxNumStep);
        PosCursor(1) = NumSquarePerRow + 2;
        NumStep =1 ;
        
        TimeStart = GetSecs;
        
        while GetSecs <= TimeStart + TimeMaxPerPattern
 
            XYCursor(1) =  mod((PosCursor(NumStep)-1),NumSquarePerRow)+1;
            XYCursor(2) =  fix((PosCursor(NumStep)-1)/NumSquarePerRow)+1;
            
            SequenceFrameDot =  ;
            
            InterSectionDot = intersect(SequencePatternDot{pattern},SequenceFrameDot);
            
            DiffSectionDot = setdiff(SequencePatternDot{pattern},SequenceFrameDot);
            
            if  any(InterSectionDot)
                IndexInterSectionDot = false(1,NumSquare);
                IndexInterSectionDot(InterSectionDot) = true;
                IndexInterSectionDot = IndexInterSectionDot(SequenceFrameDot);
       
            %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
            AudioDataLeft = reshape(DataPureTone(1,IndexInterSectionDot,1:round(TimeCodedSound*SampleRateAudio)),numel(InterSectionDot),[]);
            %求和
            AudioDataLeft = sum(AudioDataLeft,1);
            
            AudioDataRight = reshape(DataPureTone(2,IndexInterSectionDot,1:round(TimeCodedSound*SampleRateAudio)),numel(InterSectionDot),[]);
            AudioDataRight = sum(AudioDataRight,1);
            
            %归一化
            AudioData = reshape(mapminmax(AudioDataLeft(:),AudioDataRight(:)),2,[]);
            AudioDataLeft = AudioData(1,:);
            AudioDataRight = AudioData(2,:);

            
            PsychPortAudio('Stop', HandlePortAudio);
            
            %将数据填入音频播放的Buffer里
            PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,round(TimeGapSilence*SampleRateAudio));AudioDataRight,zeros(1,round(TimeGapSilence*SampleRateAudio))]);
            
            %播放白噪声
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            end
            
            RectSquareFrame = CenterRectOnPointd(RectBaseSquareFrame,SequenceXSquareCenter(PosCursor(NumStep)),SequenceYSquareCenter(PosCursor(NumStep)));
            Screen('FillRect', PointerWindow,ColorSquareFrame,RectSquareFrame);
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            
            if any(DiffSectionDot)
            Screen('FillOval', PointerWindow,ColorDiffDot,RectDot(:,DiffSectionDot),ceil(SizeDot));
            end
            if any(InterSectionDot)
            Screen('FillOval', PointerWindow,ColorInterDot,RectDot(:,InterSectionDot),ceil(SizeDot));
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            vbl = Screen('Flip', PointerWindow);
            
            
            
            
            %等待方向键或者Esc键被按下
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE')) &&  ~KeyCode(KbName('space'))
                NumStep = NumStep +1;
                if KeyCode(KbName('LeftArrow'))
                    TempXYCursor = XYCursor+[-1,0];
                elseif KeyCode(KbName('RightArrow'))
                    TempXYCursor = XYCursor+[1,0];
                elseif KeyCode(KbName('UpArrow'))
                    TempXYCursor = XYCursor+[0,-1];
                elseif KeyCode(KbName('DownArrow'))
                    TempXYCursor = XYCursor+[0,1];
                end
        
                
            else
                if KeyCode(KbName('space'))
                    break;
                else
                    if exist('HandlePortAudio','var')
                        
                        %关闭PortAudio对象
                        PsychPortAudio('Stop');
                        PsychPortAudio('Close');
                        
                        %clear HandlePortAudio ; 
                    end
                    %恢复屏幕显示优先级
                    Priority(0);
                    %关闭所有窗口对象
                    sca;
                    
                    %恢复键盘设定
                    ListenChar(0);
                    RestrictKeysForKbCheck([]);
                    
                    return;
                    
                end
            end

            %等待按键松开
            KbWait([],1);

            %若光标超出了边界
            if any(TempXYCursor<1) || any ( TempXYCursor>NumSquarePerRow)
                
                PosCursor(NumStep)=PosCursor(NumStep-1);
                
                %将之前保存在HandleOutBuffer里面的数据填入音频播放的Buffer里
                PsychPortAudio('Stop', HandlePortAudio);
                
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                PosCursor(NumStep)=TempXYCursor(1)+NumSquarePerRow*(TempXYCursor(2)-1);
                
                %播放移动声音
                PsychPortAudio('Stop', HandlePortAudio);
                %将之前保存在HandleRollBuffer里面的声音数据填入音频播放的Buffer里
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);
                
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                WaitSecs(numel(AudioDataRoll)/SampleRateAudio);
                
            end
        end
 
    end
        
        if NumStep> NumMaxStepPerTrial
            if exist('HandlePortAudio','var')
                
                %关闭PortAudio对象
                PsychPortAudio('Stop', HandlePortAudio);
                PsychPortAudio('Close', HandlePortAudio);
                
                %clear HandlePortAudio ;
                
            end
            %恢复屏幕显示优先级
            Priority(0);
            %关闭所有窗口对象
            sca;
            
            %恢复键盘设定
            ListenChar(0);
            RestrictKeysForKbCheck([]);
            
            return;
            
        end

    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
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
            
            %恢复键盘设定
            ListenChar(0);
            RestrictKeysForKbCheck([]);
            return;   
        end
        
        vbl = Screen('Flip', PointerWindow);
        
    end
    
    if exist('HandlePortAudio','var')
        
        %关闭PortAudio对象
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close', HandlePortAudio);
        
        %clear HandlePortAudio ;
        
    end
    
    %恢复屏幕显示优先级
    Priority(0);
    %关闭所有窗口对象
    sca;
    
    %恢复键盘设定
    ListenChar(0);
    RestrictKeysForKbCheck([]);

    %如果程序执行出错则执行下面程序
catch Error
    
    if exist('HandlePortAudio','var')
        
        %关闭PortAudio对象
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close', HandlePortAudio);
        
        %clear HandlePortAudio ;
        
    end
    %恢复屏幕显示优先级
    Priority(0);
    %关闭所有窗口对象
    sca;
    
    %恢复键盘设定
    ListenChar(0);
    RestrictKeysForKbCheck([]);
    
    
    %在命令行输出前面的错误提示信息
    rethrow(Error);
    
end    

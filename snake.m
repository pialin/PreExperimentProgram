%方位辨识程序
%软件环境:
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


%从输入对话框获取受试者名字

InputdlgOptions.Resize = 'on'; 
InputdlgOptions.WindowStyle = 'normal';

if exist('LastSubjectName.mat','file')
    load LastSubjectName.mat;
    SubjectName = inputdlg('Subject Name:','请输入受试者名字',[1,42],{LastSubjectName},InputdlgOptions);
else
    SubjectName = inputdlg('Subject Name:','请输入受试者名字',[1,42],{'ABC'},InputdlgOptions);
end

if isempty(SubjectName)
    return;
end

%存储本次输入的名字作为后续实验受试名称的默认值
LastSubjectName = SubjectName{1};

save LastSubjectName.mat LastSubjectName;

DateString = datestr(now,'yyyymmdd_HH-MM-SS');

%%
%随机数生成器状态设置
rng('shuffle');%Matlab R2012之后版本
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012之前版本

%%
%显示部分设置

%执行默认设置2
%相当于执行了以下三条语句：
%“AssertOpenGL;”%确保Screen函数被正确安装
%“KbName('UnifyKeyNames');”%设置一套适用于所有操作系统的KeyCode（按键码）和KeyName（按键名）对
%在创建窗口后立刻执行“Screen('ColorRange', PointerWindow, 1, [],1);”将颜色的设定方式由3个
%8位无符号组成的三维向量改成3个0到1的浮点数三维向量，目的是为了同时兼容不同颜色位数的显示器（比如16位显示器）
PsychDefaultSetup(2);

%键盘响应设置
%Matlab命令行窗口停止响应键盘字符输入（按Crtl-C可以取消这一状态）
ListenChar(2);
%限制KbCheck响应的按键范围（只有Esc键及上下左右方向键可以触发KbCheck）
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow')]);

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
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %获取每次帧刷新之间的时间间隔
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %计算每秒刷新的帧数
    FramePerSecond = 1/TimePerFlip;
    
    %获取可用的屏幕显示优先级？？
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %调用Snake_ParameterSetting.m设置相应参数
    Snake_ParameterSetting;
    
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
    HandlePassBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataPass;AudioDataPass]);
    HandleHitBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll,AudioDataHit;AudioDataRoll,AudioDataHit]);
    HandleFinishBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);
    
    %%
    %开始

    %PosCursor用于存储的光标位置变化情况，每一列分别代表一次位置的变动，第一行代表光标在方块矩阵的第几列，第二行代表光标在方块矩阵的第几行
    PosCursor = zeros(2,MaxNumStep*NumTrial);
    %给定初始光标位置，第五行第五列即中心点处
    PosCursor(:,1) = [5,5];
    PosTarget = zeros(2,NumTrial);
    
    NumStep = 1;
    
    
    %首次调用耗时较长的函数
    KbCheck;
    KbWait([],1);
    
    
    %显示优先级设置
    Priority(LevelTopPriority);
    %进行第一次帧刷新获取基准时间
    vbl = Screen('Flip', PointerWindow);
    
    %等待阶段
        %并口标记251表示实验开始
        lptwrite(LPTAddress,251);

    
    %时长为准备时长减去倒计时时长
    for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
        
        if frame == 2
            %每次打完标记后需要重新将并口置零
            lptwrite(LPTAddress,0);
        
        end
        %绘制提示语
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
        %提示程序所有内容已绘制完成
        Screen('DrawingFinished', PointerWindow);
        
        %读取键盘输入，若Esc键被按下则立刻退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %输出并口标记253表示实验被人为按下Esc键所中止
            lptwrite(LPTAddress,253);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
             
            %关闭PortAudio对象
            PsychPortAudio('Close');
            %恢复显示优先级
            Priority(0);
            %关闭所有窗口对象
            sca;
            %恢复键盘设定
            %恢复Matlab命令行窗口对键盘输入的响应
            ListenChar(0);
            %恢复KbCheck函数对所有键盘输入的响应
            RestrictKeysForKbCheck([]);
            %往并口输出0
            lptwrite(LPTAddress,0);
            %终止程序
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
    
    
    PsychPortAudio('FillBuffer', HandlePortAudio,repmat([zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight],1,3));
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %读取键盘输入，若Esc键被按下则立刻退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %输出并口标记253表示实验被人为按下Esc键所中止
            lptwrite(LPTAddress,253);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
            %关闭PortAudio对象
            PsychPortAudio('Close');
            %恢复显示优先级
            Priority(0);
            %关闭所有窗口对象
            sca;
            %恢复键盘设定
            %恢复Matlab命令行窗口对键盘输入的响应
            ListenChar(0);
            %恢复KbCheck函数对所有键盘输入的响应
            RestrictKeysForKbCheck([]);
            %往并口输出0
            lptwrite(LPTAddress,0);
            
            %终止程序
            return;
        end
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    
    TempTrial = 0;
    
    
    %%
    %随机地生成下一个目标点相对当前目标点横向偏移KeyDistance(1)和纵向偏移KeyDistance(2)
    for trial = 1:NumTrial
        
        KeyDistance = zeros(2,1);
        PosNextTarget = zeros(2,1);
        
        %限制横向和纵向偏移之和>=2,且偏移之后的点不超过9*9的矩阵区域
        while sum(abs(KeyDistance))<=2 || any(PosNextTarget>NumSquarePerRow) || any(PosNextTarget<1)
            %横/纵向的偏移范围限制在正负RangeNextTarget之间
            KeyDistance = randi([-1*RangeNextTarget,RangeNextTarget],2,1);
            %计算下一个坐标
            if trial ==1
                PosNextTarget =  PosCursor(:,1)+KeyDistance;
            else
                PosNextTarget =  PosTarget(:,trial-1)+KeyDistance;
            end
            
        end
        
        PosTarget(:,trial) = PosNextTarget;
        
        
    end
    
    %优先级设置
    Priority(LevelTopPriority);
    %进行第一次帧刷新获取基准时间
    vbl = Screen('Flip', PointerWindow);
    
    
    %%
    %开始
    
    for trial =1:NumTrial
        
        %绘制方块和圆点
        IndexTarget = PosTarget(1,trial)+NumSquarePerRow*(PosTarget(2,trial)-1);
        IndexCursor = PosCursor(1,1:NumStep)+NumSquarePerRow*(PosCursor(2,1:NumStep)-1);
        Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
        Screen('FillOval', PointerWindow,ColorDot,RectDot(:,IndexCursor),ceil(SizeDot));
        
        %绘制连线
        if NumStep > 1
            XLine = reshape(repmat(SequenceXSquareCenter(IndexCursor),2,1),1,[]);
            
            YLine = reshape(repmat(SequenceYSquareCenter(IndexCursor),2,1),1,[]);
            
            Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
            
            
        end
        Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,IndexTarget),ceil(SizeDot));
        Screen('DrawingFinished', PointerWindow);
        
        vbl = Screen('Flip', PointerWindow);
        
        
        FlagHitTarget = false;
        
        while FlagHitTarget == false 
            
            KeyDistance = PosTarget(:,trial)-PosCursor(:,NumStep);
            
            switch [num2str(sign(KeyDistance(1))),num2str(sign(KeyDistance(2)))]
                
                case '01'
                    CodedDot = 8;
                case '10'
                    CodedDot = 6;
                case '0-1'
                    CodedDot = 2;
                case '-10'
                    CodedDot = 4;
                    
                case '11'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=6;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=9;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=8;
                    end
                case '-11'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=4;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=7;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=8;
                    end
                    
                case '-1-1'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=4;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=1;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=2;
                    end
                case '1-1'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >=0 && DirectionAngle <pi/8
                        CodedDot=6;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=3;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=2;
                    end
            end
            
            
            
           %%
            %声音生成
            
            %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
            AudioDataLeft = reshape(DataPureTone(1,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
            
            AudioDataRight = reshape(DataPureTone(2,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
            
            %归一化
            MaxAmp = max([MatrixLeftAmp(CodedDot), MatrixRightAmp(CodedDot)]);
            AudioDataRight =  AudioDataRight/MaxAmp;
            AudioDataLeft =  AudioDataLeft/MaxAmp;
            
            %播放音量设置
            
            EuclidDistance = sqrt(sum(KeyDistance.^2));
            
            if EuclidDistance > sqrt(2)*RangeNextTarget
                AudioVolume = MinAudioVolume;
                
            else
                VolumeSlope = (1 - MinAudioVolume)/(1-sqrt(2)*RangeNextTarget);
                AudioVolume = (EuclidDistance - sqrt(2)* RangeNextTarget)*VolumeSlope + MinAudioVolume;
                
            end
            
            PsychPortAudio('Stop', HandlePortAudio);
            
            PsychPortAudio('Volume', HandlePortAudio, AudioVolume);
            
            
            
            %将编码声音数据填入Buffer
            PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,TimeGapSilence*SampleRateAudio),AudioDataLeft;
                zeros(1,TimeGapSilence*SampleRateAudio),AudioDataRight]);
            
            %播放声音
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            %并口标记：编码声音开始输出，实际数字为trial+200
            if trial ~=  TempTrial    
                lptwrite(LPTAddress,200+mod(trial-1,40)+1);
                WaitSecs(0.01);
                lptwrite(LPTAddress,0);
                WaitSecs(0.01);
            end
            TempTrial = trial;
            
            %等待方向键或者Esc键被按下
            
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            
            
            %等待按键松开
            KbWait([],1);
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE'))
                %如果按下方向键，则并口输出标记记录按下按键的次数
                lptwrite(LPTAddress,mod(NumStep-1,200)+1);
                WaitSecs(0.01);
                lptwrite(LPTAddress,0);
                WaitSecs(0.01);
                NumStep = NumStep +1;
                if KeyCode(KbName('LeftArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[-1;0];
                elseif KeyCode(KbName('RightArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[1;0];
                elseif KeyCode(KbName('UpArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[0;-1];
                elseif KeyCode(KbName('DownArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[0;1];
                end
                
            else
                if KeyCode(KbName('ESCAPE'))
                    %输出并口标记253表示实验被人为按下Esc键所中止
                    lptwrite(LPTAddress,253);
                    WaitSecs(0.01);
                    lptwrite(LPTAddress,0);
                    WaitSecs(0.01);
                else
                    
                    %输出并口标记252表示实验因长时间没有按键操作而中止
                    lptwrite(LPTAddress,252);
                    WaitSecs(0.01);
                    lptwrite(LPTAddress,0);
                    WaitSecs(0.01);
                    
                end
                %关闭PortAudio对象
                PsychPortAudio('Close');
                %恢复显示优先级
                Priority(0);
                %关闭所有窗口对象
                sca;
                
                %恢复键盘设定
                %恢复Matlab命令行窗口对键盘输入的响应
                ListenChar(0);
                %恢复KbCheck函数对所有键盘输入的响应
                RestrictKeysForKbCheck([]);
                %往并口输出0
                lptwrite(LPTAddress,0);
                %终止程序
                return;
                
                
            end
            
            PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
            
            %若光标超出了边界
            if any(TempPosCursor>NumSquarePerRow) || any(TempPosCursor<1)
                
                PosCursor(:,NumStep)=PosCursor(:,NumStep-1);
                
                %将之前保存在HandleOutBuffer里面的数据填入音频播放的Buffer里
                PsychPortAudio('Stop', HandlePortAudio);
                
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                PosCursor(:,NumStep)=TempPosCursor;
                
                %绘制方块和圆点
                
                IndexTarget = PosTarget(1,trial)+NumSquarePerRow*(PosTarget(2,trial)-1);
                IndexCursor = PosCursor(1,1:NumStep)+NumSquarePerRow*(PosCursor(2,1:NumStep)-1);
                
                Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                Screen('FillOval', PointerWindow,ColorDot,RectDot(:,IndexCursor),ceil(SizeDot));
                
                
                XLine = reshape(repmat(SequenceXSquareCenter(IndexCursor),2,1),1,[]);
                
                YLine = reshape(repmat(SequenceYSquareCenter(IndexCursor),2,1),1,[]);
                
                Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
                Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,IndexTarget),ceil(SizeDot));
                Screen('DrawingFinished', PointerWindow);
                
                vbl = Screen('Flip', PointerWindow);
                
                
                %若光标到达目标点
                if PosCursor(:,NumStep) == PosTarget(:,trial)
                    
                    FlagHitTarget = true;
                    %播放移动和命中声音
                    %将之前保存在HandleHitBuffer里面的声音数据填入音频播放的Buffer里
                    PsychPortAudio('Stop', HandlePortAudio);
                    
                    PsychPortAudio('FillBuffer', HandlePortAudio,HandleHitBuffer);
                    
                    %播放声音
                    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                    
                    WaitSecs((numel(AudioDataRoll)+numel(AudioDataHit))/SampleRateAudio);
                    %若光标还未到达目标点
                else
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
        
        TimeStart = GetSecs;
        if GetSecs>  TimeStart + TimeMaxPerTrial
            %并口输出标记250表示因探索时间过长自动跳至下一目标点
            lptwrite(LPTAddress,250);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
            %播放跳过提示音
            PsychPortAudio('Stop', HandlePortAudio);
            
            %将之前保存在HandleRollBuffer里面的声音数据填入音频播放的Buffer里
            PsychPortAudio('FillBuffer', HandlePortAudio,HandlePassBuffer);
            
            %播放声音
            PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
            %等待声音播放完毕
            WaitSecs(numel(AudioDataPass)/SampleRateAudio);
        end
        
    end
    
    
    %并口标记254表示实验正常结束
    lptwrite(LPTAddress,254);

    
    PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
    %将之前保存在HandleFinishBuffer里面的数据填入音频播放的Buffer里
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleFinishBuffer);
    
    
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    %%
    %实验结束提示
    
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        if frame == 2
            
            lptwrite(LPTAddress,0);
            
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %扫描键盘，如果Esc键被按下则退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %输出并口标记253表示实验被人为按下Esc键所中止
            lptwrite(LPTAddress,253);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
            
            %关闭PortAudio对象
            PsychPortAudio('Close');
            %恢复显示优先级
            Priority(0);
            %关闭所有窗口对象
            sca;
            
            %恢复键盘设定
            %恢复Matlab命令行窗口对键盘输入的响应
            ListenChar(0);
            %恢复KbCheck函数对所有键盘输入的响应
            RestrictKeysForKbCheck([]);
            %往并口输出0
            lptwrite(LPTAddress,0);
            %终止程序
            return;
        end
        
        vbl = Screen('Flip', PointerWindow);
        
    end
    
    %关闭PortAudio对象
    PsychPortAudio('Close');
    %恢复显示优先级
    Priority(0);
    %关闭所有窗口对象
    sca;
    
    %恢复键盘设定
    %恢复Matlab命令行窗口对键盘输入的响应
    ListenChar(0);
    %恢复KbCheck函数对所有键盘输入的响应
    RestrictKeysForKbCheck([]);
    %往并口输出0
    lptwrite(LPTAddress,0);
    
    %%
    %存储记录文件
    %记录文件路径
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'Snake'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %记录文件名
    RecordFile = [RecordPath,filesep,DateString,'.mat'];
    %存储的变量包括NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumTrial','PosTarget','NumStep','PosCursor');
    
    %%
    %如果程序执行出错则执行下面程序
catch Error
    
     %关闭PortAudio对象
    PsychPortAudio('Close');
    %恢复显示优先级
    Priority(0);
    %关闭所有窗口对象
    sca;
    
    %恢复键盘设定
    %恢复Matlab命令行窗口对键盘输入的响应
    ListenChar(0);
    %恢复KbCheck函数对所有键盘输入的响应
    RestrictKeysForKbCheck([]);
    %往并口输出0
    lptwrite(LPTAddress,0);
    
    
    %在命令行输出前面的错误提示信息
    rethrow(Error);
    
    
end
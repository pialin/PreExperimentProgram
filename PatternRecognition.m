%编码方式B图案探索程序
%软件环境：
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
%限制KbCheck响应的按键范围（只有Esc键及上下左右方向键和空格键可以触发KbCheck）
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

%%
%try catch语句保证在程序执行过程中出错可以及时关闭创建的window和PortAudio对象，正确退出程序
try
    
    %创建一个窗口对象，返回对象指针PointerWindow
    PointerWindow= PsychImaging('OpenWindow', ScreenNumber, black);
    
    %%
    %窗口对象参数的获取和设置
    
    %获取每次帧刷新之间的时间间隔
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %计算每秒刷新的帧数
    FramePerSecond = 1/TimePerFlip;
    
    %获取可用的屏幕显示优先级？？
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %调用PatternRecognition_ParameterSetting.m设置相应参数
    PatternRecognition_ParameterSetting;
    
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
    RectBaseSquareFrame = [0,0,round(3*SizeSquare+(3+1)*GapWidth),round(3*SizeSquare+(3+1)*GapWidth)];
    
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
    
    %等待声音真正播放再继续执行后面的语句
    WaitUntilDeviceStart = 1;
    
    %音频重放次数，无限重放直到执行 PsychPortAudio('Stop',...)
    AudioRepetition = 0;
    
    
    % 创建PortAudio对象，对应的参数如下
    % (1) [] ,调用默认的声卡
    % (2) 1 ,仅进行声音播放（不进行声音录制）
    % (3) 1 , 默认延迟模式
    % (4) SampleRateAudio,音频采样率
    % (5) 2 ,输出声道数为2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    
    %新建Buffer用于存放提示音数据
    %滚动提示音
    HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
    %超出边界提示音
    HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
    %跳过图案提示音
    HandlePassBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataPass;AudioDataPass]);
    %完成实验提示音
    HandleFinishBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);
    
    
    
    %%
    %开始
    
    %首次调用耗时较长的函数
    KbCheck;
    KbWait([],1);
    
    %显示优先级设置
    Priority(LevelTopPriority);
    %进行第一次帧刷新获取基准时间
    vbl = Screen('Flip', PointerWindow);
    
    %%
    
%     %并口标记251表示实验开始（准备阶段开始）
%     lptwrite(LPTAddress,251);
%     %将并口状态保持一段时间（时长不低于NeuralScan的采样时间间隔）
%     WaitSecs(0.01);
%     %每次打完标记后需要重新将并口置零
%     lptwrite(LPTAddress,0);
%     WaitSecs(0.01);
    
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
%             %输出并口标记253表示实验被人为按下Esc键所中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
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
%             %往并口输出0
%             lptwrite(LPTAddress,0);
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
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight]);
    
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, 3, AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %读取键盘输入，若Esc键被按下则立刻退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
%             %输出并口标记253表示实验被人为按下Esc键所中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
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
            
%             %往并口输出0
%             lptwrite(LPTAddress,0);
%             
            %终止程序
            return;
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    
    %%
    %图案探索开始
    
    %随机选取NumTrial个图案（可能会出现重复）
    IndexPattern = randi([1,NumPattern],1,NumTrial);
    
    %PosCursor为用于记录光标移动的轨迹的行向量，每一列代表每次移动后光标的位置（用1-81表示整个9*9区域的每个位置）
    PosCursor = zeros (1,MaxNumStep,NumTrial);
    
    TempTrial = 0;
    
    %循环NumTrial次，即进行NumTrial个图案的探索
    for trial = 1:NumTrial
        
        %初始位置位于1.即第一行第一列的方块
        PosCursor(1,1,trial) = 1;
        %NumStep记录当前步数
        NumStep =1 ;
        
        %获取当前时间作为开始时间
        TimeStart = GetSecs;
        
        %当探索时间不超过TimeMaxPerPattern（每个图案允许的探索时长）时继续进行声音的输出和按键的播放
        while GetSecs <= TimeStart + TimeMaxPerPattern
            
            %将光标位置换算成行数和列数便于后续运算
            %行数
            XYCursor(1) =  fix((PosCursor(1,NumStep,trial)-1)/NumSquarePerRow)+1;
            %列数
            XYCursor(2) =  mod((PosCursor(1,NumStep,trial)-1),NumSquarePerRow)+1;
            
            
            %计算九宫格的九个点的位置
            
            vertical = reshape(repmat((XYCursor(1)-2:XYCursor(1))*NumSquarePerRow,3,1),1,[]);
            horizon = repmat(XYCursor(2)-1:XYCursor(2)+1,1,3);
            
            SequenceFrameDot =   horizon + vertical;
            
            %将9*9区域外的点去掉
            
            %计算九宫格和图案的重合点
            InterSectionDot = intersect(SequencePatternDot{IndexPattern(trial)},SequenceFrameDot);
            
            %计算除去重合点外图案的剩余点
            DiffSectionDot = setdiff(SequencePatternDot{IndexPattern(trial)},SequenceFrameDot);
            
            %如果九宫格和图案存在重合点
            if  any(InterSectionDot)
                %获取编码点的索引
                [~,IndexCodedDot,~] = intersect(SequenceFrameDot,InterSectionDot);
                
                %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
                AudioDataLeft = reshape(DataPureTone(1,IndexCodedDot,1:round(TimeCodedSound*SampleRateAudio)),numel(IndexCodedDot),[]);
                AudioDataRight = reshape(DataPureTone(2,IndexCodedDot,1:round(TimeCodedSound*SampleRateAudio)),numel(IndexCodedDot),[]);
                
                %求和
                AudioDataLeft = sum(AudioDataLeft,1);
                AudioDataRight = sum(AudioDataRight,1);
                
                %归一化
                AudioData = mapminmax([AudioDataLeft,AudioDataRight]);
                
                AudioDataLeft = AudioData(1:TimeCodedSound*SampleRateAudio);
                AudioDataRight = AudioData(TimeCodedSound*SampleRateAudio+1:end);
                
                PsychPortAudio('Stop', HandlePortAudio);
                
                %将声音数据填入音频播放的Buffer里
                PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,round(TimeGapSilence*SampleRateAudio));
                    AudioDataRight,zeros(1,round(TimeGapSilence*SampleRateAudio))]);
                
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
                
            end
            
            %输出并口代表声音输出开始，实际数字为当前trial+200
           if trial ~=  TempTrial    
%                 lptwrite(LPTAddress,200+mod(trial-1,40)+1);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
            end
            TempTrial = trial;
            
            %计算并绘制以光标为中心的九宫格
            RectSquareFrame = CenterRectOnPointd(RectBaseSquareFrame,SequenceXSquareCenter(PosCursor(1,NumStep,trial)),SequenceYSquareCenter(PosCursor(1,NumStep,trial)));
            
            Screen('FillRect', PointerWindow,ColorSquareFrame,RectSquareFrame);
            %绘制9*9的方块阵
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            
            %如果除去重合点外图案还有剩余点，则绘制剩余点
            if any(DiffSectionDot)
                Screen('FillOval', PointerWindow,ColorDiffDot,RectDot(:,DiffSectionDot),ceil(SizeDot));
            end
            %如果九宫格和图案有重合点则绘制重合点
            if any(InterSectionDot)
                Screen('FillOval', PointerWindow,ColorInterDot,RectDot(:,InterSectionDot),ceil(SizeDot));
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            vbl = Screen('Flip', PointerWindow);
            
            %等待方向键、Esc键或空格键被按下
            %每次移动最长等待时间为TimeWaitPerMove
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            if any(KeyCode(KbName('LeftArrow'):KbName('DownArrow')))
%                 %如果按下方向键，则并口输出标记记录按下按键的次数
%                 lptwrite(LPTAddress,mod(NumStep-1,200)+1);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
            elseif KeyCode(KbName('ESCAPE'))
%                 %输出并口标记253表示实验被人为按下Esc键所中止
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
            elseif ~KeyCode(KbName('space'))
%                 %输出并口标记252表示实验因长时间没有按键操作而中止
%                 lptwrite(LPTAddress,252);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
                
            end
            
            
            %等待按键松开
            KbWait([],1);
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE')) &&  ~KeyCode(KbName('space'))
                %步数计数值加一
                NumStep = NumStep +1;
                %根据按下的方向键计算新的光标位置，暂时存入TempXYCursor中
                if KeyCode(KbName('LeftArrow'))
                    TempXYCursor = XYCursor+[0,-1];
                elseif KeyCode(KbName('RightArrow'))
                    TempXYCursor = XYCursor+[0,1];
                elseif KeyCode(KbName('UpArrow'))
                    TempXYCursor = XYCursor+[-1,0];
                elseif KeyCode(KbName('DownArrow'))
                    TempXYCursor = XYCursor+[1,0];
                end
                
                
            else
                if KeyCode(KbName('space'))
                    PsychPortAudio('Stop', HandlePortAudio);
                    break;
                else
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
%                     %往并口输出0
%                     lptwrite(LPTAddress,0);
                    
                    %终止程序
                    return;
                    
                end
            end
            
            
            %若光标超出了边界
            if any(TempXYCursor<1) || any ( TempXYCursor>NumSquarePerRow)
                
                %记录的光标位置不作改变
                PosCursor(1,NumStep,trial)=PosCursor(1,NumStep-1,trial);
                
                
                PsychPortAudio('Stop', HandlePortAudio);
                %将之前保存在HandleOutBuffer里面的数据填入音频播放的Buffer里
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                %播放出界提示音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                %等待提示音播放完毕
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                %记录移动后光标的位置
                PosCursor(1,NumStep,trial)=NumSquarePerRow*(TempXYCursor(1)-1)+TempXYCursor(2);
                
                %播放移动声音
                PsychPortAudio('Stop', HandlePortAudio);
                
                %将之前保存在HandleRollBuffer里面的声音数据填入音频播放的Buffer里
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);
                
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                %等待声音播放完毕
                WaitSecs(numel(AudioDataRoll)/SampleRateAudio);
                
            end
        end
        
        if GetSecs>  TimeStart + TimeMaxPerPattern
%             %并口输出标记250表示因探索时间过长自动跳至下一图案
%             lptwrite(LPTAddress,250);
%             WaitSecs(0.01);
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
            
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
    
    %%
%     %并口标记254表示实验正常结束
%     lptwrite(LPTAddress,254);
    
    %播放完成提示音
    PsychPortAudio('Stop', HandlePortAudio);
    
    %将之前保存在HandleRollBuffer里面的声音数据填入音频播放的Buffer里
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleFinishBuffer);
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    %实验结束提示
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        if frame == 2
            
%             lptwrite(LPTAddress,0);
            
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %扫描键盘，如果Esc键被按下则退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %输出并口标记253表示实验被人为按下Esc键所中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
            
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
            
%             %往并口输出0
%             lptwrite(LPTAddress,0);
            
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
    
%     %往并口输出0
%     lptwrite(LPTAddress,0);
    
    %%
    %存储记录文件
    %记录文件路径
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'PatternRecognition'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %记录文件名
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %存储的变量包括NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumTrial','IndexPattern','PosCursor','SequencePatternDot');
    
    %%
    %如果try 和catch之间的语句执行出错则执行下列语句
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
    
%     %往并口发送一个0
%     lptwrite(LPTAddress,0);
    
    %在命令行输出前面的错误提示信息
    rethrow(Error);
    
   
    
end

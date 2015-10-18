%编码方式A实验程序
%软件环境：
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

%修改工作路径至当前M文件所在目录
Path=mfilename('fullpath');
FileSepIndex = strfind(Path,filesep);
cd(Path(1:FileSepIndex(end)));

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
%“KbName('UnifyKeyNames');”%设置一套适用于所有操作系统的统一的KeyCode（按键码）和KeyName（按键名）对
%在创建窗口后立刻执行“Screen('ColorRange', PointerWindow, 1, [],1);”将颜色的设定方式由3个
%8位无符号组成的三维向量改成3个0到1的浮点数三维向量，目的是为了同时兼容不同颜色位数的显示器（比如16位显示器）
PsychDefaultSetup(2);

%键盘响应设置
%Matlab命令行窗口停止响应键盘字符输入（按Crtl-C可以取消这一状态）
ListenChar(2);
%限制KbCheck响应的按键范围（只有Esc键和小键盘1-9可以触发KbCheck）
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('1'):KbName('9')]);


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
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %获取每次帧刷新之间的时间间隔
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %计算每秒刷新的帧数
    FramePerSecond = 1/TimePerFlip;
    
    %获取可用的屏幕显示优先级？？
    LevelTopPriority = MaxPriority(PointerWindow,'KbCheck','KbWait','sound');
    
    %获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %调用AParameterSetting.m设置相应参数
    A_ParameterSetting;
    
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
    
    %等待声音真正播放再继续执行后面的语句
    WaitUntilDeviceStart = 1;
    
    
    % 创建PortAudio对象，对应的参数如下
    % (1) [] ,调用默认的声卡
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
    
%         %并口标记251表示实验开始
%         lptwrite(LPTAddress,251);
%         %将并口状态保持一段时间（时长不低于NeuralScan的采样时间间隔）

    
    %等待阶段
    %时长为准备时长减去倒计时时长
    for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
        if frame ==2
%         %每次打完标记后需要重新将并口置零
%         lptwrite(LPTAddress,0);       
        end
        %绘制提示语
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
        %提示程序所有内容已绘制完成
        Screen('DrawingFinished', PointerWindow);
        
        %读取键盘输入，若Esc键被按下则立刻退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %并口标记：实验被中途按下ESC键中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %每次打完标记后需要重新将并口置零
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
    PsychPortAudio('Start', HandlePortAudio, AudioCompetition, AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %读取键盘输入，若Esc键被按下则立刻退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %并口标记：实验被中途按下ESC键中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %每次打完标记后需要重新将并口置零
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
            %终止程序
            return;
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end

    
    PsychPortAudio('Stop', HandlePortAudio);
    

    %%
    %初始化SequenceCodedDot用于记录随机选取的编码点，每一列为一个Trial
    SequenceCodedDot = zeros(NumCodedDot,NumTrial);
    %初始化SubjectAnswer用于记录受试反馈的答案
    SubjectAnswer = zeros(NumCodedDot,NumTrial);
  
    
    %编码阶段
    %重复次数由ParameterSetting中的NumTrial决定
    for trial =1:NumTrial
        
       %随机获取进行声音编码的点
        SequenceCodedDot(:,trial) = randperm(NumSquare,NumCodedDot)';   
        
        %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
        AudioDataLeft = reshape(DataPureTone(1,SequenceCodedDot(:,trial),1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
        AudioDataLeft = reshape(AudioDataLeft',1,[]);
        
        
        AudioDataRight = reshape(DataPureTone(2,SequenceCodedDot(:,trial),1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
        AudioDataRight = reshape(AudioDataRight',1,[]);
        
        %归一化
        MaxAmp = max([MatrixLeftAmp(SequenceCodedDot(:,trial))', MatrixRightAmp(SequenceCodedDot(:,trial))']);
        
        AudioDataRight =  AudioDataRight/MaxAmp;
        AudioDataLeft =  AudioDataLeft/MaxAmp;
        
        
        
        
        %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
        PsychPortAudio('FillBuffer', HandlePortAudio,HandleNoiseBuffer);
        
        %播放白噪声
        PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
        
%             %并口标记201表示开始播放白噪声
%             lptwrite(LPTAddress,201);
      
        %%
        %白噪声呈现阶段
        %时长由ParameterSetting中的TimeWhiteNoise决定
        for frame =1:round(TimeWhiteNoise*FramePerSecond)
            
            if frame == 2
                
%                 %每次打完标记后需要重新将并口置零
%                 lptwrite(LPTAddress,0);
            end
            
            DrawFormattedText(PointerWindow,MessageWhiteNoise,'center', 'center', ColorFont);
            Screen('DrawingFinished', PointerWindow);
            
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %并口标记：实验被中途按下ESC键中止
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %每次打完标记后需要重新将并口置零
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
    
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
                %终止程序
                return;
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
        end
        
        %停止声音播放
        PsychPortAudio('Stop', HandlePortAudio);
        
        %将编码声音数据填充入Buffer中
        PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
        %播放编码声音
        PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
        
%             %并口标记1-200表示开始播放编码声音，数字代表目前的trial数
%             lptwrite(LPTAddress,mod(trial-1,200)+1);

        
        %%
        %编码声音呈现阶段
        for dot = 1:NumCodedDot
            
            for frame=1:round(TimeCodedSound*FramePerSecond)
                if dot ==1 && frame == 2
                    
%                     %每次打完标记后需要重新将并口置零
%                     lptwrite(LPTAddress,0);

                end
                %绘制方块和圆点
                Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodedDot(1:dot,trial)),ceil(SizeDot));
                
                if dot > 1
                    XLine = reshape(repmat(XSquareCenter((SequenceCodedDot(1:dot,trial))),2,1),1,[]);
                    
                    YLine = reshape(repmat(YSquareCenter((SequenceCodedDot(1:dot,trial))),2,1),1,[]);
                    
                    
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
%                     %并口标记：实验被中途按下ESC键中止
%                     lptwrite(LPTAddress,253);
%                     WaitSecs(0.01);
%                     %每次打完标记后需要重新将并口置零
%                     lptwrite(LPTAddress,0);
%                     WaitSecs(0.01);
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
                    %终止程序
                    return;
                end
                
                
                vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
                
            end
        end
        
        for frame=1:round((AudioRepetition*TimeGapSilence+(AudioRepetition-1)*TimeCodedSound*NumCodedDot)*FramePerSecond)
            
            %绘制方块和圆点
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodedDot(:,trial)),ceil(SizeDot));
            if NumCodedDot > 1
            Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
            end
            Screen('DrawingFinished', PointerWindow);
            
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                  %并口标记：实验被中途按下ESC键中止
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %每次打完标记后需要重新将并口置零
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
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
                %终止程序
                return;
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
        end
        
%         %并口标记1-200表示编码声音结束，数字代表目前的trial数
%         lptwrite(LPTAddress,mod(trial-1,200)+1);
 
        PsychPortAudio('Stop', HandlePortAudio);
        
       %%
        %静音记录阶段（Trial之间的休息时间）
        
        DrawFormattedText(PointerWindow,MessageSilence,'center', 'center', ColorFont);
        vbl = Screen('Flip', PointerWindow);

%                     %每次打完标记后需要重新将并口置零
%                     lptwrite(LPTAddress,0);

            dot=0;

            while dot<NumCodedDot
                
                %等待按键按下
                [~,KeyCode,~] = KbWait([],0);
                
                if  any(KeyCode(KbName('1'):KbName('9')))
                    
                    dot = dot + 1 ;
                    
                    
                    SubjectAnswer(dot,trial) = find([KeyCode(KbName('7'):KbName('9')),KeyCode(KbName('4'):KbName('6')),KeyCode(KbName('1'):KbName('3'))]~=0);
 
                    
                elseif  KeyCode(KbName('ESCAPE'))
                    
                    %                  %并口标记：实验被中途按下ESC键中止
                    %                 lptwrite(LPTAddress,253);
                    %                 WaitSecs(0.01);
                    %                 %每次打完标记后需要重新将并口置零
                    %                 lptwrite(LPTAddress,0);
                    %                 WaitSecs(0.01);
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
                    %终止程序
                    return;

                end
                
                 %等待按键松开
                 KbWait([],1);
                
                
            end
        
    end
    
    %%   
%     %并口标记254表示实验正常结束
%     lptwrite(LPTAddress,254);


    
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        if frame == 2
%             lptwrite(LPTAddress,0);
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %扫描键盘，如果Esc键被按下则退出程序
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
%             %并口标记：实验被中途按下ESC键中止
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %每次打完标记后需要重新将并口置零
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
    
    %%
    %存储记录文件
    %记录文件路径
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'A',num2str(NumCodedDot)];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %记录文件名
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %存储的变量包括NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumCodedDot','NumTrial','SequenceCodedDot','SubjectAnswer');

  
    
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


    %在命令行输出前面的错误提示信息
    rethrow(Error);
    
    
end





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
RestrictKeysForKbCheck(KbName('ESCAPE'));

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
    
    RefExp_ParameterSetting;
    
    %字体和大小设定
    Screen('TextFont',PointerWindow, NameFont);
    Screen('TextSize',PointerWindow, SizeFont);
    
    %设置Alpha-Blending相应参数
    Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %等待帧数设定，后面用于保证准确的帧刷新时序
    FrameWait = 1;
    
    
    
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
    %音频重放次数
    AudioRepetition = 1;
    
    
    % 创建PortAudio对象，对应的参数如下
    % (1) [] ,调用默认的
    % (2) 1 ,仅进行声音播放（不进行声音录制）
    % (3) 1 , 默认延迟模式
    % (4) SampleRateAudio,音频采样率
    % (5) 2 ,输出声道数为2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    %循环次数
    NumDot = round(TimeAll/(TimeCodedSound+TimeGapSilence));
    
    DotSequence = randi(9,1,NumDot);
    
    AudioData = zeros(2,NumDot*(TimeCodedSound+TimeGapSilence)*SampleRateAudio);
    
    
    for dot = 1: NumDot
    
        AudioData(:,(dot-1)*(TimeCodedSound+TimeGapSilence)*SampleRateAudio+1 : (dot*TimeCodedSound+(dot-1)*TimeGapSilence)*SampleRateAudio) = ...
             DataPureTone(:,DotSequence(dot),1:round(SampleRateAudio));
        
    end
    
    
    %归一化
    
    MaxAmp = max([MatrixLeftAmp(DotSequence), MatrixRightAmp(DotSequence)]);
    
    AudioData=AudioData/MaxAmp;
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,AudioData);
    
     
    %首次调用耗时较长的函数
    KbCheck;
    KbWait([],1);   
    
    %显示优先级设置
    Priority(LevelTopPriority);
    %进行第一次帧刷新获取基准时间
    vbl = Screen('Flip', PointerWindow);  
    %%
    %开始

    %等待阶段
%         %并口标记251表示实验开始
%         lptwrite(LPTAddress,251);

    
    for frame =1:round((TimePrepare)*FramePerSecond)
        
        if frame == 2
%             %每次打完标记后需要重新将并口置零
%             lptwrite(LPTAddress,0);
        
        end
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
    %开始播放声音
    
        %等待阶段
%         %并口标记1表示实验开始播放声音
%         lptwrite(LPTAddress,1);
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition , AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1: ceil(NumDot*(TimeCodedSound+TimeGapSilence)*FramePerSecond)
        
        if frame == 2
%             %每次打完标记后需要重新将并口置零
%             lptwrite(LPTAddress,0);
        
        end
        
        %绘制提示语
        DrawFormattedText(PointerWindow,MessageStart,'center', 'center', ColorFont);
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
    
    
     %绘制提示语
     DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
     vbl = Screen('Flip', PointerWindow);
     
      %关闭PortAudio对象
    PsychPortAudio('Close');
    
    WaitSecs(TimeShowFinish);
    
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
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'RefExp'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %记录文件名
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %存储的变量包括NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'DotSequence');
    
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
%     %往并口输出0
%     lptwrite(LPTAddress,0);
    
    
    %在命令行输出前面的错误提示信息
    rethrow(Error);
    
    
end
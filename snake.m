%编码方式B方位辨识程序
%环境
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
close all;
clear;
sca;
%键盘响应设置
%Matlab命令行窗口停止响应键盘字符输入（按Crtl-C取消这一状态）
ListenChar(2);
%限制KbCheck响应的按键范围（只有Esc键及上下左右方向键可以触发KbCheck）
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow')]);
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
    [MatrixXSquareCenter,MatrixYSquareCenter]= meshgrid(linspace(-1*(NumSquarePerRow-1)/2,(NumSquarePerRow-1)/2,NumSquarePerRow));
end


%将方块中心点的X坐标和Y坐标转成一个一维向量并加上偏置使坐标移至屏幕中心
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
%音频重放次数，无限重放直到执行 PsychPortAudio('Open',...)
AudioRepetition = 0;


% 创建PortAudio对象，对应的参数如下
% (1) [] ,调用默认的
% (2) 1 ,仅进行声音播放（不进行声音录制）
% (3) 1 , 默认延迟模式
% (4) SampleRateAudio,音频采样率
% (5) 2 ,输出声道数为2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);


%新建一个Buffer存放白噪声数据，HandleNoiseBuffer为此Buffer的指针
HandleNoiseBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,DataWhiteNoise);

%优先级设置
Priority(LevelTopPriority);
%进行第一次帧刷新获取基准时间
vbl = Screen('Flip', PointerWindow);


%%
%开始
%CursorPos用于存储的光标位置变化情况，每一列分别代表一次位置的变动，第一行代表光标在方块矩阵的第几列，第二行代表光标在方块矩阵的第几行
PosCursor = zeros(2,NumMaxStepPerTrial*NumTrial);
%给定初始光标位置，即第一行第一列
PosCursor(:,1) = 1;
PosTarget = zeros(2,NumTrial);

KeyDistance = zeros(2,1);
PosNextTarget = zeros(2,1);

NumStep = 0;
HitTarget = false;

%首次调用耗时较长的函数
KbCheck;
KbWait([],1);

%随机地生成下一个目标点相对当前目标点横向偏移KeyDistance(1)和纵向偏移KeyDistance(2)
%这个目标点与原目标点偏移相加必须大于1，并且不超过矩阵的范围
for trial = 1:NumTrial
    
    while sum(KeyDistance)<=1 || any(PosNextTarget>NumSquarePerRow) || any(PosNextTarget<1)
        %横/纵向的偏移范围限制在正负RangeNextTarget之间
        KeyDistance = randi([-1*RangeNextTarget,RangeNextTarget],2,1);
        %计算下一个坐标
        PosNextTarget = PosCursor(:,trial)+KeyDistance;
        
    end
    
    PosTarget(:,trial) = PosNextTarget;
    
end

for trial =1:NumTrial
    if NumStep> NumMaxStepPerTrial*NumTrial
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
    
HitTarget = false;

while HitTarget == false && NumStep<=NumMaxStepPerTrial


KeyDistance = PosCuror(:,NumStep+1)-PosTarget(:,NumTrial);


    
switch [num2str(sign(KeyDistance(1))),num2str(sign(KeyDistance(2)))]

    case '01'
        CodedDot = 2;
    case '10'
        CodedDot = 6;
    case '0-1'
        CodedDot = 8;
    case '-10'
        CodedDot =4;
        
    case '11'
        DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
        if DirectionAngle >=0 && DirectionAngle <pi/8
            CodedDot=6;
        elseif DirectionAngle >=pi/8  && DirectionAngle <pi/8*3
            CodedDot=3;
        elseif DirectionAngle >=pi/8*3  && DirectionAngle <pi/2
            CodedDot=2;                  
        end
    case '-11'
        DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
        if DirectionAngle >=0 && DirectionAngle <pi/8
            CodedDot=4;
        elseif DirectionAngle >=pi/8  && DirectionAngle <pi/8*3
            CodedDot=1;
        elseif DirectionAngle >=pi/8*3  && DirectionAngle <pi/2
            CodedDot=2;
        end
        
    case '-1-1'
        DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
        if DirectionAngle >=0 && DirectionAngle <pi/8
            CodedDot=4;
        elseif DirectionAngle >=pi/8  && DirectionAngle <pi/8*3
            CodedDot=7;
        elseif DirectionAngle >=pi/8*3  && DirectionAngle <pi/2
            CodedDot=8;
        end
    case '1-1'
        DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
        if DirectionAngle >=0 && DirectionAngle <pi/8
            CodedDot=6;
        elseif DirectionAngle >=pi/8  && DirectionAngle <pi/8*3
            CodedDot=9;
        elseif DirectionAngle >=pi/8*3  && DirectionAngle <pi/2
            CodedDot=8;
        end
end


        
%%
%声音生成

   %根据编码点生成相应的音频数据 AudioDataLeft，AudioDataRight分别代表左右声道的音频数据
    AudioDataLeft = reshape(DataPureTone(1,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
    
    AudioDataRight = reshape(DataPureTone(2,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
     
    %播放音量设置

    EuclidDistance = sqrt(sum(KeyDistance.^2));
    AudioVolume = MinAudioVolume+(1-MinAudioVolume)/(RangeNextTarget*sqrt(2)-sqrt(2))*(EuclidDistance-sqrt(2)) ;
    
    PsychPortAudio('Volume', HandlePortAudio, AudioVolume);

    
    
    %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
    PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);
                                                  AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
    
    %播放声音
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
   
    %等待方向键或者Esc键被按下
    [ ~, KeyCode, ~] = KbWait([],0,GetSecs+TimeWaitPerMove);
    %等待按键松开 
    KbWait([],1,GetSecs+TimeWaitPerMove);
    
    if any(KeyCode) && ~KeyCode(KbName('ESCAPE'))
        NumStep = NumStep +1;
        if KeyCode(KbName('LeftArrow'))
            TempPosCursor = PosCursor(:,NumStep)+[-1;0];  
        elseif KeyCode(KbName('RightArrow'))
            TempPosCursor = PosCursor(:,NumStep)+[1;0];  
        elseif KeyCode(KbName('UpArrow'))
            TempPosCursor = PosCursor(:,NumStep)+[0;1];  
        elseif KeyCode(KbName('DownArrow'))
            TempPosCursor = PosCursor(:,NumStep)+[0;-1];  
        end
        
    else
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
        
    %若光标超出了边界   
    if any(TempPosCursor>NumSquarePerRow) || any(TempPosCursor<1)
        
        PosCursor(:,NumStep+1)=PosCursor(:,NumStep);
        
        %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
        PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);
            AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
        
        %播放声音
        PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
        
    else
        
        PosCursor(:,NumStep+1)=TempPosCursor;
        %若光标到达目标点
        if PosCursor(:,NumStep) == PosTarget(:,trial)
            
            FlagHitTarget = true;
            %播放移动和命中声音
            %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
            PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);
                AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
            
            %播放声音
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
        %若光标还未到达目标点
        else
            %播放移动声音
            %将之前保存在HandleNoiseBuffer里面的白噪声数据填入音频播放的Buffer里
            PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);
                AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
            
            %播放声音
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
        end
    end
 
      
end

end


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
    
    %恢复键盘设定
    ListenChar(0);
    RestrictKeysForKbCheck([]);
    
    %在命令行输出前面的错误提示信息
    rethrow(Error);


end
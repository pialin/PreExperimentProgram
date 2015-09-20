%编码方式B方位辨识程序
%环境
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
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


%优先级设置
Priority(LevelTopPriority);
%进行第一次帧刷新获取基准时间
vbl = Screen('Flip', PointerWindow);


%%
%开始
%SequenceXYPos用于存储的光标位置变化情况，每一列分别代表一次位置的变动，第一行代表光标在方块矩阵的第几列，第二行代表光标在方块矩阵的第几行
SequenceXYPos = zeros(2,MaxNumStep);
%给定初始光标位置，即第一行第一列
SequenceXYPos(:,1) = 1;

while 
while all(KeyDistance==0) || any(NextTarget>NumSquarePerRow) || any(NextTarget<1)
Limit = min(ceil(NumSquarePerRow/2),min())
KeyDistance = randi([-1*ceil(NumSquarePerRow/2),ceil(NumSquarePerRow/2)],2,1);

NextTarget = SequenceXYPos(:,nnz(SequenceXYPos(1,:)))+KeyDistance;

end


KeyDistance

%%
%声音生成

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
    %在命令行输出前面的错误提示信息
    rethrow(Error);


end
%此程序为A编码方式的训练程序
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
%限制KbCheck响应的按键范围（只有Esc键可以触发KbCheck）
RestrictKeysForKbCheck(KbName('ESCAPE'));


%获取所有显示器的序号
AllScreen = Screen('Screens');
%若有外接显示器，保证呈现范式所用的显示器为外接显示器
ScreenNumber = max(AllScreen);

%获取黑白对应的颜色设定值并据此计算其他一些颜色的设定值
white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);
red = [white,black,black];
green = [black,white,black];
blue = [black,black,white];
gray = white/2;

%try catch语句保证在程序执行过程中出错可以及时关闭创建的window和PortAudio对象，正确退出程序
try
    
    %创建一个窗口对象，返回对象指针PointerWindow
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %获取每次帧刷新之间的时间间隔
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %计算每秒刷新的帧数
    FramePerSecond =1/TimePerFlip;
    %获取可用的屏幕显示优先级？？
    LevelTopPriority = MaxPriority(PointerWindow,'KbCheck','KbWait');
    %获取屏幕分辨率 SizeScreenX,SizeScreenY分别指横向和纵向的分辨率
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %调用B_ParameterSetting.m设置相应参数
    B_ParameterSetting;
    
    %字体和大小设定
    Screen('TextFont', PointerWindow, NameFont);
    Screen('TextSize', PointerWindow , SizeFont);
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
    
    
    %方块XY坐标分界计算
    
    %鼠标响应区域比例，在鼠标左/右位置按下且光标位于在响应区域内即可选中该方块
    %这里的响应区域比例是相对于方块原本的大小而言的
    RatioResponseArea = 0.7;
    
    %x轴分界计算
    %先获取三列方块中心各自的横坐标
    XBounderCenter = XSquareCenter(1:NumSquarePerRow);
    %再根据相应区域比例转成6个横坐标边界
    XBounder(1:2:2*NumSquarePerRow) = XBounderCenter(1:NumSquarePerRow)- RatioResponseArea*SizeSquare/2;
    XBounder(2:2:2*NumSquarePerRow) = XBounderCenter(1:NumSquarePerRow)+ RatioResponseArea*SizeSquare/2;
    
    %y轴分界计算
    %先获取三行方块中心各自的横坐标
    YBounderCenter = YSquareCenter(1:NumSquarePerRow:NumSquare);
    %再根据相应区域比例转成6个纵坐标边界
    YBounder(1:2:2*NumSquarePerRow) = YBounderCenter(1:NumSquarePerRow)- RatioResponseArea*SizeSquare/2;
    YBounder(2:2:2*NumSquarePerRow) = YBounderCenter(1:NumSquarePerRow)+ RatioResponseArea*SizeSquare/2;
    
    
    
    
    %%
    %音频设置
    
    %开启低延迟模式
    EnableSoundLowLatencyMode = 1;
    InitializePsychSound(EnableSoundLowLatencyMode);
    
    %设置音频声道数为2，即左右双声道立体声
    NumAudioChannel = 2;
    
    %PsyPortAudio('Start',...)语句执行后立刻开始播放声音
    AudioStartTime = 0;
    %等待声音真正播放后退出语句执行下面语句
    WaitUntilDeviceStart = 1;
    
    
    
    % 创建PortAudio对象，对应的参数如下
    % (1) [] ,调用默认的声卡
    % (2) 1 ,仅进行声音播放（不进行声音录制）
    % (3) 1 , 默认延迟模式
    % (4) SampleRateAudio,音频采样率
    % (5) 2 ,输出声道数为2
    HandlePortAudio = PsychPortAudio('Open', [], 1, EnableSoundLowLatencyMode,SampleRateAudio, NumAudioChannel);
    
    %播放音量设置
    PsychPortAudio('Volume', HandlePortAudio, AudioVolume);
    
    
    %显示优先级设置
    Priority(LevelTopPriority);
    %进行第一次帧刷新获取基准时间
    vbl = Screen('Flip', PointerWindow);
    
    
    %进行键盘扫描
    %返回值：
    %IsKeyDown 标志是否有按键被按下
    %KeyCode为所有（256个）按键的状态，0代表没有被按下；1代表被按下了
    [ IsKeyDown, ~, KeyCode] = KbCheck;
    %进行鼠标状态的查询：
    %返回值：
    %XMousePos，YMousePos代表鼠标所在位置的横纵坐标
    %PressedMouseButton代表鼠标按键的状态，在此为一三维逻辑矢量，分别代表鼠标的左中右键
    %同样的,0代表没有被按下；1代表被按下了
    [XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);
    
    while 1
        %如果没有按键被按下或者有按键按下但既不是Esc键也不是鼠标按键时，执行下列循环
        while (~IsKeyDown || (IsKeyDown && ~KeyCode(KbName('ESCAPE'))))  && ~any(PressedMouseButton)
            
            %绘制方块
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            Screen('DrawingFinished', PointerWindow);
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
            %重新查询鼠标和键盘
            [ IsKeyDown, ~, KeyCode] = KbCheck;
            [XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);
            
        end
        
        %如果Esc键被按下则退出程序
        if IsKeyDown &&  KeyCode(KbName('ESCAPE'))
            
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
            
        else
            %IndexPressedSquare为一逻辑向量（维数与方块数量相同），用于记录目前被选中的方块
            %初始状态为全0代表没有方块选中
            IndexPressedSquare = false(1,NumSquare);
            %SequencePressedSquare为一向量（维数与方块数量相同），同样用于记录目前被选中的方块
            %但是与此同时还记录了方块被按下的先后顺序
            SequencePressedSquare = zeros(1,NumSquare);
            
            %如果鼠标按键被按下
            while any(PressedMouseButton)
                
                %根据坐标位置以及前面计算的XY边界确定鼠标选中的方格
                if mod(nnz(XBounder <= XMousePos),2)==1 && mod(nnz(YBounder <= YMousePos),2)==1
                    
                    MouseSquare = ((nnz(YBounder < YMousePos)-1)/2)*NumSquarePerRow+(nnz(XBounder < XMousePos)+1)/2 ;
                    
                    %如果选中的方格数目小于NumDotLimit，且方格之前没有被选中
                    if nnz(IndexPressedSquare) < NumDotLimit && IndexPressedSquare(MouseSquare) == false
                        %更新IndexPressedSquare和 SequencePressedSquare
                        IndexPressedSquare(MouseSquare) = true ;
                        SequencePressedSquare(nnz(IndexPressedSquare)) = MouseSquare;
                        
                    end
                end
                
                %绘制方块
                Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                %如果有方块被选中则绘制相应的圆点
                if nnz(IndexPressedSquare)>0
                    Screen('FillOval', PointerWindow,ColorDotUncoded,RectDot(:,IndexPressedSquare),SizeDot+1);
                end
                Screen('DrawingFinished', PointerWindow);
                
                
                %读取键盘输入，若Esc键被按下则立刻退出程序
                [IsKeyDown,~,KeyCode] = KbCheck;
                if IsKeyDown && KeyCode(KbName('ESCAPE'))
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
                
                [XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);
                
            end
            %如果有方块被选中，则生成相对应的编码声音
            if nnz(IndexPressedSquare)>0
                AudioDataLeft = reshape(DataPureTone(1,SequencePressedSquare(1:nnz(IndexPressedSquare)),1:TimeCodedSound*SampleRateAudio),nnz(IndexPressedSquare),[]);
                %求和
                AudioDataLeft = sum(AudioDataLeft,1);
                
                
                
                AudioDataRight = reshape(DataPureTone(2,SequencePressedSquare(1:nnz(IndexPressedSquare)),1:TimeCodedSound*SampleRateAudio),nnz(IndexPressedSquare),[]);
                
                AudioDataRight = sum(AudioDataRight,1);
                
                %归一化
                AudioData = mapminmax([AudioDataLeft,AudioDataRight]);
                
                AudioDataLeft = AudioData(1:TimeCodedSound*SampleRateAudio);
                AudioDataRight = AudioData(TimeCodedSound*SampleRateAudio+1:end);

                
                %填充到PortAudio对象的Buffer中
                PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
                %播放声音
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                %绘制圆点和连线
                for frame = 1:round(TimeCodedSound*FramePerSecond)
                    
                    Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                    Screen('FillOval', PointerWindow,ColorDotCoded,RectDot(:,SequencePressedSquare(1:nnz(IndexPressedSquare))),SizeDot+1);
                    
                    %如果编码点数大于1，则需绘制相应的连线
                    if NumCodedDot > 1
                        XLine = reshape(repmat(XSquareCenter((SequencePressedSquare(1:nnz(IndexPressedSquare)))),2,1),1,[]);
                        
                        YLine = reshape(repmat(YSquareCenter((SequencePressedSquare(1:nnz(IndexPressedSquare)))),2,1),1,[]);

                        Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);

                    end
                    Screen('DrawingFinished', PointerWindow);
                    
                    %读取键盘输入，若Esc键被按下则立刻退出程序
                    [IsKeyDown,~,KeyCode] = KbCheck;
                    if IsKeyDown && KeyCode(KbName('ESCAPE'))
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
        end
        
    end
    
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
    %终止程序
    
    rethrow(Error);
    
    
end



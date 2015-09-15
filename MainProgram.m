%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

%%
%随机数生成器设置
rng('shuffle');%Matlab R2012之后版本
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012之前版本


%%
%显示部分设置

PsychDefaultSetup(2);

AllString = Screen('Screens');
ScreenNumber = max(Screens);


white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);
red = [white(1),black(2:3)];
green = [black(1),white(2),black(3)];
blue = [black(1:2),white(3)];
gray = white/2;

try


[PointerWindow,RectWindow] = PsychImaging('OpenWindow', ScreenNumber, black);


TimePerFlip = Screen('GetFlipInterval', PointerWindow);

FramePerSecond = 1/FlipInterval;

LevelTopPriority = MaxPriority(PointerWindow);

[SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);

%字体大小设定
Screen('TextFont', window, '微软雅黑');
Screen('TextSize', window, 40);

Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
FrameWait = 1;


%提示信息
MessagePrepare = ['实验将于',num2Str(TimePrepare),'秒后开始...'];
MessageWhiteNoise = '现在播放的是白噪声...'; 
MessageSilence = '稍后进入下一组实验...'; 

%方块坐标运算
if NumSquare == 1
    XSquareCenter = 0;
    YSquareCenter = 0;
else
    [XSquareCenter,YSquareCenter]= meshgrid(linspace(-1*(sqrt(NumSquare)-1)/2,(sqrt(NumSquare)-1)/2,sqrt(NumSquare)));
end

if ~exist(SizeSquare,'var')
    
    SizeSquare = SizeScreenY/(sqrt(NumSquare)+2)/1.2;
    
end
if ~exist(GapWidth,'var')
    
    GapWidth = 0.2* SizeSquare;
    
end

XSquareCenter = reshaple(XSquareCenter,1,NumSquare);
XSquareCenter = round(XSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);

YSquareCenter = reshaple(YSquareCenter,1,NumSquare);
YSquareCenter = round(YSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);

RectBaseSquare = [0,0,round(SizeSquare),round(SizeSquare)];
RectSquare = CenterRectOnPointd(RectBase,XSquareCenter',YSquareCenter');
RectBaseDot = [0,0,round(SizeDot),round(SizeDot)];
RectDot = CenterRectOnPointd(RectBaseDot,XSquareCenter',YSquareCenter');

    

%%
%音频设置

%开启低延迟模式
EnableSoundLowLatencyMode = true; 
InitializePsychSound(EnableLowLatencyMode);


NumAudioChannel = 2;
AudioSampleRate= 44100;

%立刻开始
AudioStartTime = 0;
WaitUntilDeviceStart = true;
AudioRepetition = 1;


% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,AudioSampleRate, NumAudioChannel);


PsychPortAudio('Volume', HandlePortAudio, 0.5);


HandleNoiseBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,DataWhiteNoise);


Priority(LevelTopPriority);
vbl = Screen('Flip', PointerWindow);

for trial =1:NumTrial
    
    CodedDotSequence = randperm(NumSquare,NumCodedDot);
    
    AudioDataLeft = reshape(DataPureTone(1,CodedDotSequence,1:TimeCodedSound*NumCodedDot*AudioSampleRate),1,[]);
    AuDioDataRight = reshape(DataPureTone(2,CodedDotSequence,1:TimeCodedSound*NumCodedDot*AudioSampleRate),1,[]);
    
    

    PsychPortAudio('FillBuffer', HandlePortAudio,HandleNoiseBuffer);
    
    
    
    for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
        
        [IsKeyDown,~,KeyCode] = KbCheck;
        
        
        
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', white);
        Screen('DrawingFinished', PointerWindow);
        
        if KeyCode(KbName('ESCAPE'))
            
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            Priority(0);
            sca;
            
        end
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        TimeLeft = (TimeCountdown*FramePerSecond-frame)/FramePerSecond;
        DrawFormattedText(PointerWindow,num2str(ceil(TimeLeft)),'center', 'center', white);
        Screen('DrawingFinished', PointerWindow);
        
           
        if KeyCode(KbName('ESCAPE'))
            
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            Priority(0);
            sca;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
    
    
    for Frame =1:round(TimeWhiteNoise*NumCodedDot*FramePerSecond)
        
        
        DrawFormattedText(PointerWindow,MessageWhiteNoise,'center', 'center', white);
        Screen('DrawingFinished', PointerWindow);
        
           
        if KeyCode(KbName('ESCAPE'))
            
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            Priority(0);
            sca;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    PsychPortAudio('Stop', HandlePortAudio);
   
    PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
      
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
    for frame=1:round(TimeCodedSound*NumCodedDot*FramePerSecond)
        
        Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
        Screen('FillOval', PointerWindow,ColorDot,RectDot,SizeDot+1);
        
        Screen('DrawingFinished', PointerWindow);
        
           
        if KeyCode(KbName('ESCAPE'))
            
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            Priority(0);
            sca;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    for frame = 1:round(TimeSilence*FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageSlience,'center', 'center', white);
        
        Screen('DrawingFinished', PointerWindow);
           
        if KeyCode(KbName('ESCAPE'))
            
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            Priority(0);
            sca;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
        
    end
    
end


Priority(0);

PsychPortAudio('Close', HandlePortAudio);

close all;
clear;
sca;

catch Error
  
    PsychPortAudio('Stop', HandlePortAudio);
    PsychPortAudio('Close', HandlePortAudio);
    
    Priority(0);
    sca;    
    
    rethrow(Error);
      
    
end

% escapeKey = KbName('ESCAPE');
% upKey = KbName('UpArrow');
% downKey = KbName('DownArrow');
% leftKey = KbName('LeftArrow');
% rightKey = KbName('RightArrow');
% 
% [keyIsDown,secs, keyCode] = KbCheck;
% 
% if keyCode(escapeKey)
%     
%     
%     
%     SetMouse(round(rand * screenXpixels), round(rand * screenYpixels), window);
%     
%      [x, y, buttons] = GetMouse(window);




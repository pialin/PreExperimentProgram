
close all;
clear;
sca;


%%
%参数计算








PsychDefaultSetup(2);


AllString = Screen('Screens');
ScreenNumber = max(Screens);


white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);


[HandleWindow,RectWindow] = PsychImaging('OpenWindow', ScreenNumber, black);


FlipInterval = Screen('GetFlipInterval', HandleWindow);

FramesPerSecond = 1/FlipInterval;

TopPriorityLevel = MaxPriority(HandleWindow);

[SizeScreenX, SizeScreenY] = Screen('WindowSize', HandleWindow);

%方块坐标运算
if NumSquare == 1
    XSquareCenter = 0;
    YSquareCenter = 0;
else
    [XSquareCenter,YSquareCenter]= meshgrid(-0.5:1/(sqrt(NumSquare)-1):0.5);
end

if ~exist(SizeSquare,'var')
    
    SizeSquare = SizeScreenY/(sqrt(NumSquare)+2)/1.2;
    
end
if ~exist(GapWidth,'var')
    
    GapWidth = 0.2* SizeSquare;
    
end

XSquareCenter = reshaple(XSquareCenter,1,NumSquare);
XSquareCenter = round(XSquareCenter.*(SizeSquare+ + SizeScreenX/2);

YSquareCenter = reshaple(YSquareCenter,1,NumSquare);
YSquareCenter = round(YSquareCenter.*SizeSquare + SizeScreenY/2);
    



Screen('BlendFunction', HandleWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


WaitFrames = 1;

Priority(topPriorityLevel);
vbl = Screen('Flip', HandleWindow);



Screen('DrawingFinished', HandleWindow);
vbl = Screen('Flip', HandleWindow, vbl + (WaitFrames - 0.5) * FlipInterval);


Priority(0);



close all;
clear;
sca;



%���뷽ʽBʵ�����
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

%%
%�����������״̬����
rng('shuffle');%Matlab R2012֮��汾
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012֮ǰ�汾


%%
%��ʾ��������

%ִ��Ĭ������2
%�൱��ִ��������������䣺
%��AssertOpenGL;��%ȷ��Screen��������ȷ��װ
%��KbName('UnifyKeyNames');��%���ݵ�ǰ����ϵͳ����KeyCode�������룩��KeyName�����������Ķ�Ӧ
%�ڴ������ں�����ִ�С�Screen('ColorRange', PointerWindow, 1, [],1);������ɫ���趨��ʽ��3��
%8λ�޷�����ɵ���ά�����ĳ�3��0��1�ĸ�������ά������Ŀ����Ϊ��ͬʱ���ݲ�ͬ��ɫλ������ʾ��������16λ��ʾ����
PsychDefaultSetup(2);

%��ȡ������ʾ�������
AllScreen = Screen('Screens');
%���������ʾ������֤���ַ�ʽ���õ���ʾ��Ϊ�����ʾ��
ScreenNumber = max(AllScreen);

%��ȡ�ڰ׶�Ӧ����ɫ�趨ֵ���ݴ˼�������һЩ��ɫ���趨ֵ
white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);
gray = white/2;
red = [white,black,black];
green = [black,white,black];
blue = [black,black,white];


%try catch��䱣֤�ڳ���ִ�й����г�����Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
try

%����һ�����ڶ��󣬷��ض���ָ��PointerWindow
[PointerWindow,~] = PsychImaging('OpenWindow', ScreenNumber, black);

%��ȡÿ��֡ˢ��֮���ʱ����
TimePerFlip = Screen('GetFlipInterval', PointerWindow);
%����ÿ��ˢ�µ�֡��
FramePerSecond = 1/TimePerFlip;

%��ȡ���õ����ȼ�����
LevelTopPriority = MaxPriority(PointerWindow);

%��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
[SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);


%����ʹ�С�趨
Screen('TextFont',PointerWindow, '����');
Screen('TextSize',PointerWindow, 40);
%����Alpha-Blending��Ӧ����
Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%�ȴ�֡���趨���������ڱ�֤׼ȷ��֡ˢ��ʱ��
FrameWait = 1;

%����ParameterSetting.m������Ӧ����
ParameterSetting;


%����������㣺XSquareCenter, YSquareCenter�ֱ𱣴淽�����ĵ��X�����Y����
if NumSquare == 1
    XSquareCenter = 0;
    YSquareCenter = 0;
else
    [XSquareCenter,YSquareCenter]= meshgrid(linspace(-1*(NumSquarePerRow-1)/2,(NumSquarePerRow-1)/2,NumSquarePerRow));
end


%���������ĵ��X�����Y����ת��һ��һά����������ƫ��ʹ����������Ļ����
XSquareCenter = reshape(XSquareCenter',1,NumSquare);
XSquareCenter = round(XSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);

YSquareCenter = reshape(YSquareCenter',1,NumSquare);
YSquareCenter = round(YSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);

%��׼����
RectBaseSquare = [0,0,round(SizeSquare),round(SizeSquare)];
%���ݻ�׼����ͷ������ĵ������������з���ķ�Χ����ά��������ʽ��[���Ͻ�X����,���Ͻ�X����,���½�X���꣬���½�Y����]��
RectSquare = CenterRectOnPointd(RectBaseSquare,XSquareCenter',YSquareCenter')';
%��׼Բ��
RectBaseDot = [0,0,round(SizeDot),round(SizeDot)];
%���ݻ�׼Բ��ͷ������ĵ�������������Բ��ķ�Χ����ʽͬ��
RectDot = CenterRectOnPointd(RectBaseDot,XSquareCenter',YSquareCenter')';

    

%%
%��Ƶ����

%�������ӳ�ģʽ
EnableAudioLowLatencyMode = 1; 
InitializePsychSound(EnableAudioLowLatencyMode);

%������Ƶ������Ϊ2��������˫����������
NumAudioChannel = 2;

%PsyPortAudio('Start',...)���ִ�к����̿�ʼ��������
AudioStartTime = 0;
%�ȴ������������ź��˳����ִ���������
WaitUntilDeviceStart = 1;
%��Ƶ�طŴ��������貥��һ��
AudioRepetition = 1;


% ����PortAudio���󣬶�Ӧ�Ĳ�������
% (1) [] ,����Ĭ�ϵ�
% (2) 1 ,�������������ţ�����������¼�ƣ�
% (3) 1 , Ĭ���ӳ�ģʽ
% (4) SampleRateAudio,��Ƶ������
% (5) 2 ,���������Ϊ2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);

%������������
PsychPortAudio('Volume', HandlePortAudio, AudioVolume);

%�½�һ��Buffer��Ű��������ݣ�HandleNoiseBufferΪ��Buffer��ָ��
HandleNoiseBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,DataWhiteNoise);

%���ȼ�����
Priority(LevelTopPriority);
%���е�һ��֡ˢ�»�ȡ��׼ʱ��
vbl = Screen('Flip', PointerWindow);

%%
%�ȴ��׶�
%ʱ��Ϊ׼��ʱ����ȥ����ʱʱ��
for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
    %������ʾ��
    DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', white);
    %��ʾ�������������ѻ������
    Screen('DrawingFinished', PointerWindow);
    
    %��ȡ�������룬��Esc���������������˳�����
    [IsKeyDown,~,KeyCode] = KbCheck;
    if IsKeyDown && KeyCode(KbName('ESCAPE'))
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
%             clear HandlePortAudio ;
        end
        Priority(0);
        sca;
        return;
    end
    
    %֡ˢ��
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end

%%
%����ʱ�׶�

for frame =1:round(TimeCountdown*FramePerSecond)
    %���㵹��ʱʣ��ʱ��
    TimeLeft = (TimeCountdown*FramePerSecond-frame)/FramePerSecond;
    %���Ƶ���ʱ����
    DrawFormattedText(PointerWindow,num2str(ceil(TimeLeft)),'center', 'center', white);
    Screen('DrawingFinished', PointerWindow);
    
    %ɨ����̣����Esc�����������˳�����
    [IsKeyDown,~,KeyCode] = KbCheck;
    if IsKeyDown && KeyCode(KbName('ESCAPE'))
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
%             clear HandlePortAudio ;
        end
        Priority(0);
        sca;
        return;
        
    end
    
    
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end

%%
%����׶�
%�ظ�������ParameterSetting�е�NumTrial����
for trial =1:NumTrial
    
    %�����ȡ������������ĵ�
    SequenceCodedDot = randperm(NumSquare,NumCodedDot);
    
    %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
    AudioDataLeft = reshape(DataPureTone(1,SequenceCodedDot,1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
    %���
    AudioDataLeft = sum(AudioDataLeft);
    %��һ��
    AudioDataLeft =  AudioDataLeft/max(abs(AudioDataLeft));

    
    AudioDataRight = reshape(DataPureTone(2,SequenceCodedDot,1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);

    AudioDataRight = sum(AudioDataRight);

    AudioDataRight =  AudioDataRight/max(abs(AudioDataRight));
    
    
    %��֮ǰ������HandleNoiseBuffer����İ���������������Ƶ���ŵ�Buffer��
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleNoiseBuffer);
    
    %���Ű�����
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
    
%%
%���������ֽ׶�
%ʱ����ParameterSetting�е�TimeWhiteNoise����
    for Frame =1:round(TimeWhiteNoise*FramePerSecond)
         
        DrawFormattedText(PointerWindow,MessageWhiteNoise,'center', 'center', white);
        Screen('DrawingFinished', PointerWindow);
        
           
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            if exist('HandlePortAudio','var')
                PsychPortAudio('Stop', HandlePortAudio);
                PsychPortAudio('Close', HandlePortAudio);
%                 clear HandlePortAudio ;
            end
            Priority(0);
            sca;
            return;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    %ֹͣ��������
    PsychPortAudio('Stop', HandlePortAudio);
    
    %�������������������Buffer��
    PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
    %���ű�������
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
    
%%
%�����������ֽ׶�   
for frame=1:round(TimeCodedSound*FramePerSecond)
    
    %���Ʒ����Բ��
    Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
    Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodedDot),SizeDot+1);
    %��������������1�����������Ӧ������
    if NumCodedDot > 1
        XLine = reshape(repmat(XSquareCenter((SequenceCodedDot)),2,1),1,[]);
        
        YLine = reshape(repmat(YSquareCenter((SequenceCodedDot)),2,1),1,[]);
        
 
        Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);

        
    end
    Screen('DrawingFinished', PointerWindow);
    
    
    [IsKeyDown,~,KeyCode] = KbCheck;
    if IsKeyDown && KeyCode(KbName('ESCAPE'))
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            %                     clear HandlePortAudio ;
        end
        Priority(0);
        sca;
        return;
        
    end
    
    
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end
    
    PsychPortAudio('Stop', HandlePortAudio);
%%
%�����׶Σ�Trial֮�����Ϣʱ�䣩
    for frame = 1:round(TimeSilence*FramePerSecond)
        
        if trial ~= NumTrial
            DrawFormattedText(PointerWindow,MessageSilence,'center', 'center', white);
            
        else
            
            DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', white);
            
        end
        
        Screen('DrawingFinished', PointerWindow);
           
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            if exist('HandlePortAudio','var')
                PsychPortAudio('Stop', HandlePortAudio);
                PsychPortAudio('Close', HandlePortAudio);
%                 clear HandlePortAudio ;
            end
            Priority(0);
            sca;
            return;
            
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
        
    end
    
end

%�ָ���ʾ���ȼ�
Priority(0);
%�ر�PortAudio����
PsychPortAudio('Close', HandlePortAudio);
% clear HandlePortAudio ;

close all;
% clear;
%�رմ��ڶ���
sca;

%�������ִ�г�����ִ���������
catch Error

    if exist('HandlePortAudio','var')

        %�ر�PortAudio����
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close', HandlePortAudio);
        
%         clear HandlePortAudio ;

    end
    %�ָ���Ļ��ʾ���ȼ�
    Priority(0);
    %�ر����д��ڶ���  
    sca;
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);


end





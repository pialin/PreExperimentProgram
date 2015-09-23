%���뷽ʽB��λ��ʶ����
%����
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
close all;
clear;
sca;
%������Ӧ����
%Matlab�����д���ֹͣ��Ӧ�����ַ����루��Crtl-C����ȡ����һ״̬��
ListenChar(2);
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc�����������ҷ�������Դ���KbCheck��
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow')]);

%�޸Ĺ���·������ǰM�ļ�����Ŀ¼
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(PosFileSep(end)));

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

%����SnakeParameterSetting.m������Ӧ����
SankeParameterSetting;

%����ʹ�С�趨
Screen('TextFont',PointerWindow, NameFont);
Screen('TextSize',PointerWindow, SizeFont);
%����Alpha-Blending��Ӧ����
Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%�ȴ�֡���趨���������ڱ�֤׼ȷ��֡ˢ��ʱ��
FrameWait = 1;


%����������㣺XSquareCenter, YSquareCenter�ֱ𱣴淽�����ĵ��X�����Y����
if NumSquare == 1
    XSquareCenter = 0;
    YSquareCenter = 0;
else
    [MatrixXSquareCenter,MatrixYSquareCenter]= meshgrid(linspace(-1*(NumSquarePerRow-1)/2,(NumSquarePerRow-1)/2,NumSquarePerRow));
end


%���������ĵ��X�����Y����ת��һ��һά����������ƫ��ʹ����������Ļ����
MatrixXSquareCenter =  round(MatrixXSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);
MatrixYSquareCenter =  round(MatrixYSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);

SequenceXSquareCenter = reshape(MatrixXSquareCenter',1,NumSquare);
SequenceYSquareCenter = reshape(MatrixYSquareCenter',1,NumSquare);


%��׼����
RectBaseSquare = [0,0,round(SizeSquare),round(SizeSquare)];
%���ݻ�׼����ͷ������ĵ������������з���ķ�Χ����ά��������ʽ��[���Ͻ�X����,���Ͻ�X����,���½�X���꣬���½�Y����]��
RectSquare = CenterRectOnPointd(RectBaseSquare,SequenceXSquareCenter',SequenceYSquareCenter')';
%��׼Բ��
RectBaseDot = [0,0,round(SizeDot),round(SizeDot)];
%���ݻ�׼Բ��ͷ������ĵ�������������Բ��ķ�Χ����ʽͬ��
RectDot = CenterRectOnPointd(RectBaseDot,SequenceXSquareCenter',SequenceYSquareCenter')';


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
%��Ƶ�طŴ����������ط�ֱ��ִ�� PsychPortAudio('Stop',...)
AudioRepetition = 0;


% ����PortAudio���󣬶�Ӧ�Ĳ�������
% (1) [] ,����Ĭ�ϵ�
% (2) 1 ,�������������ţ�����������¼�ƣ�
% (3) 1 , Ĭ���ӳ�ģʽ
% (4) SampleRateAudio,��Ƶ������
% (5) 2 ,���������Ϊ2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);


%�½�Buffer���ڴ����ʾ������
HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
HandleHitBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll,AudioDataHit;AudioDataRoll,AudioDataHit]);
HandleFinishBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);

%%
%��ʼ
%CursorPos���ڴ洢�Ĺ��λ�ñ仯�����ÿһ�зֱ����һ��λ�õı䶯����һ�д������ڷ������ĵڼ��У��ڶ��д������ڷ������ĵڼ���
PosCursor = zeros(2,NumMaxStepPerTrial*NumTrial);
%������ʼ���λ�ã�����һ�е�һ��
PosCursor(:,1) = 1;
PosTarget = zeros(2,NumTrial);

KeyDistance = zeros(2,1);
PosNextTarget = zeros(2,1);

NumStep = 1;


%�״ε��ú�ʱ�ϳ��ĺ���
KbCheck;
KbWait([],1);

%�����������һ��Ŀ�����Ե�ǰĿ������ƫ��KeyDistance(1)������ƫ��KeyDistance(2)
%���Ŀ�����ԭĿ���ƫ����ӱ������1�����Ҳ���������ķ�Χ
for trial = 1:NumTrial
    
    while sum(KeyDistance)<=1 || any(PosNextTarget>NumSquarePerRow) || any(PosNextTarget<1)
        %��/�����ƫ�Ʒ�Χ����������RangeNextTarget֮��
        KeyDistance = randi([-1*RangeNextTarget,RangeNextTarget],2,1);
        %������һ������
        if trial ==1
            PosNextTarget =  PosCursor(:,1)+KeyDistance;
        else
            PosNextTarget =  PosTarget(:,trial-1)+KeyDistance;
        end
            
    end
    
    PosTarget(:,trial) = PosNextTarget;
    
end



%���ȼ�����
Priority(LevelTopPriority);
%���е�һ��֡ˢ�»�ȡ��׼ʱ��
vbl = Screen('Flip', PointerWindow);

%%
%�ȴ��׶�
%ʱ��Ϊ׼��ʱ����ȥ����ʱʱ��
for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
    %������ʾ��
    DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
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
        
        %�ָ������趨
        ListenChar(0);
        RestrictKeysForKbCheck([]);
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
    DrawFormattedText(PointerWindow,num2str(ceil(TimeLeft)),'center', 'center', ColorFont);
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
        
        %�ָ������趨
        ListenChar(0);
        RestrictKeysForKbCheck([]);
        return;
        
    end
    
    
    vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
    
end





for trial =1:NumTrial
    
    %���Ʒ����Բ��
    Screen('FillRect', PointerWindow,ColorSquare,RectSquare);    
    Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,PosTarget(trial)),ceil(SizeDot));
    Screen('FillOval', PointerWindow,ColorDot,RectDot(:,PosCursor(1:NumStep)),ceil(SizeDot));

    
    if NumStep > 1
        XLine = reshape(repmat(XSquareCenter((PosCursor(1:NumStep))),2,1),1,[]);
        
        YLine = reshape(repmat(YSquareCenter((PosCursor(1:NumStep))),2,1),1,[]);
        
        Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
        
        
    end
    
    Screen('DrawingFinished', PointerWindow);
    
    vbl = Screen('Flip', PointerWindow);
   
   
FlagHitTarget = false;

while FlagHitTarget == false && NumStep<=NumMaxStepPerTrial

KeyDistance = PosTarget(:,NumTrial)-PosCuror(:,NumStep);
   
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
%��������

   %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
    AudioDataLeft = reshape(DataPureTone(1,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
    
    AudioDataRight = reshape(DataPureTone(2,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
     
    %������������

    EuclidDistance = sqrt(sum(KeyDistance.^2));
    AudioVolume = MinAudioVolume+(1-MinAudioVolume)/(RangeNextTarget*sqrt(2)-sqrt(2))*(EuclidDistance-sqrt(2)) ;
    
    PsychPortAudio('Volume', HandlePortAudio, AudioVolume);

    
    
    %������������������Buffer
    PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,TimeGapSilence*SampleRate,AudioAudioDataLeft);
                                                  zeros(1,TimeGapSilence*SampleRateAudio),AudioDataRight]);
    
    PsychPortAudio('Stop', HandlePortAudio);
                                              
    %��������
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
   
    %�ȴ����������Esc��������
    [ ~, KeyCode, ~] = KbWait([],0,GetSecs+TimeWaitPerMove);
    %�ȴ������ɿ� 
    KbWait([],1);
    
    if any(KeyCode) && ~KeyCode(KbName('ESCAPE'))
        NumStep = NumStep +1;
        if KeyCode(KbName('LeftArrow'))
            TempPosCursor = PosCursor(:,NumStep-1)+[-1;0];  
        elseif KeyCode(KbName('RightArrow'))
            TempPosCursor = PosCursor(:,NumStep-1)+[1;0];  
        elseif KeyCode(KbName('UpArrow'))
            TempPosCursor = PosCursor(:,NumStep-1)+[0;1];  
        elseif KeyCode(KbName('DownArrow'))
            TempPosCursor = PosCursor(:,NumStep-1)+[0;-1];  
        end
        
    else
        if exist('HandlePortAudio','var')
            
            %�ر�PortAudio����
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            
            %clear HandlePortAudio ;
            
        end
        %�ָ���Ļ��ʾ���ȼ�
        Priority(0);
        %�ر����д��ڶ���
        sca;
        
        %�ָ������趨
        ListenChar(0);
        RestrictKeysForKbCheck([]);
        
        return;
        
    end
    
    PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
        
    %����곬���˱߽�   
    if any(TempPosCursor>NumSquarePerRow) || any(TempPosCursor<1)
        
        PosCursor(:,NumStep)=PosCursor(:,NumStep-1);
        
        %��֮ǰ������HandleOutBuffer���������������Ƶ���ŵ�Buffer��
        PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
        
        PsychPortAudio('Stop', HandlePortAudio);
        
        %��������
        PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
        
        
        WaitSecs(numel(AudioDataOut)/AudioSampleRate);
        
    else
        
        PosCursor(:,NumStep)=TempPosCursor;
        
        %���Ʒ����Բ��
        Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
        Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,PosTarget(trial)),ceil(SizeDot));
        Screen('FillOval', PointerWindow,ColorDot,RectDot(:,PosCursor(1:NumStep)),ceil(SizeDot));
        
        
        if NumStep > 1
            XLine = reshape(repmat(XSquareCenter((PosCursor(1:NumStep))),2,1),1,[]);
            
            YLine = reshape(repmat(YSquareCenter((PosCursor(1:NumStep))),2,1),1,[]);
            
            Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
            
            
        end
        
        Screen('DrawingFinished', PointerWindow);
        
        vbl = Screen('Flip', PointerWindow);
        
        
        %����굽��Ŀ���
        if PosCursor(:,NumStep) == PosTarget(:,trial)
            
            FlagHitTarget = true;
            %�����ƶ�����������
            %��֮ǰ������HandleHitBuffer�������������������Ƶ���ŵ�Buffer��
            PsychPortAudio('FillBuffer', HandleHitBuffer);
            
            PsychPortAudio('Stop', HandlePortAudio);
            %��������
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            WaitSecs((numel(AudioDataRoll)+numel(AudioDataHit))/AudioSampleRate);
        %����껹δ����Ŀ���
        else
            %�����ƶ�����
            %��֮ǰ������HandleRollBuffer�������������������Ƶ���ŵ�Buffer��
            PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);
            
            %��������
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            WaitSecs(numel(AudioDataRoll)/AudioSampleRate);
            
        end
    end
 
      
end

if NumStep> NumMaxStepPerTrial
    if exist('HandlePortAudio','var')
        
        %�ر�PortAudio����
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close', HandlePortAudio);
        
        %clear HandlePortAudio ;
        
    end
    %�ָ���Ļ��ʾ���ȼ�
    Priority(0);
    %�ر����д��ڶ���
    sca;
    
    %�ָ������趨
    ListenChar(0);
    RestrictKeysForKbCheck([]);
    
    return;
    
end


end

PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
%��֮ǰ������HandleFinishBuffer���������������Ƶ���ŵ�Buffer��
PsychPortAudio('FillBuffer', HandlePortAudio,HandleFinshBuffer);

PsychPortAudio('Stop', HandlePortAudio);

%��������
PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
WaitSecs(numel(AudioDataFinish)/AudioSampleRate);

for frame = 1:round(TimeMessgeFinish * FramePerSecond)
    
   DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
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
        
        %�ָ������趨
        ListenChar(0);
        RestrictKeysForKbCheck([]);
        return;
        
        
    end

end



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
    
    %�ָ������趨
    ListenChar(0);
    RestrictKeysForKbCheck([]);
    
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);


end
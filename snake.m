%���뷽ʽB��λ��ʶ����
%����
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
close all;
clear;
sca;

%�޸Ĺ���·������ǰM�ļ�����Ŀ¼
cd mfilename('fullpath');

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


%try catch��䱣֤�ڳ���ִ�й����г������Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
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

%����ParameterSetting.m������Ӧ����
ParameterSetting;

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
%��Ƶ�طŴ��������貥��һ��
AudioRepetition = 1;


% ����PortAudio���󣬶�Ӧ�Ĳ�������
% (1) [] ,����Ĭ�ϵ�
% (2) 1 ,�������������ţ�����������¼�ƣ�
% (3) 1 , Ĭ���ӳ�ģʽ
% (4) SampleRateAudio,��Ƶ������
% (5) 2 ,���������Ϊ2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);




%���ȼ�����
Priority(LevelTopPriority);
%���е�һ��֡ˢ�»�ȡ��׼ʱ��
vbl = Screen('Flip', PointerWindow);


%%
%��ʼ
%CursorPos���ڴ洢�Ĺ��λ�ñ仯�����ÿһ�зֱ����һ��λ�õı䶯����һ�д�������ڷ������ĵڼ��У��ڶ��д�������ڷ������ĵڼ���
PosCursor = zeros(2,MaxNumStep);
%������ʼ���λ�ã�����һ�е�һ��
PosCursor(:,1) = 1;
PosTarget = zeros(2,NumTrial);

while trial <= NumTrail 

KeyDistance = zeros(2,1);
PosNextTarget = zeros(2,1);


%�����������һ��Ŀ�����Ե�ǰĿ������ƫ��KeyDistance(1)������ƫ��KeyDistance(2)
%���Ŀ�����ԭĿ���ƫ����ӱ������1�����Ҳ���������ķ�Χ
while sum(KeyDistance)<=1 || any(PosNextTarget>NumSquarePerRow) || any(PosNextTarget<1)
%��/�����ƫ�Ʒ�Χ����������NextTargetRange֮��
KeyDistance = randi([-1*RangeNextTarget,RangeNextTarget],2,1);
%������һ������
PosNextTarget = PosCursor(:,nnz(PosCursor(1,:)))+KeyDistance;

end

TargetPos(:,trial) = PosNextTarget;

%�״ε��ú�ʱ�ϳ��ĺ���
[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
[secs, keyCode, deltaSecs] = KbWait([deviceNumber][, forWhat=0][, untilTime=inf])

StartTime =GetSecs;

HitTarget = false;

while HitTarget == false
    
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

    
    
    %��֮ǰ������HandleNoiseBuffer����İ���������������Ƶ���ŵ�Buffer��
    PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,TimeGapSilence*SampleRateAudio);
                                                  AudioDataRight,zeros(1,TimeGapSilence*SampleRateAudio)]);
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);

    
    TimeStart = GetSecs;
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    while GetSecs <= TimeStart + TimeWaitPerMove  
    
    
    
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
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);


end
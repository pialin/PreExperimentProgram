%��λ��ʶ����
%�������:
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64
%%
close all;
clear;
sca;

%�޸Ĺ���·������ǰM�ļ�����Ŀ¼
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(1:PosFileSep(end)));


%������Ի����ȡ����������

InputdlgOptions.Resize = 'on'; 
InputdlgOptions.WindowStyle = 'normal';

if exist('LastSubjectName.mat','file')
    load LastSubjectName.mat;
    SubjectName = inputdlg('Subject Name:','����������������',[1,42],{LastSubjectName},InputdlgOptions);
else
    SubjectName = inputdlg('Subject Name:','����������������',[1,42],{'ABC'},InputdlgOptions);
end

if isempty(SubjectName)
    return;
end

%�洢���������������Ϊ����ʵ���������Ƶ�Ĭ��ֵ
LastSubjectName = SubjectName{1};

save LastSubjectName.mat LastSubjectName;

DateString = datestr(now,'yyyymmdd_HH-MM-SS');

%%
%�����������״̬����
rng('shuffle');%Matlab R2012֮��汾
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012֮ǰ�汾



%%
%��ʾ��������

%ִ��Ĭ������2
%�൱��ִ��������������䣺
%��AssertOpenGL;��%ȷ��Screen��������ȷ��װ
%��KbName('UnifyKeyNames');��%����һ�����������в���ϵͳ��KeyCode�������룩��KeyName������������
%�ڴ������ں�����ִ�С�Screen('ColorRange', PointerWindow, 1, [],1);������ɫ���趨��ʽ��3��
%8λ�޷�����ɵ���ά�����ĳ�3��0��1�ĸ�������ά������Ŀ����Ϊ��ͬʱ���ݲ�ͬ��ɫλ������ʾ��������16λ��ʾ����
PsychDefaultSetup(2);

%������Ӧ����
%Matlab�����д���ֹͣ��Ӧ�����ַ����루��Crtl-C����ȡ����һ״̬��
ListenChar(2);
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc�����������ҷ�������Դ���KbCheck��
RestrictKeysForKbCheck(KbName('ESCAPE'));

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
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %��ȡÿ��֡ˢ��֮���ʱ����
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %����ÿ��ˢ�µ�֡��
    FramePerSecond = 1/TimePerFlip;
    
    %��ȡ���õ���Ļ��ʾ���ȼ�����
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    RefExp_ParameterSetting;
    
    %����ʹ�С�趨
    Screen('TextFont',PointerWindow, NameFont);
    Screen('TextSize',PointerWindow, SizeFont);
    
    %����Alpha-Blending��Ӧ����
    Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    %�ȴ�֡���趨���������ڱ�֤׼ȷ��֡ˢ��ʱ��
    FrameWait = 1;
    
    
    
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
    %��Ƶ�طŴ���
    AudioRepetition = 1;
    
    
    % ����PortAudio���󣬶�Ӧ�Ĳ�������
    % (1) [] ,����Ĭ�ϵ�
    % (2) 1 ,�������������ţ�����������¼�ƣ�
    % (3) 1 , Ĭ���ӳ�ģʽ
    % (4) SampleRateAudio,��Ƶ������
    % (5) 2 ,���������Ϊ2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    %ѭ������
    NumDot = round(TimeAll/(TimeCodedSound+TimeGapSilence));
    
    DotSequence = randi(9,1,NumDot);
    
    AudioData = zeros(2,NumDot*(TimeCodedSound+TimeGapSilence)*SampleRateAudio);
    
    
    for dot = 1: NumDot
    
        AudioData(:,(dot-1)*(TimeCodedSound+TimeGapSilence)*SampleRateAudio+1 : (dot*TimeCodedSound+(dot-1)*TimeGapSilence)*SampleRateAudio) = ...
             DataPureTone(:,DotSequence(dot),1:round(SampleRateAudio));
        
    end
    
    
    %��һ��
    
    MaxAmp = max([MatrixLeftAmp(DotSequence), MatrixRightAmp(DotSequence)]);
    
    AudioData=AudioData/MaxAmp;
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,AudioData);
    
     
    %�״ε��ú�ʱ�ϳ��ĺ���
    KbCheck;
    KbWait([],1);   
    
    %��ʾ���ȼ�����
    Priority(LevelTopPriority);
    %���е�һ��֡ˢ�»�ȡ��׼ʱ��
    vbl = Screen('Flip', PointerWindow);  
    %%
    %��ʼ

    %�ȴ��׶�
        %���ڱ��251��ʾʵ�鿪ʼ
        lptwrite(LPTAddress,251);

    
    for frame =1:round((TimePrepare)*FramePerSecond)
        
        if frame == 2
            %ÿ�δ����Ǻ���Ҫ���½���������
            lptwrite(LPTAddress,0);
        
        end
        %������ʾ��
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
        %��ʾ�������������ѻ������
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
            lptwrite(LPTAddress,253);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
             
            %�ر�PortAudio����
            PsychPortAudio('Close');
            %�ָ���ʾ���ȼ�
            Priority(0);
            %�ر����д��ڶ���
            sca;
            %�ָ������趨
            %�ָ�Matlab�����д��ڶԼ����������Ӧ
            ListenChar(0);
            %�ָ�KbCheck���������м����������Ӧ
            RestrictKeysForKbCheck([]);
            %���������0
            lptwrite(LPTAddress,0);
            %��ֹ����
            return;
        end
        
        %֡ˢ��
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end


    
    %%
    %��ʼ��������
    
        %�ȴ��׶�
        %���ڱ��1��ʾʵ�鿪ʼ��������
        lptwrite(LPTAddress,1);
    PsychPortAudio('Start', HandlePortAudio, AudioRepetition , AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1: ceil(NumDot*(TimeCodedSound+TimeGapSilence)*FramePerSecond)
        
        if frame == 2
            %ÿ�δ����Ǻ���Ҫ���½���������
            lptwrite(LPTAddress,0);
        
        end
        
        %������ʾ��
        DrawFormattedText(PointerWindow,MessageStart,'center', 'center', ColorFont);
        %��ʾ�������������ѻ������
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
            lptwrite(LPTAddress,253);
            WaitSecs(0.01);
            lptwrite(LPTAddress,0);
            WaitSecs(0.01);
             
            %�ر�PortAudio����
            PsychPortAudio('Close');
            %�ָ���ʾ���ȼ�
            Priority(0);
            %�ر����д��ڶ���
            sca;
            %�ָ������趨
            %�ָ�Matlab�����д��ڶԼ����������Ӧ
            ListenChar(0);
            %�ָ�KbCheck���������м����������Ӧ
            RestrictKeysForKbCheck([]);
            %���������0
            lptwrite(LPTAddress,0);
            %��ֹ����
            return;
        end
        
        %֡ˢ��
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);

    end
    
    %���ڱ��254��ʾʵ����������
    lptwrite(LPTAddress,254);
    
     %������ʾ��
     DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
     vbl = Screen('Flip', PointerWindow);
     
      %�ر�PortAudio����
    PsychPortAudio('Close');
    
    WaitSecs(TimeShowFinish);
    
    %�ָ���ʾ���ȼ�
    Priority(0);
    %�ر����д��ڶ���
    sca;
    
    %�ָ������趨
    %�ָ�Matlab�����д��ڶԼ����������Ӧ
    ListenChar(0);
    %�ָ�KbCheck���������м����������Ӧ
    RestrictKeysForKbCheck([]);
    
        %���������0
    lptwrite(LPTAddress,0);

   %%
    %�洢��¼�ļ�
    %��¼�ļ�·��
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'RefExp'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %��¼�ļ���
    RecordFile = [RecordPath,filesep,DateString,'.mat'];
    %�洢�ı�������NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'DotSequence');
    
    %%
    %�������ִ�г�����ִ���������
catch Error
    
     %�ر�PortAudio����
    PsychPortAudio('Close');
    %�ָ���ʾ���ȼ�
    Priority(0);
    %�ر����д��ڶ���
    sca;
    
    %�ָ������趨
    %�ָ�Matlab�����д��ڶԼ����������Ӧ
    ListenChar(0);
    %�ָ�KbCheck���������м����������Ӧ
    RestrictKeysForKbCheck([]);
    %���������0
    lptwrite(LPTAddress,0);
    
    
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);
    
    
end
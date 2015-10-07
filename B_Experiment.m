%���뷽ʽBʵ�����
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

%�޸Ĺ���·������ǰM�ļ�����Ŀ¼
Path=mfilename('fullpath');
FileSepIndex = strfind(Path,filesep);
cd(Path(1:FileSepIndex(end)));


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
%%
%�����������״̬����
rng('shuffle');%Matlab R2012֮��汾
% rand('twister',mod(floor(now*8640000),2^31-1));%Matlab R2012֮ǰ�汾


%%
%��ʾ��������

%ִ��Ĭ������2
%�൱��ִ��������������䣺
%��AssertOpenGL;��%ȷ��Screen��������ȷ��װ
%��KbName('UnifyKeyNames');��%����һ�����������в���ϵͳ��ͳһ��KeyCode�������룩��KeyName������������
%�ڴ������ں�����ִ�С�Screen('ColorRange', PointerWindow, 1, [],1);������ɫ���趨��ʽ��3��
%8λ�޷�����ɵ���ά�����ĳ�3��0��1�ĸ�������ά������Ŀ����Ϊ��ͬʱ���ݲ�ͬ��ɫλ������ʾ��������16λ��ʾ����
PsychDefaultSetup(2);

%������Ӧ����
%Matlab�����д���ֹͣ��Ӧ�����ַ����루��Crtl-C����ȡ����һ״̬��
ListenChar(2);
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc�����Դ���KbCheck��
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

%%
%try catch��䱣֤�ڳ���ִ�й����г�����Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
try
    
    %����һ�����ڶ��󣬷��ض���ָ��PointerWindow
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %��ȡÿ��֡ˢ��֮���ʱ����
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %����ÿ��ˢ�µ�֡��
    FramePerSecond = 1/TimePerFlip;
    
    %��ȡ���õ���Ļ��ʾ���ȼ�����
    LevelTopPriority = MaxPriority(PointerWindow);
    
    %��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %����ParameterSetting.m������Ӧ����
    B_ParameterSetting;
    
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
        %���ڱ��251��ʾʵ�鿪ʼ
        lptwrite(LPTAddress,251);

    
    
    %�ȴ��׶�
    %ʱ��Ϊ׼��ʱ����ȥ����ʱʱ��
    for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
        
        if frame ==2 
            
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
            
            %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
            lptwrite(LPTAddress,253);
            %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
            WaitSecs(0.01);
            %ÿ�δ����Ǻ���Ҫ���½���������
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
            %��ֹ����
            return;
        end
        
        %֡ˢ��
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    
   %%
     %����ʱ�׶�
    
    %����ʱ��ʾ��
    AudioDataLeft = reshape(DataPureTone(1,5,1:round(SampleRateAudio)),1,[]);
    AudioDataRight = reshape(DataPureTone(2,5,1:round(SampleRateAudio)),1,[]);
    
    %��һ��
    
    MaxAmp = max([MatrixLeftAmp(5), MatrixRightAmp(5)]);
    
    AudioDataLeft =  AudioDataLeft/MaxAmp;
    AudioDataRight =  AudioDataRight/MaxAmp;
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,round(0.7*SampleRateAudio)),AudioDataLeft;zeros(1,round(0.7*SampleRateAudio)),AudioDataRight]);
    
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, AudioCompetition, AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
            lptwrite(LPTAddress,253);
            %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
            WaitSecs(0.01);
            %ÿ�δ����Ǻ���Ҫ���½���������
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
            %��ֹ����
            return;
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end

    
    PsychPortAudio('Stop', HandlePortAudio);
    

    
    %%
    %��ʼ��SequenceCodedDot���ڼ�¼���ѡȡ�ı���㣬ÿһ��Ϊһ��Trial
    SequenceCodedDot = zeros(NumCodedDot,NumTrial);
    
    %����׶�
    %�ظ�������ParameterSetting�е�NumTrial����
    for trial =1:NumTrial
        
        %�����ȡ������������ĵ�
        SequenceCodedDot(:,trial) = randperm(NumSquare,NumCodedDot);
        
        %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
        AudioDataLeft = reshape(DataPureTone(1,SequenceCodedDot(:,trial),1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
        %���
        AudioDataLeft = sum(AudioDataLeft,1);
        
        
        
        AudioDataRight = reshape(DataPureTone(2,SequenceCodedDot(:,trial),1:TimeCodedSound*SampleRateAudio),NumCodedDot,[]);
        
        AudioDataRight = sum(AudioDataRight,1);
        
        %��һ��
        AudioData = mapminmax([AudioDataLeft,AudioDataRight]);
        
        AudioDataLeft = AudioData(1:TimeCodedSound*SampleRateAudio);
        AudioDataRight = AudioData(TimeCodedSound*SampleRateAudio+1:end);


        PsychPortAudio('Stop', HandlePortAudio);
        
        %��֮ǰ������HandleNoiseBuffer����İ���������������Ƶ���ŵ�Buffer��
        PsychPortAudio('FillBuffer', HandlePortAudio,HandleNoiseBuffer);
        
        %���Ű�����
        PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
        
            %���ڱ��201��ʾ��ʼ���Ű�����
            lptwrite(LPTAddress,201);

        
        
        
        %%
        %���������ֽ׶�
        %ʱ����ParameterSetting�е�TimeWhiteNoise����
        for frame =1:round(TimeWhiteNoise*FramePerSecond)
            
            if frame == 2

                    %ÿ�δ����Ǻ���Ҫ���½���������
                    lptwrite(LPTAddress,0);
            
            end
            
            DrawFormattedText(PointerWindow,MessageWhiteNoise,'center', 'center', ColorFont);
            Screen('DrawingFinished', PointerWindow);
            
            
            %��ȡ�������룬��Esc���������������˳�����
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
                
                %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
                lptwrite(LPTAddress,253);
                %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
                WaitSecs(0.01);
                %ÿ�δ����Ǻ���Ҫ���½���������
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
                %��ֹ����
                return;
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
        end
        
        %ֹͣ��������
        PsychPortAudio('Stop', HandlePortAudio);
        
        %�ѱ�������������䵽PortAudio�����Buffer��
        PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,round(TimeGapSilence*SampleRateAudio)),AudioDataLeft;
                    zeros(1,round(TimeGapSilence*SampleRateAudio)),AudioDataRight]);
        %���ű�������
        PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
        
            %���ڱ��1-200��ʾ��ʼ���ű������������ִ���Ŀǰ��trial��
            lptwrite(LPTAddress,mod(trial-1,200)+1);

        
        %%
        %�����������ֽ׶�
        for frame=1:round((TimeCodedSound+TimeGapSilence)*AudioRepetition*FramePerSecond)
            
            if frame ==2

                    %ÿ�δ����Ǻ���Ҫ���½���������
                    lptwrite(LPTAddress,0);


            end
            
            %���Ʒ����Բ��
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodedDot(:,trial)),SizeDot+1);
            %��������������1�����������Ӧ������
            if NumCodedDot > 1
                XLine = reshape(repmat(XSquareCenter((SequenceCodedDot(:,trial))),2,1),1,[]);
                
                YLine = reshape(repmat(YSquareCenter((SequenceCodedDot(:,trial))),2,1),1,[]);
                
                
                Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
                
                
            end
            Screen('DrawingFinished', PointerWindow);
            
            
            %��ȡ�������룬��Esc���������������˳�����
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
                %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
                lptwrite(LPTAddress,253);
                %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
                WaitSecs(0.01);
                %ÿ�δ����Ǻ���Ҫ���½���������
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
                %��ֹ����
                return;
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
        end
        
        PsychPortAudio('Stop', HandlePortAudio);
        
            %���ڱ��1-200��ʾ�����������������ִ���Ŀǰ��trial��
            lptwrite(LPTAddress,mod(trial-1,200)+1);

        
        %%
        %������Ϣ�׶Σ�Trial֮�����Ϣʱ�䣩
        for frame = 1:round(TimeBreak*FramePerSecond)
            
            if frame ==2 

                    %ÿ�δ����Ǻ���Ҫ���½���������
                    lptwrite(LPTAddress,0);
            
            end
            
            if trial ~= NumTrial
                DrawFormattedText(PointerWindow,MessageSilence,'center', 'center', ColorFont);
                
            else
                
                DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
                
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            %��ȡ�������룬��Esc���������������˳�����
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
                %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
                lptwrite(LPTAddress,253);
                %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
                WaitSecs(0.01);
                %ÿ�δ����Ǻ���Ҫ���½���������
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
                %��ֹ����
                return;
            end
            
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
            
        end
        
    end
    
    %%   
    %���ڱ��254��ʾʵ����������
        lptwrite(LPTAddress,254);

    
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        if frame ==2 

                lptwrite(LPTAddress,0);
       
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %ɨ����̣����Esc�����������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
            %���ڱ��253��ʾʵ����ΪESC�������¶���ֹ
            lptwrite(LPTAddress,253);
            %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
            WaitSecs(0.01);
            %ÿ�δ����Ǻ���Ҫ���½���������
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
            %��ֹ����
            return;
        end
        
        vbl = Screen('Flip', PointerWindow);
        
    end
    
    
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
    
    %%
    %�洢��¼�ļ�
    %��¼�ļ�·��
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'B',num2str(NumCodedDot)];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %��¼�ļ���
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %�洢�ı�������NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumCodedDot','NumTrial','SequenceCodedDot');
    
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


    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);
end    
    





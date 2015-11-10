%���뷽ʽAʵ�����
%����������
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
%��KbName('UnifyKeyNames');��%����һ�����������в���ϵͳ��ͳһ��KeyCode�������룩��KeyName������������
%�ڴ������ں�����ִ�С�Screen('ColorRange', PointerWindow, 1, [],1);������ɫ���趨��ʽ��3��
%8λ�޷�����ɵ���ά�����ĳ�3��0��1�ĸ�������ά������Ŀ����Ϊ��ͬʱ���ݲ�ͬ��ɫλ������ʾ��������16λ��ʾ����
PsychDefaultSetup(2);

%������Ӧ����
%Matlab�����д���ֹͣ��Ӧ�����ַ����루��Crtl-C����ȡ����һ״̬��
ListenChar(2);
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc����С����1-9���Դ���KbCheck��
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
%try catch��䱣֤�ڳ���ִ�й����г������Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
try
    
    %����һ�����ڶ��󣬷��ض���ָ��PointerWindow
    PointerWindow = PsychImaging('OpenWindow', ScreenNumber, black);
    
    %��ȡÿ��֡ˢ��֮���ʱ����
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %����ÿ��ˢ�µ�֡��
    FramePerSecond = 1/TimePerFlip;
    
    %��ȡ���õ���Ļ��ʾ���ȼ�����
    LevelTopPriority = MaxPriority(PointerWindow,'KbCheck','KbWait','sound');
    
    %��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %����AParameterSetting.m������Ӧ����
    A_ParameterSetting;
    
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
    
    %�ȴ��������������ټ���ִ�к�������
    WaitUntilDeviceStart = 1;
    
    
    % ����PortAudio���󣬶�Ӧ�Ĳ�������
    % (1) [] ,����Ĭ�ϵ�����
    % (2) 1 ,�������������ţ�����������¼�ƣ�
    % (3) 1 , Ĭ���ӳ�ģʽ
    % (4) SampleRateAudio,��Ƶ������
    % (5) 2 ,���������Ϊ2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    %������������
    PsychPortAudio('Volume', HandlePortAudio, AudioVolume);
  
    %���ȼ�����
    Priority(LevelTopPriority);
    %���е�һ��֡ˢ�»�ȡ��׼ʱ��
    vbl = Screen('Flip', PointerWindow);
    
    %%
    
%         %���ڱ��251��ʾʵ�鿪ʼ
%         lptwrite(LPTAddress,251);
%         %������״̬����һ��ʱ�䣨ʱ��������NeuroScan�Ĳ���ʱ������


    
    %�ȴ��׶�
    %ʱ��Ϊ׼��ʱ����ȥ����ʱʱ��
    for frame =1:round(TimePrepare*FramePerSecond)
        if frame == 2
%         %ÿ�δ����Ǻ���Ҫ���½���������
%         lptwrite(LPTAddress,0);       
        end
        %������ʾ��
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
        %��ʾ�������������ѻ������
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %ÿ�δ����Ǻ���Ҫ���½���������
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
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
    
    
    %��ʼ������
    PsychPortAudio('Stop',HandlePortAudio);
    %����������������Ƶ���ŵ�Buffer��
    PsychPortAudio('FillBuffer', HandlePortAudio,repmat(DataWhiteNoise,2,1));
    %����
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    
    
    for frame =1:ceil(TimeWhiteNoise*FramePerSecond)
        
        %������ʾ��
        DrawFormattedText(PointerWindow,MessageWhiteNoise1,'center', 'center', ColorFont);
        %��ʾ�������������ѻ������
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %ÿ�δ����Ǻ���Ҫ���½���������
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
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
    %��ʼ��SequenceCodeDot���ڼ�¼���ѡȡ�ı���㣬ÿһ��Ϊһ��Trial
    SequenceCodeDot = zeros(NumCodedDot,NumTrial);
  
    
    %����׶�
    %�ظ�������ParameterSetting�е�NumTrial����
    for trial =1:NumTrial
        
        
        %�����ȡ������������ĵ�
        SequenceCodeDot(:,trial) = randperm(NumSquare,NumCodedDot)';  
        %���������������ֵ�����ڹ�һ��
        MaxAmp = max([MatrixLeftAmp(SequenceCodeDot(:,trial))', MatrixRightAmp(SequenceCodeDot(:,trial))']);
        
        %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
        AudioDataLeft = [ 
            zeros(1,SampleRateAudio),...
            reshape(DataPureTone(1,5,:)/max(MatrixLeftAmp(5),MatrixRightAmp(5)),1,[]),...
            zeros(1,SampleRateAudio*2),...
            repmat([reshape(DataPureTone(1,SequenceCodeDot(:,trial),1:TimeCodeSound*SampleRateAudio),NumCodedDot,[]),zeros(1,SampleRateAudio*TimeGapSilence)]/MaxAmp,1,AudioRepetition),...
            DataWhiteNoise,...
            ];
        AudioDataRight = [ 
            zeros(1,SampleRateAudio),...
            reshape(DataPureTone(2,5,:)/max(MatrixLeftAmp(5),MatrixRightAmp(5)),1,[]),...
            zeros(1,SampleRateAudio*2),...
            repmat([reshape(DataPureTone(2,SequenceCodeDot(:,trial),1:TimeCodeSound*SampleRateAudio),NumCodedDot,[]),zeros(1,SampleRateAudio*TimeGapSilence)]/MaxAmp,1,AudioRepetition ),...
            DataWhiteNoise,...
            ];
        
        

        PsychPortAudio('Stop',HandlePortAudio);
        %����������������Ƶ���ŵ�Buffer��
        PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
        
        %����
        PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
        
%         %���ڱ�ǣ�Trial��ʼ
%         lptwrite(LPTAddress,trial);


        %����
        for frame =1:round(1*FramePerSecond)
            
            Screen('DrawingFinished', PointerWindow);
            
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
    
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
        
%         %ÿ�δ����Ǻ���Ҫ���½���������
%         lptwrite(LPTAddress,0);
              


        %���Ųο���
        for frame =1:round(1*FramePerSecond)
            
            DrawFormattedText(PointerWindow,MessageRefSound,'center', 'center', ColorFont);
            Screen('DrawingFinished', PointerWindow);
            
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
    
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
        
        
        %����
        for frame =1:round(2*FramePerSecond)
            Screen('DrawingFinished', PointerWindow);
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
    
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
        
        
        %�����������ֽ׶�
        for dot = 1:NumCodedDot
            
            for frame=1:round(TimeCodeSound*FramePerSecond)

                %���Ʒ����Բ��
                Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodeDot(1:dot,trial)),ceil(SizeDot));
                
                if dot > 1
                    XLine = reshape(repmat(XSquareCenter((SequenceCodeDot(1:dot,trial))),2,1),1,[]);
                    
                    YLine = reshape(repmat(YSquareCenter((SequenceCodeDot(1:dot,trial))),2,1),1,[]);
                    
                    
                    if dot ~= NumCodedDot
                        
                        Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
                        
                    else
                        %����������һ�����飬���貹��һ���ɳ�ʼ�㵽�յ������
                        Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
                        
                    end
                    
                end
                
                Screen('DrawingFinished', PointerWindow);

                [IsKeyDown,~,KeyCode] = KbCheck;
                if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                     %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                     lptwrite(LPTAddress,253);
%                     WaitSecs(0.01);
%                     %ÿ�δ����Ǻ���Ҫ���½���������
%                     lptwrite(LPTAddress,0);
%                     WaitSecs(0.01);
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
        
        for frame=1:round((AudioRepetition*TimeGapSilence+(AudioRepetition-1)*TimeCodeSound*NumCodedDot)*FramePerSecond)
            
            %���Ʒ����Բ��
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            Screen('FillOval', PointerWindow,ColorDot,RectDot(:,SequenceCodeDot(:,trial)),ceil(SizeDot));
            if NumCodedDot > 1
            Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
            end
            Screen('DrawingFinished', PointerWindow);
            
            [IsKeyDown,~,KeyCode] = KbCheck;
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                  %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
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
        
  
       %%
        %���Լ�¼�𰸣�Trial֮�����Ϣʱ�䣩
        for frame = 1:round(TimeWhiteNoise*FramePerSecond)
            
            DrawFormattedText(PointerWindow,MessageWhiteNoise2,'center', 'center', ColorFont);
            Screen('DrawingFinished', PointerWindow);
            
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                
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
        
        
        %����
        for frame =1:round(1*FramePerSecond)
            Screen('DrawingFinished', PointerWindow);
            if IsKeyDown && KeyCode(KbName('ESCAPE'))
%                 %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%                 lptwrite(LPTAddress,253);
%                 WaitSecs(0.01);
%                 %ÿ�δ����Ǻ���Ҫ���½���������
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
    
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
%     lptwrite(LPTAddress,254);


    
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        if frame == 2
%             lptwrite(LPTAddress,0);
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %ɨ����̣����Esc�����������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
%             %���ڱ�ǣ�ʵ�鱻��;����ESC����ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
%             %ÿ�δ����Ǻ���Ҫ���½���������
%             lptwrite(LPTAddress,0);
%             WaitSecs(0.01);
            
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
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'A',num2str(NumCodedDot)];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %��¼�ļ���
    RecordFile = [RecordPath,filesep,DateString,'.mat'];

    %�洢�ı�������NumCodedDot,NumTrial,SequenceCodeDot
    save(RecordFile,'NumCodedDot','NumTrial','SequenceCodeDot','SubjectAnswer');


  
    
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




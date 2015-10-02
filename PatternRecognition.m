%���뷽ʽBͼ����֪����
%�������
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
% ListenChar(2);
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc�����������ҷ�������Դ���KbCheck��
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow'),KbName('space')]);

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
    
    %��ȡ���õ���Ļ��ʾ���ȼ�����
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %����PatternRecognitionParameterSetting.m������Ӧ����
    PatternRecognitionParameterSetting;
    
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
    
    
    %���������ĵ��X�����Y�������ƫ��ʹ����������Ļ���Ĳ�ת��һά����
    MatrixXSquareCenter =  round(MatrixXSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenX/2);
    MatrixYSquareCenter =  round(MatrixYSquareCenter.*(SizeSquare+GapWidth)+ SizeScreenY/2);
    
    SequenceXSquareCenter = reshape(MatrixXSquareCenter',1,NumSquare);
    SequenceYSquareCenter = reshape(MatrixYSquareCenter',1,NumSquare);
    
    
    %��׼����
    RectBaseSquareFrame = [0,0,round(3*SizeSquare+(3+1)*GapWidth),round(3*SizeSquare+(3+1)*GapWidth)];
    
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
    
    %%
    %��ʼ
   
    
    %�״ε��ú�ʱ�ϳ��ĺ���
    KbCheck;
    KbWait([],1);
   
    
    
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
    
    %����ʱ��ʾ��
    AudioDataLeft = reshape(DataPureTone(1,5,1:round(SampleRateAudio)),1,[]);
    AudioDataRight = reshape(DataPureTone(2,5,1:round(SampleRateAudio)),1,[]);
   
    %��һ��
    
    MaxAmp = max([MatrixLeftAmp(5), MatrixRightAmp(5)]);
    
    AudioDataLeft =  AudioDataLeft/MaxAmp;
    AudioDataRight =  AudioDataRight/MaxAmp;

    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight]);
                                                 
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, 3, AudioStartTime, WaitUntilDeviceStart);
    

    for frame =1:round(TimeCountdown*FramePerSecond)

       
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
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
    

    PsychPortAudio('Stop', HandlePortAudio);
    
    %���ڱ��1��ʾʵ�鿪ʼ
    lptwrite(LPTWrite,1);
    WaitSecs(0.01);
    lptwrite(LPTWrite,0);
    WaitSecs(0.01);

    
    for trial = 1:NumTrial
        
        pattern = randi([1,NumPattern]);
        
        PosCursor = zeros (1,MaxNumStep);
        PosCursor(1) = 1;
        NumStep =1 ;
        
        TimeStart = GetSecs;
        
        while GetSecs <= TimeStart + TimeMaxPerPattern
 
            XYCursor(1) =  mod((PosCursor(NumStep)-1),NumSquarePerRow)+1;
            XYCursor(2) =  fix((PosCursor(NumStep)-1)/NumSquarePerRow)+1;
            
            horizon = repmat(XYCursor(1)-1:XYCursor(1)+1,1,3);
            vertical = reshape(repmat((XYCursor(2)-2:XYCursor(2))*NumSquarePerRow,3,1),1,[]);

            SequenceFrameDot =   horizon + vertical;
            
            SequenceFrameDot(SequenceFrameDot<0)=[];
            
            InterSectionDot = intersect(SequencePatternDot{pattern},SequenceFrameDot);
            
            DiffSectionDot = setdiff(SequencePatternDot{pattern},SequenceFrameDot);
            
            if  any(InterSectionDot)
                IndexInterSectionDot = false(1,NumSquare);
                IndexInterSectionDot(InterSectionDot) = true;
                IndexInterSectionDot = IndexInterSectionDot(SequenceFrameDot);
       
            %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
            AudioDataLeft = reshape(DataPureTone(1,IndexInterSectionDot,1:round(TimeCodedSound*SampleRateAudio)),numel(InterSectionDot),[]);
            %���
            AudioDataLeft = sum(AudioDataLeft,1);
            
            AudioDataRight = reshape(DataPureTone(2,IndexInterSectionDot,1:round(TimeCodedSound*SampleRateAudio)),numel(InterSectionDot),[]);
            AudioDataRight = sum(AudioDataRight,1);
            
            %��һ��
            AudioData = reshape(mapminmax(AudioDataLeft(:),AudioDataRight(:)),2,[]);
            AudioDataLeft = AudioData(1,:);
            AudioDataRight = AudioData(2,:);

            
            PsychPortAudio('Stop', HandlePortAudio);
            
            %������������Ƶ���ŵ�Buffer��
            PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft,zeros(1,round(TimeGapSilence*SampleRateAudio));AudioDataRight,zeros(1,round(TimeGapSilence*SampleRateAudio))]);
            
            %���Ű�����
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            end
            
            RectSquareFrame = CenterRectOnPointd(RectBaseSquareFrame,SequenceXSquareCenter(PosCursor(NumStep)),SequenceYSquareCenter(PosCursor(NumStep)));
            Screen('FillRect', PointerWindow,ColorSquareFrame,RectSquareFrame);
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            
            if any(DiffSectionDot)
            Screen('FillOval', PointerWindow,ColorDiffDot,RectDot(:,DiffSectionDot),ceil(SizeDot));
            end
            if any(InterSectionDot)
            Screen('FillOval', PointerWindow,ColorInterDot,RectDot(:,InterSectionDot),ceil(SizeDot));
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            vbl = Screen('Flip', PointerWindow);
            
            
            
            
            %�ȴ����������Esc��������
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            lptWrite(LPTAddress,mod(NumStep-1,254)+2);
            
            %�ȴ������ɿ�
            KbWait([],1);
            
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE')) &&  ~KeyCode(KbName('space'))
                NumStep = NumStep +1;
                if KeyCode(KbName('LeftArrow'))
                    TempXYCursor = XYCursor+[-1,0];
                elseif KeyCode(KbName('RightArrow'))
                    TempXYCursor = XYCursor+[1,0];
                elseif KeyCode(KbName('UpArrow'))
                    TempXYCursor = XYCursor+[0,-1];
                elseif KeyCode(KbName('DownArrow'))
                    TempXYCursor = XYCursor+[0,1];
                end
        
                
            else
                if KeyCode(KbName('space'))
                    break;
                else

                    PsychPortAudio('Close');

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

            

            %����곬���˱߽�
            if any(TempXYCursor<1) || any ( TempXYCursor>NumSquarePerRow)
                
                PosCursor(NumStep)=PosCursor(NumStep-1);
                
                %��֮ǰ������HandleOutBuffer���������������Ƶ���ŵ�Buffer��
                PsychPortAudio('Stop', HandlePortAudio);
                
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                %��������
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                PosCursor(NumStep)=TempXYCursor(1)+NumSquarePerRow*(TempXYCursor(2)-1);
                
                %�����ƶ�����
                PsychPortAudio('Stop', HandlePortAudio);
                %��֮ǰ������HandleRollBuffer�������������������Ƶ���ŵ�Buffer��
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);
                
                %��������
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                WaitSecs(numel(AudioDataRoll)/SampleRateAudio);
                
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

    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
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
        
        vbl = Screen('Flip', PointerWindow);
        
    end
    
    if exist('HandlePortAudio','var')
        
        %�ر�PortAudio����
        PsychPortAudio('Stop', HandlePortAudio);
        PsychPortAudio('Close');
        
        %clear HandlePortAudio ;
        
    end
    
    %�ָ���Ļ��ʾ���ȼ�
    Priority(0);
    %�ر����д��ڶ���
    sca;
    
    %�ָ������趨
    ListenChar(0);
    RestrictKeysForKbCheck([]);

    %�������ִ�г�����ִ���������
catch Error
    
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
    
    
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);
    
end    

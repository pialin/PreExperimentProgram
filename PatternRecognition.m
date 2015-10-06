%���뷽ʽBͼ��̽������
%���������
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


SubjectName = inputdlg('Subject Name:','����������������',[1,42],{'ABC'},InputdlgOptions);
if isempty(SubjectName)
    return;
end

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
%����KbCheck��Ӧ�İ�����Χ��ֻ��Esc�����������ҷ�����Ϳո�����Դ���KbCheck��
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

%%
%try catch��䱣֤�ڳ���ִ�й����г�����Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
try
    
    %����һ�����ڶ��󣬷��ض���ָ��PointerWindow
    PointerWindow= PsychImaging('OpenWindow', ScreenNumber, black);
    
    %%
    %���ڶ�������Ļ�ȡ������
    
    %��ȡÿ��֡ˢ��֮���ʱ����
    TimePerFlip = Screen('GetFlipInterval', PointerWindow);
    %����ÿ��ˢ�µ�֡��
    FramePerSecond = 1/TimePerFlip;
    
    %��ȡ���õ���Ļ��ʾ���ȼ�����
    LevelTopPriority = MaxPriority(PointerWindow,'GetSecs','WaitSecs','KbCheck','KbWait','sound');
    
    %��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
    [SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);
    
    %����PatternRecognition_ParameterSetting.m������Ӧ����
    PatternRecognition_ParameterSetting;
    
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
    
    %�ȴ��������������ټ���ִ�к�������
    WaitUntilDeviceStart = 1;
    
    %��Ƶ�طŴ����������ط�ֱ��ִ�� PsychPortAudio('Stop',...)
    AudioRepetition = 0;
    
    
    % ����PortAudio���󣬶�Ӧ�Ĳ�������
    % (1) [] ,����Ĭ�ϵ�����
    % (2) 1 ,�������������ţ�����������¼�ƣ�
    % (3) 1 , Ĭ���ӳ�ģʽ
    % (4) SampleRateAudio,��Ƶ������
    % (5) 2 ,���������Ϊ2
    HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);
    
    
    %�½�Buffer���ڴ����ʾ������
    %������ʾ��
    HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
    %�����߽���ʾ��
    HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
    %����ͼ����ʾ��
    HandlePassBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataPass;AudioDataPass]);
    %���ʵ����ʾ��
    HandleFinishBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);
    
    
    
    %%
    %��ʼ
    
    %�״ε��ú�ʱ�ϳ��ĺ���
    KbCheck;
    KbWait([],1);
    
    %��ʾ���ȼ�����
    Priority(LevelTopPriority);
    %���е�һ��֡ˢ�»�ȡ��׼ʱ��
    vbl = Screen('Flip', PointerWindow);
    
    %%
    
    %     %���ڱ��251��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
    %     lptwrite(LPTAddress,251);
    %     %������״̬����һ��ʱ�䣨ʱ��������NeuralScan�Ĳ���ʱ������
    %     WaitSecs(0.01);
    %     %ÿ�δ����Ǻ���Ҫ���½���������
    %     lptwrite(LPTAddress,0);
    %     WaitSecs(0.01);
    
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
%             %���������0
%             lptwrite(LPTAddress,0);
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
    
    PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight]);
    
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, 3, AudioStartTime, WaitUntilDeviceStart);
    
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
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
            
%             %���������0
%             lptwrite(LPTAddress,0);
            
            %��ֹ����
            return;
        end
        
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    
    %%
    %ͼ��̽����ʼ
    
    %���ѡȡNumTrial��ͼ�������ܻ�����ظ���
    IndexPattern = randi([1,NumPattern],1,NumTrial);
    
    %PosCursorΪ���ڼ�¼����ƶ��Ĺ켣����������ÿһ�д���ÿ���ƶ������λ�ã���1-81��ʾ����9*9�����ÿ��λ�ã�
    PosCursor = zeros (1,MaxNumStep,NumTrial);
    
    %ѭ��NumTrial�Σ�������NumTrial��ͼ����̽��
    for trial = 1:NumTrial
        
        %��ʼλ��λ��1.����һ�е�һ�еķ���
        PosCursor(1,1,trial) = 1;
        %NumStep��¼��ǰ����
        NumStep =1 ;
        
        %��ȡ��ǰʱ����Ϊ��ʼʱ��
        TimeStart = GetSecs;
        
        %��̽��ʱ�䲻����TimeMaxPerPattern��ÿ��ͼ�������̽��ʱ����ʱ������������������Ͱ����Ĳ���
        while GetSecs <= TimeStart + TimeMaxPerPattern
            
            %�����λ�û�����������������ں�������
            %����X
            XYCursor(1) =  mod((PosCursor(1,NumStep,trial)-1),NumSquarePerRow)+1;
            %����Y
            XYCursor(2) =  fix((PosCursor(1,NumStep,trial)-1)/NumSquarePerRow)+1;
            
            %����Ź���ľŸ����λ��
            horizon = repmat(XYCursor(1)-1:XYCursor(1)+1,1,3);
            vertical = reshape(repmat((XYCursor(2)-2:XYCursor(2))*NumSquarePerRow,3,1),1,[]);
            
            SequenceFrameDot =   horizon + vertical;
            
            %��9*9������ĵ�ȥ��
            SequenceFrameDot(SequenceFrameDot<0)=[];
            
            %����Ź����ͼ�����غϵ�
            InterSectionDot = intersect(SequencePatternDot{IndexPattern(trial)},SequenceFrameDot);
            
            %�����ȥ�غϵ���ͼ����ʣ���
            DiffSectionDot = setdiff(SequencePatternDot{IndexPattern(trial)},SequenceFrameDot);
            
            %����Ź����ͼ�������غϵ�
            if  any(InterSectionDot)
                %��ȡ����������
                [~,IndexCodedDot,~] = intersect(SequenceFrameDot,InterSectionDot);
                
                %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
                AudioDataLeft = reshape(DataPureTone(1,IndexCodedDot,1:round(TimeCodedSound*SampleRateAudio)),numel(IndexCodedDot),[]);
                AudioDataRight = reshape(DataPureTone(2,IndexCodedDot,1:round(TimeCodedSound*SampleRateAudio)),numel(IndexCodedDot),[]);
                
                %���
                AudioDataLeft = sum(AudioDataLeft,1);
                AudioDataRight = sum(AudioDataRight,1);
                
                %��һ��
                AudioData = reshape(mapminmax([AudioDataLeft(:),AudioDataRight(:)]),2,[]);
                
                PsychPortAudio('Stop', HandlePortAudio);
                
                %����������������Ƶ���ŵ�Buffer��
                PsychPortAudio('FillBuffer', HandlePortAudio,[AudioData,zeros(2,round(TimeGapSilence*SampleRateAudio))]);
                
                %��������
                PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
                
            end
            
            %         %������ڴ������������ʼ��ʵ������Ϊ��ǰtrial+200
            %         lptwrite(LPTAddress,200+mod(trial,40)+1);
            %         WaitSecs(0.01);
            %         lptwrite(LPTAddress,0);
            %         WaitSecs(0.01);
            
            %���㲢�����Թ��Ϊ���ĵľŹ���
            RectSquareFrame = CenterRectOnPointd(RectBaseSquareFrame,SequenceXSquareCenter(PosCursor(1,NumStep,trial)),SequenceYSquareCenter(PosCursor(1,NumStep,trial)));
            
            Screen('FillRect', PointerWindow,ColorSquareFrame,RectSquareFrame);
            %����9*9�ķ�����
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            
            %�����ȥ�غϵ���ͼ������ʣ��㣬�����ʣ���
            if any(DiffSectionDot)
                Screen('FillOval', PointerWindow,ColorDiffDot,RectDot(:,DiffSectionDot),ceil(SizeDot));
            end
            %����Ź����ͼ�����غϵ�������غϵ�
            if any(InterSectionDot)
                Screen('FillOval', PointerWindow,ColorInterDot,RectDot(:,InterSectionDot),ceil(SizeDot));
            end
            
            Screen('DrawingFinished', PointerWindow);
            
            vbl = Screen('Flip', PointerWindow);
            
            %�ȴ��������Esc����ո��������
            %ÿ���ƶ���ȴ�ʱ��ΪTimeWaitPerMove
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            if any(KeyCode(KbName('LeftArrow'):KbName('DownArrow')))
                %������·�������򲢿������Ǽ�¼���°����Ĵ���
                %                 lptwrite(LPTAddress,mod(NumStep-1,200)+1);
                %                 WaitSecs(0.01);
                %                 lptwrite(LPTAddress,0);
                %                 WaitSecs(0.01);
                
            elseif KeyCode(KbName('ESCAPE'))
                %������ڱ��252��ʾʵ�鱻��Ϊ����Esc������ֹ
                %                 lptwrite(LPTAddress,252);
                %                 WaitSecs(0.01);
                %                 lptwrite(LPTAddress,0);
                %                 WaitSecs(0.01);
                
            elseif ~KeyCode(KbName('space'))
                %������ڱ��253��ʾʵ����ʱ��û�а�����������ֹ
                %                 lptwrite(LPTAddress,253);
                %                 WaitSecs(0.01);
                %                 lptwrite(LPTAddress,0);
                %                 WaitSecs(0.01);
                
                
            end
            
            
            %�ȴ������ɿ�
            KbWait([],1);
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE')) &&  ~KeyCode(KbName('space'))
                %��������ֵ��һ
                NumStep = NumStep +1;
                %���ݰ��µķ���������µĹ��λ�ã���ʱ����TempXYCursor��
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
%             %���������0
%             lptwrite(LPTAddress,0);
                    
                    %��ֹ����
                    return;
                    
                end
            end
            
            
            %����곬���˱߽�
            if any(TempXYCursor<1) || any ( TempXYCursor>NumSquarePerRow)
                
                %��¼�Ĺ��λ�ò����ı�
                PosCursor(1,NumStep,trial)=PosCursor(1,NumStep-1,trial);
                
                
                PsychPortAudio('Stop', HandlePortAudio);
                %��֮ǰ������HandleOutBuffer���������������Ƶ���ŵ�Buffer��
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                %���ų�����ʾ��
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                %�ȴ���ʾ���������
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                %��¼�ƶ������λ��
                PosCursor(1,NumStep,trial)=TempXYCursor(1)+NumSquarePerRow*(TempXYCursor(2)-1);
                
                %�����ƶ�����
                PsychPortAudio('Stop', HandlePortAudio);
                
                %��֮ǰ������HandleRollBuffer�������������������Ƶ���ŵ�Buffer��
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);
                
                %��������
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                %�ȴ������������
                WaitSecs(numel(AudioDataRoll)/SampleRateAudio);
                
            end
        end
        
        if GetSecs>  TimeStart + TimeMaxPerPattern
            %����������250��ʾ��̽��ʱ������Զ�������һͼ��
            %             lptwrite(LPTAddress,250);
            %             WaitSecs(0.01);
            %             lptwrite(LPTAddress,0);
            %             WaitSecs(0.01);
            
            %����������ʾ��
            PsychPortAudio('Stop', HandlePortAudio);
            
            %��֮ǰ������HandleRollBuffer�������������������Ƶ���ŵ�Buffer��
            PsychPortAudio('FillBuffer', HandlePortAudio,HandlePassBuffer);
            
            %��������
            PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
            %�ȴ������������
            WaitSecs(numel(AudioDataPass)/SampleRateAudio);
        end
        
    end
    
    %%
    %���ڱ��254��ʾʵ����������
    %     lptwrite(LPTAddress,254);
    
    %���������ʾ��
    PsychPortAudio('Stop', HandlePortAudio);
    
    %��֮ǰ������HandleRollBuffer�������������������Ƶ���ŵ�Buffer��
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleFinishBuffer);
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    %ʵ�������ʾ
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        if frame == 2
            
            %     lptwrite(LPTAddress,0);
            
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %ɨ����̣����Esc�����������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
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
            
%             %���������0
%             lptwrite(LPTAddress,0);
            
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
    
%             %���������0
%             lptwrite(LPTAddress,0);
    
    %%
    %�洢��¼�ļ�
    %��¼�ļ�·��
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'PatternRecognition'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %��¼�ļ���
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %�洢�ı�������NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumTrial','IndexPattern','PosCursor','SequencePatternDot');
    
    %%
    %���try ��catch֮������ִ�г�����ִ���������
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
    
%     %�����ڷ���һ��0
%     lptwrite(LPTAddress,0);
    
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);
    
   
    
end

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
RestrictKeysForKbCheck([KbName('ESCAPE'),KbName('LeftArrow'):KbName('DownArrow')]);

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
    
    %����Snake_ParameterSetting.m������Ӧ����
    Snake_ParameterSetting;
    
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
    HandlePassBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataPass;AudioDataPass]);
    HandleHitBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll,AudioDataHit;AudioDataRoll,AudioDataHit]);
    HandleFinishBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);
    
    %%
    %��ʼ

    %PosCursor���ڴ洢�Ĺ��λ�ñ仯�����ÿһ�зֱ����һ��λ�õı䶯����һ�д������ڷ������ĵڼ��У��ڶ��д������ڷ������ĵڼ���
    PosCursor = zeros(2,MaxNumStep*NumTrial);
    %������ʼ���λ�ã������е����м����ĵ㴦
    PosCursor(:,1) = [5,5];
    PosTarget = zeros(2,NumTrial);
    
    NumStep = 1;
    
    
    %�״ε��ú�ʱ�ϳ��ĺ���
    KbCheck;
    KbWait([],1);
    
    
    %��ʾ���ȼ�����
    Priority(LevelTopPriority);
    %���е�һ��֡ˢ�»�ȡ��׼ʱ��
    vbl = Screen('Flip', PointerWindow);
    
    %�ȴ��׶�
%         %���ڱ��251��ʾʵ�鿪ʼ
%         lptwrite(LPTAddress,251);

    
    %ʱ��Ϊ׼��ʱ����ȥ����ʱʱ��
    for frame =1:round((TimePrepare-TimeCountdown)*FramePerSecond)
        
        if frame == 2
%             %ÿ�δ����Ǻ���Ҫ���½���������
%             lptwrite(LPTAddress,0);
        
        end
        %������ʾ��
        DrawFormattedText(PointerWindow,MessagePrepare,'center', 'center', ColorFont);
        %��ʾ�������������ѻ������
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
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
    
    
    PsychPortAudio('FillBuffer', HandlePortAudio,repmat([zeros(1,0.7*SampleRateAudio),AudioDataLeft;zeros(1,0.7*SampleRateAudio),AudioDataRight],1,3));
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    for frame =1:round(TimeCountdown*FramePerSecond)
        
        DrawFormattedText(PointerWindow,MessageCountdown,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %��ȡ�������룬��Esc���������������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
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
%             %���������0
%             lptwrite(LPTAddress,0);
            
            %��ֹ����
            return;
        end
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
    end
    
    
    PsychPortAudio('Stop', HandlePortAudio);
    
    
    TempTrial = 0;
    
    
    %%
    %�����������һ��Ŀ�����Ե�ǰĿ������ƫ��KeyDistance(1)������ƫ��KeyDistance(2)
    for trial = 1:NumTrial
        
        KeyDistance = zeros(2,1);
        PosNextTarget = zeros(2,1);
        
        %���ƺ��������ƫ��֮��>=2,��ƫ��֮��ĵ㲻����9*9�ľ�������
        while sum(abs(KeyDistance))<=2 || any(PosNextTarget>NumSquarePerRow) || any(PosNextTarget<1)
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
    %��ʼ
    
    for trial =1:NumTrial
        
        %���Ʒ����Բ��
        IndexTarget = PosTarget(1,trial)+NumSquarePerRow*(PosTarget(2,trial)-1);
        IndexCursor = PosCursor(1,1:NumStep)+NumSquarePerRow*(PosCursor(2,1:NumStep)-1);
        Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
        Screen('FillOval', PointerWindow,ColorDot,RectDot(:,IndexCursor),ceil(SizeDot));
        
        %��������
        if NumStep > 1
            XLine = reshape(repmat(SequenceXSquareCenter(IndexCursor),2,1),1,[]);
            
            YLine = reshape(repmat(SequenceYSquareCenter(IndexCursor),2,1),1,[]);
            
            Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
            
            
        end
        Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,IndexTarget),ceil(SizeDot));
        Screen('DrawingFinished', PointerWindow);
        
        vbl = Screen('Flip', PointerWindow);
        
        
        FlagHitTarget = false;
        
        while FlagHitTarget == false 
            
            KeyDistance = PosTarget(:,trial)-PosCursor(:,NumStep);
            
            switch [num2str(sign(KeyDistance(1))),num2str(sign(KeyDistance(2)))]
                
                case '01'
                    CodedDot = 8;
                case '10'
                    CodedDot = 6;
                case '0-1'
                    CodedDot = 2;
                case '-10'
                    CodedDot = 4;
                    
                case '11'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=6;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=9;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=8;
                    end
                case '-11'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=4;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=7;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=8;
                    end
                    
                case '-1-1'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >= 0 && DirectionAngle < pi/8
                        CodedDot=4;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=1;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=2;
                    end
                case '1-1'
                    DirectionAngle = atan(abs(KeyDistance(2)/KeyDistance(1)));
                    if DirectionAngle >=0 && DirectionAngle <pi/8
                        CodedDot=6;
                    elseif DirectionAngle >= pi/8  && DirectionAngle < pi/8*3
                        CodedDot=3;
                    elseif DirectionAngle >= pi/8*3  && DirectionAngle < pi/2
                        CodedDot=2;
                    end
            end
            
            
            
           %%
            %��������
            
            %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
            AudioDataLeft = reshape(DataPureTone(1,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
            
            AudioDataRight = reshape(DataPureTone(2,CodedDot,1:TimeCodedSound*SampleRateAudio),1,[]);
            
            %��һ��
            MaxAmp = max([MatrixLeftAmp(CodedDot), MatrixRightAmp(CodedDot)]);
            AudioDataRight =  AudioDataRight/MaxAmp;
            AudioDataLeft =  AudioDataLeft/MaxAmp;
            
            %������������
            
            EuclidDistance = sqrt(sum(KeyDistance.^2));
            
            if EuclidDistance > sqrt(2)*RangeNextTarget
                AudioVolume = MinAudioVolume;
                
            else
                VolumeSlope = (1 - MinAudioVolume)/(1-sqrt(2)*RangeNextTarget);
                AudioVolume = (EuclidDistance - sqrt(2)* RangeNextTarget)*VolumeSlope + MinAudioVolume;
                
            end
            
            PsychPortAudio('Stop', HandlePortAudio);
            
            PsychPortAudio('Volume', HandlePortAudio, AudioVolume);
            
            
            
            %������������������Buffer
            PsychPortAudio('FillBuffer', HandlePortAudio,[zeros(1,TimeGapSilence*SampleRateAudio),AudioDataLeft;
                zeros(1,TimeGapSilence*SampleRateAudio),AudioDataRight]);
            
            %��������
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            %���ڱ�ǣ�����������ʼ�����ʵ������Ϊtrial+200
            if trial ~=  TempTrial    
%                 lptwrite(LPTAddress,200+mod(trial-1,40)+1);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
            end
            TempTrial = trial;
            
            %�ȴ����������Esc��������
            
            [~,KeyCode,~] = KbWait([],0,GetSecs+TimeWaitPerMove);
            
            
            
            %�ȴ������ɿ�
            KbWait([],1);
            
            if any(KeyCode) && ~KeyCode(KbName('ESCAPE'))
%                 %������·�������򲢿������Ǽ�¼���°����Ĵ���
%                 lptwrite(LPTAddress,mod(NumStep-1,200)+1);
%                 WaitSecs(0.01);
%                 lptwrite(LPTAddress,0);
%                 WaitSecs(0.01);
                NumStep = NumStep +1;
                if KeyCode(KbName('LeftArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[-1;0];
                elseif KeyCode(KbName('RightArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[1;0];
                elseif KeyCode(KbName('UpArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[0;-1];
                elseif KeyCode(KbName('DownArrow'))
                    TempPosCursor = PosCursor(:,NumStep-1)+[0;1];
                end
                
            else
                if KeyCode(KbName('ESCAPE'))
%                     %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
%                     lptwrite(LPTAddress,253);
%                     WaitSecs(0.01);
%                     lptwrite(LPTAddress,0);
%                     WaitSecs(0.01);
                else
                    
%                     %������ڱ��252��ʾʵ����ʱ��û�а�����������ֹ
%                     lptwrite(LPTAddress,252);
%                     WaitSecs(0.01);
%                     lptwrite(LPTAddress,0);
%                     WaitSecs(0.01);
                    
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
%                 %���������0
%                 lptwrite(LPTAddress,0);
                %��ֹ����
                return;
                
                
            end
            
            PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
            
            %����곬���˱߽�
            if any(TempPosCursor>NumSquarePerRow) || any(TempPosCursor<1)
                
                PosCursor(:,NumStep)=PosCursor(:,NumStep-1);
                
                %��֮ǰ������HandleOutBuffer���������������Ƶ���ŵ�Buffer��
                PsychPortAudio('Stop', HandlePortAudio);
                
                PsychPortAudio('FillBuffer', HandlePortAudio,HandleOutBuffer);
                
                
                %��������
                PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                
                
                WaitSecs(numel(AudioDataOut)/SampleRateAudio);
                
            else
                
                PosCursor(:,NumStep)=TempPosCursor;
                
                %���Ʒ����Բ��
                
                IndexTarget = PosTarget(1,trial)+NumSquarePerRow*(PosTarget(2,trial)-1);
                IndexCursor = PosCursor(1,1:NumStep)+NumSquarePerRow*(PosCursor(2,1:NumStep)-1);
                
                Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                Screen('FillOval', PointerWindow,ColorDot,RectDot(:,IndexCursor),ceil(SizeDot));
                
                
                XLine = reshape(repmat(SequenceXSquareCenter(IndexCursor),2,1),1,[]);
                
                YLine = reshape(repmat(SequenceYSquareCenter(IndexCursor),2,1),1,[]);
                
                Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
                Screen('FillOval', PointerWindow,ColorTarget,RectDot(:,IndexTarget),ceil(SizeDot));
                Screen('DrawingFinished', PointerWindow);
                
                vbl = Screen('Flip', PointerWindow);
                
                
                %����굽��Ŀ���
                if PosCursor(:,NumStep) == PosTarget(:,trial)
                    
                    FlagHitTarget = true;
                    %�����ƶ�����������
                    %��֮ǰ������HandleHitBuffer�������������������Ƶ���ŵ�Buffer��
                    PsychPortAudio('Stop', HandlePortAudio);
                    
                    PsychPortAudio('FillBuffer', HandlePortAudio,HandleHitBuffer);
                    
                    %��������
                    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
                    
                    WaitSecs((numel(AudioDataRoll)+numel(AudioDataHit))/SampleRateAudio);
                    %����껹δ����Ŀ���
                else
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
        
        TimeStart = GetSecs;
        if GetSecs>  TimeStart + TimeMaxPerTrial
%             %����������250��ʾ��̽��ʱ������Զ�������һĿ���
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
    
    
%     %���ڱ��254��ʾʵ����������
%     lptwrite(LPTAddress,254);

    
    PsychPortAudio('Volume', HandlePortAudio, VolumeHint);
    %��֮ǰ������HandleFinishBuffer���������������Ƶ���ŵ�Buffer��
    PsychPortAudio('Stop', HandlePortAudio);
    
    PsychPortAudio('FillBuffer', HandlePortAudio,HandleFinishBuffer);
    
    
    
    %��������
    PsychPortAudio('Start', HandlePortAudio, 1, AudioStartTime, WaitUntilDeviceStart);
    
    %%
    %ʵ�������ʾ
    
    for frame = 1:round(TimeMessageFinish * FramePerSecond)
        
        if frame == 2
            
%             lptwrite(LPTAddress,0);
            
        end
        
        DrawFormattedText(PointerWindow,MessageFinish,'center', 'center', ColorFont);
        Screen('DrawingFinished', PointerWindow);
        
        %ɨ����̣����Esc�����������˳�����
        [IsKeyDown,~,KeyCode] = KbCheck;
        if IsKeyDown && KeyCode(KbName('ESCAPE'))
            
%             %������ڱ��253��ʾʵ�鱻��Ϊ����Esc������ֹ
%             lptwrite(LPTAddress,253);
%             WaitSecs(0.01);
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
%     %���������0
%     lptwrite(LPTAddress,0);
    
    %%
    %�洢��¼�ļ�
    %��¼�ļ�·��
    RecordPath = ['.',filesep,'RecordFiles',filesep,SubjectName{1},filesep,'Snake'];
    if ~exist(RecordPath,'dir')
        mkdir(RecordPath);
    end
    %��¼�ļ���
    RecordFile = [RecordPath,filesep,datestr(now,'yyyymmdd_HH-MM-SS'),'.mat'];
    %�洢�ı�������NumCodedDot,NumTrial,SequenceCodedDot
    save(RecordFile,'NumTrial','PosTarget','NumStep','PosCursor');
    
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
%     %���������0
%     lptwrite(LPTAddress,0);
    
    
    %�����������ǰ��Ĵ�����ʾ��Ϣ
    rethrow(Error);
    
    
end
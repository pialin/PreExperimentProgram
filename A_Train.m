%�˳���ΪA���뷽ʽ��ѵ������
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


close all;
clear;
sca;

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
red = [white,black,black];
green = [black,white,black];
blue = [black,black,white];
gray = white/2;

%try catch��䱣֤�ڳ���ִ�й����г�����Լ�ʱ�رմ�����window��PortAudio������ȷ�˳�����
try

%����һ�����ڶ��󣬷��ض���ָ��PointerWindow
[PointerWindow,~] = PsychImaging('OpenWindow', ScreenNumber, black);

%��ȡÿ��֡ˢ��֮���ʱ����
TimePerFlip = Screen('GetFlipInterval', PointerWindow);
%����ÿ��ˢ�µ�֡��
FramePerSecond =1/TimePerFlip;
%��ȡ���õ����ȼ�����
LevelTopPriority = MaxPriority(PointerWindow);
%��ȡ��Ļ�ֱ��� SizeScreenX,SizeScreenY�ֱ�ָ���������ķֱ���
[SizeScreenX, SizeScreenY] = Screen('WindowSize', PointerWindow);

%����ParameterSetting.m������Ӧ����
ParameterSetting;

%����ʹ�С�趨
Screen('TextFont', PointerWindow, NameFont);
Screen('TextSize', PointerWindow ,SizeFont);
%����Alpha-Blending��Ӧ����
Screen('BlendFunction', PointerWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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


%����XY����ֽ����

%�����Ӧ����������������/��λ�ð����ҹ��λ������Ӧ�����ڼ���ѡ�и÷���
%�������Ӧ�������������ڷ���ԭ���Ĵ�С���Ե�
RatioResponseArea = 0.7; 

%x��ֽ����
%�Ȼ�ȡ���з������ĸ��Եĺ�����
XBounderCenter = XSquareCenter(1:NumSquarePerRow);
%�ٸ�����Ӧ�������ת��6��������߽�
XBounder(1:2:2*NumSquarePerRow) = XBounderCenter(1:NumSquarePerRow)- RatioResponseArea*SizeSquare/2;
XBounder(2:2:2*NumSquarePerRow) = XBounderCenter(1:NumSquarePerRow)+ RatioResponseArea*SizeSquare/2;

%y��ֽ����
%�Ȼ�ȡ���з������ĸ��Եĺ�����
YBounderCenter = YSquareCenter(1:NumSquarePerRow:NumSquare);
%�ٸ�����Ӧ�������ת��6��������߽�
YBounder(1:2:2*NumSquarePerRow) = YBounderCenter(1:NumSquarePerRow)- RatioResponseArea*SizeSquare/2;
YBounder(2:2:2*NumSquarePerRow) = YBounderCenter(1:NumSquarePerRow)+ RatioResponseArea*SizeSquare/2;


    

%%
%��Ƶ����

%�������ӳ�ģʽ
EnableSoundLowLatencyMode = 1; 
InitializePsychSound(EnableSoundLowLatencyMode);

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
HandlePortAudio = PsychPortAudio('Open', [], 1, EnableSoundLowLatencyMode,SampleRateAudio, NumAudioChannel);

%������������
PsychPortAudio('Volume', HandlePortAudio, AudioVolume);


%���ȼ�����
Priority(LevelTopPriority);
%���е�һ��֡ˢ�»�ȡ��׼ʱ��
vbl = Screen('Flip', PointerWindow);


%���м���ɨ��
%����ֵ��
%IsIsAnyKeyPressed ��־�Ƿ��а���������
%KeyCodeΪ���У�256����������״̬��0����û�б����£�1����������
[ IsAnyKeyPressed, ~, KeyCode] = KbCheck;
%�������״̬�Ĳ�ѯ��
%����ֵ��
%XMousePos��YMousePos�����������λ�õĺ�������
%PressedMouseButton������갴����״̬���ڴ�Ϊһ��ά�߼�ʸ�����ֱ�������������Ҽ�
%ͬ����,0����û�б����£�1����������
[XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);

while 1
    %���û�а��������»����а������µ��Ȳ���Esc��Ҳ������갴��ʱ��ִ������ѭ��
    while (~IsAnyKeyPressed || (IsAnyKeyPressed && ~KeyCode(KbName('ESCAPE'))))  && ~any(PressedMouseButton)
        
        %���Ʒ���
        Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
        Screen('DrawingFinished', PointerWindow);
        
        vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
        
        %���²�ѯ���ͼ���
        [ IsAnyKeyPressed, ~, KeyCode] = KbCheck;
        [XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);
        
    end
    
    %���Esc�����������Ƴ�����
    if IsAnyKeyPressed &&  KeyCode(KbName('ESCAPE'))
        %ֹͣ���ر�PortAudio����
        if exist('HandlePortAudio','var')
            PsychPortAudio('Stop', HandlePortAudio);
            PsychPortAudio('Close', HandlePortAudio);
            %         clear HandlePortAudio ;
        end
        %�ָ���Ļ��ʾ���ȼ�
        Priority(0);
        %�ر����д��ڶ���
        sca;
        return;
        
    else
        %IndexPressedSquareΪһ�߼�������ά���뷽��������ͬ�������ڼ�¼Ŀǰ��ѡ�еķ���
        %��ʼ״̬Ϊȫ0����û�з���ѡ��
        IndexPressedSquare = false(1,NumSquare);
        %SequencePressedSquareΪһ������ά���뷽��������ͬ����ͬ�����ڼ�¼Ŀǰ��ѡ�еķ���
        %�������ͬʱ����¼�˷��鱻���µ��Ⱥ�˳��
        SequencePressedSquare = zeros(1,NumSquare);
        
        %�����갴��������
        while any(PressedMouseButton)
               
            %��������λ���Լ�ǰ������XY�߽�ȷ�����ѡ�еķ���
            if mod(nnz(XBounder <= XMousePos),2)==1 && mod(nnz(YBounder <= YMousePos),2)==1
                
                MouseSquare = ((nnz(YBounder < YMousePos)-1)/2)*NumSquarePerRow+(nnz(XBounder < XMousePos)+1)/2 ;
                
                %���ѡ�еķ�����ĿС��NumDotLimit���ҷ���֮ǰû�б�ѡ��
                if nnz(IndexPressedSquare) < NumDotLimit && IndexPressedSquare(MouseSquare) == false
                    %����IndexPressedSquare�� SequencePressedSquare
                    IndexPressedSquare(MouseSquare) = true ;         
                    SequencePressedSquare(nnz(IndexPressedSquare)) = MouseSquare;
                    
                end
            end
            
            %���Ʒ���
            Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
            %����з��鱻ѡ���������Ӧ��Բ��
            if nnz(IndexPressedSquare)>0
                Screen('FillOval', PointerWindow,ColorDotUncoded,RectDot(:,IndexPressedSquare),SizeDot+1);
            end
            Screen('DrawingFinished', PointerWindow);
            
            
            [IsAnyKeyPressed,~,KeyCode] = KbCheck;
            if IsAnyKeyPressed &&  KeyCode(KbName('ESCAPE'))
                if exist('HandlePortAudio','var')
                    PsychPortAudio('Stop', HandlePortAudio);
                    PsychPortAudio('Close', HandlePortAudio);
                    clear HandlePortAudio ;
                end
                Priority(0);
                sca;
                return;
                
            end
            
            vbl = Screen('Flip', PointerWindow, vbl + (FrameWait-0.5) * TimePerFlip);
            
            [XMousePos, YMousePos, PressedMouseButton] = GetMouse(PointerWindow);
            
        end
        %����з��鱻ѡ�У����������Ӧ�ı�������
        if nnz(IndexPressedSquare)>0
            
            %���ݱ����������Ӧ����Ƶ���� AudioDataLeft��AudioDataRight�ֱ����������������Ƶ����
            AudioDataLeft = reshape(DataPureTone(1,SequencePressedSquare(1:nnz(IndexPressedSquare)),1:TimeCodedSound*SampleRateAudio),nnz(IndexPressedSquare),[]);
            AudioDataLeft = reshape(AudioDataLeft',1,[]);
            
            
            AudioDataRight = reshape(DataPureTone(2,SequencePressedSquare(1:nnz(IndexPressedSquare)),1:TimeCodedSound*SampleRateAudio),nnz(IndexPressedSquare),[]);
            AudioDataRight = reshape(AudioDataRight',1,[]);
            
            %��һ��
            MaxAmp = max([MatrixLeftAmp(IndexPressedSquare), MatrixRightAmp(IndexPressedSquare)]);
            AudioDataRight =  AudioDataRight/MaxAmp;
            AudioDataLeft =  AudioDataLeft/MaxAmp;
            
            
            %��䵽PortAudio�����Buffer��
            PsychPortAudio('FillBuffer', HandlePortAudio,[AudioDataLeft;AudioDataRight]);
            %��������
            PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
            
            %����������Բ�������
            for dot = 1:nnz(IndexPressedSquare)
                
                for frame = 1:TimeCodedSound*FramePerSecond
                    
                    Screen('FillRect', PointerWindow,ColorSquare,RectSquare);
                    Screen('FillOval', PointerWindow,ColorDotCoded,RectDot(:,SequencePressedSquare(1:dot)),SizeDot+1);
                    
                    if dot <= nnz(IndexPressedSquare)-1
                        Screen('FillOval', PointerWindow,ColorDotUncoded,RectDot(:,SequencePressedSquare(dot+1:nnz(IndexPressedSquare))),SizeDot+1);
                    end
                    
                    %���ѡ�з�����Ŀ����1����Ҫ������Ӧ������
                    if dot > 1
                        XLine = reshape(repmat(XSquareCenter((SequencePressedSquare(1:dot))),2,1),1,[]);
                        
                        YLine = reshape(repmat(YSquareCenter((SequencePressedSquare(1:dot))),2,1),1,[]);
                        
                        
                        if dot ~= nnz(IndexPressedSquare)
                            
                            Screen('DrawLines',PointerWindow,[XLine(2:end-1);YLine(2:end-1)],WidthLine,ColorLine);
                            
                        else
                            %����������һ�����飬���貹��һ���ɳ�ʼ�㵽�յ������
                            Screen('DrawLines',PointerWindow,[XLine(2:end),XLine(1);YLine(2:end),YLine(1)],WidthLine,ColorLine);
                            
                        end
                        
                    end
                    Screen('DrawingFinished', PointerWindow);
                    
                    [IsAnyKeyPressed,~,KeyCode] = KbCheck;
                    if IsAnyKeyPressed && KeyCode(KbName('ESCAPE'))
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
                
            end
        end
    end

end
    

%�������ִ�г�����ִ���������
catch Error
     %�ر�PortAudio����
    if exist('HandlePortAudio','var')
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
    



%�˳������ͼ��̽��ʵ��Ĳ�������
%���������
%Psychtoolbox:3.0.12
%Matlab:R2015a x64
%OS:Windows 8.1 x64





%%
%����ʵ���������
%trial����һ��trial��Ӧһ��ͼ����̽����
NumTrial = 3;



%%
%ʱ���������
%׼��ʱ��(��������ʱʱ������λ����)
TimePrepare = 10; 

%����ʱ��������λ���룩
TimeCountdown = 5.2; 

%ʵ�������ʾʱ������λ���룩
TimeMessageFinish =1;

%������������ʱ��
TimeCodedSound = 1;

%�������ʱ�䣨�����α�������֮�������ʱ������λ���룩
TimeGapSilence = 1;


%%
%��ֵ�趨

%ÿ���ƶ����ȴ�ʱ��������ʱ���Զ��˳�����,��λ���룩
TimeWaitPerMove = 100;

%һ��ͼ����໨�ѵ�ʱ��
TimeMaxPerPattern = 200;

%һ��ͼ�����̽������
MaxNumStep = 500;


%%
%��ʾ����

%��Ļ��ɫ��ȱʡֵΪ��ɫ����ѡ��ɫΪblack��white,red,green,blue,gray,���߿�����
%һ����ά����ֱ��ָ����������ԭɫ����,�ڴ˾�Ϊ������Ԫ�ؾ�ӦΪ0-1֮�����ֵ����ͬ��
ColorBackground = black;

%������ɫ(ȱʡֵΪ��ɫ,��[1,1,1])
ColorSquare = white;
%�ܷ�����
NumSquare=81;


%���ݷ������ÿһ��/�еķ�����Ŀ
NumSquarePerRow = sqrt(NumSquare);

%�����С(��λ������)
%������ָ������Ĭ��ֵ����
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
% GapWidth = 0.1* SizeSquare;

SizeSquareFrame =  SizeScreenY/(NumSquarePerRow+2);
SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;

%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.6��
SizeDot = 0.6* SizeSquare ;

%�Ź���߿����ɫ
ColorSquareFrame = red;


%�Ź����ͼ���غϵ����ɫ
ColorInterDot = red;
%ͼ����Ź���δ�غϵ����ɫ
ColorDiffDot = black;

%��������
NameFont = '΢���ź�';
%�����С
SizeFont = 50;
%������ɫ
ColorFont = white;



%%
%ͼ���������

%ͼ������
NumPattern = 10;

%ÿ��ͼ����Ӧ�ĵ�����
SequencePatternDot=...
    {
%     38:44;
%     14:9:68;
%     [38:44,14:9:32,50:9:68];
%     [38:44,14:9:32];
%     [38:44,50:9:68];
%     [38:40,14:9:68];
%     [42:44,14:9:68];
%     [38:41,14:9:32];
%     [41:44,14:9:32];
%     [38:41,50:9:68];
%     [41:44,50:9:68];

    14:9:68;%1
    [12:16,25,34,39:43,48,57,66:70];%2
    [12:16,25,34,39:43,52,61,66:70];%3
    [11:9:38,14:9:41,47:52,59,68];%4
    [12:16,21,30,39:43,52,61,66:70];%5
    [12:16,21,30,39:43,48,57,52,61,66:70];%6
    [12:15,24:9:69];%7
    [12:16,21,30,25,34,39:43,48,57,52,61,66:70];%8
    [12:16,21,30,25,34,39:43,52,61,66:70];%9
    [12:16,21:9:57,25:9:61,66:70];%0
    };

    

%%
%��Ƶ��������

%��Ƶ��������
AudioVolume = 0.5;


%�޸Ĺ���·������ǰM�ļ�����Ŀ¼
Path = mfilename('fullpath');
PosFileSep = strfind(Path,filesep);
cd(Path(1:PosFileSep(end)));


%������ʾ������
if exist('.\DataAudio\DataHintAudio.mat','file')
    load .\DataAudio\DataHintAudio.mat;
else
    AudioDataHit = audioread('.\DataAudio\Hit.wav')';
    AudioDataHit = mapminmax(AudioDataHit);
    
    AudioDataOut = audioread('.\DataAudio\Out.wav')';
    AudioDataOut = mapminmax(AudioDataOut);
    
    AudioDataRoll = audioread('.\DataAudio\Roll.wav')';
    AudioDataRoll = mapminmax(AudioDataRoll(1:8000))*0.6;
    
    
    AudioDataPass = audioread('.\DataAudio\Pass.wav')';
    AudioDataPass = maxminmax(AudioDataPass);
    
    AudioDataFinish = audioread('.\DataAudio\Finish.wav')';
    AudioDataFinish = maxminmax(AudioDataFinish);

    save .\DataAudio\DataHintAudio.mat  AudioDataHit AudioDataOut AudioDataRoll AudioDataPass AudioDataFinish;
end

%�����̶�
SequenceMel = [900 1000 1100  600  700  800 300  400  500];

%��������Ƶ��
MatrixFreq = reshape (700*(10.^(SequenceMel/2595)-1),3,3);
            
MatrixLeftAmp = [ 0.8 0.5 0.2
                  0.8 0.5 0.2
                  0.8 0.5 0.2 ];

MatrixRightAmp = [ 0.2 0.5 0.8
                   0.2 0.5 0.8
                   0.2 0.5 0.8 ];  
               
MatrixLeftAmp =MatrixLeftAmp';
MatrixRightAmp = MatrixRightAmp';

%��Ƶ�����ʣ�Ĭ��Ϊ48Hz,��λ��Hz��
SampleRateAudio = 48000;

%��Ƶ�������ɲ���
%������������Ƿ����
if exist('.\DataAudio\AudioGeneartion.mat','file')
    %�����ڣ����ȡ����
    load .\DataAudio\AudioGeneartion.mat;
    %����Ƶ�ʡ������ʡ�����ʱ�������Ҷ�ǿ���������ļ����жԱȣ���һ�£��������������������ļ�
    if  isequal(MatrixFreq,MatrixFreq_last)  &&...
            SampleRateAudio == SampleRateAudio_last &&...
            TimeCodedSound == TimeCodedSound_last &&...
            TimeWhiteNosie == TimeWhiteNoise_last &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_last) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_last) 
        
        clear MatrixFreq_last SampleRateAudio_last TimeCodedSound_last TimeWhiteNoise_last MatrixLeftAmp_last MatrixRightAmp_last;
    %����һ�����������������ļ�������ȡ���ļ�
    else
        
        AudioGeneration(TimeCodedSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\DataAudio\AudioGeneartion.mat DataPureTone DataWhiteNoise;
        disp('��Ƶ�����Ѹ���!')
        
    end
%�������ļ������ڣ���ֱ�����������ļ�������ȡ���ļ�
else
    
    AudioGeneration(TimeCodedSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\DataAudio\AudioGeneartion.mat DataPureTone DataWhiteNoise;
    
    disp('������Ƶ����!')
     
end


%%
%��ʾ��Ϣ

MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);
MessageCountdown = double('������ʼ...');
MessageFinish = double('ʵ�������)');


%%
%����

%���ڵ�ַ����
LPTAddress = 53264;

%���ڱ�Ǻ���˵��
%1-200:��ʾ��ǵ��з�������£����ִ�����������ÿ��ͼ���ֱ������
%201-240:��ʾ��ǵ㴦����Ŀ���λ�ã�ʵ������ΪTrial��+200
%241-249:��ʱ����
%250:��ʾ��̽��ʱ��������Զ�ת����һĿ���
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:��ʾʵ�鳤ʱ��(TimeWaitPerMove)δ��⵽�����������ֹ
%253:��ʾʵ����Esc�����¶���ֹ
%254:��ʾʵ����������




%�˳������ڷ�λ��ʶʵ��Ĳ�������

%������������
%Trial��������һ��������Ŀ���Ϊһ��Trial��
NumTrial = 3;

%������������ʱ����A���뷽����ʾÿ����ı�������ʱ����B���뷽��ָÿ��ͼ�����������ʱ����
TimeCodedSound = 1;

%�������ʱ�䣨�����α�������֮�������ʱ������λ���룩
TimeGapSilence = 2;



%%
%ʱ���������

%׼��ʱ��(��������ʱʱ������λ����)
TimePrepare = 10; 

%����ʱ��������λ���룩
TimeCountdown = 6; 

%ʵ�������ʾʱ������λ���룩
TimeMessageFinish =1;

%%
%��ֵ�趨

%ÿ���ƶ����ȴ�ʱ��������ʱ���Զ��˳�����,��λ���룩
TimeWaitPerMove = 100;

%����Trial��໨�ѵ�ʱ��
TimeMaxPerTrial = 200;

%һ��ͼ�����̽������
MaxNumStep = 500;


%%
%��ʾ�����趨

%��Ļ��ɫ��ȱʡֵΪ��ɫ����ѡ��ɫΪblack��white,red,green,blue,gray,���߿�����
%һ����ά����ֱ��ָ����������ԭɫ����,�ڴ˾�Ϊ������Ԫ�ؾ�ӦΪ0-1֮�����ֵ����ͬ��
ColorBackground = black;

%������ɫ(ȱʡֵΪ��ɫ,��[1,1,1])
ColorSquare = white;
%�ܷ�����
NumSquare=81;

%���ݷ������ÿһ��/�еķ�����Ŀ
NumSquarePerRow = sqrt(NumSquare);


%��һ��Ŀ���ĳ��ַ�Χ�޶�
%������һ��Ŀ��������ԭĿ���ĺ�/����ƫ��������RangeNextTarget֮��
%Ĭ��ֵΪceil(NumSquarePerRow/2)
RangeNextTarget = ceil(NumSquarePerRow/2);

%�����С(��λ������)
%������ָ������Ĭ��ֵ����
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
% GapWidth = 0.2* SizeSquare;

SizeSquareFrame =  SizeScreenY/(NumSquarePerRow+2);
SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;

%Բ����ɫ(�û������Ƶĵ�ȱʡֵΪ��ɫ,��[1,0,0])
%δ����Ŀ���ʱ
ColorDot = red;

%Ŀ�����ɫ
ColorTarget =black;

%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.6��
SizeDot = 0.6* SizeSquare ;

%������ɫ�Ϳ��
ColorLine = red;
WidthLine = 7;%�Ѿ����

%��������
NameFont = '΢���ź�';
%�����С
SizeFont = 50;
%������ɫ
ColorFont = white;



%��ʾ��Ϣ
MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);

MessageCountdown = double('������ʼ...');

MessageFinish = double('ʵ�������)');
%%
%��Ƶ�����趨

%��С�������ã��������Ŀ��������Զʱ��������С��
MinAudioVolume = 0.2;

%��ʾ����������
VolumeHint = 0.8;

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
%����

%���ڵ�ַ����
LPTAddress = 53264;

%���ڱ�Ǻ���˵��
%1-200:��ʾ��ǵ��з�������£����ִ�����������ÿ��Ŀ���ֱ������
%201-240:��ʾ��ǵ㴦����Ŀ���λ�ã�ʵ������ΪTrial��+200
%241-249:��ʱ����
%250:��ʾ��̽��ʱ��������Զ�ת����һĿ���
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:��ʾʵ�鳤ʱ��(TimeWaitPerMove)δ��⵽�����������ֹ
%253:��ʾʵ����Esc�����¶���ֹ
%254:��ʾʵ����������





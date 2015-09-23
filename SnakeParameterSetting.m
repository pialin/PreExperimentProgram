%��һ��Ŀ���ĳ��ַ�Χ�޶�
%������һ��Ŀ��������ԭĿ���ĺ�/����ƫ��������RangeNextTarget֮��
%Ĭ��ֵΪceil(NumSquarePerRow/2)
RangeNextTarget = ceil(NumSquarePerRow/2);


%��С�������ã��������Ŀ��������Զʱ��������С��
MinAudioVolume = 0.2;

%��ʾ����������
VolumeHint = 0.8;

%%
%ʱ���������

%׼��ʱ��(��������ʱʱ��)
TimePrepare = 5; 

%����ʱ����
TimeCountdown = 3; 

%ʵ�������ʾʱ��
TimeMessageFinish =2;

%�������ʱ�䣨�����α�������֮�������ʱ������λ���룩
TimeGapSilence = 2;

%ÿ���ƶ����ȴ�ʱ��������ʱ���Զ��˳�����,��λ���룩
TimeWaitPerMove = 100;


%һ��Trial�������Ĳ���
NumMaxStepPerTrial=100;

%������
NumSquare=81;

%���ݷ������ÿһ��/�еķ�����Ŀ
NumSquarePerRow = sqrt(NumSquare);


%��ʾ��Ϣ
MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);

MessageFinish = double('ʵ�������)');

%������ʾ������
load DataHintAudio.mat;

AudioDataHit = audioread('Hit.wav')';
AudioDataOut = audioread('Out.wav')';
AudioDataRoll = audioread('Roll.wav')';
AudioDataFinish = audioread('Finish.wav')';

%Trial�� ������->��������->���� Ϊһ��Trail��
NumTrial = 3;

%������������ʱ����A���뷽����ʾÿ����ı�������ʱ����B���뷽��ָÿ��ͼ�����������ʱ����
TimeCodedSound = 1;

%��ʾ��������

%��Ļ��ɫ��ȱʡֵΪ��ɫ����ѡ��ɫΪblack��white,red,green,blue,gray,���߿�����
%һ����ά����ֱ��ָ����������ԭɫ����,�ڴ˾�Ϊ������Ԫ�ؾ�ӦΪ0-1֮�����ֵ����ͬ��
ColorBackground = black;

%������ɫ(ȱʡֵΪ��ɫ,��[1,1,1])
ColorSquare = white;

%�����С(��λ������)
%������ָ������Ĭ��ֵ����
% SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.2;
% GapWidth = 0.2* SizeSquare;

SizeSquare = SizeScreenY/(NumSquarePerRow+2)/1.1;
GapWidth = 0.1* SizeSquare;

%Բ����ɫ(ȱʡֵΪ��ɫ,��[1,0,0])
ColorDot  = red;
ColorTarget =black;

%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.5��
SizeDot = 0.5* SizeSquare ;

%����ѵ�������Բ����ɫ
ColorDotUncoded = blue; 
ColorDotCoded = red;


%����ѵ����������ɫ�Ϳ��
ColorLine = red;
WidthLine = 7;%�Ѿ����

%��������
NameFont = '΢���ź�';
%�����С
SizeFont = 50;
%������ɫ
ColorFont = white;

%%
%��Ƶ��������

%��Ƶ��������
AudioVolume = 0.5;

%��������Ƶ��
MatrixFreq = [  800 1008 1267
                400  504  635 
                200  252  317  ];
            
MatrixLeftAmp = [ 0.8 0.5 0.2
                  0.8 0.5 0.2
                  0.8 0.5 0.2 ];

MatrixRightAmp = [ 0.2 0.5 0.8
                   0.2 0.5 0.8
                   0.2 0.5 0.8 ];  
               
MatrixFreq= MatrixFreq';
MatrixLeftAmp =MatrixLeftAmp';
MatrixRightAmp = MatrixRightAmp';

%��Ƶ�����ʣ�Ĭ��Ϊ48Hz,��λ��Hz��
SampleRateAudio = 48000;

%��Ƶ�������ɲ���
load DataPureTone.mat;

if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
        SampleRateAudio==SampleRateAudio_mat &&...
        TimeCodedSound == TimeCodedSound_mat &&...
        isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
        isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
    clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

else
    
     AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio); 
     
     load DataPureTone.mat DataPureTone


end





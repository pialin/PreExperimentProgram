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


%��ʾ��Ϣ
MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);

MessageFinish = double('ʵ�������)');

%������ʾ������
load DataHintAudio.mat;

AudioDataHit = audioread('Hit.wav')';
AudioDataOut = audioread('Out.wav')';
AudioDataRoll = audioread('Roll.wav')';
AudioDataFinish = audioread('Finish.wav')';


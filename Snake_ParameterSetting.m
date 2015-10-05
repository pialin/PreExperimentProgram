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
TimeMessageFinish =2;

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

%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.5��
SizeDot = 0.5* SizeSquare ;

%������ɫ�Ϳ���
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

%������ʾ������
if exist('.\HintSound\DataHintAudio.mat','file')
    load .\HintSound\DataHintAudio.mat;
else
    AudioDataHit = audioread('.\HintSound\Hit.wav')';
    AudioDataHit = AudioDataHit/max(abs(AudioDataHit(:)));
    
    AudioDataOut = audioread('.\HintSound\Out.wav')';
    AudioDataOut = AudioDataOut/max(abs(AudioDataOut(:)));
    
    AudioDataRoll = audioread('.\HintSound\Roll.wav')';
    AudioDataRoll = AudioDataRoll/max(abs(AudioDataRoll(:)));
    AudioDataRoll = AudioDataRoll(1:12000);
    
    AudioDataPass = audioread('.\HintSound\Pass.wav')';
    AudioDataPass = AudioDataPass/max(abs(AudioDataPass(:)));
    
    AudioDataFinish = audioread('.\HintSound\Finish.wav')';
    AudioDataFinish = AudioDataFinish/max(abs(AudioDataFinish(:)));

    save .\HintSound\DataHintAudio.mat SampleRateAudio AudioDataHit AudioDataOut AudioDataRoll AudioDataPass AudioDataFinish;
end

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


%%
%����

%���ڵ�ַ����
LPTAddress = 53264;

%���ڱ�Ǻ���˵��
%1-200:��ʾ��ǵ��з�������£����ִ�������������ÿ��Ŀ���ֱ������
%201-240:��ʾ��ǵ㴦����Ŀ���λ�ã�ʵ������ΪTrial��+200
%241-249:��ʱ����
%250:��ʾ��̽��ʱ��������Զ�ת����һĿ���
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:��ʾʵ����Esc�����¶���ֹ
%253:��ʾʵ�鳤ʱ��(TimeWaitPerMove)δ��⵽�����������ֹ
%254:��ʾʵ����������




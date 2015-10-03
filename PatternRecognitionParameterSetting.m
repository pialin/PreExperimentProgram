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
TimeMessageFinish =2;

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

%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.5��
SizeDot = 0.5* SizeSquare ;

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
NumPattern = 2;

%ÿ��ͼ����Ӧ�ĵ�����
SequencePatternDot={
                    [38:44];
                    [14:9:68]
                    };
    

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

%��Ƶ�����ʣ�Ĭ��Ϊ48KHz,��λ��Hz��
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
     
     load DataPureTone.mat DataPureTone;


end

%������ʾ������
load DataHintAudio.mat;



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
%201-240:��ʾ��ǵ㴦������ͼ���ĸ��������ּ�ȥ200��Ϊͼ�������
%241-250:��ʱ����
%251:��ʾʵ�鿪ʼ
%252:��ʾʵ����Esc�����¶���ֹ
%253:��ʾʵ�鳤ʱ��(TimeWaitPerMove)δ��⵽�����������ֹ
%254:��ʾʵ����������





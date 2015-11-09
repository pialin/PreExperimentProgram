%�˳�������A����ʵ���������һЩ����
%���������
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64

%%
%������������
%�������
NumCodedDot = 2;
%��Ƶ�طŴ���
AudioCompetition = 4;

%Trial�� ������->��������->���� Ϊһ��Trail��
NumTrial = 3;




%%
%ʱ���������

%׼��ʱ��(��������ʱʱ��)
TimePrepare = 3; 


%����������ʱ������λ���룩
TimeWhiteNoise = 2;

%������������ʱ����A���뷽����ʾÿ����ı�������ʱ����B���뷽��ָÿ��ͼ�����������ʱ����
TimeCodeSound = 1;

%�������ʱ�䣨�����α�������֮�������ʱ������λ���룩
TimeGapSilence = 1;

%��������ѭ������
AudioRepetition = 3;


%ʵ�������ʾʱ������λ���룩
TimeMessageFinish =1;




%%
%��ʾ��������

%��Ļ��ɫ��ȱʡֵΪ��ɫ����ѡ��ɫΪblack��white,red,green,blue,gray,���߿�����
%һ����ά����ֱ��ָ����������ԭɫ����,�ڴ˾�Ϊ������Ԫ�ؾ�ӦΪ0-1֮�����ֵ����ͬ��
ColorBackground = black;
%���������ÿ��/�еķ��������ƽ����
NumSquare = 9;
%���ݷ������ÿһ��/�еķ�����Ŀ
NumSquarePerRow = sqrt(NumSquare);

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



%Բ���С��Ĭ��ֱ��Ϊ����߳�����0.6��
SizeDot = 0.6* SizeSquare ;


%����ѵ�������Բ����ɫ
ColorDotUncoded = blue; 
ColorDotCoded = red;

%����ѵ����������ɫ�Ϳ��
ColorLine = red;
WidthLine = 7;%�Ѿ����

%ѵ�������������Ƶ���
NumDotLimit = 4;

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

%�����̶�
SequenceMel = [900 1000 1100  600  700  800 300  400  500];

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
            TimeCodeSound == TimeCodeSound_last &&...
            TimeWhiteNosie == TimeWhiteNoise_last &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_last) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_last) 
        
        clear MatrixFreq_last SampleRateAudio_last TimeCodeSound_last TimeWhiteNoise_last MatrixLeftAmp_last MatrixRightAmp_last;
    %����һ�����������������ļ�������ȡ���ļ�
    else
        
        AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\DataAudio\AudioGeneartion.mat DataPureTone DataWhiteNoise;
        disp('��Ƶ�����Ѹ���!')
        
    end
%�������ļ������ڣ���ֱ�����������ļ�������ȡ���ļ�
else
    
    AudioGeneration(TimeCodeSound,TimeWhiteNoise,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\DataAudio\AudioGeneartion.mat DataPureTone DataWhiteNoise;
    
    disp('������Ƶ����!')
     
end



        
%��ʾ��Ϣ
MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);
MessageRefSound = double('�ο���...');
MessageWhiteNoise = double('���ñ���ֽ�ϼ�¼��Ĵ�...'); 
MessageFinish = double('ʵ�������)');

%%
%����

%���ڵ�ַ����
LPTAddress = 53264;

%���ڱ�Ǻ���˵��
%1-200:��ʾÿ��ͼ����trial���������ֵĿ�ʼ�ͽ���
%201:��ʾ���Ÿ�˹������
%202-250:����
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:����
%253:ʵ����ΪESC�������¶���ֹ
%254:��ʾʵ����������

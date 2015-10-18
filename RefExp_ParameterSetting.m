%�˳������òο�ʵ���������һЩ����
%���������
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64




%׼��ʱ������λ���룩
TimePrepare = 3;

%������������г����ã���λ���룩
TimeAll = 60;

%����ʱ��(��λ����)
TimeCodedSound = 1;

%�������(��λ����)
TimeGapSilence = 1;

%�ȴ�ʵ�鿪ʼ(��λ����)
TimeWait = 3;

%��ʵ���������ʾʱ������λ���룩
TimeShowFinish = 1;

%��������
AudioVolume = 0.8 ;

%��Ƶ������
SampleRateAudio = 48000;

%��ʾ��Ϣ
MessagePrepare = double('׼��ʵ��...');
MessageStart = double('�ο�ʵ�鿪ʼ...');
MessageFinish = double('ʵ����� ����'); 

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
%���������������Ƿ����
if exist('.\CodeSound\DataPureTone.mat','file')
    %�����ڣ����ȡ����
    load .\CodeSound\DataPureTone.mat;
    %����Ƶ�ʡ������ʡ�����ʱ�������Ҷ�ǿ���������ļ����жԱȣ���һ�£��������������������ļ�
    if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
            SampleRateAudio==SampleRateAudio_mat &&...
            TimeCodedSound == TimeCodedSound_mat &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
        clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;
    %����һ�����������������ļ�������ȡ���ļ�
    else
        
        AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\CodeSound\DataPureTone.mat DataPureTone;
        disp('DataPureTone�Ѿ�����!')
        
    end
%�������ļ������ڣ���ֱ�����������ļ�������ȡ���ļ�
else
    
    AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\CodeSound\DataPureTone.mat DataPureTone;
    
    disp('����DataPureTone!')
     
end

%���ڱ�Ǻ���˵��
%1:��ʾ�������ſ�ʼ
%2-250:����
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:����
%253:��ʾʵ����Esc�����¶���ֹ
%254:��ʾʵ����������


%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64


%%
%�˳�������ʵ���������һЩ����


%%
%������������
%�������

NumCodedDot = 3;

%Trial�� ������->��������->���� Ϊһ��Trail��
NumTrial = 10;


%%
%ʱ���������

%׼��ʱ��(��������ʱʱ��)
TimePrepare = 10; 

%����ʱ����
TimeCountdown = 3; 

%����������ʱ������λ���룩
TimeWhiteNoise = 1;

%������������ʱ������λ����/�㣩
TimeCodedSound = 1;

%����ʱ��(��λ����)
TimeSilence = 2;




%%
%��ʾ��������

%��Ļ��ɫ��ȱʡֵΪ��ɫ����ѡ��ɫΪblack��white,red,green,blue,gray,���߿�����
%һ����ά����ֱ��ָ����������ԭɫ����,�ڴ˾�Ϊ������Ԫ�ؾ�ӦΪ0-1֮�����ֵ����ͬ��
ColorBackground = black;
%���������ÿ��/�еķ��������ƽ����
NumSquare = 9;

%������ɫ(ȱʡֵΪ��ɫ,��[1,1,1])
ColorSquare = white;

%�����С(��λ������)
%������ָ������Ĭ��ֵ����
% SizeSquare = ;
% WidthGap = ;

%Բ����ɫ(ȱʡֵΪ��ɫ,��[1,0,0])
ColorDot  = red;

%Բ���С��Ĭ��ֱ��Ϊ����߳���0.7��
% SizeDot = ;


%%
%��Ƶ��������

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



%��Ƶ�����ʣ�Ĭ��Ϊ44100Hz,��λ��Hz��
SampleRateAudio = 44100;

load DataPureTune.mat;
if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
        SampleRateAudio==SampleRateAudio_mat &&...
        TimeCodedSound == TimeCodedSound_mat &&...
        isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
        isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
    clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;

else
    
     AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,AudioSampleRate) 
     
     load DataPureTune.mat DataPureTune


end

DataWhiteNoise = randn(2,TimeWhiteNoise*AudioSampleRate);

DataWhiteNoise = DataWhiteNoise/max(abs(DataWhiteNoise(:)));
        



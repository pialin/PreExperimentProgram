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
TimePrepare = 10; 

%����ʱ����
TimeCountdown = 5.2; 

%����������ʱ������λ���룩
TimeWhiteNoise = 2;

%������������ʱ����A���뷽����ʾÿ����ı�������ʱ����B���뷽��ָÿ��ͼ�����������ʱ����
TimeCodedSound = 1;

%�������ʱ�䣨�����α�������֮�������ʱ������λ���룩
TimeGapSilence = 1;

%��������ѭ������
AudioRepetition = 3;


%����ʱ��(Trial֮�����Ϣʱ�� ��λ����)
TimeBreak = 3;

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

DataWhiteNoise = randn(2,TimeWhiteNoise*SampleRateAudio);

DataWhiteNoise = DataWhiteNoise/max(abs(DataWhiteNoise(:)));
        
%��ʾ��Ϣ
MessagePrepare = double(['ʵ�齫�� ',num2str(TimePrepare),' ���ʼ...']);
MessageCountdown = double('������ʼ...');
MessageWhiteNoise = double('���ڲ��ŵ��ǰ�����...'); 
MessageSilence = double('����С���̼�¼��������ͼ��...'); 
MessageFinish = double('ʵ�������)');

%%
%����

%���ڵ�ַ����
LPTAddress = 53264;

%���ڱ�Ǻ���˵��
%1-200:��ʾÿ��ͼ����trial���������ֵĿ�ʼ�ͽ���
%201:��ʾ���Ÿ�˹������
%202-250:��ʱ����
%251:��ʾʵ�鿪ʼ��׼���׶ο�ʼ��
%252:����
%253:ʵ����ΪESC�������¶���ֹ
%254:��ʾʵ����������




% %%
% %������֤���֣�
% 
% %%
% %�������� 
% if isscalar(NumCodedDot)  && isnumeric(NumCodedDot) &&  fix(NumCodedDot)==NumCodedDot && NumCodedDot <= NumSquare && NumCodedDot>0
%     
% else   
%     
%     errordlg('NumCodedDot��������','�������ô���');
%     return;
%     
% end
% 
% if isscalar(NumTrial)  && isnumeric(NumTrial) &&  fix(NumTrial)==NumTrial && NumTrial>0
%     
% else   
%     
%     errordlg('NumTrial��������','�������ô���');
%     return;
%     
% end
% 
% 
% 
% %ʱ���������
% if isscalar(TimePrepare)  && isnumeric(TimePrepare) &&  TimePrepare>= TimeCountdown && TimePrepare >0
%     
% else
%      errordlg('TimePrepare��������','�������ô���');
%      return;
%      
% end
% 
% if isscalar(TimeCountdown)  && isnumeric(TimeCountdown) &&  TimeCountdown<= TimeCountdown && TimeCountdown >0
%      
% else
%     
%      errordlg('TimeCountdown��������','�������ô���');
%      return;
%      
% end
% 
% 
% if isscalar(TimeWhiteNoise)  && isnumeric(TimeWhiteNoise) &&  TimeWhiteNoise>0
%     
% else
%     
%      errordlg('TimeWhiteNoise��������','�������ô���');
%      return;
%      
% end
% 
% if isscalar(TimeCodedSound)  && isnumeric(TimeCodedSound) &&  TimeCodedSound>0
%     
% else
%     
%      errordlg('TimeCodedSound��������','�������ô���');
%      return;
%      
% end
% 
% if isscalar(TimeBreak)  && isnumeric(TimeBreak) &&  TimeBreak>0
%     
% else
%     
%      errordlg('TimeSilence��������','�������ô���');
%      return;
%      
% end
% 
% 
% %��ʾ��������
% 
% if (isscalar(ColorBackground) || numel(ColorBackground) == 3) && isnumeric(ColorBackground) && ...
%       all(ColorBackground>=0)  && all(ColorBackground<=1) 
% 
% else
%      errordlg('ColorBackground��������','�������ô���');
%      return;
%    
% end
% 
% if isscalar(NumSquare) && isnumeric(NumSquare) && NumSquare>0 && fix(NumSquarePerRow) == NumSquarePerRow 
% 
% else
%      errordlg('NumSquare��������','�������ô���');
%      return;
%    
% end
% 
% if (isscalar(ColorSquare) || numel(ColorSquare) == 3) && isnumeric(ColorSquare) && ...
%       all(ColorSquare>=0)  && all(ColorSquare<=1)
% 
% else
%      errordlg('ColorSquare��������','�������ô���');
%      return;
%    
% end
% 
% 
% if isscalar(SizeSquare) &&  isnumeric(SizeSquare) && SizeSquare>0  && SizeSquare <=SizeScreenY/NumSquarePerRow 
% 
% else
%     errordlg('SizeSquare��������','�������ô���'); 
%     return;
%     
% end
% 
% if isscalar(GapWidth) &&  isnumeric(GapWidth) && GapWidth>0  && GapWidth <=SizeSquare 
% 
% else
%     errordlg('GapWidth��������','�������ô���');
%     return;
%     
% end
% 
% 
% 
% if (isscalar(ColorDot) || numel(ColorDot) == 3) && isnumeric(ColorDot) && ...
%     all(ColorDot>=0)  && all(ColorDot<=1) 
% 
% else
%      errordlg('ColorDot��������','�������ô���');
%      return;
%    
% end
% 
% 
% if isscalar(SizeDot) &&  isnumeric(SizeDot) && SizeDot>0  && SizeDot <=SizeSquare 
% 
% else
%     errordlg('SizeDot��������','�������ô���'); 
%     return;
%     
% end
% 
% if (isscalar(ColorDotUncoded) || numel(ColorDotUncoded) == 3) && isnumeric(ColorDotUncoded) && ...
%     all(ColorDotUncoded>=0)  && all(ColorDotUncoded<=1) 
% 
% else
%      errordlg('ColorDotUncoded��������','�������ô���');
%      return;
%    
% end
% 
% 
% if (isscalar(ColorDotCoded) || numel(ColorDotCoded) == 3) && isnumeric(ColorDotCoded) && ...
%     all(ColorDotCoded>=0)  && all(ColorDotCoded<=1)
% 
% else
%      errordlg('ColorDotCoded��������','�������ô���');
%      return;
%    
% end
% 
% if (isscalar(ColorLine) || numel(ColorLine) == 3) && isnumeric(ColorLine) && ...
%     all(ColorLine>=0)  && all(ColorLine<=1) 
% 
% else
%      errordlg('ColorLine��������','�������ô���');
%      return;
%    
% end
% 
% if isscalar(WidthLine) &&  isnumeric(WidthLine) && WidthLine>0  && WidthLine<=WidthLine && fix(WidthLine) == WidthLine
% 
% else
%     errordlg('WidthLine��������','�������ô���'); 
%     return;
%     
% end
% 
% 
% if isscalar(NumDotLimit)  && isnumeric(NumDotLimit) &&  fix(NumDotLimit)==NumDotLimit && NumDotLimit <= NumSquare && NumDotLimit>0
%     
% else   
%     
%     errordlg('NumDotLimit��������','�������ô���');
%     return;
%     
% end
% 
% 
% if isscalar(SizeFont) && isnumeric(SizeFont) && SizeFont>0 && fix(SizeFont) ==SizeFont
% 
% else
%     errordlg('SizeFont��������','�������ô���');
%     return;
%     
% end
% 
% if (isscalar(ColorFont) || numel(ColorFont) == 3) && isnumeric(ColorFont) && ...
%     all(ColorFont>=0)  && all(ColorFont<=1) 
% 
% else
%      errordlg('ColorFont��������','�������ô���');
%      return;
%    
% end
% 
% 
% %��Ƶ������֤
% 
% if isscalar(AudioVolume) && isnumeric(AudioVolume)&& AudioVolume>=0 && AudioVolume<=1
%     
% else
%       errordlg('AudioVolume��������','�������ô���');
%       return;
% end
% 
% if ismatrix(MatrixFreq) && isnumeric(MatrixFreq) && numel(MatrixFreq)== NumSquare && all(MatrixFreq(:)>0)
%     
% else
%       errordlg('MatrixFreq��������','�������ô���');
%       return;
% 
% end
% 
% if ismatrix(MatrixLeftAmp) && isnumeric(MatrixLeftAmp) && numel(MatrixLeftAmp)== NumSquare && all(MatrixLeftAmp(:)>=0)  && all(MatrixLeftAmp(:) <=1)
%     
% else
%       errordlg('MatrixLeftAmp��������','�������ô���');
%       return;
% 
% end
% 
% if ismatrix(MatrixRightAmp) && isnumeric(MatrixRightAmp) && numel(MatrixRightAmp)== NumSquare && all(MatrixRightAmp(:)>=0)  && all(MatrixRightAmp(:) <=1)
%     
% else
%       errordlg('MatrixRightAmp��������','�������ô���');
%       return;
% 
% end
% 
% 
% if isscalar(SampleRateAudio) && isnumeric(SampleRateAudio) && SampleRateAudio>0
% 
% else
%     errordlg('SampleRateAudio��������','�������ô���');
%     return;
% end
% 
% 










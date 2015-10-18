%此程序设置参考实验主程序的一些参数
%软件环境：
%Psychtoolbox:3.0.12 
%Matlab:R2015a x64
%OS:Windows 8.1 x64




%准备时长（单位：秒）
TimePrepare = 3;

%随机听声音的市场设置（单位：秒）
TimeAll = 60;

%声音时长(单位：秒)
TimeCodedSound = 1;

%声音间隔(单位：秒)
TimeGapSilence = 1;

%等待实验开始(单位：秒)
TimeWait = 3;

%‘实验结束’显示时长（单位：秒）
TimeShowFinish = 1;

%音量设置
AudioVolume = 0.8 ;

%音频采样率
SampleRateAudio = 48000;

%提示信息
MessagePrepare = double('准备实验...');
MessageStart = double('参考实验开始...');
MessageFinish = double('实验结束 ：）'); 

%字体名称
NameFont = '微软雅黑';
%字体大小
SizeFont = 50;
%字体颜色
ColorFont = white;


%%
%音频参数设置

%音频音量设置
AudioVolume = 0.5;

%编码声音频率

%美尔刻度
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

%音频采样率（默认为48Hz,单位：Hz）
SampleRateAudio = 48000;

%音频数据生成部分
%检查编码声音数据是否存在
if exist('.\CodeSound\DataPureTone.mat','file')
    %若存在，则读取数据
    load .\CodeSound\DataPureTone.mat;
    %并将频率、采样率、编码时长、左右耳强度与数据文件进行对比，若一致，则无需重新生成数据文件
    if  isequal(MatrixFreq,MatrixFreq_mat)  &&...
            SampleRateAudio==SampleRateAudio_mat &&...
            TimeCodedSound == TimeCodedSound_mat &&...
            isequal(MatrixLeftAmp,MatrixLeftAmp_mat) &&...
            isequal(MatrixRightAmp,MatrixRightAmp_mat)
        
        clear MatrixFreq_mat SampleRateAudio_mat TimeCodedSound_mat MatrixLeftAmp_mat MatrixRightAmp_mat;
    %若不一致则重新生成数据文件，并读取该文件
    else
        
        AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
        
        load .\CodeSound\DataPureTone.mat DataPureTone;
        disp('DataPureTone已经更新!')
        
    end
%若数据文件不存在，则直接生成数据文件，并读取该文件
else
    
    AudioGeneration(TimeCodedSound,MatrixFreq,MatrixLeftAmp,MatrixRightAmp,SampleRateAudio);
    
    load .\CodeSound\DataPureTone.mat DataPureTone;
    
    disp('生成DataPureTone!')
     
end

%并口标记含义说明
%1:表示声音播放开始
%2-250:保留
%251:表示实验开始（准备阶段开始）
%252:保留
%253:表示实验因Esc键按下而中止
%254:表示实验正常结束


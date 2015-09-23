%下一个目标点的出现范围限定
%即将下一个目标点相对于原目标点的横/纵向偏移限制在RangeNextTarget之内
%默认值为ceil(NumSquarePerRow/2)
RangeNextTarget = ceil(NumSquarePerRow/2);


%最小音量设置（即光标与目标点距离最远时的音量大小）
MinAudioVolume = 0.2;

%提示音音量设置
VolumeHint = 0.8;

%%
%时间参数设置

%准备时长(包括倒计时时长)
TimePrepare = 5; 

%倒计时秒数
TimeCountdown = 3; 

%实验结束显示时长
TimeMessageFinish =2;

%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 2;

%每次移动光标等待时长（超过时长自动退出程序,单位：秒）
TimeWaitPerMove = 100;


%一个Trial最多允许的步数
NumMaxStepPerTrial=100;

%方块数
NumSquare=81;


%提示信息
MessagePrepare = double(['实验将于 ',num2str(TimePrepare),' 秒后开始...']);

MessageFinish = double('实验结束：)');

%加载提示音数据
load DataHintAudio.mat;

AudioDataHit = audioread('Hit.wav')';
AudioDataOut = audioread('Out.wav')';
AudioDataRoll = audioread('Roll.wav')';
AudioDataFinish = audioread('Finish.wav')';


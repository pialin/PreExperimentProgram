%%
%音频设置

%开启低延迟模式
EnableAudioLowLatencyMode = 1; 
InitializePsychSound(EnableAudioLowLatencyMode);

%设置音频声道数为2，即左右双声道立体声
NumAudioChannel = 2;

%PsyPortAudio('Start',...)语句执行后立刻开始播放声音
AudioStartTime = 0;
%等待声音真正播放后退出语句执行下面语句
WaitUntilDeviceStart = 1;
%音频重放次数，无限重放直到执行 PsychPortAudio('Stop',...)
AudioRepetition = 0;


% 创建PortAudio对象，对应的参数如下
% (1) [] ,调用默认的
% (2) 1 ,仅进行声音播放（不进行声音录制）
% (3) 1 , 默认延迟模式
% (4) SampleRateAudio,音频采样率
% (5) 2 ,输出声道数为2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);


%新建Buffer用于存放提示音数据
HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
HandleHitBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll,AudioDataHit;AudioDataRoll,AudioDataHit]);
HandleFinishBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);


PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);

%播放声音
PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
WaitSecs(numel(AudioDataRoll)/AudioSampleRate);
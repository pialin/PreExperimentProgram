%%
%��Ƶ����

%�������ӳ�ģʽ
EnableAudioLowLatencyMode = 1; 
InitializePsychSound(EnableAudioLowLatencyMode);

%������Ƶ������Ϊ2��������˫����������
NumAudioChannel = 2;

%PsyPortAudio('Start',...)���ִ�к����̿�ʼ��������
AudioStartTime = 0;
%�ȴ������������ź��˳����ִ���������
WaitUntilDeviceStart = 1;
%��Ƶ�طŴ����������ط�ֱ��ִ�� PsychPortAudio('Stop',...)
AudioRepetition = 0;


% ����PortAudio���󣬶�Ӧ�Ĳ�������
% (1) [] ,����Ĭ�ϵ�
% (2) 1 ,�������������ţ�����������¼�ƣ�
% (3) 1 , Ĭ���ӳ�ģʽ
% (4) SampleRateAudio,��Ƶ������
% (5) 2 ,���������Ϊ2
HandlePortAudio = PsychPortAudio('Open', [], 1, 1,SampleRateAudio, NumAudioChannel);


%�½�Buffer���ڴ����ʾ������
HandleRollBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll;AudioDataRoll]);
HandleOutBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataOut;AudioDataOut]);
HandleHitBuffer = PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataRoll,AudioDataHit;AudioDataRoll,AudioDataHit]);
HandleFinishBuffer =  PsychPortAudio('CreateBuffer',HandlePortAudio,[AudioDataFinish;AudioDataFinish]);


PsychPortAudio('FillBuffer', HandlePortAudio,HandleRollBuffer);

%��������
PsychPortAudio('Start', HandlePortAudio, AudioRepetition, AudioStartTime, WaitUntilDeviceStart);
WaitSecs(numel(AudioDataRoll)/AudioSampleRate);
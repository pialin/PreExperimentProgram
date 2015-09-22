%下一个目标点的出现范围限定
%即将下一个目标点相对于原目标点的横/纵向偏移限制在RangeNextTarget之内
%默认值为ceil(NumSquarePerRow/2)
RangeNextTarget = ceil(NumSquarePerRow/2);


%最小音量设置（即光标与目标点距离最远时的音量大小）
MinAudioVolume = 0.2;


%声音间隔时间（即两次编码声音之间的无声时长，单位：秒）
TimeGapSilence = 3;

%每次移动光标等待时长（超过时长自动退出程序,单位：秒）
TimeWaitPerMove = 100;


%一个Trial最多允许的步数
NumMaxStepPerTrial=100;

%方块数
NumSquare=81;


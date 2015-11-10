%静息态数据采集

%时长设置（单位：秒）

TimeRestingState = 60;


LPTAddress = 53264;

lptwrite(LPTAddress,251);

WaitSecs(TimeRestingState);

lptwrite(LPTAddress,0);

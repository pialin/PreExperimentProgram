%��Ϣ̬���ݲɼ�

%ʱ�����ã���λ���룩

TimeRestingState = 60;


LPTAddress = 53264;

lptwrite(LPTAddress,251);

WaitSecs(TimeRestingState);

lptwrite(LPTAddress,0);

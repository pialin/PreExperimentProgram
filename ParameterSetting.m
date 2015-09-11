%%
%此程序设置实验主程序的一些参数

%%
%显示参数设置

%屏幕底色（缺省值为黑色，即[0,0,0],0<=red,green,blue<=1,各表示红绿蓝三原色比例,下同）
ColorBackground = [red,green,blue];
%方块个数（每行/列的方块个数的平方）
NumSquare = 9;

%方块颜色(缺省值为白色,即[1,1,1])
% ColorSquare = [red,green,blue];

%方块大小(单位：像素)
%若不作指定则按照默认值设置
% SizeSquare = ;
% WidthGap = ;

%圆点颜色(缺省值为红色,即[1,0,0])
% ColorDot  = [red,green,blue];

%圆点大小（默认直径为方块边长的0.7）
% SizeDot = 
%%
%时间参数设置

%白噪声呈现时长（单位：秒）
TimeWhiteNoise = 1;

%编码声音呈现时长（单位：秒/点）
TimeCodedSound = 1;

%无声时长(单位：秒)
TimeQuiet = 2;

%Trial数 （白噪->编码声音->无声 为一个Trail）

NumTrial = 10;


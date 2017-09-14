%% import
clear
addpath('dlls');
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('C:\Users\fortu\Documents\GitHub\QOS\qos\settings');
ustcaddaObj = ustcadda_v1.GetInstance();
%%
sampleRateAD = 1e9;
sampleRateDA = 2e9;
demodeFreq =  50e6;
windowLength = 2e3;
ustcaddaObj.runReps = 100;
ustcaddaObj.adRecordLength = windowLength;
t = 1:4e3;
T_DA = floor(sampleRateDA/demodeFreq); % unit sample point.
T_AD = floor(sampleRateAD/demodeFreq); 
omegaDA = 1/T_DA*2*pi;
omegaAD = 1/T_AD*2*pi;
wavedata_1 = 2e4*sin(omegaDA*t)+32768;
wavedata_2 = 2e4*cos(omegaDA*t)+32768;
% wavedata_1 = ones(1,4000)*32768 - 10000;
% wavedata_1(mod(t,40)>20) = 32768 + 10000;
% wavedata_2 = ones(1,4000)*32768 + 10000;
% wavedata_2(mod(t,40)>20) = 32768 - 10000;

delay = 0;
demodulationwindow = t(delay+1:delay+windowLength);
sinwt = sin(omegaAD*demodulationwindow);
coswt = cos(omegaAD*demodulationwindow);
nrepeat = 500000; % increase repeat times for a long time measurement
db(nrepeat) = struct('time',[],'dataI',[],'dataQ',[],'s',[],'temp',[]);
s = NaN(1, nrepeat);
for irepeat = 1:nrepeat
    ustcaddaObj.SendWave(1,wavedata_1);
    ustcaddaObj.SendWave(2,wavedata_2);
    ustcaddaObj.SendWave(3,wavedata_1);
    ustcaddaObj.SendWave(4,wavedata_2);
    db(irepeat).temp = ustcaddaObj.da_list(1).da.GetDATemperature(1);
    [It,Qt] = ustcaddaObj .Run(true);
    I = sinwt*double(It')+coswt*double(Qt');
    Q = coswt*double(It')-sinwt*double(Qt');
    db(irepeat).time = now;
    db(irepeat).dataI = I;
    db(irepeat).dataQ = Q;
    db(irepeat).s = mean(I) + 1i * mean(Q);
    if(mod(irepeat,10) == 0)
        disp(irepeat);
    end
    if(abs(db(irepeat).s)<5000)
        errordata.It = It;
        errordata.Qt = Qt;
    end
end
%% multiADC test
wavedata = 2e4*sin((1:2000)/2000*2*pi)+32768;
ustcaddaObj.SetADDemod([1,2],[0,1]);
ustcaddaObj.SetADDemodFreq([1,2],[10e6,10e6]);
ustcaddaObj.SetADWindowStart([1,2],[0,0]);
ustcaddaObj.SetADWindowWidth([1,2],[2000,2000]);
ustcaddaObj.SetDAChnlOutputDelay(1:8,zeros(1,8));%设置da的通道输出延时，共8个通道
ustcaddaObj.SetDABoardTrigDelay([1,2],[0,0]);%设置da板子的触发延时，共两个板子
ustcaddaObj.SetDAChnlOutputOffset(1:8,zeros(1,8));%设置da通道输出偏置，共8个通道
ustcaddaObj.SetDARuntimes([1,2],[2000,2000]);%设置da板子接收触发次数，共2个板子
ustcaddaObj.SetDATrigCount([1 2],[2000,2000]);%设置da板子触发次数，共2个板子
ustcaddaObj.SetADTrigCount([1 2],[2000,2000]);%设置ad接收触发次数，共2个ad
ustcaddaObj.SetADSampleDepth([1 2],[4000,4000]);%设置ad板子的采样深度，共2个ad
for irepeat = 1:8
    tic
    for ch = 1:8
        ustcaddaObj.SendWave(ch,wavedata);
    end
    ret = ustcaddaObj.Run([1,2]);
%     if(ret == 1)
%         subplot(2,2,1);plot(ustcaddaObj.ad_list(1).I);
%         subplot(2,2,2);plot(ustcaddaObj.ad_list(1).Q);
%         subplot(2,2,3);plot(ustcaddaObj.ad_list(2).I);
%         subplot(2,2,4);plot(ustcaddaObj.ad_list(2).Q);
%     end
    disp(toc);
end
%% other
a = zeros(1,nrepeat);
p = zeros(1,nrepeat);
temp = zeros(1,nrepeat);
for k = 1:nrepeat
a(k) = abs(db(k).s);
p(k) = angle(db(k).s);
temp(k) = db(k).temp;
end
subplot(3,1,1)
plot(a);
subplot(3,1,2)
plot(p);
subplot(3,1,3)
plot(temp);
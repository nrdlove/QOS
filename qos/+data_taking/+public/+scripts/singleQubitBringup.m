% bring up qubits one by one
% Yulin Wu, 2017/3/11
%%
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
%%
qNames = allQNames();
readoutFreqs = getQSettings('r_fr');
%% just in case the hardware dose not startup with zero dc output, we set the output of qubit dc channels to zero
setQSettings('zdc_amp',0);
for ii = 1:numel(qNames)
    % set to the dc value in registry:
	setZDC(qNames{ii});
    % or set to an specifice value
    % setZDC(qNames{ii},0); 
end
%% s21 vs power with network analyzer
qubitIndex = 10;
data_taking.public.s21_scan_networkAnalyzer(... % 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-4e6,'stopFreq',readoutFreqs(qubitIndex)+4e6,...
      'numFreqPts',501,'avgcounts',30,...
      'NAPower',[-30:1:10],'bandwidth',30e3,...
      'notes','attenuation:20dB','gui',true,'save',true);
%% s21 vs qubit dc bias with network analyzer
qubitIndex = 1;
s21_zdc_networkAnalyzer('qubit',qNames{qubitIndex},...% 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-0.1e6,'stopFreq',readoutFreqs(qubitIndex)+0.6e6,...
      'numFreqPts',101,'avgcounts',20,'NApower',-2,...
      'biasAmp',[-3.2e4:200:3.2e4],'bandwidth',30e3,...
      'gui',true,'save',true);
%% s21 with DAC, a coarse scan to find all the qubit readoutFreqs
amp = 3e4; % logspace(log10(1000),log10(32768),20);
freq = 6.55e9:0.5e6:7.1e9;
s21_rAmp('qubit',qNames{1},'freq',freq,'amp',amp,...
      'notes','attenuation:20dB','gui',true,'save',true);
%% finds all qubit readoutFreqs automatically by fine s21 scan, session/public/autoConfig.readoutResonators.* has to be properly set for it to work
[readoutFreqs, pkWithd] = auto.qubitreadoutFreqs();
% after this you need to order the readoutFreqs in accordance with the qNames
% names and input the readoutFreqs value to r_fr in registry for each qubit:
%% if all readoutFreqs are found correctly, save them to r_fr and r_freq in registry for each qubit:
for ii = 1:numel(qNames)
    % r_fr, the qubit dip frequency, it's exact value changes with qubit state and readout power,
    % the value of r_fr is just a reference frequency for automatic
    % routines.
    setQSettings(qNames{ii},r_fr,value); 
    % also set r_freq is the frequency of the readout pulse, it is slightly
    % different than the qubit dip frequency, but at the beginning of the
    % meausrement, set it to the qubit dip frequency is OK.
    setQSettings(qNames{ii},r_freq,value); 
end
%%  s21 vs power with DAC to finds the dispersive shift, loop over all quits.
amp = logspace(log10(1000),log10(32768),20);
for ii = 1:10
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0.5e6:0.05e6:readoutFreqs(ii)+1e6],'amp',amp,...
      'notes','attenuation:20dB','gui',true,'save',true);
end
%%
s21_zdc('qubit', qNames{4},...
      'freq',[readoutFreqs(4)-3.5e6:0.1e6:readoutFreqs(4)+1e6],'amp',[-3e4:1.5e3:3e4],...
      'gui',true,'save',true);
%%
s21_zpa('qubit', 'q4',...
      'freq',[readoutFreqs(4)-2.2e6:0.15e6:readoutFreqs(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);
%% spectroscopy1_zpa_s21
% for ii = 1:numel(qNames)
% 	setZDC(qNames{ii},1e4);
% end
% setZDC(qNames{7},3000);
for ii = 2
spectroscopy1_zpa_s21('qubit',qNames{ii},...
       'biasAmp',[0],'driveFreq',[5.85e9-0e6:0.2e6:6.15e9+0e6],...
       'gui',true,'save',true);
end
% spectroscopy1_zpa_s21('qubit','q2'); % lazy mode
%%
spectroscopy1_zpa('qubit','q2',...
       'biasAmp',[10000],'driveFreq',[6.033e9-3e6:0.2e6:6.033e9+3e6],...
       'gui',true,'save',true);
%%
%q2zAmp2f01 =@(x) - 1.398*(x-500).^2 - 2.634e+04*(x-500) + 5.982e+09;
q2zAmp2f01 =@(x) - 1.397*x.^2 - 2.695e+04*x + 5.977e+09;
q2zAmp2f01_ = @(x)q2zAmp2f01(x+5800);
q7zAmp2f01 =@(x) - 1.629*x.^2 + 2857*x + 5.794e+09;
spectroscopy1_zpa_bndSwp('qubit','q2',...
       'swpBandCenterFcn',q2zAmp2f01_,'swpBandWdth',100e6,...
       'biasAmp',[-1e4:100:2e4],'driveFreq',[4.8e9:0.25e6:6.15e9],...
       'gui',false,'save',true);
% spectroscopy1_zpa_bndSwp('qubit','q2',...
%        'swpBandCenterFcn',q2zAmp2f01,'swpBandWdth',120e6,...
%        'biasAmp',[6000:50:9750],'driveFreq',[5.56e9:0.2e6:5.77e9],...
%        'gui',false,'save',true);
%%
spectroscopy1_zdc('qubit','q7_c',...
       'biasAmp',[0:2:10],'driveFreq',[5.81044e9-10e6:0.2e6:5.81044e9+5e6],...
       'gui',true,'save',true);
%%
rabi_amp1('qubit','q2','biasAmp',0,'biasLonger',20,...
      'xyDriveAmp',[0:500:3e4],'detuning',[0],'driveTyp','X',...
      'dataTyp','P','gui',true,'save',false);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
rabi_long1('qubit','q2','biasAmp',0,'biasLonger',0,...
      'xyDriveAmp',1e4,'xyDriveLength',[0:2:100],...
      'dataTyp','P','gui',true,'save',false);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
ramsey('qubit','q2','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:4:2e3],'detuning',[-5]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
spin_echo('qubit','q2','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:2:10e3],'detuning',[-5]*1e6,...
      'notes','','gui',true,'save',true);
%%
T1_1('qubit','q2','biasAmp',[0],'biasDelay',20,'time',[0:200:10e3],...
      'gui',true,'save',true);
%%
resonatorT1('qubit','q2',...
      'swpPiAmp',1.8e3,'biasDelay',16,'swpPiLn',28,'time',[0:10:2000],...
      'gui',true,'save',true)
%%
tuneup.APE('qubit','q2',...
      'phase',-pi:pi/15:pi,'numI',3,...
      'gui',true,'save',true);
%%
photonNumberCal('qubit','q2',...
'time',[-500:50:4e3],'detuning',[-300e6:5e6:300e6],...
'r_amp',[],'r_ln',[],...
'ring_amp',[],'ring_w',[],...
'gui',true,'save',true);
%%
zDelay('qubit','q2','zAmp',5000,'zLn',[],'zDelay',[-50:1:50],...
       'gui',true,'save',true)
%%
delayTime = [[0:1:20],[21:2:50],[51:5:100],[101:10:500],[501:50:3000]];
delayTime = [0:5:1e3];
zPulseRipple('qubit','q2',...
        'delayTime',delayTime,...
       'zAmp',0e4,'gui',true,'save',true);
%%
state = '|0>-i|1>';
data = singleQStateTomo('qubit','q2','reps',2,'state',state);
rho = sqc.qfcns.stateTomoData2Rho(data);
h = figure();bar3(real(rho));h = figure();bar3(imag(rho));
%%
gate = 'Y/2';
data = singleQProcessTomo('qubit','q2','reps',2,'process',gate);
chi = sqc.qfcns.processTomoData2Rho(data);
h = figure();bar3(real(chi));h = figure();bar3(imag(chi));
%%
numGates = 1:1:20;
[Pref,Pi] = randBenchMarking('qubit','q2',...
       'process','X','numGates',numGates,'numReps',20,...
       'gui',true,'save',true);
%%
tuneup.zpls2f01('qubit','q7','maxBias',35e3 ,'gui',true,'save',false);
%%

%% automatic function, after previous steps pined down qubit parameters, 
q = qNames{2};
tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save',true);
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%%
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'AE',true,'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
%%
zdc2f01('qubit','q7_c','gui',true,'save',true);

  
  
  
function s21_CompJPAOnOff_networkAnalyzer(varargin)

    args = qes.util.processArgs(varargin,{'gui',false,'notes','','save',true});
    
data0=data_taking.public.jpa.s21_BiasPwrpPwrs_networkAnalyzer('jpaName',args.jpaName,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',2e9,'pumpPower',-30,...
    'bias',args.bias,...
    'notes','JPA OFF','gui',false,'save',true);
data1=data_taking.public.jpa.s21_BiasPwrpPwrs_networkAnalyzer('jpaName',args.jpaName,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',args.pumpFreq,'pumpPower',args.pumpPower,...
    'bias',args.bias,...
    'notes','JPA ON','gui',false,'save',true);

figure;
data=log10(abs(data1.data{1,1}{1,1}(1,:)))*20-log10(abs(data0.data{1,1}{1,1}(1,:)))*20;
freqs=linspace(args.startFreq,args.stopFreq,args.numFreqPts);
plot(freqs,data,'-')
xlabel('Freq (Hz)')
ylabel('Amplified (dB)')
title(['JPA On/Off @ B=' num2str(args.bias,'%.2e') 'A, P=' num2str(args.pumpPower) 'dBm'])

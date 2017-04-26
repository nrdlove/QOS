%% JPA bringup
data=data_taking.public.jpa.s21_BiasPwrpPwrs_networkAnalyzer('jpaName','impa1',...
    'startFreq',4e9,'stopFreq',8e9,...
    'numFreqPts',401,'avgcounts',20,...
    'NAPower',-20,'bandwidth',3e3,...
    'pumpFreq',[],'pumpPower',[],...
    'bias',[-1e-3:1e-4:1e-3],...
    'notes','Check JPA alive��40dB @ RT','gui',true,'save',true);
%%
delt=1.05;
if exist('Data','var') && numel(Data)==1 % Analyse loaded data
    Data = Data{1,1};
    bias = SweepVals{1,1}{1,1};
    freqs = Data{1,1}(2,:);
else % Analyse fresh data
    Data = data.data{1};
    bias = data.sweepvals{1,1}{1,1};
    freqs = Data{1,1}(2,:);
end
meshdata=NaN(numel(bias),numel(freqs));
for II=1:numel(bias)
    meshdata(II,:)=Data{II,1}(1,:);
end
ANG=unwrap(angle(meshdata'));
figure(11);imagesc(bias,freqs,abs(meshdata'));  set(gca,'ydir','normal');xlabel('JPA bias');ylabel('Freq'); title('|S21|')
slop=(mean(ANG(end,:))-mean(ANG(1,:)))/(freqs(end)-freqs(1))*delt;
slops=meshgrid(slop*(freqs-freqs(1)),ones(1,numel(bias)))';
ANGS=mod(ANG-slops-(ANG(1,end))+pi,2*pi);
figure(12);imagesc(bias,freqs,ANGS);  set(gca,'ydir','normal');xlabel('JPA bias');ylabel('Freq');colorbar;title('unwraped phase')
%%
data=data_taking.public.jpa.s21_BiasPwrpPwrs_networkAnalyzer('jpaName','impa1',...
    'startFreq',4e9,'stopFreq',8e9,...
    'numFreqPts',4001,'avgcounts',1,...
    'NAPower',-20,'bandwidth',10e3,...
    'pumpFreq',14e9,'pumpPower',-30:0.5:10,...
    'bias',0,...
    'notes','Check JPA alive','gui',true,'save',true);
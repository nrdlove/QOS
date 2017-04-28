function varargout = resonatorT1(varargin)
% resonatorT1: resonator T1
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% 
% <_o_> = resonatorT1('qubit',_c&o_,...
%       'swpPiAmp',_f_,'biasDelay',biasDelay,'swpPiLn',_i_,...
%       'backgroundWithZBias',b,...
%       'time',[_i_],'r_avg',<_i_>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017/4/28

fcn_name = 'data_taking.public.xmon.resonatorT1'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r_avg',[],'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes',''});
q = data_taking.public.util.getQubits(args,{'qubit'});

if ~isempty(args.r_avg) %add by GM, 20170416
    q.r_avg=args.r_avg;
end

X = gate.X(q);
I1 = gate.I(q);
I1.ln = X.length+args.biasDelay;
I2 = gate.I(q);
I2.ln = X.length+args.biasDelay;
Z = op.zBias4Spectrum(q);
Z.amp = args.swpPiAmp;
Z.ln = args.swpPiLn;
function proc = procFactory(delay)
	I2.ln = delay;
	proc = Z*I2*Z*I1;
end
R = measure.rReadout4T1(q,X.mw_src{1},false);

y = expParam(@procFactory);
y.name = [q.name,' decay time(da sampling interval)'];
y.auxpara = X;
y.callbacks ={@(x_) x_.expobj.Run(); @(x_) x_.auxpara.Run()};

function rerunZ()
    proc_ = procFactory(y.val);
    proc_.Run();
end
if args.backgroundWithZBias
    R.postRunFcns = @rerunZ;
end

y_s = expParam(R,'delay');
y_s.offset = X.length;

s1 = sweep({y,y_s});
s1.vals = {args.time,args.time};
e = experiment();
e.name = 'Resonator T1';
e.sweeps = s1;
e.measurements = R;
e.datafileprefix = sprintf('%s',q.name);
if ~args.gui
    e.showctrlpanel = false;
    e.plotdata = false;
end
if ~args.save
    e.savedata = false;
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
e.Run();
varargout{1} = e;
end
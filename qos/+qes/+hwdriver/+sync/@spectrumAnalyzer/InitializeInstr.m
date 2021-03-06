function [varargout] = InitializeInstr(obj)
    % Initialize instrument
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    ErrMsg = '';
    if strcmp(obj.interfaceobj.Status,'open')
        fclose(obj.interfaceobj);
    end
    switch TYP
        case{'agilent_N9030B'}
            %%% Keysight Technologies, N9030B default byte order is big endian
            obj.interfaceobj.InputBufferSize = 1024*1024;
            obj.interfaceobj.Timeout = 30;
            obj.interfaceobj.ByteOrder = 'bigEndian';
            %%%
        case{'tek_rsa607a'}
            obj.interfaceobj.InputBufferSize = 1024*1024;
            obj.interfaceobj.Timeout = 30;
    end
    fopen(obj.interfaceobj);
    varargout{1} = ErrMsg;
    fprintf(obj.interfaceobj,'*RST');
end
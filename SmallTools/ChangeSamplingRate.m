function [ out ] = ChangeSamplingRate( in, fs_initial, fs_target )


[P,Q] = rat(fs_target/fs_initial);
abs(P/Q*fs_initial-fs_target);
out = resample(in,P,Q);


end


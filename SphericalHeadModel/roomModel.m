function [outL, outR] = roomModel( in, inL, inR, reflexion_delay, reflexion_amp, fs, L )
% Room model from Brown and Duda.
% Single, psychoacoutically/spatially non-processed, reflexion

% Note: beacuse of the reflexion (reflexion_delay in samples is longer than 200), output HRIR becomes now a "BRIR" of 
% longer signal length.

% reflexion signal
delay_samp = reflexion_delay / 1000 * fs; % 10 ms = 662 samples at 44100 Hz SP
delay_samp = round(delay_samp); % [delete once fractional delay is implemented]
ref_sig = [zeros(delay_samp, 1); db2mag(-reflexion_amp)*in(1:4)];  % !!!!! TO DO: IMPLEMENT FRACTIONAL DELAY !!!!!!

% zero pad HRIR and add reflexion
outL = ref_sig + [inL; zeros(length(ref_sig)-L, 1)];
outR = ref_sig + [inR; zeros(length(ref_sig)-L, 1)];


end 


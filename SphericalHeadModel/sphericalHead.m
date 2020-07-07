function [out, delay] = sphericalHead(in, M, D, S, a, alfa_min, theta_min, fs, frac)
% in       : signal input
% M        : position listener
% D        : position ear
% s        : vector center of head to source
% a        : radius head
% alfa_min : algo constant
% theta_min: algo constant
% fs       : sampling frequency
% frac     : boolean for processing with fractional delay

% observation angle for direct path -> equation 7
e = D - M; % vector from head center to ear
s = (S - M) / norm(S - M);
theta_D = acos(dot(s, e)/a);

% direct path processing
direct_out = head_shadow(in, theta_D, a, alfa_min, theta_min, fs);

[out, delay] = head_itd(direct_out, theta_D, a, fs, frac);

end
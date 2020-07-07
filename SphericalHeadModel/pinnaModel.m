function [ out ] = pinnaModel( in, az, el, fs, L, k )
% Pinna model from brown and duda
% Consisting of the direct sound + 5 reflexions

% pinna constants
rho = [0.5, -1, 0.5, -0.25, 0.25];
A = [1, 5, 5, 5, 5]; % in samples
B = [2, 4, 7, 11, 13]; % in samples
D12 = [1, 0.5, 0.5, 0.5, 0.5; 0.85, 0.35, 0.35, 0.35, 0.35];

% choose between D1 or D2, different pinna coefficients
if nargin > 5
    D = D12(k,:);
else
    D = D12(1,:);
end

% compute rounded delays, in samples, relative to azimuth and elevation angles
tau = zeros(1, 5);
for i = 1:5
    tau(i) = ( (A(i)*cos(az/2)*sin(D(i)*(deg2rad(90)-el)) + B(i)) );
    tau(i) = round(tau(i)); % once frac delay implemented, can delete the rounding
    if tau(i) == 0
        tau(i) = 1;
    end
end

% signal delay and amplitude
out = in;
for i = 1:5
    out = out + [zeros(tau(i), 1); rho(i)*in(1:L-tau(i))];   % !!!!! TO DO: IMPLEMENT FRACTIONAL DELAY !!!!!!
end

end


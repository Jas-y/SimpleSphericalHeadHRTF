function out = head_shadow(in, theta, a, alfa_min, theta_min, fs)
% head shadow effect Duda and Brown

c = 343;
T = 1/fs;

alfa = (1+alfa_min/2) + (1-alfa_min/2)*cos(theta/theta_min*pi);
% theta_flat = theta_min*(0.5+1/pi*asin(alfa_min/(2-alfa_min))); % in rad
tau = 2*a/c;

% shadow filter
b_coeff = [2*alfa*tau+T, T-2*alfa*tau];
a_coeff = [2*tau+T, T-2*tau];

%figure
%freqz(b_coeff, a_coeff)

out = filter(b_coeff, a_coeff, in);

% alfa_l = 1-sin(theta);
% alfa_r = 1+sin(theta); % note: alfa_l + alfa_r = 2

% b_shadow_l = [2*alfa_l+tau, tau/fs-2*alfa_l]; % shadow filter coefficients
% b_shadow_r = [2*alfa_r+tau, tau/fs-2*alfa_r];
% a_shadow = [2+tau/fs, tau/fs-2]; % denominator is constant
% 
% out_l = filter(b_shadow_l, a_shadow, in);
% out_r = filter(b_shadow_r, a_shadow, in);

end


function [out, delay] = head_itd(in, theta, a, fs, frac)
% ITD from Duda and Brown
% in cascade after the head shadow filter
% here we use vertical-polar coordinate system -> theta [-180; 180]

% constants
c = 343; % speed of sound [m/s]
ac = a/c;
initial_padding = 20; % adding 20 null samples before each HRIR

if abs(theta) < pi/2
    delay = -ac*cos(theta)+ac; % adding ac to the result in order to have positive delays and keep the system causl, the ITD stays the same.
else
    delay = ac*(abs(theta)-pi/2)+ac;
end

% convert time-delays to samples
delay_samp = delay*fs;

if frac                     % !!!!! TO DO: IMPLEMENT FRACTIONAL DELAY !!!!!! (without DSP toolbox)
    % fractional delay 
    base_delay = floor(delay_samp);
    frac_delay = delay_samp - base_delay;
    h = dfilt.delay(base_delay);
    d = fdesign.fracdelay(frac_delay);
    ThirdOrderFrac = design(d,'lagrange','filterstructure','farrowfd');
    Hcas = dfilt.cascade(h, ThirdOrderFrac);
    out = filter(Hcas, in);
else
    % delay filter with rounding the delay to closest integer
    h = dfilt.delay(round(delay_samp));
    out = filter(h, in);
    out = [zeros(initial_padding, 1); out(1:(length(out)-initial_padding))];
end

%out = [out(1:150); zeros(50,1)];


% head_delay_max = round( ac(pi/2)+ac );
% 
% b_coeff = [zeros(1,delay_samp) 1 zeros(1,head_delay_max-delay_samp)];
% out = filter(b_coeff, 1, in);

% b_coeff_l = [zeros(1,delay_l) 1 zeros(1,head_delay_max-delay_l)];
% b_coeff_r = [zeros(1,delay_r) 1 zeros(1,head_delay_max-delay_r)];

% T_l = (a+a*theta)/c; % left delay
% T_r = (a-a*sin(theta))/c; % right delay
% if theta < 0
%     temp = T_l; % interchange delay if negative azimuth
%     T_l = T_r;
%     T_r = temp;
% end

end


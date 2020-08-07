% close all
clear

% Paper1: AN EFFICIENT HRTF MODEL FOR 3-D SOUND - C. Phillip Brown Richard 0. Duda
% Paper2: A Structural Model for Binaural Sound Synthesis - C. Phillip Brown and Richard O. Duda
% Paper3: Optimization and Prediction of the Spherical and Ellipsoidal ITD Model Parameters Using Offset Ears. - Hélène Bahu and David Romblom. “

%% "public" variables

X1 = 13.6474; % head width (default: KEMAR)
X3 = 19.7778; % head depth (default: KEMAR)
k = 1; % k = {1,2}, pinna number
az = 18; % [-180; 180] degrees (vertical-polar coordinate system with azimuth between [-180; 180] degrees)
el = 0; % [-90; 90] degrees
pinna = 1; % boolean. apply pinna processing
room = 0; % boolean. apply single reflexion (single "spatially unprocessed" echo). increases the length of the HRIR
reflexion_delay = 15; % echo delay in [ms]
reflexion_amp = 15; % echo attenuation in [dB]
frac = 0; % boolean. process with fractional delay. for now, no frac delay is implemented
L = 128; % number of samples of HRIR
export = 0; % boolean. 0 = no save data, 1 = save data

%% audio signal

fs = 44100;
[in_music, fs0] = audioread('trvf-open.wav');
in_music = ChangeSamplingRate(in_music, fs0, fs);
in_music = in_music(1:fs*15);

%% constants and setup

in = [1; zeros(L-1,1)]; % delta impulse

% constants
c = 343; % speed of sound
alfa_min = 0.1; % shadow cst
theta_min = 5*pi/6; % shadow cst (=150 degree)
theta_flat = theta_min*(0.5+1/pi*asin(alfa_min/(2-alfa_min))); % in rad

% anthropometric constants
X1 = X1/2;
X3 = X3/2;
a = (0.41*X1 + 0.22*X3 + 3.7) / 100; % optimal head radius (from linear regression) [Paper3]
% a = 0.0775; % head radius in [m]
e_b = 0.0094; % ear front shift // ear displacement according to [Paper3]
e_d = 0.021; % ear down shift
[D_l(1), D_l(2), D_l(3)] = sph2cart(atan(a/e_b), atan(a/e_d) - pi/2, a); % left ear position
[D_r(1), D_r(2), D_r(3)] = sph2cart(-atan(a/e_b), atan(a/e_d) - pi/2, a); % right ear position

% initialise positions/source direction
M = [0, 0, 0]; % center of head point
az_rad = deg2rad(az); % we are in the vertical-polar coordinate system
el_rad = deg2rad(el);
[x, y, z] = sph2cart(-az_rad, el_rad, 1);
x(abs(x) < eps) = 0;
y(abs(y) < eps) = 0;
z(abs(z) < eps) = 0;
S = [x, y, z]; % source point 
% S = [4, 6, 1.8];

%% audio processing
% HEAD -> PINNA -> ROOM

% spherical head (head shadow + itd)
[head_l, delay_l] = sphericalHead(in, M, D_l, S, a, alfa_min, theta_min, fs, frac);
[head_r, delay_r] = sphericalHead(in, M, D_r, S, a, alfa_min, theta_min, fs, frac);

% pinna
if pinna
    [az, el] = nav2sph(az, el); % to have az in interval [0,360]
    [az_vert, el_vert] = sph2hor(az, el); % conversion to interaural-polar coordinate system
    if el_vert > 90
        el_vert = 180 - el_vert; % project to frontal half sphere
    end
    az_vert_rad = deg2rad(az_vert);
    el_vert_rad = deg2rad(el_vert);
    head_l = pinnaModel( head_l, az_vert_rad, el_vert_rad, fs, L, k );
    head_r = pinnaModel( head_r, az_vert_rad, el_vert_rad, fs, L, k );
end

% room model
if room
    [head_l, head_r] = roomModel( in, head_l, head_r, reflexion_delay, reflexion_amp, fs, L );
end

%% plot

% figure
% plot(head_l)
% hold on
% plot(head_r)
% legend('left', 'right')
fftPlot([head_l'; head_r'], fs, {'left', 'right'})

%% listen

output(:,1) = convolveFFT(in_music, head_l);
output(:,2) = convolveFFT(in_music, head_r);
output = output/max(abs(output(:)));
% soundsc(output, fs)

%% generate dataset according to Jesper's format

min_phase = 0; % boolean. 1 = minimum phase HRIRs, 0 = keep delays in HRIRs

[ MP_L, MP_R, GD_L, GD_R, S ] = ConvertToHRIRdatabase( L, M, D_l, D_r, a, k, alfa_min, theta_min, fs, frac, min_phase, pinna );

% plot all azimuths spectrum
figure;imagesc_freq(MP_L(:,:,5),40,44100,0,'xlog');

% % 3D scatter plot of spatial points
% figure
% scatter3(S(:,1),S(:,2),S(:,3),'filled')
% view(40,35)

% save dataset
if export
    save('C:\Users\jytissieres\Documents\MATLAB\Spatial\SimpleSphericalHeadHRTF\HRIRdatasets\headSpherical', 'MP_L', 'MP_R', 'GD_L', 'GD_R');
end

%% convert to SOFA file

if export
    SphercialHead2CIPIC('C:\Users\jytissieres\Documents\MATLAB\Spatial\SimpleSphericalHeadHRTF\HRIRdatasets\sofaHRIRs', L, M, D_l, D_r, a, k, alfa_min, theta_min, fs, frac );
end


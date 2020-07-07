function [ MP_L, MP_R, GD_L, GD_R ] = ConvertToHRIRdatabase( L, M, D_l, D_r, a, k, alfa_min, theta_min, fs, frac, min_phase )
% Generates dataset of spherical head HRIR

in = [1; zeros(L-1,1)]; % delta impulse

% azimuth and elevation angles
azimuths = 0:2:360;
elevations = 90:-22.5:-45;
[p, q] = meshgrid(azimuths, elevations);
pairs = [p(:) q(:)];

matrix_l = zeros(L, 181, 7); % format: (samples, az, el)
matrix_r = zeros(L, 181, 7);

delays_l = zeros(181, 7);
delays_r = zeros(181, 7);

for i = 1:length(pairs)
    [az, el] =  sph2nav(pairs(i,1), pairs(i,2)); % az [-180, 180]
    az_rad = deg2rad(az);
    el_rad = deg2rad(el);
    [x, y, z] = sph2cart(-az_rad, el_rad, 1);
    
    % remove noise below eps
    x(abs(x)<eps)=0;
    y(abs(y)<eps)=0;
    z(abs(z)<eps)=0;
    
    % source position
    S = [x, y, z];
    
    % spherical head (head shadoe + itd)
    [head_l, delay_l] = sphericalHead(in, M, D_l, S, a, alfa_min, theta_min, fs, frac);
    [head_r, delay_r] = sphericalHead(in, M, D_r, S, a, alfa_min, theta_min, fs, frac);
    
    % pinna
    [az, el] = nav2sph(az, el); % az back to [0, 360]
    [az_vert, el_vert] = sph2hor(az, el); % conversion to interaural-polar coordinate system
    if el_vert > 90
        el_vert = 180 - el_vert; % project to frontal half sphere
    end
    az_vert_rad = deg2rad(az_vert);
    el_vert_rad = deg2rad(el_vert);
    head_l = pinnaModel( head_l, az_vert_rad, el_vert_rad, fs, L, k );
    head_r = pinnaModel( head_r, az_vert_rad, el_vert_rad, fs, L, k );
    
    % conversion to minimum phase
    if min_phase
        hrtf_l = fft(head_l);
        hrtf_r = fft(head_r);
        hrtf_l_mps = mps(hrtf_l);
        hrtf_r_mps = mps(hrtf_r);
%         hrtf_l_mps_phase = angle(hrtf_l_mps);
%         hrtf_r_mps_phase = angle(hrtf_r_mps);
%         hrtf_l_mps = abs(hrtf_l_mps).*exp(1i*hrtf_l_mps_phase);
%         hrtf_r_mps = abs(hrtf_r_mps).*exp(1i*hrtf_r_mps_phase);       
        head_l = ifft(hrtf_l_mps, 'symmetric');
        head_r = ifft(hrtf_r_mps, 'symmetric');
    end
    
    % store in matrices
    az_idx = find(azimuths == round(az, 1));
    el_idx = find(elevations == round(el, 1));
    matrix_l(:, az_idx, el_idx) = head_l;
    matrix_r(:, az_idx, el_idx) = head_r;
    delays_l(az_idx, el_idx) = delay_l * fs; % in samples
    delays_r(az_idx, el_idx) = delay_r * fs;
end

% normalize
matrix_l = matrix_l/max(matrix_l(:));
matrix_r = matrix_r/max(matrix_r(:));

% return
MP_L = matrix_l;
MP_R = matrix_r;
GD_L = delays_l;
GD_R = delays_r;

end



















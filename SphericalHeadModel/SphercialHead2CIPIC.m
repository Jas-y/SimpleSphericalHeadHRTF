function SphercialHead2CIPIC( filePath, L, M, D_l, D_r, a, k, alfa_min, theta_min, fs, frac )
% Computes HRIR for CIPIC coordinates and then converts the dataset to SOFA file format

% delta impulse
in = [1; zeros(L-1,1)];

% CIPIC plus stategic points
azimuths = [-90 -80 -65 -55 -45:5:45 55 65 80 90];
elevations = [-90 -45 + 5.626*(0:49) 270];

% angle pairs
[p, q] = meshgrid(azimuths, elevations);
pairs = [p(:) q(:)];

% initialize matrices
matrix_l = zeros(27, 52, L);
matrix_r = zeros(27, 52, L);

% computing loop
for i = 1:length(pairs)
    % conversion to vertical-polar coordinate system
    [az, el] =  hor2sph(pairs(i,1), pairs(i,2));
    if az > 180 % to have -180:180
        az = az - 360;
    end
    [x, y, z] = sph2cart(-deg2rad(az), deg2rad(el), 1);
    
    % remove noise below eps
    x(abs(x)<eps)=0;
    y(abs(y)<eps)=0;
    z(abs(z)<eps)=0;
    
    S = [x, y, z];
    
    % spherical head (head shadoe + itd)
    [head_l, delay_l] = sphericalHead(in, M, D_l, S, a, alfa_min, theta_min, fs, frac);
    [head_r, delay_r] = sphericalHead(in, M, D_r, S, a, alfa_min, theta_min, fs, frac);
    
    % pinna
    [az, el] = nav2sph(az, el); % az back to [0, 360]
    [az_vert, el_vert] = sph2hor(az, el); % conversion back to interaural-polar coordinate system
    if el_vert > 90
        el_vert = 180 - el_vert; % project to frontal half sphere
    end
    az_vert_rad = deg2rad(az_vert);
    el_vert_rad = deg2rad(el_vert);
    head_l = pinnaModel( head_l, az_vert_rad, el_vert_rad, fs, L, k );
    head_r = pinnaModel( head_r, az_vert_rad, el_vert_rad, fs, L, k );
    
    % store in matrices
    [~, az_idx] = min(abs(azimuths - pairs(i,1)));
    [~, el_idx] = min(abs(elevations - pairs(i,2)));
    matrix_l(az_idx, el_idx, :) = head_l;
    matrix_r(az_idx, el_idx, :) = head_r;
    
end

% normalize
matrix_l = matrix_l/max(matrix_l(:));
matrix_r = matrix_r/max(matrix_r(:));

% conversion to SOFA
cipic.hrir_l = matrix_r; % had to inverse left and right
cipic.hrir_r = matrix_l;
cipic.name = 'headSphere101';
perso2sofa('sphericalHeadCIPIC', cipic, filePath)

end


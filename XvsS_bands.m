clc; clear; close all;
% LunaNet Link Budget Calculation
% Hunter Adams - 11.24.19

fprintf("S-band and X-band for Proximity Connections");

% General Inputs

% Elevation Angle
elev_angle = 90; % deg / Input
rad_moon = 1737; % km / Input
alt_sat = 700;  % km / Input
alt_ground = 0.002; % km / Input
lat_ground = 89.54; % deg / Input


a11 = [2, 2];
b11 = [2.2, 8.4];
c11 = [6, 6];
d11 = [45, 45];

for z = 1:2
    
    
% Transmitter Information
trans_power = a11(z);  % watts / Input
return_loss = -20*log10(0.239543726);  % dB
return_loss_power = trans_power; % watts
trans_power2 = 10*log10(return_loss_power);  % dBW
frequency = b11(z); % GHz / Input
trans_ant_gain = c11(z); % dBi / Input
trans_ant_beamw = d11(z); % deg
ant_point_loss1 = 2; % dB
circuit_loss1 = .1; % dB
EIRP = trans_power2 + trans_ant_gain + ant_point_loss1 + circuit_loss1;  % dBW
a = 1;     
b = -2*rad_moon*cos(pi/2+elev_angle*pi/180);
c = rad_moon^2-(rad_moon+alt_sat)^2;
range = (-b+sqrt(b^2-4*a*c))/(2*a);  % km
free_space_loss = 87.6-20*log10(range*frequency*1000000000);  % dB / Input
atmospheric_attenuation = 0;  % dB / Input

% Reciever Information
rec_ant_diam = .2;   % meters / Input
ant_eff = 0.6;   %(percentage) / Input
rec_ant_gain = 10*log10((ant_eff./100)*(pi*rec_ant_diam/(0.03/frequency))^2);% dB
rec_ant_beamw = 21/(frequency*rec_ant_diam);  % deg
ant_point_loss2 = 0;  % dB
radome_loss = 0;  % dB
polarization_loss = 0;  % dB
circuit_loss2 = 0;   % dB
Pt = EIRP + free_space_loss + atmospheric_attenuation + rec_ant_gain + polarization_loss + ...
    ant_point_loss2 + circuit_loss2 + radome_loss;  % dBW
sys_noise_temp = 350;                                                       % K / Input
sys_noise_temp2 = 10*log10(sys_noise_temp);                                   % dB

% Link Margin Calculation

rec_GT = rec_ant_gain + polarization_loss + ant_point_loss2 + radome_loss + circuit_loss2 - ...
    sys_noise_temp2;                                                        % dB/K
No = sys_noise_temp2 - 228.602;                                             % dBw/Hz
PrNo = EIRP + free_space_loss + rec_ant_gain + 228.6 - sys_noise_temp2;     % dB
bit_rate = 6;                                                             % Mbps / Input
bit_rate2 = 10*log10(bit_rate*1000000);                                       % dB
EbNo_avail = PrNo - bit_rate2;                                              % dB     
EbNo_req = .5;                                                             % dB / Input
rec_sys_implementation_loss = 0;                                            % dB
if z == 1
    fprintf('\nThe S-Band Link Margin is: ')
    link_margin1 = EbNo_avail - EbNo_req + rec_sys_implementation_loss          % dB
else
    fprintf('\nThe X-band Link Margin is: ');
    link_margin2 = EbNo_avail - EbNo_req + rec_sys_implementation_loss
end
end

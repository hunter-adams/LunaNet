clc; clear; close all;

% Link Margin/Data Rate Optimization Algorithm

% Satellite Band Frequencies
band_freq = [2.2, 8.4, 15, 35]; % S-Band, X-Band, Ku-Band, Ka-Band
% Satellite Altitude
altitude = linspace(300, 5000, 100); % km
% Transmitter Power [Input]
trans_power = linspace(1,8,14); % watts
% Transmitter Antenna Gain
transmit_antenna_gain =  linspace(7,15,16); %dbi
% Reciever Antenna Diameter
rec_ant_diam = linspace (0.05, 0.25, 5); % m
% Reciever Antenna Efficiency
ant_eff = linspace(0.5,0.8,6); % percentage
% System Bit Rate
bit_rate = linspace(5,20,20); % Mbps

lunanet.band_freq = [];
lunanet.altitude = [];
lunanet.trans_power = [];
lunanet.transmit_antenna_gain = [];
lunanet.rec_ant_diam = [];
lunanet.ant_eff = [];
lunanet.bit_rate = [];


counter = 1;
for h = 1:length(band_freq)
    band_freq_FL = band_freq(h);
    for i = 1:length(altitude)
        altitude_FL = altitude(i);
        for j = 1:length(trans_power)
            trans_power_FL = trans_power(j);
            for k = 1:length(transmit_antenna_gain)
                transmit_antenna_gain_FL = transmit_antenna_gain(k);
                for l = 1:length(rec_ant_diam)
                    rec_ant_diam_FL = rec_ant_diam(l);
                    for m = 1:length(ant_eff)
                        ant_eff_FL = ant_eff(m);
                        for n = 1:length(bit_rate)
                            bit_rate_FL = bit_rate(n);
                            
                            lunanet.band_freq(counter) = band_freq_FL;
                            lunanet.altitude(counter) = altitude_FL;
                            lunanet.trans_power(counter) = trans_power_FL;
                            lunanet.transmit_antenna_gain(counter) = transmit_antenna_gain_FL;
                            lunanet.rec_ant_diam(counter) = rec_ant_diam_FL;
                            lunanet.ant_eff(counter) = ant_eff_FL;
                            lunanet.bit_rate(counter) = bit_rate_FL;
                            counter = counter + 1;
                            
                        end
                    end
                end
            end
        end
    end
end

lunanet.link_margin = [];

for o = 1:(counter-1)
    
    % Elevation Angle [Input]
    elev_angle = 80;% deg
    % Originally 90 because orbit is polar. Selva said that was optomistic,
    % reduced to 80 bc of feedback.
    
    % Radius of the Moon/Planetary Body [Input]
    rad_moon = 1737.1;% km
    
    % Altitude of the Ground Station [Input - Shackelton Crater]
    alt_ground = 0.002;  % km
    
    % Latitude of the Ground Station [Input - Shackelton Crater]
    lat_ground = 89.54;   % deg
    
    
    alt_sat = lunanet.altitude(o);
    
    % Transmitter Information _________________________________________
    % Transmitter Power [Input]
    trans_power = lunanet.trans_power(o);  % watts
    
    % Return Loss [Input]
    return_loss = -20*log10(0.239543726);  % dB
    
    % Return Loss Power [Calculation]
    return_loss_power = lunanet.trans_power(o);  % watts
    
    % Transmitter Power [Different Unit | Calculation]
    trans_power2 = 10*log10(return_loss_power);  % dBW
    
    % Frequency [Input]
    frequency = lunanet.band_freq(o);  % GHz
    
    % Transmitter Antenna Gain [Input]
    trans_ant_gain = lunanet.transmit_antenna_gain(o);    % dBi
    
    % Transmitted Antenna Beamwidth [Input] **Need to trace this**
    trans_ant_beamw = 47.72;   % deg
    
    % Antenna Pointing Loss [Input - Estimated]
    ant_point_loss1 = 2;  % dB
    
    % Circuit Loss [Input - Estimated]
    circuit_loss1 = 0.1;   % dB
    
    % Equivalent Isotropically Radiated Power [Calculation]
    EIRP = trans_power2 + trans_ant_gain + ant_point_loss1 + circuit_loss1; % dBW
    
    % Given Variable and Calculation
    a = 1;
    b = -2*rad_moon*cos(pi/2+elev_angle*pi/180);
    c = rad_moon^2-(rad_moon+alt_sat)^2;
    
    % Range [Calculation - Based on Quadratic Equation of a,b & c]
    range = (-b+sqrt(b^2-4*a*c))/(2*a);  % km
    
    % Free Space Loss [Calculation]
    free_space_loss = 87.6-20*log10(range*frequency*1000000000);  % dB
    
    % Atmospheric Attenuation [Input - None bc Moon has no atmosphere]
    atmospheric_attenuation = 0;  % dB
    
    
    
    % Reciever Information_____________________________________________
    % Reciever Antenna Diameter [Input]
    rec_ant_diam = lunanet.rec_ant_diam(o);   % meters
    
    % Antenna Efficiency [Input - Estimated]
    ant_eff = lunanet.ant_eff(o);  %(percentage)
    
    % Reciever Antenna Gain [Calculation]
    rec_ant_gain = 10*log10((ant_eff./100)*(pi*rec_ant_diam/(0.03/frequency))^2);% dB
    
    % Reciever Antenna Beamwidth [Calculation]
    rec_ant_beamw = 21/(frequency*rec_ant_diam); % deg
    
    % Reciever Antenna Poining Loss [Input - Estimated]
    ant_point_loss2 = 2; % dB
    
    % Radome Losses [Input - Estimated Insignificant]
    radome_loss = 0;  % dB
    
    % Polarization Losses [Input - Estimated Insignificant]
    polarization_loss = 0; % dB
    
    % Circuit Losses [Input - Estimated Insignificant]
    circuit_loss2 = 0.1;  % dB
    
    % Recieved Signal Power [Calculation]
    Pt = EIRP + free_space_loss + atmospheric_attenuation + rec_ant_gain + polarization_loss + ...
        ant_point_loss2 + circuit_loss2 + radome_loss;  % dBW
    
    % System Noise Temperature [Input - Estimated (Will vary for each
    % connection type even with same parts)]
    sys_noise_temp = 350;  % K
    
    % System Noise Temperature [Calculation - Different Unit]
    sys_noise_temp2 = 10*log10(sys_noise_temp);  % dB
    
    
    
    % Link Margin Calculation__________________________________________
    % Antenna Gain to Noise Temperature [Calculation]
    rec_GT = rec_ant_gain + polarization_loss + ant_point_loss2 + radome_loss + circuit_loss2 - ...
        sys_noise_temp2;  % dB/K
    
    % System Noise Spectral Density [Calculation]
    No = sys_noise_temp2 - 228.602;  % dBw/Hz
    
    % Signal to Noise Spectral Density Ratio [Calculation]
    PrNo = EIRP + free_space_loss + rec_ant_gain + 228.6 - sys_noise_temp2; % dB
    
    % Bit Rate [Input]
    bit_rate = lunanet.bit_rate(o);  % Mbps
    
    % Bit Rate [Calculation - Different Units]
    bit_rate2 = 10*log10(bit_rate*1000000); % dB
    
    % Energy per bit to noise power spectral density ratio Availible
    % [Calculation]
    EbNo_avail = PrNo - bit_rate2;  % dB
    
    % Energy per bit to noise power spectral density ratio Availible
    % [Calculation]
    EbNo_req = 1;  % dB / Input
    
    % Recieved System Implementation Loss [Input - Estimated Insignificant]
    rec_sys_implementation_loss = 0;  % dB
    
    % Link Margin [Caclulated]
    lunanet.link_margin(o) = EbNo_avail - EbNo_req + rec_sys_implementation_loss; % dB
    
end

usable_link_margins.link_margin = [];
usable_link_margins.lunanet_index = [];
counter2 = 1;
for p = 1:(counter-1)
  if lunanet.link_margin(p) > 3 
      usable_link_margins.link_margin(counter2) = lunanet.link_margin(p);
      usable_link_margins.lunanet_index(counter2) = p;   
      counter2 = counter2 + 1; 
  end
end

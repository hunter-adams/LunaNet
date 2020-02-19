clc; clear; close all;
% LunaNet Altitude vs. Number of Sats vs. Orbit Altitude Simulation for
% Proximity Communications(Lunar Surface & Lunar Orbit) 
% Hunter Adams - 2.9.20


% General Inputs

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



% ''Simulation''
plot_vals = [];

% S-Band Frequency struct creation
s_band.frequency = 2.2; %GHz
s_band.linkbudget = [];
s_band.altitude = [];
s_band.satellites = [];

% X-Band Frequency struct creation
x_band.frequency = 8.4;
x_band.linkbudget = [];
x_band.altitude = [];
x_band.satellites = [];


% for loop creation for varying band types
for band_freq = [s_band.frequency, x_band.frequency]
    
    i = 1; % iteration counter 1
    
    % for loop creation for varying Satellite Altitude [Input | km]
    for alt_sat = 100:10:2000
        
        if(band_freq == s_band.frequency)
        s_band.altitude(i,1) = alt_sat; % make altitude list for s-band
        else
        x_band.altitude(i,1) = alt_sat; % make altitude list for x-band
        end
        

        
        % Link Budget Calculation
            % For simulation using COTS Part TX-2400 S-Band Transmitter and
            % a 20cm Diameter In-House Parabolic Antenna (Values Estimated)
       
            
        % Transmitter Information _________________________________________
        % Transmitter Power [Input]
        trans_power = 2.5;  % watts 
        
        % Return Loss [Input]
        return_loss = -20*log10(0.239543726);  % dB
        
        % Return Loss Power [Calculation]
        return_loss_power = trans_power;  % watts
        
        % Transmitter Power [Different Unit | Calculation]
        trans_power2 = 10*log10(return_loss_power);  % dBW
        
        % Frequency [Input]
        frequency = band_freq;  % GHz 
        
        % Transmitter Antenna Gain [Input]
        trans_ant_gain = 8.953;    % dBi
        
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
        rec_ant_diam = .2;   % meters
        
        % Antenna Efficiency [Input - Estimated]
        ant_eff = 0.6;  %(percentage)
        
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
        bit_rate = 6;  % Mbps 
        
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
        link_margin = EbNo_avail - EbNo_req + rec_sys_implementation_loss; % dB
        
        % Storing Link Margin for Each Altitude for Each Frequency Type
        if(band_freq == s_band.frequency)
        s_band.linkbudget(i,1) = link_margin; % make altitude list for s-band
        else
        x_band.linkbudget(i,1) = link_margin; % make altitude list for x-band
        end
        

        
        % Number of Satellites Calculation
        alpha = alt_sat*tand(0.5*rec_ant_beamw);
        theta = 2*asind(alpha/rad_moon);
        arc = (theta/360)*2*pi*rad_moon;
        num_sat = (2*pi*rad_moon)/arc;
        
        if(band_freq == s_band.frequency)
        s_band.satellites(i,1) = floor(num_sat); % make altitude list for s-band
        else
        x_band.satellites(i,1) = floor(num_sat); % make altitude list for x-band
        end
        
        i=i+1;
    end
    

end

% prob = normcdf(0,[_____margin, adidtion of variances]);

figure(1)
scatter3(s_band.altitude, s_band.satellites,  s_band.linkbudget, '.b');
hold on;

title('Altitude vs. Link Magin vs. # of Sats');
scatter3(x_band.altitude, x_band.satellites, x_band.linkbudget, '.k');


% creating surface for minimum link margin
x = 50:2000;
y = 0:500;
[X,Y] = meshgrid(x,y);
Z(1:501,1:1951) = 3;
surf(X,Y,Z,'FaceAlpha',0.5,'FaceColor',[1 0 0],'EdgeColor','none');

% creating surface for max number os sattelites
x2 = 50:2000;
z2 = -5:30;
[X2,Z2] = meshgrid(x2,z2);
Y2(1:36,1:1951) = 18;
surf(X2,Y2,Z2,'FaceAlpha',0.5,'FaceColor',[0 1 0],'EdgeColor','none');

% creating surface for good link margin
x3 = 50:2000;
y3 = 0:500;
[X3,Y3] = meshgrid(x3,y3);
Z3(1:501,1:1951) = 12;
surf(X3,Y3,Z3,'FaceAlpha',0.3,'FaceColor',[0 1 1],'EdgeColor','none');

legend('S-Band (2.2 GHz)','X-Band (8.4 GHz)','Minimum System Link Margin','Max # of Satellites','Good System Link Margin');
xlabel('Altitude (km)'); ylabel('# of Sats'); zlabel('Link Margin (dB)');


% figure(2)
% stem3(s_band.altitude, s_band.linkbudget, s_band.satellites)
% grid on
% xv = linspace(min(s_band.altitude), max(s_band.altitude), 20);
% yv = linspace(min(s_band.linkbudget), max(s_band.linkbudget), 20);
% [X,Y] = meshgrid(xv, yv);
% Z = griddata(s_band.altitude,s_band.linkbudget,s_band.satellites,X,Y);
% 
% xlabel = ('Altitude (km)'); ylabel = ('Link Margin (dB)'); zlabel('# of Sats');
% title('Altitude vs. Link Magin vs. # of Sats');
% 
% figure(3)
% surf(X, Y, Z);
% grid on
% set(gca, 'ZLim',[0 100])
% shading interp








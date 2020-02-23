% optimum altitude tolerance data
% 15000 m degeneration is maximum tolerance.
%% deltav per stationkeeping maneuver
altitudes = 1000*linspace(6,12,7); %max allowable altitude degeneration
delv_sk = zeros(1,7);
timesteps = [3260847.923 3279600.523 5554961.343 5549923.266 5754906.431 7978687.879 8076009.214];
m2 = .07346e24; %mass of moon
G = 6.67408e-11; %universal gravitational constant.
u2 = G*m2; %gravitational constants.
for i = 1:1:length(altitudes)
    v1 = sqrt(2*u2*(1/(1738e3+700e3+altitudes(i))-1/(2*1738e3+700e3+700e3)));
    v2 = sqrt(2*u2*(1/(1738e3+700e3+altitudes(i))-1/(2*1738e3+700e3+700e3+altitudes(i))));
    v3 = sqrt(2*u2*(1/(1738e3+700e3)-1/(2*1738e3+700e3+700e3+altitudes(i))));
    v4 = sqrt(2*u2*(1/(1738e3+700e3)-1/(2*1738e3+700e3+700e3)));
    dv1 = v1-v2; dv2 = v4-v3;
    delv_sk(i) = abs(dv2)+abs(dv1);
end
missionlife = 365.25*8*24*3600;
N = double(int64(missionlife*timesteps.^-1)-1); %number of stationkeeping maneuvers
%% deltav for slot insertion (constant over altitude degeneration)
v4 = sqrt(2*u2*(1/(1738e3+700e3)-1/(2*1738e3+700e3+700e3)));
n4 = sqrt(u2/(1738e3+700e3)^3);
T4 = 2*pi/n4;
T5 = 18.03125/18*T4;
n5 = 2*pi/T5;
a5 = (u2/n5^2)^(1/3);
v5 = sqrt(2*u2*(1/(1738e3+700e3)-1/2/a5));
dv3 = v5-v4;
delv_si = dv3*2;
Tsi = T5*32; %time to correct
%% Total delta v for non-one-time maneuvers
delta_v = N.*(delv_sk+delv_si);
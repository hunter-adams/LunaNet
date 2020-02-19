        % Number of Satellites Calculation
      
        rad_moon = 1737.1;
        alt_sat = 700;
        rec_ant_beamw = 47.72;
        alpha = alt_sat*tand(0.5*rec_ant_beamw);
        theta = 2*asind(alpha/rad_moon);
        arc = (theta/360)*2*pi*rad_moon;
        num_sat = (2*pi*rad_moon)/arc
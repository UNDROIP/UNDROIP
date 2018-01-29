function [left_spd, right_spd, new_res] = speed_correct_eca(left_image, right_image, posXY, orig_res, varargin)
% Resamples side scan sonar image to target_res in both along- and across-track
% 
% Input- 
%
% sss_in : Eca (Klein) sonar structure generated by read_xtf_sonar_bath_eca
%
% target_res : wanted resolution in [m] typical 0.05 - 0.2
%
% Author: Fredrik Elmgren DeepVision [fredrik@deepvision.se]
% Project: SWARMs
% Date: Nov 04, 2016
%
% Tweaked for speed performance by MS Al-Rawi (al-rawi@ua.pt)
% 
% In this simple speed correction function we assume:
% * that speed is constant
% * pingrate is constant
% * scan is following a stright line (no turning)
% 
% These assumptions are only valid for the early trial data set
%
%
%
%
%
% Project SWARMs http://www.swarms.eu/
%
% License:
%=====================================================================
% This is part of the UNDROIP toolbox, released under
% the GPL. https://github.com/rawi707/UNDROIP/blob/master/LICENSE
% 
% The UNDROIP toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the UNDROIP toolbox.
%
% ======================================================================
%%

defaults.target_res = 0.1; % lower values will result in more resampling, thus, slower execution
args = propval(varargin, defaults);

sl = size(left_image);
nPing = sl(1); %Number of pings
nSample = sl(2); %Number of samples per ping

% Calculate distance between first and last ping
rlat1    = posXY(1,2) / 180 * pi;
rlon1    = posXY(1,1) / 180 * pi;
rlat2    = posXY(nPing,2) / 180 * pi;
rlon2    = posXY(nPing,1) / 180 * pi;

dlon_2   = .5*(rlon1-rlon2);
dlat_2   = .5*(rlat1-rlat2);
a        = (sin(dlat_2))^2 + cos(rlat2)*cos(rlat1)*(sin(dlon_2))^2;
c        = 2*asin( min(1,sqrt(a)) );
d        = 6.367e6*c; %EARTH_RADIUS*c;

% Resample across track
orgRange = nSample * orig_res;
new_n_samples_per_ping = round( orgRange / args.target_res );

% code added by Rawi starts here
  newLeft = resample( double(left_image)', new_n_samples_per_ping, nSample )';
  newRight = resample( double(right_image)' , new_n_samples_per_ping, nSample )';
% code by Rawi ends here
 
% Resample along track
new_number_of_ping = round( d / args.target_res );

% code added by Rawi starts here
left_spd  = resample( newLeft,  new_number_of_ping, nPing );
right_spd = resample( newRight, new_number_of_ping, nPing );
% code added by Rawi ends here

new_res = orgRange / new_n_samples_per_ping;





% Original code by Fredrik
%      code commented by Rawi starts here
%
% newLeft = zeros(nPing, new_n_samples_per_ping);
% newRight = zeros(nPing, new_n_samples_per_ping);
% 
% %  for p = 1:nPing
%      newLeft(p,:) = resample( double(left_image(p,:)), new_n_samples_per_ping, nSample );
%      newRight(p,:) = resample( double(right_image(p,:)), new_n_samples_per_ping, nSample );
%  end
% 
%      code commented by Rawi ends here



% code commented by Rawi starts here
% newLeft2  = zeros(new_number_of_ping, new_n_samples_per_ping);
% newRight2 = zeros(new_number_of_ping, new_n_samples_per_ping);
% 
% for s = 1:new_n_samples_per_ping
%      newLeft2(:,s)  = resample( newLeft(:,s),  new_number_of_ping, nPing );
%      newRight2(:,s) = resample( newRight(:,s), new_number_of_ping, nPing );
% end
% code commented by Rawi ends here
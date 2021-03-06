%=============================================================================
% Compute Cij for HTI model 
%=============================================================================

clear all;   close all;

%=============================================================================

Vp = 3.368;   Vs = 1.829;   epsilon = -0.22;   delta = -0.22;   gamma = -0.11;   
% Vp = 4.900;   Vs = 3.100;   epsilon = -0.22;   delta = -0.22;   gamma = -0.11;   
c33 = Vp^2  
c11 = c33*(1 + 2*epsilon)
c44 = Vs^2
c66 = c44*(1 + 2*gamma)
c13 = sqrt( 2*c33*(c33-c66)*delta + (c33-c66)^2 ) - c66
c23 = c33 - 2*c44

%=============================================================================



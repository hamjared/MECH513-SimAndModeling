function [mt L V mf] = tool4(y_vect,x_vect);
 
% Split up y_vect into all CA variables 
mt = y_vect(1);
L = y_vect(2);
V = y_vect(3);
mf = y_vect(4);
% Split up x_vect into all design variables 
Sw = x_vect(1);
t = x_vect(2); 

%  Tool X is made up of the following equation
C_d = 0.025;
rho = 1.2;
BSFC = 400;
efficiency = 0.85;
D = 0.5 * rho * C_d * Sw * V^2;
mf = BSFC/1000 * D*V/1000 * t * efficiency;

function [mt L V mf] = tool3(y_vect,x_vect);
 
% Split up y_vect into all CA variables 
mt = y_vect(1);
L = y_vect(2);
V = y_vect(3);
mf = y_vect(4);
% Split up x_vect into all design variables 
Sw = x_vect(1);
t = x_vect(2); 

%  Tool X is made up of the following equation
C_l = 0.5;
rho = 1.2;
V = sqrt(L/(0.5*rho*C_l*Sw));

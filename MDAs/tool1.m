function [mt L V mf] = tool1(y_vect,x_vect);
 
% Split up y_vect into all CA variables 
mt = y_vect(1);
L = y_vect(2);
V = y_vect(3);
mf = y_vect(4);
% Split up x_vect into all design variables 
Sw = x_vect(1);
t = x_vect(2); 

%  Tool X is made up of the following equation
wing_mass_slope = 6 ; % the wing mass scales as 6kg/m2
pilot_mass = 100; %kg
structure_mass = 800 ; %kg
mt = pilot_mass + mf + Sw*wing_mass_slope + structure_mass  ; % total mass is the sum of fuel mass, wing mass, baseline mass, pilot mass.



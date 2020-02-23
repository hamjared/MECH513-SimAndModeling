% Thomas Bradley, Colorado State University
% THIS PROGRAM COMPARES THE EXPERIMENTAL LIFT SLOPE OF AIRFOILS TO TWO
% TYPES OF AIRFOIL LIFT SLOPE MODELS: Thin Airfoil Theory, and
% Computational Fluid Dynamics.  The inputs to this program are the
% datafiles of the airfoil shapes (NACA***.txt), and the experimental
% validation experimental data (Sandia_Data.xls).  The outputs of this
% program are MATLAB variables ***AoA, which represents the angle of attack
% for each airfoil section model/experiment pair, and ***_CL, which
% represents the coefficient of lift for each airfoil section
% model/experiment pair.  

% Additional references: 
% https://en.wikipedia.org/wiki/Airfoil#Thin_airfoil_theory
% https://en.wikipedia.org/wiki/Angle_of_attack
% https://en.wikipedia.org/wiki/Lift_coefficient

clear 
close all;
airfoil_number = ['NACA0021']; % choose thin airfoil NACA0021, or thick airfoil NACA0012
x_foil_batch_v2(airfoil_number,160000);% Assemble the CFD batch code using airfoil geometry
dos run_Xfoil.bat; % run the CFD program at a MATLAB DOS prompt
[polar_out] = polar_maker_xfoil_NACA('Sandia_',airfoil_number);  % assemble the computational results

[data0012,TXT]=xlsread('SANDIA Data.xls','NACA0012 Re=160k'); % read in the experimental results
[data0015,TXT]=xlsread('SANDIA Data.xls','NACA0015 Re=160k');% read in the experimental results
[data0018,TXT]=xlsread('SANDIA Data.xls','NACA0018 Re=160k','');% read in the experimental results
[data0021,TXT]=xlsread('SANDIA Data.xls','NACA0021 Re=160k');% read in the experimental results




%%% Plotting of Results %%%
figure;  plot(polar_out(:,1), polar_out(:,2),'r.-')
hold on; plot(polar_out(:,1), 2*pi*deg2rad(polar_out(:,1)),'k.-')

xlabel('Angle of Attack, deg'); 
% hold on ; plot(polar_out(:,1), polar_out(:,3),'r')
ylabel('Lift Coefficient, C_L')
legend('Section Lift Coefficient Simulated')
hold on ; plot(data0012(:,1)-180, data0012(:,2),'bo'); plot(data0012(:,1), data0012(:,2),'bo')
% hold on ; plot(data0012(:,1)-180, data0012(:,3),'ro'); plot(data0012(:,1), data0012(:,3),'ro')
hold on ; plot(data0015(:,1)-180, data0015(:,2),'bo'); plot(data0015(:,1), data0015(:,2),'bo')
% hold on ; plot(data0015(:,1)-180, data0015(:,3),'ro'); plot(data0015(:,1), data0015(:,3),'ro')
hold on ; plot(data0018(:,1)-180, data0018(:,2),'bo'); plot(data0018(:,1), data0018(:,2),'bo')
% hold on ; plot(data0018(:,1)-180, data0018(:,3),'ro'); plot(data0018(:,1), data0018(:,3),'ro')
hold on ; plot(data0021(:,1)-180, data0021(:,2),'bo'); plot(data0021(:,1), data0021(:,2),'bo')
% hold on ; plot(data0021(:,1)-180, data0021(:,3),'ro'); plot(data0021(:,1), data0021(:,3),'ro')

max_a = 10;
axis([0 max_a 0 1])
legend('Section Lift Coefficient, CFD Simulated','Section Lift Coefficient, Thin Airfoil Theory Simulated', ...
    'Section Lift Coefficient, Experiment')


%%%%%%%%%% Organize the output data for processing %%%%%%%%%%
index = find(polar_out(:,1)<=max_a &  polar_out(:,1)>=0);

% this is the angle of attack and CL data for the CFD simulation 
CFD_AoA = polar_out(index,1);
CFD_CL = polar_out(index,2);

% this is the angle of attack and CL data for the Thin Airfoil Simulation 
TAS_AoA = polar_out(index,1);
TAS_CL = 2*pi*deg2rad(polar_out(index,1));

% this is the angle of attack and CL data for the Experimental Dataset 
Exp_AoA = [data0012(1:max_a,1); data0015(1:max_a,1); data0018(1:max_a,1); data0021(1:max_a,1) ];
Exp_CL = [data0012(1:max_a,2); data0015(1:max_a,2); data0018(1:max_a,2); data0021(1:max_a,2) ];


% clean up the workspace
clear TXT        data0015   index     ans        data0018   polar_out  data0012   data0021 
clc
% disp('Data Collection is done, type ">> who" at the MATLAB prompt to see the outputs');
% disp('CFD_AoA & CFD_CL are the angle of attack and lift coefficient as modeled using CFD');
% disp('Exp_AoA & Exp_CL are the angle of attack and lift coefficient as measured by SNL using Experiment');
% disp('TAS_AoA & TAS_CL are the angle of attack and lift coefficient as modeled using Thin Airfoil Assumption');

















function [fid] = x_foil_batch_v2(AF_FILENAME_base,REY_NUM)
% Xfoil Sequence
% Global Xfoil inputs for txt file
% Sequencial Number of command

FILENAME = 'XFOIL_RUN.txt';
delete(FILENAME)
AF_FILENAME = [AF_FILENAME_base '_standard.txt'];
F_PANEL = 1; % Flag to repanel
F_VISC = 1; % Flag Vicid or inviscid Calculations
% REY_NUM = 150000; % Reynolds Number
N_ITER = 100; % Number of iterations
POLAR_FILE = ['Polar' AF_FILENAME_base '.txt'];
Dump_FILE = 'Temp_FILE.txt';
delete(Dump_FILE)
delete(POLAR_FILE)
ALFA_MIN = -20 ;
ALFA_MAX = 20;
ALFA_INC = 1;
% --------------------------------------------------------------
% Create the input file
% INPUT - Have two choice From File or Naca
fid =  fopen(FILENAME,'w');

% FROM FILE
fprintf(fid,'%s\n','load');
fprintf(fid,'%s\n',AF_FILENAME);

% GDES can visualize the airfoil
% Look to create an output file
fprintf(fid,'%s\n',' ')
% PANNELING
fprintf(fid,'%s\n','pane')
if F_PANEL == 1
        fprintf(fid,'%s\n','ppar');
        fprintf(fid,'%s\n','n');
        fprintf(fid,'%s\n','140');
        fprintf(fid,'%s\n',' ');
        fprintf(fid,'%s\n',' ');
end
% OPER
if F_VISC == 1
        fprintf(fid,'%s\n','oper');
        fprintf(fid,'%s\n','visc');
        fprintf(fid,'%i\n',REY_NUM); % (Change to integer)
        fprintf(fid,'%s\n','iter');
        fprintf(fid,'%i\n',N_ITER);
end
fprintf(fid,'%s\n','vpar');         % set the roughness pretty high
fprintf(fid,'%s\n','n');         % set the roughness pretty high
fprintf(fid,'%s\n','4');         % set the roughness pretty high, works pretty good at 4
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\n','pacc');         % Start Storing data for drag polar
fprintf(fid,'%s\n',POLAR_FILE);         % Start Storing data for drag polar
fprintf(fid,'%s\n',Dump_FILE);      % Start Storing data for drag polar
%fprintf(fid,'%s\n','a1');          % Multiple angles of attack
fprintf(fid,'%s\n','cpx');          % Multiple angles of attack

fprintf(fid,'%s\n','aseq');         % Multiple angles of attack
fprintf(fid,'%i\n',0);              % Minimum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_MAX);         % Maximum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_INC);         % Increment in Angle of Attack (Deg)

fprintf(fid,'%s\n','cpx');          % Multiple angles of attack
fprintf(fid,'%s\n','init');         % Multiple angles of attac
%fprintf(fid,'%s\n','a1');          % Multiple angles of attackk
fprintf(fid,'%s\n','aseq');         % Multiple angles of attack
fprintf(fid,'%i\n',0);              % Minimum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_MIN);         % Maximum Angle of Attack (Deg)
fprintf(fid,'%i\n',-ALFA_INC);         % Increment in Angle of Attack (Deg)

fprintf(fid,'%s\n','cpx');         % Multiple angles of attack
fprintf(fid,'%s\n','init');         % Multiple angles of attack
fprintf(fid,'%s\n','aseq');         % Multiple angles of attack
fprintf(fid,'%i\n',ALFA_MAX/2);         % Minimum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_MAX);         % Maximum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_INC/3);         % Increment in Angle of Attack (Deg)

fprintf(fid,'%s\n','cpx');         % Multiple angles of attack
fprintf(fid,'%s\n','init');         % Multiple angles of attack
fprintf(fid,'%s\n','aseq');         % Multiple angles of attack
fprintf(fid,'%i\n',ALFA_MIN/2);         % Minimum Angle of Attack (Deg)
fprintf(fid,'%i\n',ALFA_MIN);         % Maximum Angle of Attack (Deg)
fprintf(fid,'%i\n',-ALFA_INC/3);         % Increment in Angle of Attack (Deg)

fprintf(fid,'%s\n','pacc'); % Stop Storing data for drag polar
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n','quit'); % Quit Program

fclose(fid);
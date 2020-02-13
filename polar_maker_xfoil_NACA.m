function [dummy] = polar_maker(which_prop,photo_filename);
['Polar' ,photo_filename ,'.txt']
fid = fopen(['Polar' ,photo_filename ,'.txt'])
[alpha ,   CL,        CD  ,     CDp    ,   CM    , Top_Xtr , Bot_Xtr] ...
    = textread(['Polar' [photo_filename] '.txt'],'%f%f%f%f%f%f%f','headerlines' ,12);

try
    fclose(fid)
end
% figure; plot(alpha, CL,'ro')
% figure; plot(CD,CL,'ro')

for i=1:length(alpha) 
    CL(find(alpha(i)==alpha)) = min(CL(find(alpha(i)==alpha)));
    CD(find(alpha(i)==alpha)) = max(CD(find(alpha(i)==alpha)));    
end
index = 0;
for i = -20 : 0.1 : 20
    
    if and(sum(i == alpha) > .5, ~isnan(CL(find(i == alpha))))
        index = index+1;
        index_2 = find(i==alpha);
        CL_out_raw(index) = CL(index_2(1));
        CD_out_raw(index) = CD(index_2(1));
        alpha_out(index) = i;
    end
    
end

low_angle_CL_spline = spap2([-20*ones(1,10) 20*ones(1,10)],10,alpha_out,CL_out_raw);
low_angle_CD_spline = spap2([-20*ones(1,10) 20*ones(1,10)],10,alpha_out,CD_out_raw);
CL_out = fnval(low_angle_CL_spline, alpha_out);
CD_out = fnval(low_angle_CD_spline, alpha_out);
CL_out = CL_out_raw;
CD_out = CD_out_raw;

% Performance at Very High Angle of Attack
Sandia_CL_coeffs = [ -2.7484E-08, 1.3315E-05, - 2.2164E-03, 1.2681E-01, 1.2796E+00];%[0.00000633,-0.0015554002,0.0981206941,-0.7715384615]; %Sandia regression coefficients
alpha_Sandia = [ 35 : 90];
CD_Sandia = 1.8492E-08*alpha_Sandia.^4 - 6.5545E-06*alpha_Sandia.^3 + 4.6777E-04*alpha_Sandia.^2 + 2.0896E-02*alpha_Sandia.^1 - 2.9628E-01;%1.8*(sin(alpha_Sandia*pi/180)).^2;
CL_Sandia =  -2.7484E-08*alpha_Sandia.^4 + 1.3315E-05*alpha_Sandia.^3 - 2.2164E-03*alpha_Sandia.^2 + 1.2681E-01*alpha_Sandia.^1 - 1.2796E+00;%polyval(Sandia_CL_coeffs, alpha_Sandia);

%Performance at Intermediate Angles of Attack
intermediate_spline = csapi([alpha_out(end) alpha_Sandia]' ,[CL_out(end) CL_Sandia]');
alpha_inter = [alpha_out(end)+1 : 34];
CL_inter = fnval(intermediate_spline, alpha_inter);
intermediate_spline = csapi([alpha_out(end) alpha_Sandia]' ,[CD_out(end) CD_Sandia]');
CD_inter = fnval(intermediate_spline, alpha_inter);

% Performance under the negative stall
for i=1:length(CL_out)-1; dCLda(i) = CL_out(i+1)-CL_out(i); end
alpha_low_stall = alpha_out(max(1,-6+max(find(dCLda(1:length(CL_out)/2)<0))));% added the -2 to allow it to find the stall
CL_low_stall = CL_out(max(1,-6+max(find(dCLda(1:length(CL_out)/2)<0))));
CD_low_stall = CD_out(max(1,-6+max(find(dCLda(1:length(CL_out)/2)<0))));
if isempty(alpha_low_stall)
    alpha_low_stall=min(alpha_out);
    CL_low_stall = min(CL_out);
    CD_low_stall = min(CD_out);
end
alpha_Sandia_low = -fliplr(alpha_Sandia); [-90 : -35];
CL_Sandia_low = -fliplr(CL_Sandia);
CD_Sandia_low =  fliplr(CD_Sandia);%1.8*(sin(alpha_Sandia_low*pi/180+pi)).^2;


% Performance under the intermediate negative stall
intermediate_spline = csapi([alpha_Sandia_low alpha_low_stall]' , [CL_Sandia_low CL_low_stall]' );
alpha_inter_low = [-34 : alpha_low_stall-1];
CL_inter_low = fnval(intermediate_spline, alpha_inter_low);
intermediate_spline = csapi([alpha_Sandia_low alpha_low_stall]' , [CD_Sandia_low CD_low_stall]' );
CD_inter_low = fnval(intermediate_spline, alpha_inter_low);


% Sum up all of the polars and plot
polar_out = [[alpha_Sandia_low  alpha_inter_low alpha_out(find(alpha_out>=alpha_low_stall)) alpha_inter alpha_Sandia]' ...
            [CL_Sandia_low  CL_inter_low CL_out(find(alpha_out>=alpha_low_stall)) CL_inter CL_Sandia]'...
            [CD_Sandia_low  CD_inter_low CD_out(find(alpha_out>=alpha_low_stall)) CD_inter CD_Sandia]'];

% % figure;  plot(polar_out(:,1), polar_out(:,2))
% % xlabel('Angle of Attack, deg'); 
% % hold on ; plot(polar_out(:,1), polar_out(:,3),'r')
% % ylabel('CD, CL')
% % legend('Section Lift Coefficient', 'Section Drag Coefficient')
% % grid

% subplot(2,1,2);; plot(polar_out(:,3), polar_out(:,2))
% xlabel('Section Drag Coefficient')
% ylabel('Section Lift Coefficient')
% grid

% Save to Polar_Total file
dlmwrite(['Polar_Total_' [which_prop photo_filename(1:length(photo_filename)-4)] '.txt'],polar_out, ' ' )

dummy = polar_out;


% fclose(fid)
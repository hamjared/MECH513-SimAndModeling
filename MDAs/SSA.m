function [] = SSA(design_vars,ca_guess)
% MECH 513 System Sensitivity Analysis Code
% Blake A. Moffitt UTRC, Thomas H. Bradley CSU

close all
format compact
format short
warning off

% Read the excel file using NUMERIC and TXT matrices
input_template_filename = 'SSA_513.xls'; 
[num_des_vars,num_CA_inputs,num_CA_outputs, num_CAs, num_CA_vars, design_vars_in, CA_in, CA_out,CA_list_sorted_ordered, design_vars_list_sorted_ordered, ...
    design_vars_errors_sorted_ordered, CA_outputs_errors_sorted_ordered, ca_names_list]  = CA_info_xls_parser(input_template_filename);

% Set the Design Variables
des_vars = design_vars; % {Sw, t} 
h = 0.001;   %Step size (0 < h < 1) percent

% Solve for the CA variables
CA_vars_guess = ca_guess;
CA_vars_converged = fsolve('List_of_CAs',CA_vars_guess,optimset('Display','iter','MaxFunEvals',1000),des_vars);
% disp('These are the converged outputs of the MDA:')
CA_vars = CA_vars_converged;

%%%Variables above must be determinesd prior to SSA calculation%%%

% Compute the LSM, LSV and GSV
[LSM] = LSM_calc(des_vars, CA_vars,h,num_des_vars,num_CA_inputs,num_CA_outputs, num_CAs, num_CA_vars, design_vars_in, CA_in, CA_out,CA_list_sorted_ordered, design_vars_list_sorted_ordered, ...
    design_vars_errors_sorted_ordered, CA_outputs_errors_sorted_ordered, ca_names_list);    
[LSV] = LSV_calc(des_vars, CA_vars,h,num_des_vars,num_CA_inputs,num_CA_outputs, num_CAs, num_CA_vars, design_vars_in, CA_in, CA_out,CA_list_sorted_ordered, design_vars_list_sorted_ordered, ...
    design_vars_errors_sorted_ordered, CA_outputs_errors_sorted_ordered, ca_names_list);
[GSV] = GSV_calc(LSM,LSV);

% Call up the percent input/output error normalized fractions
% disp('These uncertainties are input to the SSA:');
% disp('1) Tool uncertainties:');
uncertT_fraction = CA_outputs_errors_sorted_ordered';
% disp('2) Design variable uncertainties:');
uncertX_fraction = design_vars_errors_sorted_ordered';

%Convert error fractions to application-specific numerical values
uncertT =  CA_vars' .* uncertT_fraction;
uncertX = des_vars' .* uncertX_fraction;

%Compute the uncertainty in the output vector, Y as a stdDev and percent
uncertY_variance = ((inv(LSM)).^2) * (uncertT.^2 +  (LSV.^2) * uncertX.^2);
uncertY_stdev = (uncertY_variance).^(1/2);
% disp('These uncertainties are output from the SSA:');
CA_vars_names = [' ']; for i=1:sum(num_CA_vars); CA_vars_names = [CA_vars_names CA_list_sorted_ordered{i} ' ']; end

    
% disp(['1) Uncertainties in the CA variables, [' CA_vars_names ' ]:']);
uncertY_fraction = uncertY_stdev ./ CA_vars';

% Plot the contribution from each source of uncertainty to each of the CA
% output variables.  Data is presented in terms of variance.  
W = inv(LSM).^2; % build a set of buffer matrices representing the contribution of tool uncertainty
buff1 = W(1,:).*(uncertT.^2)';
buff2 = W(2,:).*(uncertT.^2)';
buff3 = W(3,:).*(uncertT.^2)';
buff4 = W(4,:).*(uncertT.^2)';
W = inv(LSM).^2 * LSV.^2; % build a set of buffer matrices representing the contribution of design variable uncertainty
buff5 = W(1,:).*(uncertX.^2)';
buff6 = W(2,:).*(uncertX.^2)';
buff7 = W(3,:).*(uncertX.^2)';
buff8 = W(4,:).*(uncertX.^2)';
 
bar_chart = [buff1 buff5 ; buff2 buff6 ; buff3 buff7 ; buff4 buff8]; % make bar chart plot with labels
bar(bar_chart, 'stacked')
Labels = {CA_list_sorted_ordered{1:end}};
set(gca, 'XTick', 1:4, 'XTickLabel', Labels);
legend('\sigmaT1','\sigmaT2','\sigmaT3','\sigmaT4','\sigmaX1','\sigmaX2','\sigmaX3')
xlabel('CA Variables')
ylabel('Variance and their Sources')
ylim([0 1500])



end


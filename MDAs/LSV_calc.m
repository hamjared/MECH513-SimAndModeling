function [LSV] = LSV_calc(des_vars, CA_vars,h,num_des_vars,num_CA_inputs,num_CA_outputs, num_CAs, num_CA_vars, design_vars_in, CA_in, CA_out,CA_list_sorted_ordered, design_vars_list_sorted_ordered, ...
    design_vars_errors_sorted_ordered, CA_outputs_errors_sorted_ordered, ca_names_list)

total_num_CA_vars = size(CA_list_sorted_ordered,1);
total_num_des_vars = size(design_vars_list_sorted_ordered,1);

%%% Establish the string used to calculate the difference between vars_up and vars_down
eval_string_up = '';
for k = 1:total_num_CA_vars
     eval_string_up = [eval_string_up  'up_output_des_vars(' num2str(k) ') '];
end
            
eval_string_down = '';
for k = 1:total_num_CA_vars
    eval_string_down = [eval_string_down  'down_output_des_vars(' num2str(k) ') '];
end

%%% Calculate the LSV
for i = 1:total_num_CA_vars % Tool number
    current_tool = ca_names_list{i};
    
    for j = 1:total_num_des_vars % Input number
       
         des_vars_up = des_vars;
         des_vars_up(j) = des_vars(j)*(1 + (1/2*h));     
         des_vars_down = des_vars;
         des_vars_down(j) = des_vars(j)*(1 - (1/2*h));
            
         eval(['[' eval_string_up '] = ' current_tool '(CA_vars,des_vars_up);']) 
         eval(['[' eval_string_down '] = ' current_tool '(CA_vars,des_vars_down);']) 

         LSV(i,j) = ((up_output_des_vars(i) - down_output_des_vars(i))/(h*des_vars(j)));
          
     end
end


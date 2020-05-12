function [num_des_vars,num_CA_inputs,num_CA_outputs, num_CAs, num_CA_vars, design_vars_in, CA_in, CA_out,CA_list_sorted_ordered, design_vars_list_sorted_ordered, ...
    design_vars_errors_sorted_ordered, CA_outputs_errors_sorted_ordered, ca_names_list]  = CA_info_xls_parser(input_template_filename)
% This function parses the CA information input template 
%[NUMERIC,TXT] = xlsread('C:\Program Files\MATLAB\R2006a\work\CA_info_input_template.xls');
%[NUMERIC,TXT] = xlsread('CA_info_input_template.xls');
[NUMERIC,TXT] = xlsread(input_template_filename);
%num_CAs = max(NUMERIC);

% FIGURE OUT WHERE THE CA'S START AND END
j=0;
for i=1:size(TXT,1)
    header = 'x inputs';
    read_length = min(length(header), length(TXT{i}));
    if(and(sum( TXT{i}(1:read_length) == header(1:read_length) ) == read_length, size(TXT{i,1},1) > 0))
        % you are 1 step before the data
        j = j+1;
        CA_start_line(j) = i+1;
    end
       
end
num_CAs = j;  
CA_start_line(j+1) = i+3;

% FIGURE OUT WHAT THE DESIGN VARS, CA INPUTS, AND CA OUTPUTS ARE
k0=0;
k1=0;
k2=0;
k3=0;

for i=1:num_CAs
    k=0;
    % FIGURE OUT WHAT THE CA NAMES are
    j = CA_start_line(i)-2;
    if size(TXT{j,3},2) > 0
        k0 = k0+1;
        ca_names_list{k0} = TXT{j,3};
    end
    
    % FIGURE OUT WHAT THE DESIGN VARS are
    k=0;
    for j = CA_start_line(i):CA_start_line(i+1)-3
        if size(TXT{j,1},1) > 0
            k1 = k1+1;
            k=k+1;
            design_vars_buff{i,k1} = TXT{j,1};
            design_vars_list{k1} = TXT{j,1};
            design_vars_errors(k1) = NUMERIC(j,3);
         end
    end
    num_des_vars(i) = k;
    
    
    % FIGURE OUT WHAT THE CA INPUTS are  
    k=0;
    for j = CA_start_line(i):CA_start_line(i+1)-3
        if size(TXT{j,2},1) > 0
            k2 = k2+1;
            k=k+1;
            CA_inputs_buff{i,k2} = TXT{j,2};
            CA_inputs_list{k2} = TXT{j,2};
        end
    end
    num_CA_inputs(i) = k;

    % FIGURE OUT WHAT THE CA outputs are 
    k=0;
    for j = CA_start_line(i):CA_start_line(i+1)-3
        if size(TXT{j,3},1) > 0
            k3 = k3+1;
            k=k+1;
            CA_outputs_buff{i,k3} = TXT{j,3};
            CA_outputs_list{k3} = TXT{j,3};
            CA_outputs_errors_sorted_ordered(k3) = NUMERIC(j,4);
        end
    end
    num_CA_outputs(i) = k;
end

%REMOVE ALL SPACES in CA_LIST AND DESIGN VARIABLE LIST
for i=1:length(CA_outputs_list)
    string_length = length(CA_outputs_list{i});
    for j = 1:string_length
        temp_compare = CA_outputs_list{i}(j) == ' ';
        if(temp_compare == 0)
            CA_outputs_list_no_spaces{i}(j) = CA_outputs_list{i}(j);
        end
    end
end

for i=1:length(CA_inputs_list)
    string_length = length(CA_inputs_list{i});
    for j = 1:string_length
        temp_compare = CA_inputs_list{i}(j) == ' ';
        if(temp_compare == 0)
            CA_inputs_list_no_spaces{i}(j) = CA_inputs_list{i}(j);
        end
    end
end

for i=1:length(design_vars_list)
    string_length = length(design_vars_list{i});
    for j = 1:string_length
        temp_compare = design_vars_list{i}(j) == ' ';
        if(temp_compare == 0)
            design_vars_list_no_spaces{i}(j) = design_vars_list{i}(j);
        end
    end
end

clear design_vars_list CA_inputs_list CA_outputs_list
design_vars_list = design_vars_list_no_spaces;
CA_outputs_list = CA_outputs_list_no_spaces;
CA_inputs_list = CA_inputs_list_no_spaces;


%COMPARE CA INPUTS AND OUTPUTS
k = 0;
for i=1:length(CA_inputs_list)
    clear duplicated
    for j=1:length(CA_outputs_list);
        compare_length = min(length(CA_inputs_list{i}),length(CA_outputs_list{j}) ) ;
        if length(CA_inputs_list{i}) == length(CA_outputs_list{j})
            duplicated(j) = sum(CA_inputs_list{i}(1:compare_length) == CA_outputs_list{j}(1:compare_length)) == compare_length;
        else
            duplicated(j) = 0;
        end
    end
    if (sum(duplicated)==0)
        k=k+1;
        CA_input_error{k} = CA_inputs_list{i};        
    end
end 

% ALL CA INPUTS MUST BE EITHER AN OUTPUT OF ANOTHER CA OR A DESIGN VARIABLE
% INPUT
if k>0
    CA_input_error'
    error('CA Inputs that are not CA Outputs')
end

CA_list = CA_outputs_list';  %ONLY NEEDS TO BE BASED ON THE CA OUTPUTS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort THE DESIGN VARS, CA INPUTS, AND CA OUTPUTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=0 ;        %Sort THE DESIGN VARS
for i = length(design_vars_list):-1:1
    clear duplicated
    for j = i:-1:1
        compare_length = min(length(design_vars_list{i}),length(design_vars_list{j}) ) ;
        if length(design_vars_list{i}) == length(design_vars_list{j})
            duplicated(j) = sum(design_vars_list{j}(1:compare_length) == design_vars_list{i}(1:compare_length)) == compare_length;
        else
            duplicated(j) = 0;
        end
    end
    if (sum(duplicated)==1)
        k=k+1;
        design_vars_list_sorted{k} = design_vars_list{i};
        design_vars_errors_sorted(k) = design_vars_errors(i);
    end
end
for i = 1:length(design_vars_list_sorted)
    design_vars_list_sorted_ordered{length(design_vars_list_sorted)+1-i} = design_vars_list_sorted{i};
    design_vars_errors_sorted_ordered(length(design_vars_list_sorted)+1-i) = design_vars_errors_sorted(i);
end

k=0 ;        %Sort THE CA INPUTS
m = 0;
for i = length(CA_list):-1:1
    clear duplicated
    for j = i:-1:1
        compare_length = min(length(CA_list{i}),length(CA_list{j}) ) ;
        if length(CA_list{i}) == length(CA_list{j})
            duplicated(j) = sum(CA_list{j}(1:compare_length) == CA_list{i}(1:compare_length)) == compare_length;
        else
            duplicated(j) = 0;
        end
    end
    if (sum(duplicated)==1)
        k=k+1;
        CA_list_sorted{k} = CA_list{i};
    else
        m=m+1;
        CA_output_duplicates{m} = CA_list{i};
    end
end
for i = 1:length(CA_list_sorted)
    CA_list_sorted_ordered{length(CA_list_sorted)+1-i} = CA_list_sorted{i};
end

if m>0
   CA_output_duplicates'
   error('The above are duplicates in the CA outputs')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAke the CA INPUT MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
CA_input_mat = zeros(num_CAs,length(CA_list_sorted_ordered));
for CA_number  = 1:size(CA_inputs_buff, 1)
    for CA_variable_num = 1:length(CA_list_sorted_ordered)
        for i = 1:size(CA_inputs_buff, 2)
            
            if length(CA_list_sorted_ordered{CA_variable_num}) == length(CA_inputs_buff{CA_number,i})
                compare_length = min(length(CA_list_sorted_ordered{CA_variable_num}), length(CA_inputs_buff{CA_number,i}) );
               %sum(CA_list_sorted_ordered{CA_variable_num}(1:compare_length) == CA_inputs_buff{i,CA_number}(1:compare_length)) == compare_length
            
                if sum(CA_list_sorted_ordered{CA_variable_num}(1:compare_length) == CA_inputs_buff{CA_number,i}(1:compare_length)) == compare_length
                    if compare_length > 0
                        CA_input_mat(CA_number,CA_variable_num) = 1;
                    end
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE the CA OUTPUT MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
CA_output_mat = zeros(num_CAs,length(CA_list_sorted_ordered));
for CA_number  = 1:size(CA_outputs_buff, 1)
    for CA_variable_num = 1:length(CA_list_sorted_ordered)
        for i = 1:size(CA_outputs_buff, 2)
            
            if length(CA_list_sorted_ordered{CA_variable_num}) == length(CA_outputs_buff{CA_number,i})
                compare_length = min(length(CA_list_sorted_ordered{CA_variable_num}), length(CA_outputs_buff{CA_number,i}) );
               %sum(CA_list_sorted_ordered{CA_variable_num}(1:compare_length) == CA_inputs_buff{i,CA_number}(1:compare_length)) == compare_length
            
                if sum(CA_list_sorted_ordered{CA_variable_num}(1:compare_length) == CA_outputs_buff{CA_number,i}(1:compare_length)) == compare_length
                    if compare_length > 0
                        CA_output_mat(CA_number,CA_variable_num) = 1;
                    end
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAke the CA DESIGN VARIABLE MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
X_output_mat = zeros(num_CAs,length(design_vars_list_sorted_ordered));
for CA_number  = 1:size(design_vars_buff, 1)
    for X_variable_num = 1:length(design_vars_list_sorted_ordered)
        for i = 1:size(design_vars_buff, 2)
            %CA_num_X_var_num = [CA_number X_variable_num]
            if length(design_vars_list_sorted_ordered{X_variable_num}) == length(design_vars_buff{CA_number,i})
                compare_length = min(length(design_vars_list_sorted_ordered{X_variable_num}), length(design_vars_buff{CA_number,i}) );
                        
                if sum(design_vars_list_sorted_ordered{X_variable_num}(1:compare_length) == design_vars_buff{CA_number,i}(1:compare_length)) == compare_length
                    if compare_length > 0
                        X_output_mat(CA_number,X_variable_num) = 1;
                    end
                end
            end
        end
    end
end

% DO THE OUTPUT
%num_CA_vars = length(CA_list_sorted_ordered);
disp ' '
disp ' '
disp ' '
disp 'Number of variables in each tool, each column is a tool'
num_CA_vars = num_CA_outputs;
%num_CAs = length(CA_list_sorted_ordered);
disp ' '
disp 'Tool x Variable'
disp ' '
design_vars_in = X_output_mat;
CA_in = CA_input_mat;
CA_out = CA_output_mat;
CA_list_sorted_ordered = CA_list_sorted_ordered';
design_vars_list_sorted_ordered = design_vars_list_sorted_ordered';






















            
        
        
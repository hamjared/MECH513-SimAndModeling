function [Deceleration,Mean_Deceleration,Std_Deceleration, Brake_Energy, Mean_Brake_Energy, Std_Brake_Energy ] = run_monte_carlo(spring_constant,relative_pressure_error_cdf, relative_pressure_error)
Landing_Velocity_Mean = 286.9; %ft/s
Landing_Velocity_sdev = Landing_Velocity_Mean * 0.05/1.645;

Brake_Friction_Coefficient_Data = [0.35 0.45 0.5 0.52 0.55 0.65 0.7 0.72 0.75 0.8] ;
Mean_Brake_Friction_Coefficient = mean(Brake_Friction_Coefficient_Data);
Brake_Friction_Coefficient_sdev = std(Brake_Friction_Coefficient_Data);

Historical_Air_Density = [0.002099519	0.002095169	0.002077174	0.00205492	0.002047357	0.002054161	0.002095169	0.002095038	0.002088272	0.002073973	0.002035563	0.002047779	0.002048865	0.00205568	0.002049997	0.002050339	0.002035002	0.002028341	0.002032767	0.002044666	0.002079186	0.002086426	0.002071331	0.002049997	0.00205644	0.002074463	0.002089158	0.002087596	0.002082923	0.002069795	0.002071331	0.002064837	0.002066755	0.00206522	0.002069795	0.00206673	0.002060248	0.002067139	0.002072484	0.002071672	0.002056453	0.002044347	0.002037607	0.002014229	0.002048155	0.00204698	0.002050753	0.002067113	0.002059485	0.002061775	0.002048155	0.002043656	0.002043344	0.002038805	0.002047028	0.002040295	0.002040739	0.002024756	0.002036574	0.002010548	0.002023119	0.002039322	0.002063293	0.002057211	0.002042535	0.002036945	0.002014598	0.002046653	0.002065201	0.002074024	0.002079432	0.002082534	0.002070563	0.002061389	0.002055696	0.002038805	0.002022419	0.002039848	0.002010558	0.002042652	0.002041894	0.002033492	0.002044666	0.002054541	0.002060248	0.002048155	0.002029429	0.002032024	0.002017553	0.002059488	0.002024236	0.002053428]; %slug/ft^3
Mean_Air_Density = mean(Historical_Air_Density);
Air_density_sdev = std(Historical_Air_Density); 

Runway_Downslope_Mean = 1;
Runway_Downslope_sdev = Runway_Downslope_Mean * 0.05/1.645;

Airplane_Mass_Mean = 544; %slugs
Airplane_Mass_sdev = Airplane_Mass_Mean * 0.05/1.645;

Engine_Thrust_Mean = 500; % lbs 
Engingine_Thrust_sdev = Engine_Thrust_Mean * 0.05/1.645;

Rolling_Friction_Coefficient_Mean = 0.01;
Rolling_Friction_Coefficient_sdev = Rolling_Friction_Coefficient_Mean * 0.05/1.645;

AC_d_Mean = 9.25; % ft^2S
AC_d_sdev = AC_d_Mean * 0.05/1.645;

Pedal_Force = 50;
Pedal_Angular_Displacement = 9;
BMV_Spring_Constant = spring_constant;

num_iterations = 200;
num_samples = 5;
iteration_number = zeros(num_iterations,1);
Deceleration = zeros(num_iterations, num_samples);
Mean_Deceleration = zeros(num_iterations, num_samples);
Std_Deceleration = zeros(num_iterations, num_samples);
Brake_Energy = zeros(num_iterations, num_samples);
Mean_Brake_Energy = zeros(num_iterations, num_samples);
Std_Brake_Energy = zeros(num_iterations, num_samples);
for sample_number = 1:num_samples
    for n=1:num_iterations
        iteration_number(n) = n;
        assignin('base','Landing_Velocity', norminv(rand(1,1),Landing_Velocity_Mean, Landing_Velocity_sdev));
        assignin('base','Air_Density', norminv(rand(1,1), Mean_Air_Density, Air_density_sdev));
        assignin('base','AC_d', norminv(rand(1,1),AC_d_Mean, AC_d_sdev));
        assignin('base','Runway_Downslope', norminv(rand(1,1),Runway_Downslope_Mean, Runway_Downslope_sdev));
        assignin('base','Airplane_Mass', norminv(rand(1,1), Airplane_Mass_Mean, Airplane_Mass_sdev));
        assignin('base','Engine_Thrust', norminv(rand(1,1), Engine_Thrust_Mean, Engingine_Thrust_sdev));
        assignin('base','Rolling_Friction_Coefficient',  norminv(rand(1,1), Rolling_Friction_Coefficient_Mean, Rolling_Friction_Coefficient_sdev));
        assignin('base','Brake_Friction_Coefficient', norminv(rand(1,1), Mean_Brake_Friction_Coefficient, Brake_Friction_Coefficient_sdev));
        
        assignin('base','BMV_Model_Relative_Error', interp1(relative_pressure_error_cdf, relative_pressure_error, rand(1,1)));
        
        simOut_local = sim("LandinModel.slx", 'FixedStep', '0.01');
        Deceleration(n, sample_number) = mean(simOut_local.Acceleration.signals.values);
        Mean_Deceleration(n,sample_number) = mean(Deceleration(1:n, sample_number));
        Std_Deceleration(n,sample_number) = std(Deceleration(1:n, sample_number));
        
        position = simOut_local.Position.signals.values ;
        wheelBrakeForce = simOut_local.WheelBrakeForce.signals.values + zeros(length(position), 1);
        wheelBrakeForceEnergy = sum(trapz(position, wheelBrakeForce));
        Brake_Energy(n,sample_number) = wheelBrakeForceEnergy;
        Mean_Brake_Energy(n,sample_number) = mean(Brake_Energy(1:n,sample_number));
        Std_Brake_Energy(n,sample_number) = std(Brake_Energy(1:n, sample_number));
        
    end
end
end


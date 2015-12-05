function [time, input, output] = stepInput(length, settlingTime, frictionCompensator, stepHeight)
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.
    N_S = length / T_S; %Compute the number of points to save the datas.
    SETTLING_LENGTH = settlingTime / T_S;
    time = 0:T_S:(N_S-1)*T_S; %Vector saving the time steps.

    output = zeros(8, N_S); %Vector saving the datas. If there are several datas to save, change "1" to the number of outputs.
    input = horzcat(zeros(1,SETTLING_LENGTH), ones(1,N_S - SETTLING_LENGTH)*stepHeight); %Vector storing the input sent to the plant.

    openinout; %Open the ports of the analog computer.
    i=1; %Set the counter to 1.
    tic %Begins the first strike of the clock.


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while i <= N_S
        [output(1,i), output(2,i), output(3,i), output(4,i), output(5,i), output(6,i), output(7,i), output(8,i)]  = anain; %Acquisition of the measurements.
        
        rmVelocity = output(5,i); %saving the inputs in a variable for ease of working
        lmVelocity = output(4,i);
        lTraction = output(3,i);
        rTraction = output(2,i);
        
        
        amps = input(i) + frictionCompensator; %Input of the system.
        anaout(0, amps); %Command to send the input to the analog computer.

        if toc > i*T_S
            disp('Sampling time too small');%Test if the sampling time is too small.
        else
            while toc <= i*T_S %Does nothing until the second strike of the clock reaches the sampling time set.
            end
        end
        i = i+1;
    end


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    figure %Open a new window for plot.
    plot(time,output(5,:),time,input(:)); %Plot the experiment (input and output).

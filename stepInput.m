function [time, input, data] = stepInput(length, settlingTime, frictionCompensator, stepHeight)
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.
    N_S = length / T_S; %Compute the number of points to save the datas.
    SETTLING_LENGTH = settlingTime / T_S;
    time = 0:T_S:(N_S-1)*T_S; %Vector saving the time steps.

    data = zeros(8, N_S); %Vector saving the datas. If there are several datas to save, change "1" to the number of outputs.
    input = horzcat(zeros(1,SETTLING_LENGTH), ones(1,N_S - SETTLING_LENGTH)*stepHeight); %Vector storing the input sent to the plant.

    openinout; %Open the ports of the analog computer.
    i=1; %Set the counter to 1.
    tic %Begins the first strike of the clock.


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    while i <= N_S
        data(i, :) = anain; %Acquisition of the measurements.

        input = input(i) + frictionCompensator; %Input of the system.
        anaout(input, 0); %Command to send the input to the analog computer.

        if toc > i*T_S
            disp('Sampling time too small');%Test if the sampling time is too small.
        else
            while toc <= i*T_S %Does nothing until the second strike of the clock reaches the sampling time set.
            end
        end
        i = i+1;
    end

    closeinout %Close the ports.

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    figure %Open a new window for plot.
    plot(time,data(1,:),time,input(1,:)); %Plot the experiment (input and output).

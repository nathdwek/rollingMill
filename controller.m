function [time, reference, input, output] = controller()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Control System Design Lab: Overall Controller Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.


    function [nSamples, time, reference, input, output] = referenceGenerator()
        STEP_LENGTH = 30;%seconds
        STEP_HEIGHT = 1.2;
        
        SETUP_TIME = 5;%seconds
        SETUP_POINT = 5.3;%V
        SETTLING_TIME = 2;%seconds
        
        reference = horzcat(0:T_S*SETUP_POINT/SETUP_TIME:SETUP_POINT, SETUP_POINT*ones(1,SETTLING_TIME/T_S), (SETUP_POINT+STEP_HEIGHT)*ones(1,STEP_LENGTH/T_S));
        
        nSamples = length(reference);
        time=0:T_S:(nSamples-1)*T_S; 
        input = zeros(2, nSamples);
        output = zeros(8, nSamples);
    end


    [nSamples, time, reference, input, output] = referenceGenerator(); %precompute the reference and generate arrays of according size
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Controllers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function current = lmController(speedRef, measuredSpeed)
        FRICTION_COMPENSATOR = 2.7;
        KP = 2;
        KI = KP/3.642;

        persistent errorIntegral;
        if isempty(errorIntegral)
            errorIntegral = 0;
        end

        error = speedRef - measuredSpeed;
        errorIntegral = errorIntegral + error*T_S;

        current = FRICTION_COMPENSATOR + KP*error + KI*errorIntegral; 
    end

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Main Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i=1; %Set the counter to 1.
    tic %Begins the first strike of the clock.
    openinout; %Open the ports of the analog computer.
    while i < nSamples
        output(:,i) = anain; %Acquisition of the measurements.
        
        current = lmController(reference(i), output(1,i));
        input(1,i) = current;
        anaout(current, 0);

        if toc > T_S
            disp('Sampling time too small');%Test if the sampling time is too small.
        else
            while toc <= T_S %Does nothing until the second strike of the clock reaches the sampling time set.
            end
            tic
        end
        i=i+1;
    end
    closeinout %Close the ports.

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure %Open a new window for plot.
    plot(time,reference(1,:), time, output(1, :), time, reference(1,:) - output(1, :), time, input(1,:)); %Plot the experiment (input and output).
end

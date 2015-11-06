function [time, reference, output, input] = controller()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Control System Design Lab: Overall Controller Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.


    function [nSamples, time, reference, output, input] = referenceGenerator()
        STEP_LENGTH = 10;%seconds
        STEP_HEIGHT = 1.3;
        
        SETUP_TIME = 5;%seconds
        %SETUP_POINT = 2.4;%V Right Motor
        SETUP_POINT = 2.7;%V Left Motor
        SETTLING_TIME = 2;%seconds
        
        reference = horzcat(0:T_S*SETUP_POINT/SETUP_TIME:SETUP_POINT, SETUP_POINT*ones(1,SETTLING_TIME/T_S), (SETUP_POINT+STEP_HEIGHT)*ones(1,STEP_LENGTH/T_S));
        
        nSamples = length(reference);
        time=0:T_S:(nSamples-1)*T_S; 
        output = zeros(2, nSamples);
        input = zeros(8, nSamples);
    end


    [nSamples, time, reference, output, input] = referenceGenerator(); %precompute the reference and generate arrays of according size
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Controllers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function current = lmController(speedRef, measuredSpeed)
        if speedRef < 0
            FRICTION_COMPENSATOR  = -2.7;
        else
            FRICTION_COMPENSATOR  = 2.7;
        end
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

    function current = rmController(speedRef, measuredSpeed)
        if speedRef < 0
            FRICTION_COMPENSATOR  = -2.7;
        else
            FRICTION_COMPENSATOR  = 2.7;
        end
        KP = 3;

        error = speedRef - measuredSpeed;
        current = FRICTION_COMPENSATOR + KP*error;
    end


    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Main Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i=1; %Set the counter to 1.
    while i < nSamples
        tic %Begins the first strike of the clock.
        [input(1,i), input(2,i), input(3,i), input(4,i), input(5,i), input(6,i), input(7,i), input(8,i)]  = anain; %Acquisition of the measurements.

        if(input(2,i) > 8 || input(3,i) > 8)
            lmCurrent = 0;
            rmCurrent = 0;

        else
            lmCurrent = lmController(reference(i), input(4,i));
            rmCurrent = rmController(-reference(i)/2, input(5,i));
        end

        output(2,i) = rmCurrent;
        output(1,i) = lmCurrent;
        anaout(lmCurrent, rmCurrent);
        

        if toc > T_S
            disp('Sampling time too small');%Test if the sampling time is too small.
        else
            while toc <= T_S %Does nothing until the second strike of the clock reaches the sampling time set.
            end
        end
        i=i+1;
    end

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    figure %Open a new window for plot.
    plot(time,reference(1,:), time, input(4, :), time, reference(1,:) - input(4, :), time, output(1,:)); %Plot the experiment (input and output).
    legend('reference(t)','velocity(t)','error(t)','current(t)');
    figure;
    plot(time,input(1,:), time, input(2, :), time,input(3, :), time, input(4,:),time,input(5,:)); %Plot the experiment (input and output).
end

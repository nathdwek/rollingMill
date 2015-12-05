function [time, reference, input, output] = rmController()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Control System Design Lab: Overall Controller Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.


    function [nSamples, time, reference, input, output] = referenceGenerator()
        %REF(1,:) = traction
       
        %master
        SETUP_TIME = 8;%seconds
        SETUP_POINT = 3.5;%V Left Motor
        STEP_LENGTH = 30;%s
        SETTLING_TIME = 5;%s
        
        nSamples = (SETUP_TIME+STEP_LENGTH)/T_S;
        ramp = 0:T_S*SETUP_POINT/SETUP_TIME:SETUP_POINT;
        rampLength = length(ramp);
        finalValue = 5.5;
        
        reference(1,:) = [ramp ones(1,SETTLING_TIME/T_S)*SETUP_POINT ones(1,nSamples-rampLength-SETTLING_TIME/T_S)*finalValue];
        

        time=0:T_S:(nSamples-1)*T_S; 
        input = zeros(2, nSamples);
        output = zeros(8, nSamples);
    end


    [nSamples, time, reference, input, output] = referenceGenerator(); %precompute the reference and generate arrays of according size
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Controllers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    

    function current = rmController(speedRef, measuredSpeed)
        if speedRef < 0
            FRICTION_COMPENSATOR  = -2.1;
        else
            FRICTION_COMPENSATOR  = 2.1;
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
        [output(1,i), output(2,i), output(3,i), output(4,i), output(5,i), output(6,i), output(7,i), output(8,i)]  = anain; %Acquisition of the measurements.
        
        rmVelocity = output(5,i); %saving the inputs in a variable for ease of working
        
        rmCurrent = rmController(reference(i), rmVelocity);
           
        input(2,i) = rmCurrent;
        anaout(0, rmCurrent);
        

        if toc > T_S
            disp('Sampling time too small');%Test if the sampling time is too small.
        else
            while toc <= T_S %Does nothing until the second strike of the clock reaches the sampling time set.
            end
        end
        i=i+1;
    end
end

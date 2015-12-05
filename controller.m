function [time, reference, output, input, innerTractionRefArray, rSpeedRefArray] = controller()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Control System Design Lab: Overall Controller Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T_S = 0.01;%Set the sampling time.


    function [nSamples, time, reference, output, input] = referenceGenerator()
        %REF(1,:) = traction
        %REF(2,:) = master speed
        
        %traction
        EXP_LENGTH = 50;%sec
        TRACTION_REF = 3;
        TRAC_SETUP_TIME = 8;
        
        tracRamp = 0:T_S*TRACTION_REF/TRAC_SETUP_TIME:TRACTION_REF;
        reference(1,:) = [tracRamp TRACTION_REF*ones(1, EXP_LENGTH/T_S - length(tracRamp))];
        
        %master
        SETUP_TIME = 8;%seconds
        SETUP_POINT = 2;%V Left Motor
        
        ramp = 0:T_S*SETUP_POINT/SETUP_TIME:SETUP_POINT;
        rampLength = length(ramp);
        
        reference(2,:) = [ramp ones(1,length(reference(1,:))-rampLength)*SETUP_POINT];
        
        nSamples = length(reference);
        time=0:T_S:(nSamples-1)*T_S; 
        output = zeros(2, nSamples);
        input = zeros(8, nSamples);
    end


    [nSamples, time, reference, output, input] = referenceGenerator(); %precompute the reference and generate arrays of according size
    innerTractionRefArray = zeros(1,nSamples);
    rSpeedRefArray = zeros(1,nSamples);
    
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
            FRICTION_COMPENSATOR  = -2.1;
        else
            FRICTION_COMPENSATOR  = 2.1;
        end
        KP = 3;

        error = speedRef - measuredSpeed;
        current = FRICTION_COMPENSATOR + KP*error;
    end

    function speedRef = innerLoopSpeed(traction, innerTractionRef)
        K = -0.123;
        speedRef = K*(innerTractionRef-traction);
    end

    function innerTractionRef = outerLoopTraction(traction, tractionRef)
        persistent errorIntegral;
        if isempty(errorIntegral)
            errorIntegral = 0;
        end
        K = 2;
        ZERO = 1.9;
        KI = ZERO*K;
        error = tractionRef - traction;
        errorIntegral = errorIntegral + error*T_S;
        innerTractionRef = K*(error) + KI*errorIntegral;
    end

    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Main Loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    i=1; %Set the counter to 1.
    while i < nSamples
        tic %Begins the first strike of the clock.
        [input(1,i), input(2,i), input(3,i), input(4,i), input(5,i), input(6,i), input(7,i), input(8,i)]  = anain; %Acquisition of the measurements.
        
        rmVelocity = input(5,i); %saving the inputs in a variable for ease of working
        lmVelocity = input(4,i);
        lTraction = input(3,i);
        rTraction = input(2,i);
        
        if(lTraction > 6 || rTraction > 6) % safety measures if traction is to hinh
            lmCurrent = 0;
            rmCurrent = 0;
            i = nSamples + 1;
            
        else
            lmCurrent = lmController(reference(2,i), lmVelocity);
            
            %Cascade loops
            innerTractionRef = outerLoopTraction(rTraction, reference(1,i));
            rSpeedRef = innerLoopSpeed(rTraction, innerTractionRef);
            rmCurrent = rmController(rSpeedRef, rmVelocity);
            innerTractionRefArray(i) = innerTractionRef;
            rSpeedRefArray(i) = rSpeedRef;
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
end

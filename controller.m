%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Control System Design Lab: Overall Controller Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T_S = 0.01;%Set the sampling time.
[reference, outputs, inputs] = referenceGenerator(); %precompute the reference and generate arrays of according size
i=1; %Set the counter to 1.
time=0:T_S:(N_S-1)*T_S; %Vector saving the time steps.

tic %Begins the first strike of the clock.
openinout; %Open the ports of the analog computer.



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while cond==1
    [in1,in2,in3,in4,in5,in6,in7,in8]=anain; %Acquisition of the measurements.
    if reference < SetupPoint
        reference = reference + (SetupPoint/SetupTime)*T_S;
        if reference >=  SetupPoint
            reference = endRef;
        end
    end
    error = reference - in1;
    Errors(end+1) = error;
    References(end+1) = reference;
    Integral = Integral + Ki*error*T_S;
    input = Kp*error + Integral + frictionCompensator;
    DataCommands(end+1) = input;
    anaout(input,0); %Command to send the input to the analog computer.

    Data(end+1,1)=in1; %Save one of the measurements (in1).
    t=toc; %Second strike of the clock.
    if t>i*T_S
        disp('Sampling time too small');%Test if the sampling time is too small.
    else
        while toc<=i*T_S %Does nothing until the second strike of the clock reaches the sampling time set.
        end
    end
    if i==N_S %Stop condition.
        cond=0;
    end
    i=i+1;
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

closeinout %Close the ports.

figure %Open a new window for plot.
plot(time,Data(:,1), 'b', time,DataCommands(:,1), 'g', time, References, 'r', time, Errors,'y'); %Plot the experiment (input and output).

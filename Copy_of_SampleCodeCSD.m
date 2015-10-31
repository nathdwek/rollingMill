%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Control System Design Lab: Sample Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

openinout; %Open the ports of the analog computer.
Ts=0.01;%Set the sampling time.
lengthExp=15; %Set the length of the experiment (in seconds).
N0=lengthExp/Ts; %Compute the number of points to save the datas.
Data=[]; %Vector saving the datas. If there are several datas to save, change "1" to the number of outputs.
DataCommands = [];
DataCommands(1:3000) = 0;
Errors = [];
References = [];
cond=1; %Set the condition variable to 1.
i=1; %Set the counter to 1.
tic %Begins the first strike of the clock.
time=0:Ts:(N0-1)*Ts; %Vector saving the time steps.

frictionCompensator=2.7;

Kp = 2;
Ki = Kp/3.642;
Integral = 0;
SetupPoint = 5.3;
endRef=6.5;
reference = 0;

SetupTime = 5;




%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while cond==1  
    [in1,in2,in3,in4,in5,in6,in7,in8]=anain; %Acquisition of the measurements.
    if reference < SetupPoint
        reference = reference + (SetupPoint/SetupTime)*Ts;
        if reference >=  SetupPoint
            reference = endRef;
        end
    end       
    error = reference - in1;
    Errors(end+1) = error;
    References(end+1) = reference;
    Integral = Integral + Ki*error*Ts;
    input = Kp*error + Integral + frictionCompensator;
    DataCommands(end+1) = input;
    anaout(input,0); %Command to send the input to the analog computer.

    Data(end+1,1)=in1; %Save one of the measurements (in1).
    t=toc; %Second strike of the clock.
    if t>i*Ts
        disp('Sampling time too small');%Test if the sampling time is too small.
    else
        while toc<=i*Ts %Does nothing until the second strike of the clock reaches the sampling time set.
        end
    end
    if i==N0 %Stop condition.
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
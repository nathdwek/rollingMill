openinout;
[time, reference, output, input, innerTractionRef, rSpeedRef] = controller();
anaout(0,0);
closeinout;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure %Open a new window for plot.
plot(time,reference(1,:), time, input(2,:), time, input(4,:), time, input(5,:), time, rSpeedRef); %Plot the experiment (input and output).
legend('traction reference','traction','master speed', 'slave speed', 'slave speed reference');
title('Reference and output values')
xlabel('Time [s]');ylabel('Measurement [V]');

figure;
plot(time, output(1,:), time, output(2,:));
legend('Master motor current', 'Slave motor current');
title('Actuators input')
xlabel('Time [s]');ylabel('Value [V]');

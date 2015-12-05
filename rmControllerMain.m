openinout;
[time, reference, input, output] = rmController();
anaout(0,0);
closeinout;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure %Open a new window for plot.
plot(time, reference, time, output(5,:), time, input(2,:)); %Plot the experiment (input and output).
legend('Velocity Ref', 'Measured Velocity', 'Current');
title('');
xlabel('Time [s]');ylabel('Value');

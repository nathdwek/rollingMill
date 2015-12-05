openinout;
[time, input, output] = stepInput(60, 15, 2.1, 3.5-2.1);
anaout(0,0);
closeinout;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure %Open a new window for plot.
plot(time, output(2,:), time, input(:)); %Plot the experiment (input and output).
legend('Velocity', 'Reference');
title('')
xlabel('Time [s]');ylabel('Measurement [V]');

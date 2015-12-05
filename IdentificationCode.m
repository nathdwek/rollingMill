Ts = 0.01;

thisU=reference(13/Ts:end);
thisY=output(5,13/Ts:end);
uOffset = thisU(1); %Operating point
yOffset = thisY(1);
SystemOrder=[0 1]; %Number of zeros and of poles (0 and 1), respectively.
sysIdent = IdentifySystem(thisU - uOffset,thisY - yOffset,SystemOrder,Ts);
interval = time(13/Ts:end);

plot(interval,thisY - yOffset,'.');
hold on;
lsim(sysIdent,thisU - uOffset,interval);
sysIdent

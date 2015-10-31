u=DataCommands(3000:end,1).';
y=Data(3000:end,1).';
offset = 8.62; %Operating point
SystemOrder=[0 1]; %Number of zeros and of poles (0 and 1), respectively.
sysIdent=IdentifySystem(u,y-offset,SystemOrder,Ts);
plot(time(3000:end),y-offset,'.');
hold on;
lsim(sysIdent,u,time(3000:end));
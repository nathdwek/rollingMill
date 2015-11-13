Ts = 0.01;

u=-(input(5,3232:1:4246)-input(4,3232:1:4246));
y=input(3,3232:1:4246);
uOffset = -(input(5,3232) - input(4,3232)); %Operating point
yOffset = input(3,3232);
SystemOrder=[0 1]; %Number of zeros and of poles (0 and 1), respectively.
sysIdent=IdentifySystem(u - uOffset,y-yOffset,SystemOrder,Ts);
plot(time(3232:1:4246),y-yOffset,'.');
hold on;
lsim(sysIdent,u - uOffset,time(3232:1:4246));
sysIdent
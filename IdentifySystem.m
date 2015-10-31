function sys = IdentifySystem(input,output,S_Order,Ts)

global u y SystemOrder k;

u = input;
y = output;
SystemOrder = S_Order;
k = 0:Ts:(length(u)-1)*Ts;

theta_0 = rand(1,SystemOrder(1) + SystemOrder(2) + 1); 
% Nb parameters = Nb poles + Nb zeros + 1 (Static Gain)
theta = fminsearch('cost',theta_0);
Num = [];
Den = [];
for i = 1 : SystemOrder(1)+1
    Num = [Num theta(1,i)];
end
for j = i+1 : SystemOrder(2)+SystemOrder(1)+1
    Den = [Den theta(1,j)];
end
Den = [Den 1];
sys = tf(Num,Den);
%sys = c2d(tf(Num,Den),Ts,'matched');
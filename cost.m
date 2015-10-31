function J = cost(theta)

global u y SystemOrder k
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
hatY = lsim(sys,u,k)';

epsilon = y - hatY;

J = epsilon*epsilon';


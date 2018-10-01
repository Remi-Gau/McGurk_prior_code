%%

close all
clear all

A = [0.11 0.116 0.12];

color = 'brgckmy' 

x = -1:1:83;

for i=1:length(A)
   
    a = 1 - exp(-A(i)*x);
    
    if a(14)>0.7 && a(14)<0.8
        a(14)
        i
    end
    
    Derivative = diff(a);
    
    figure(1)
    subplot(211)
    hold on
    plot(a, color(i))
    subplot(212)
    hold on
    plot(Derivative, color(i))
    
    LegendContent{i,:} = strcat('A=', num2str(A(i)));
        
end

subplot(211)
xlabel 'Time'
text(41, 0.5, 'y = 1-exp(-Ax)')
axis([0 82 0 1.1])

subplot(212)
xlabel 'Time'
legend([LegendContent], 'Location', 'SouthEast')
text(25, 0.3, 'y''')
axis([0 50 0 0.5])
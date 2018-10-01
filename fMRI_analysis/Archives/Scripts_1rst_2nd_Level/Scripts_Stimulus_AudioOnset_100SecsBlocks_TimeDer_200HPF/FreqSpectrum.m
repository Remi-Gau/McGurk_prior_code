clc
clear
close all

HPF = 200;
rt = 2.56;

StartDirectory = pwd;

cd ('1/Analysis')

load SPM.mat

NbSess = length(SPM.Sess)
NbScan = SPM.nscan(1)



for i=1:NbSess
    
    figure(i)
    subplot(6,2,[1 3])
    plot(1:NbScan, SPM.xX.X([1:NbScan]+NbScan*(i-1), 1 + (i-1)*18 ), 'b', 1:NbScan, SPM.xX.X([1:NbScan]+NbScan*(i-1), 7 + (i-1)*18), 'r')
    
    X(1,[1:NbScan]+NbScan*(i-1)) = SPM.xX.X([1:NbScan]+NbScan*(i-1), 1 + (i-1)*18 );
    X(2,[1:NbScan]+NbScan*(i-1)) = SPM.xX.X([1:NbScan]+NbScan*(i-1), 7 + (i-1)*18 );
        
    subplot(6,2,[2 4 6])
    plot(1:NbScan, SPM.xX.X([1:NbScan]+NbScan*(i-1), 1 + (i-1)*18 ) - SPM.xX.X([1:NbScan]+NbScan*(i-1), 7 + (i-1)*18), 'g')
    
    
    
    gX = abs(fft(SPM.xX.X([1:NbScan]+NbScan*(i-1), 1 + (i-1)*18 ))).^2;
    gX = gX*diag(1./sum(gX));
    q = size(gX,1);
    Hz = [0:(q - 1)]/(q*rt);
    q = 2:fix(q/2);
    
    subplot(6,2,[5 7])
    patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
    hold on
    plot(Hz(q),gX(q,:), 'b')
  
    xlabel('Frequency (Hz)')
    ylabel('relative spectral density')
    %title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
    grid on
    axis tight
    
    
    
    gX = abs(fft(SPM.xX.X([1:NbScan]+NbScan*(i-1), 7 + (i-1)*18 ))).^2;
    gX = gX*diag(1./sum(gX));
    q = size(gX,1);
    Hz = [0:(q - 1)]/(q*rt);
    q = 2:fix(q/2);
    
    subplot(6,2,[9 11])
    patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
    hold on
    plot(Hz(q),gX(q,:), 'r')
  
    xlabel('Frequency (Hz)')
    ylabel('relative spectral density')
    %title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
    grid on
    axis tight
    


    gX = abs(fft(SPM.xX.X([1:NbScan]+NbScan*(i-1), 1 + (i-1)*18 ) - SPM.xX.X([1:NbScan]+NbScan*(i-1), 7 + (i-1)*18))).^2;
    gX = gX*diag(1./sum(gX));
    q = size(gX,1);
    Hz = [0:(q - 1)]/(q*rt);
    q = 2:fix(q/2);
    
    subplot(6,2,[8 10 12])
    patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
    hold on
    plot(Hz(q),gX(q,:), 'g')
  
    xlabel('Frequency (Hz)')
    ylabel('relative spectral density')
    title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
    grid on
    axis tight
    
end




X(3,:) = X(1,:)-X(2,:);

cd (StartDirectory)

return



figure(i+1)
subplot(6,2,[1 3])
plot(1:length(X),X(1,:),'b',1:length(X),X(2,:),'r')

subplot(6,2,[2 4 6])
plot(1:length(X),X(3,:),'g')



gX = abs(fft(X(1,:))).^2;
gX = gX*diag(1./sum(gX));
q = size(gX,1);
Hz = [0:(q - 1)]/(q*rt);
q = 2:fix(q/2);

subplot(6,2,[5 7])
patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
hold on
plot(Hz(q),gX(q,:), 'b')

xlabel('Frequency (Hz)')
ylabel('relative spectral density')
%title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
grid on
axis tight



gX = abs(fft(X(2,:))).^2;
gX = gX*diag(1./sum(gX));
q = size(gX,1);
Hz = [0:(q - 1)]/(q*rt);
q = 2:fix(q/2);

subplot(6,2,[9 11])
patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
hold on
plot(Hz(q),gX(q,:), 'r')

xlabel('Frequency (Hz)')
ylabel('relative spectral density')
%title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
grid on
axis tight



gX = abs(fft(X(3,:))).^2;
gX = gX*diag(1./sum(gX));
q = size(gX,1);
Hz = [0:(q - 1)]/(q*rt);
q = 2:fix(q/2);

subplot(6,2,[8 10 12])
patch([0 1 1 0]/HPF,[0 0 1 1]*max(max(gX)),[1 1 1]*.9);
hold on
plot(Hz(q),gX(q,:), 'g')

xlabel('Frequency (Hz)')
ylabel('relative spectral density')
title(['Frequency domain',sprintf('\n'), ' {\bf',num2str(HPF),'}', ' second High-pass filter'],'Interpreter', 'Tex');
grid on
axis tight

cd (StartDirectory)
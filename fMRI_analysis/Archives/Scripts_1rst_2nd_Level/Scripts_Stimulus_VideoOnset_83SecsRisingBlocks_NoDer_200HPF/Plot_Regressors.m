cd (num2str(13))

cd Analysis_RisingBlocks_NoDer_200HPF

load SPM.mat

figure(3)
hold on
plot(SPM.xX.X(:,5),'b')
axis([0 320 -0.5 1.5])

cd ../..

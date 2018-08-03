close all

X=0;

for i=2:NbTrials
	if Trials{1,1}(i,2)==1
		X(i) = X(i-1) + IBI + BlockDuration - Trials{1,1}(i-1,3);
	else
		X(i) = X(i-1) + Trials{1,1}(i,3)-Trials{1,1}(i-1,3);
	end
end

figure(1)
plot(Trials{1,1}(:,1),Trials{1,1}(:,3))

figure(2)
hold on
plot(Trials{1,1}(:,1), Trials{6,1}(:,1), 'b')
plot(Trials{1,1}(:,1), X, 'r')

figure(3)
plot([X - Trials{6,1}(:,1)],'g')

%%

Y = reshape(Trials{1,1}(:,3), 12, 10)

b=0;

for i=1:NbTrials
	if Trials{1,1}(i,2)==1
		b=b+1;
		Z(Trials{1,1}(i,2),b) = 0;
		Ref = CollectVisualOnset(i);
	else
		Z(Trials{1,1}(i,2),b) = CollectVisualOnset(i)-Ref;
	end
	
	 
end

Z

for i=1:10
	figure(i)
	hold on
	plot(1:12, Y(:,i), 'b')
	plot(1:12, Z(:,i), 'r')
end
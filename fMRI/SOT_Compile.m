	switch Trials{1,1}(i,8);
		case 0
			B=1;
		case 1
			B=2;
		case 999
			B=3;
	end
	
	switch Trials(i,3)
		case 0
		% Find what stimulus was played
		A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMovies, 1) ), SOT_CON) );
		SOT_CON{A,  = Trials{6,1}(i,1);
		case 1
		% Find what stimulus was played
		A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMovies, 1) ), SOT_INC) );			
		case 2
		% Find what stimulus was played
		A = find( strcmp (cellstr( repmat(TotalTrials{2,1}(i,:), NbMovies, 1) ), SOT_McGurk) );
	end
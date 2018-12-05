            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).name = BlocksNames{j};
            
            sf = zeros(NbVols*NbSlices+128,1); % Creates an empty vector
            ton = round(Block_Onset{j,i}*NbSlices/TR) + 33; % Onset value after upsampling
            ton_2nd = round(Block_2nd_Onset{j,i}*NbSlices/TR) + 33;
            
            % Define shape of the block
            for BlockNumber=1:length(Block_Durations{j,i})
                ExpParam = -log(0.2)/(ton_2nd(BlockNumber)-ton(BlockNumber));
                BlockDuration = Block_Durations{j,i}(BlockNumber);
                Block = round(BlockDuration*NbSlices/TR); % number of slices in one block = number of sampling point.
                ExpBlock = [1-exp(-ExpParam*(1:Block))];
                if size(sf,1) > ton(BlockNumber)
                    sf(ton(BlockNumber):ton(BlockNumber)+Block-1,:) = sf(ton(BlockNumber):ton(BlockNumber)+Block-1,:) + ExpBlock';
                end
            end
            
            sf = sf(1:(NbVols*NbSlices + 32),:);
            X1 = conv(sf,bf); % Convolve with HRF
            X2 = X1((0:(NbVols - 1))*NbSlices + ReferenceSlice + 32,:); % Downsample
            
            matlabbatch{1,1}.spm.stats.fmri_spec.sess(1,i).regress(1,j).val = X2;
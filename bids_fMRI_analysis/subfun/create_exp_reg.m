function block_parameters = create_exp_reg(opt, cfg, nb_vols, block_parameters)

%% Define HRF
SPM.xBF.UNITS = 'secs';
% Temporal resolution in seconds of the informed basis set you are going to create
SPM.xBF.dt = opt.TR / opt.nb_slices;
SPM.xBF.name = 'hrf';
% Length of the HRF in seconds
SPM.xBF.length = 32;
SPM.xBF.order = 2;

% Creates the informed basis set
SPM.xBF = spm_get_bf(SPM.xBF);
bf = SPM.xBF.bf;


%% Define regressors
for iCdt =  1:numel(block_parameters)

% Creates an empty vector
empty_vec = zeros(nb_vols * opt.nb_slices + 128, 1); 
% Onset value after upsampling
ton = round(block_parameters(iCdt).onsets_1 * opt.nb_slices / opt.TR) + 33; 
% Onset of the second stimuli value after upsampling
ton_2nd = round(block_parameters(iCdt).onsets_2 * opt.nb_slices / opt.TR) + 33; 


% Define shape of the block
for iBlock=1:length(ton)
    
    exp_param = -log(0.2)/(ton_2nd(iBlock)-ton(iBlock));
    
    duration = block_parameters(iCdt).duration(iBlock);
    % number of slices in one block = number of sampling point.
    duration = round( duration / opt.TR * opt.nb_slices); 
    
    % create shape of the block
    exp_block = [ 1 - exp( -exp_param*(1:duration) ) ];
    
    % insert this shape at the onset of every block
    if size(empty_vec,1) > ton(iBlock)
        empty_vec( ton(iBlock) : (ton(iBlock)+duration-1), :) = ...
            empty_vec( ton(iBlock) : (ton(iBlock)+duration-1), :) + exp_block';
    else
        warning('block is outside of the session');
    end
    
end

% trim the vector 
empty_vec = empty_vec( 1:(nb_vols * opt.nb_slices + 32), : );

% Convolve with HRF
X1 = conv(empty_vec,bf); 
% Downsample
X2 = X1( ( 0:(nb_vols - 1)) * opt.nb_slices + cfg.slice_reference + 32, :); 

block_parameters(iCdt).exp_reg = X2;

end

end
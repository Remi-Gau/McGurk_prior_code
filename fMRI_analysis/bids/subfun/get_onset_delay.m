function onset_delay = get_onset_delay(cfg)
% be default the stimulus onset was set to be in between the beginning of
% the movie (V) and the onset of the pronounced syllable (A). This fucntion can
% set shift it align with either or leave it unchanged.
    switch cfg.stim_onset
        case 'A'
            onset_delay = (1-0.04*8)/2;
        case 'V'
            onset_delay = (1-0.04*8)/2 * -1;
        case 'B'
            onset_delay = 0; 
    end
end


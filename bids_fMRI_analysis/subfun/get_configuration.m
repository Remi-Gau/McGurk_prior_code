function cfg = get_configuration(all_GLMs, opt, iGLM)

        cfg.despiked = opt.despiked(all_GLMs(iGLM,1));
        cfg.slice_reference = opt.slice_reference(all_GLMs(iGLM,2));
        cfg.norm_res = opt.norm_res(all_GLMs(iGLM,3));
        
        
        cfg.GLM_denoise = opt.GLM_denoise(all_GLMs(iGLM,4));
        cfg.HPF = opt.HPF(all_GLMs(iGLM,5));
        cfg.stim_onset = opt.stim_onset{all_GLMs(iGLM,6)};
        cfg.RT_correction = opt.RT_correction(all_GLMs(iGLM,7));
        cfg.block_type = opt.block_type{all_GLMs(iGLM,8)};
        cfg.time_der = opt.time_der(all_GLMs(iGLM,9));
        cfg.mvt = opt.mvt(all_GLMs(iGLM,10));
        cfg.concat = opt.concat(all_GLMs(iGLM,11));
        
end


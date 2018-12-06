function func_file_prefix = set_file_prefix(cfg)
%gets the right prefix for the files to use
        
        if cfg.despiked
            despik_pfx = 'd';
        else
            despik_pfx = 'd';
        end
        
        func_file_prefix = ...
            ['sw' sprintf('%02.0f', cfg.norm_res) ...
            '_' despik_pfx 'a-' sprintf('%02.0f', cfg.slice_reference) '_ug_'];
end


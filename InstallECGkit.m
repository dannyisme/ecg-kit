% InstallECGkit 
% -------------
% 
% Description:
% 
% Function for installing the Kit.
% 
% 
% Author: Mariano Llamedo Soria (llamedom at {electron.frba.utn.edu.ar; unizar.es}
% Version: 0.1 beta
% Birthdate  : 01/09/2012
% Last update: 20/02/2013

function InstallECGkit()

    % Version info.
    releaseInfo = '0.1 beta - 01/09/2012';

    %path related constants.
    root_path = [fileparts(mfilename('fullpath')) filesep ];

    fprintf(1, [ ... 
            '+---------------------------------+\n' ...
            '|        Mariano''s ECGkit         |\n' ...
            '| Release: %s  |\n' ...
            '+---------------------------------+\n' ...
            'Compiling sources. ' ...
            ], releaseInfo );
        
    %Check compilation of source MEX files
    common_path = [ root_path 'common' filesep];
    source_files = dir([ common_path '*.c'] );
    lsource_files = length(source_files);
    for ii = 1:lsource_files
        [~, source_file_name] = fileparts( source_files(ii).name);
        mex_file = dir([common_path  source_file_name '.' mexext ]);
        if( isempty(mex_file) || mex_file.datenum <= source_files(ii).datenum  )
            eval(['mex -outdir ''' common_path ''' ''' [common_path source_files(ii).name] '''']);
        end
    end
    
    fprintf(1, 'done !\n' );
   
    fprintf(1, 'Adding paths. ' );
    
    %path related constants.
    default_paths = { ...
                        [root_path ';' ]; ...
                        [root_path 'common' filesep ';' ]; ...
                        [ root_path 'common' filesep 'export_fig' filesep ';' ]; ...
                        [ root_path 'common' filesep 'wavedet' filesep ';' ]; ...
                        [ root_path 'common' filesep 'prtools' filesep ';' ]; ...
                        [ root_path 'common' filesep 'prtools_addins' filesep ';' ]; ...
                        [ root_path 'common' filesep 'kur' filesep ';' ]; ...
                        [ root_path 'common' filesep 'LIBRA' filesep ';' ]; ...
                        [root_path 'a2hbc' filesep ';' ]; ...
                        [root_path 'a2hbc' filesep 'scripts' filesep ';' ]; ...
                    };

    default_paths = char(default_paths)';
    default_paths = (default_paths(:))';
    addpath(default_paths);

    savepath
    
    fprintf(1, 'done !\n' );
    fprintf(1, '\nKit was correctly installed.\n\nYou can start reading the %s, or if you prefer, trying these %s.\nGo to the %s if you need help.\n', ...
        '<a href = "http://code.google.com/p/a2hbc/wiki/Tutorial">documentation</a>', ...
        '<a href = "matlab: opentoline(examples.m,1)">examples</a>', ...
        '<a href = "https://groups.google.com/forum/?fromgroups&hl=en#!forum/a2hbc-users">forum</a>');
end
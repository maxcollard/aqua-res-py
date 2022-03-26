function [] = exportAllRes(allRes, includeCells, fileStem, exportDir)
%EXPORTALLRES Export many res structures to HDF5
%   allRes - array of res structs
%   includeCells - whether to include cell markers for each event (requires region map)
%   fileStem - name stem for exported hdf5 files
%   exportDir - destination directory

% Prepare the export directory
if ~exist( exportDir, 'dir' )
    mkdir( exportDir )
end

% For each res-file ...
for iRes = 1:length( allRes )
    
    exportFilename = [fileStem '_' num2str( iRes ) '.hdf5'];
    exportPath = fullfile( exportDir, exportFilename );
    
    fprintf( 'Exporting %s...', exportPath );

    res = allRes(iRes);
    saveStruct = getMarks( res, includeCells );

    save( exportPath, '-v7.3', '-struct', 'saveStruct' );

    fprintf( 'Done\n' );

end

fprintf( 'Finished.\n' )

end


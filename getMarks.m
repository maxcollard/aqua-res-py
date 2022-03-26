function [markStruct] = getMarks(res, includeCells)
%GETMARKS Convert res format to a format more compatible with hdf5 export
%   res - res struct from AQuA
%   includeCells - whether to include cell labels (requires region specification)

if includeCells == true
    nCells = size( res.fts.region.cell.incluLmk, 1 );
end

nEvents = size( res.fts.loc.t0, 2 );

% Framerate and resolution
frameT = res.opts.frameRate;
pixelUM = res.opts.spatialRes;

% This is in *pixels*
imageSize = res.opts.sz;

% Onset time for all events
frameEventAll = res.fts.loc.t0;

% Cell identity for each event
if includeCells == true
    cellEventAll = zeros( nEvents, 1 );
    for i = 1:nEvents
        cellEventAll(i) = find( res.fts.region.cell.memberIdx(i, :) == 1 );
    end
end

% Decode direction order
directionOrder = res.fts.notes.propDirectionOrder;
for iDir = 1:4
    if strcmp( directionOrder{iDir}, 'Anterior' )
        anteriorIndex = iDir;
    end
    if strcmp( directionOrder{iDir}, 'Posterior' )
        posteriorIndex = iDir;
    end
    if strcmp( directionOrder{iDir}, 'Left' )
        leftIndex = iDir;
    end
    if strcmp( directionOrder{iDir}, 'Right' )
        rightIndex = iDir;
    end
end

% Marks for each event
marks = struct;

marks.area = res.fts.basic.area';
marks.peri = res.fts.basic.peri';
marks.circMetric = res.fts.basic.circMetric';

marks.dffMax = res.fts.curve.dffMax';
marks.dffMax2 = res.fts.curve.dffMax2';
marks.rise19 = res.fts.curve.rise19';
marks.fall91 = res.fts.curve.fall91';
marks.width55 = res.fts.curve.width55';
marks.width11 = res.fts.curve.width11';
marks.decayTau = res.fts.curve.decayTau';

marks.propGrowAnterior = res.fts.propagation.propGrowOverall(:, anteriorIndex);
marks.propGrowPosterior = res.fts.propagation.propGrowOverall(:, posteriorIndex);
marks.propGrowLeft = res.fts.propagation.propGrowOverall(:, leftIndex);
marks.propGrowRight = res.fts.propagation.propGrowOverall(:, rightIndex);
marks.propShrinkAnterior = res.fts.propagation.propShrinkOverall(:, anteriorIndex);
marks.propShrinkPosterior = res.fts.propagation.propShrinkOverall(:, posteriorIndex);
marks.propShrinkLeft = res.fts.propagation.propShrinkOverall(:, leftIndex);
marks.propShrinkRight = res.fts.propagation.propShrinkOverall(:, rightIndex);

marks.nOccurSameTime = res.fts.networkAll.nOccurSameTime;
marks.nOccurSameLoc = res.fts.networkAll.nOccurSameLoc(:, 1);
marks.nOccurSameLocSize = res.fts.networkAll.nOccurSameLoc(:, 2);

% Determine event centroid
% TODO Get position at start?
marks.centroidXPixels = NaN( size( marks.area ) );
marks.centroidYPixels = NaN( size( marks.area ) );
marks.centroidXUM = NaN( size( marks.area ) );
marks.centroidYUM = NaN( size( marks.area ) );

alreadyErrd = false;

for i = 1 : numel( marks.centroidXPixels )
    curX2D = res.fts.loc.x2D{1, i};
    [r, c] = ind2sub( imageSize(1:2), curX2D );
    startX = min( c );
    startY = min( r );
    
    curMap = res.fts.basic.map{1, i};

    try

        relCentroid = regionprops( true( size( curMap ) ), curMap, 'WeightedCentroid' ).WeightedCentroid;
        centroid = [startX, startY] + relCentroid;

        marks.centroidXPixels(i) = centroid(1);
        marks.centroidYPixels(i) = centroid(2);
        marks.centroidXUM(i) = centroid(1) * pixelUM;
        marks.centroidYUM(i) = centroid(2) * pixelUM;

    catch err

        if alreadyErrd == false
            fprintf( '\n' )
        end
        alreadyErrd = true;

        fprintf( 'Issue with determining centroid for event %d\n', i );

    end
    
end

% Format output

markStruct = struct;

% TODO These are dataset-specific keys
markStruct.name = res.name;
markStruct.mouseID = res.mouseID;
markStruct.date = res.date;
markStruct.tSeriesNum = res.tSeriesNum;

markStruct.fs = 1 / frameT;
markStruct.pixelUM = pixelUM;
markStruct.eventFrames = frameEventAll';
if includeCells == true
    markStruct.eventCells = cellEventAll;
end

% Save marks in systematic way
markNames = fieldnames( marks );
for kMark = 1 : numel( markNames )
    markData = marks.(markNames{kMark});
    markKey = ['mark_', markNames{kMark}];
    markStruct.(markKey) = markData;
end

end


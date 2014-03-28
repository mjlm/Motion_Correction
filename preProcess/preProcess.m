function preProcess(path, suffix, binFactor)
% preProcess(path, [suffix], [binFactor]) loads all tiff files whose path
% starts with PATH (wildcard allowed), applies lineshift correction, splits
% channels and slices, and saves the result as tiffs for separate channels
% in the same folder.
%
% Optionally, a SUFFIX is added to the base name of the
% files. 
%
% Optionally, pixel binning is applied.

if ~exist('suffix', 'var') || isempty(suffix)
    suffix = '';
end

if ~exist('binFactor', 'var') || isempty(binFactor)
    binFactor = 1;
end

ls = dir(path);

if isempty(ls)
    error('No files found at the supplied path.')
end

folder = fileparts(path);

for f = ls'
    [~, fNameBase, ext] = fileparts(f.name);
    if ~isempty(suffix)
        fNameBase = [fNameBase, '_', suffix];
    end
    
    % Skip non-tiff files:
    if ~(strcmpi(ext, '.tif') || strcmpi(ext, '.tiff'))
        continue
    end
    
    % Load files:
    [mov, siStruct] = tiffRead(fullfile(folder, f.name), 'uint16');
    siStruct = siStruct.(cell2mat(fieldnames(siStruct))); % Remove unnecessary layer in scanimage struct.
    
    %% Perform lineshift correction:
    % For now, this is done on all channels simultaneously. May be more
    % efficent to use only red channel, but not everyone uses red channel.
    % Also, the correction only takes a few seconds per 1000 frames.
    mov = correctLineShift(mov);
    
    %% Spatial binning:
    if binFactor > 1
        mov = binSpatial(mov, binFactor);
    end
    
    %% Split data into channels/slices:
    % Nomencalture: frames and slices refer to the concepts used in
    % ScanImage. For clarity, the z-dimenstion in the tiff is therefore
    % called "tiffPage" here.
    [height, width, nTiffPages] = size(mov);
    nChannels = numel(siStruct.channelsSave);
    nSlices = siStruct.stackNumSlices; % Slices are acquired at different locations (e.g. depths).
    nFrames = nTiffPages/(nChannels*nSlices); % Frames are acquired at same locations.
    
    mov = reshape(mov, height, width, nChannels, nFrames, nSlices);
    
    for sl = 1:nSlices
        for ch = 1:nChannels            
            fName = sprintf('%s_slice%1.0f_ch%1.0f%s', fNameBase, sl, ch, ext);
            tiffWrite(reshape(mov(:,:,ch,:,sl), height, width, nFrames), ...
                fName, fullfile(folder, 'processed'));
        end
    end
end

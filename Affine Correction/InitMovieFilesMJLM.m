%% Change This: Create variable / filenames names and location
nameOffset = 0;

% movO = tiffRead('C:\Users\Matthias\Local\Storage\labdata\imaging\MMe001\MMe001_140330\preProcessFunctionTestActivityAcq\processed\MMe001_140330_920spontAct_001_001_slice1_ch1.tif');
% imaging_dir = 'C:\Users\Matthias\Local\Storage\labdata\imaging\';
% mouse_dir = 'MMe001';
% session_dir = 'MMe001_140330';
% subsession_dir = 'processed';

view_name = 'MM021_140518_spont_001';
slice_name = 'slice1_ch1';

% tiff_dir = fullfile(imaging_dir, mouse_dir, session_dir, subsession_dir);
% tiff_dir = 'C:\Users\Matthias\Local\Storage\labdata\imaging\motionCorrectionTests';
tiff_dir = 'C:\Users\Matthias\Local\Storage\labdata\imaging\MM021\MM021_140518\processed';
ls = dir( fullfile(tiff_dir, [view_name '*']));

tiffPath = tiff_dir;
filepath = tiffPath;

movie_file = fullfile(tiff_dir, [view_name '_mov']);
ICPC_file = fullfile(tiff_dir, [view_name '_icpc']);

% Select file names based on string included in name:
correctFileIdentifier = 'ch1';
applyFileIdentifier = 'ch1';

correct_filenames = {ls(cellfun(@(c) ~isempty(c), strfind({ls.name}, correctFileIdentifier))).name};
apply_filenames = {ls(cellfun(@(c) ~isempty(c), strfind({ls.name}, correctFileIdentifier))).name};

if numel(correct_filenames) ~= numel(apply_filenames)
    error('Must have the same number of "correct" and "apply" file names."');
else
    num_files = numel(correct_filenames);
end

%% Do Not Change This: Initialize File Variables
cd(filepath),

if exist([movie_file '.mat'], 'file')
    delete([movie_file '.mat']);
    disp('Old movie file deleted')
end

MovFile = matfile([movie_file '.mat'],'Writable',true);
MovFile.movie_mask = [];
MovFile.acqFrames=[];
MovFile.cated_xShift = [];
MovFile.cated_yShift = [];
MovFile.acqRef = zeros(0,0,0,'single');
MovFile.correct_filenames = correct_filenames;
MovFile.apply_filenames = apply_filenames;
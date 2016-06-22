function ntok = OP_labels_all(hemi, surfaces, subjdir, subjid)
% function ntok = OP_labels_all(hemi, OPs, <subjdir>, <subjid>)

% Andreas Højlund Nielsen: 2016-01-29

% Wrapper-function for running surfaceids with fs_make_label - to be called
% from bash, see OP_vol2label.sh in $SUBJECTS_DIR.
% Note: this takes multiple inputs per argument in order to loop over them
% within this wrapper so as to not open and close matlab from within the
% bash loop on every iteration

% hemi = hemispheres, i.e. 'lh' and or 'rh' - if multiple inputs, it
%   will/should be listed in a string with arguments separated by spaces,
%   e.g. 'lh rh'
% surfaces = surfaceids as they're used in the file name, i.e.
%   "?h.<surfaceid>.w"
% subjdir = default is freesurfer's $SUBJECTS_DIR, should be the name of
%   the folder where the surfaces can be found in the 'surf' subdirectory
% subjid = default is 'fsaverage', should be the name of the subject on
%   which the surface is based, i.e. name of the relevant folder in
%   freesurfer's $SUBJECTS_DIR 



%% Wrapper script for running a number of surfaces with fs_make_label

% Checking if subjdir and subjid are assigned, otherwise assigning default
if (nargin ~=3 || nargind ~=4)
    if exist('subjdir','var') ~= 1
        if c == 1
            subjdir = '/Applications/freesurfer/subjects/';
        elseif c == 2
            subjdir = '/usr/local/freesurfer/subjects/';
        end
    elseif exist('subjdir','var') == 1
        custom_dir = 1;
    end
    if exist('subjid','var') ~= 1
        subjid = 'fsaverage';
    end
end

% Checking if 'freesurfer/matlab' is added to the path
if exist('freesurfer/matlab','dir') ~= 7
    if strncmp('MAC',computer,3)
        c = 1;  % variable determining os environment, 1=mac, 2=linux, 3=win
        if custom_dir == 1 % adapt to the custom freesurfer directory
            addpath(fullfile(subjdir(1:regexp(subjdir,'/subjects')),'/matlab/'))
        else
            addpath /Applications/freesurfer/matlab/
        end
    elseif (strncmp('GLN',computer,3) || strncmp('SOL',computer,3))
        c = 2;
        if custom_dir == 1 % adapt to the custom freesurfer directory
            addpath(fullfile(subjdir(1:regexp(subjdir,'/subjects')),'/matlab/'))
        else
            addpath /usr/local/freesurfer/matlab/
        end
    end
end
    
subj = {subjid};
hemis = strread(hemi,'%s ');
surfaceids = strread(surfaces,'%s');

ntok = 0;

for i = 1:length(subj)
    for j = 1:length(surfaceids)
        for k = 1:length(hemis)
            hemi_white = fullfile(subjdir,subj{i},'surf',sprintf('%s.white',hemis{k}));
            wfile = fullfile(subjdir,subj{i},'surf',sprintf('%s.%s.w',hemis{k},surfaceids{j}));
            outfile = fullfile(subjdir,subj{i},'label',sprintf('%s.%s.label',hemis{k},surfaceids{j}));
            ok = fs_make_label(hemi_white,wfile,outfile,subj{i});
            ntok = ntok + ok;
        end
    end
end

display(sprintf('Number of surfaces transformed to label: %d',ntok))


return

%% Old version which is too long due to opening and closing matlab for each
%% iteration - but it will work with OP_vol2label_long.sh

% ntok = 0;
% 
% subjects_dir = '/Applications/freesurfer/subjects/';
% 
% hemi_white = fullfile(subjects_dir,subjid,'surf',sprintf('%s.white',hemi));
% wfile = fullfile(subjects_dir,subjid,'surf',sprintf('%s.%s.w',hemi,surfaceid));
% outfile = fullfile(subjects_dir,subjid,'label',sprintf('%s.%s.label',hemi,surfaceid));
% ntok = fs_make_label(hemi_white,wfile,outfile,subjid);

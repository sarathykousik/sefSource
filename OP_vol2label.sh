#! /bin/bash
## author: andreas
printf "\n\n\n##### \nWARNING! Have you thresholded your volumes? \nIf not, you may get some overlaps between your labels. \nUse tksurfer or the like to check this (see closing comment for more info on tksurfer). \n##### \n\n\n"


mat_script_path="/Users/linahn/MATLAB/gen_scripts/"
hemis=("lh" "rh")
OPs=("OP1" "OP2" "OP3" "OP4")
subjs=("013_7UF" "015_IHM")

for i in "${hemis[@]}"; do
	for j in "${OPs[@]}"; do
		mri_vol2surf --src "$SUBJECTS_DIR/Operculum_$j.nii" --src_type analyse --srcreg "$SUBJECTS_DIR/fsaverage/mri/transforms/reg.mni152.2mm.dat" --hemi "$i" --out "$i.$j.w" --out_type paint;
	done;
done;

# checking if freesurfer is set up on a Virtual Box - if so, then abort from here (i.e. the || enforces this abortion)
{
vboxmanage --version && printf "\n\n\n##### \nIt seems freesurfer is running on a Virtual Box installation. \nTherefore matlab cannot be called from within this script. \nIf CFIN-affiliated, try moving your processing to isis; otherwise, try buying a proper computer. \n##### \n\n\n" && exit
} || {
printf "\n\n\n##### \nChecked that freesurfer isn't running on a Virtual Box - you're good to go! I'll take it from here. \n##### \n\n\n"
}

printf "\n\n\n##### \nmatlab call: OP_labels_all '${hemis[*]}' '${OPs[*]}' '$SUBJECTS_DIR' 'fsaverage'; exit \n##### \n\n\n"

cd "$mat_script_path"
matlab -nosplash -nodesktop -nojvm -r "OP_labels_all '${hemis[*]}' '${OPs[*]}' '$SUBJECTS_DIR' 'fsaverage'; exit"

printf "\nmatlab processing done!\n"
cd "$SUBJECTS_DIR"

for i in "${hemis[@]}"; do
	for j in "${OPs[@]}"; do
		for k in "${subjs[@]}"; do
			mri_label2label --srclabel "$SUBJECTS_DIR/fsaverage/label/$i.$j.label" --srcsubject fsaverage --trglabel "$SUBJECTS_DIR/$k/label/$i.$j.label" --trgsubject "$k" --regmethod surface --hemi "$i"
		done;
	done;
done

printf "\n\n\nAll done! Use \ntksurfer <subject> <hemi> <surface> --label <labelname> \nto check your new labels (or click on File > Label > Load Label in the tksurfer GUI to manually load your labels).\n"

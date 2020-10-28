# Agespan 7T project
Scripts for processing Matt's 7T data
- python fwdl.py: download manual segmentations from FW
- binarize.R: binarize segmentation masks
- ./prepare.sh: qsub preprocessing
- ./mimosa.sh: qsub mimosa
- try_thresholds.R: calculate dice coefficient for various mimosa probability map thresholds

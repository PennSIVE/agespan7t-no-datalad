#!/bin/bash

qsub -t 1-9 -b y -cwd -l h_vmem=512G -pe threaded 2-64 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
SINGULARITYENV_INDEX=\$SGE_TASK_ID SINGULARITYENV_NSLOTS=\$NSLOTS \
singularity run --cleanenv /cbica/home/robertft/simg/neuror_4.0.sif Rscript ~/repos/agespan7t/mimosa.R

# qsub -t 1-1 -b y -cwd -l h_vmem=512G -pe threaded 2-64 -o ~/sge/\$JOB_ID -e ~/sge/\$JOB_ID \
# SINGULARITYENV_INDEX=\$SGE_TASK_ID SINGULARITYENV_NSLOTS=\$NSLOTS \
# singularity run --cleanenv -B ~/nic_train:/nic_train:ro /cbica/home/robertft/simg/neuror_4.0.sif Rscript ~/repos/agespan7t/mimosa_with_nic.R
# for mask in $(find ~/nic_train -name T1_brain.nii.gz); do
# outdir=$(echo $mask | grep -Eo \/[0-9]{1}\/ | grep -Eo [0-9]{1})
# singularity run /cbica/home/robertft/simg/neuror_4.0.sif Rscript -e "library(neurobase); writenii(readnii('${mask}') > 0, '~/mimosa_with_nic/${outdir}/binmask.nii.gz')"
# done
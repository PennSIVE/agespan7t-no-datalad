#!/bin/bash

declare -A image_map
image_map[INV1_ws.nii.gz]=flair.nii.gz
image_map[UNI_ws.nii.gz]=t1.nii.gz
image_map[INV2_ws.nii.gz]=pd.nii.gz
image_map[T1map_ws.nii.gz]=t2.nii.gz
image_map[mks-bin.nii.gz]=lesion.nii.gz
mkdir ~/nic_train
for image_label in UNI_ws.nii.gz INV1_ws.nii.gz INV2_ws.nii.gz T1map_ws.nii.gz mks-bin.nii.gz; do
    i=1
    for image in $(find ~/data/scitran -name "*${image_label}"); do
        mkdir ~/nic_train/${i} 2> /dev/null
        ln -s $image ~/nic_train/${i}/${image_map[${image_label}]}
        i=$((i+1))
    done
done

# config is at /cbica/projects/agespan7T/repos/nicMSlesions/config/configuration.cfg
# qsub -l h_vmem=64G -l V100 -b y -cwd -o ~/sge/nic-\$JOB_ID -e ~/sge/nic-\$JOB_ID \
qsub -l h_vmem=64G -l gpu=1 -b y -cwd -o ~/sge/nic-\$JOB_ID -e ~/sge/nic-\$JOB_ID \
singularity run --nv \
-B ~/nic_train:/data \
-B ~/repos/nicMSlesions:/root/nicMSlesions/ \
-B /usr/local/cuda-9.0 \
/cbica/home/robertft/singularity_images/nicmslesions_cuda.sif python /root/nicMSlesions/nic_train_network_batch.py

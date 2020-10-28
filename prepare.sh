#!/bin/bash

cd ~
# for uni in $(find ~/data/scitran -name *UNI.nii.gz); do
#     image_label=$(basename ${uni} .nii.gz)
#     outdir=$(dirname ${uni})

    # n4_jid=$(qsub -b y -cwd -o ${outdir}/${image_label}.n4 -e ${outdir}/${image_label}.n4 -l h_vmem=8G -l short -terse \
    #     singularity run --cleanenv -B $uni:/in.nii.gz:ro -B $PWD/repos/agespan7t:/code -B $outdir:/out /cbica/home/robertft/simg/neuror_4.0.sif Rscript /code/n4.R)
    # echo $n4_jid

    # mass_jid=$(qsub -b y -cwd -l h_vmem=24G -o ${outdir}/${image_label}.mass -e ${outdir}/${image_label}.mass -terse -hold_jid $n4_jid \
    #     singularity run --cleanenv /cbica/home/robertft/simg/mass_latest.sif \
    #     -in ${outdir}/uni_n4.nii.gz -dest $outdir -ref /opt/mass-1.1.1/data/Templates/WithCerebellum -NOQ -mem 20)
    # bet_jid=$(qsub -b y -cwd -o ${outdir}/${image_label}.bet -e ${outdir}/${image_label}.bet -l h_vmem=8G -terse \
    #     singularity run --cleanenv -B $outdir/uni_n4.nii.gz:/uni_n4.nii.gz:ro -B $PWD/repos/agespan7t:/code -B $outdir:/out /cbica/home/robertft/simg/neuror_4.0.sif Rscript /code/fslbet.R)
    # echo $bet_jid
    # actually, kelly already skull stripped these^
    # on takim:
    # cd /project/carly/agespan_7T
    # find . -name mp2rage_INV2_n4_fslbet_stripped.nii.gz | grep baseline > ~/fl
    # on cubic:
    # rsync -azP --files-from=timrf@sciget.pmacs.upenn.edu:~/fl timrf@sciget.pmacs.upenn.edu:/project/carly/agespan_7T ~/from_kelly
# done

for outdir in $(find ~/data/scitran -type d -name for-mimosa); do
for image in UNI.nii.gz INV1.nii.gz INV2.nii.gz T1map.nii.gz; do
    subj_num=$(echo $outdir | grep -Eo [0-9]{3})
    ss=$(find ~/from_kelly/${subj_num} -type f)
    to_process=$(find $outdir -name *${image})
    qsub -b y -cwd -o ${outdir}/${image}.log -e ${outdir}/${image}.log -l h_vmem=16G -terse \
        SINGULARITYENV_LABEL=$(basename ${image} .nii.gz) SINGULARITYENV_WS_TYPE=$([ $image = UNI.nii.gz ] && echo "T1" || echo "T2") singularity run --cleanenv -B $ss:/mask.nii.gz:ro -B $to_process:/in.nii.gz:ro -B ~/repos/agespan7t:/code -B $outdir:/out /cbica/home/robertft/simg/neuror_4.0.sif Rscript /code/preprocess.R

done
done

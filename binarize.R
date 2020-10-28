mask = neurobase::readnii(Sys.getenv("MASK"))
mask[mask!=0] = 1
RNifti::orientation(mask) = "RAS"
mask = oro.nifti::nii2oro(mask)
neurobase::writenii(mask, Sys.getenv("OUT"))

# for mask in $(find ~/data -name *mks.nii.gz); do
# SINGULARITYENV_MASK=$mask SINGULARITYENV_OUT=$(dirname $mask)/$(basename $mask .nii.gz)-bin.nii.gz singularity run --cleanenv /cbica/home/robertft/simg/neuror_4.0.sif Rscript ~/repos/agespan7t/binarize.R
# done

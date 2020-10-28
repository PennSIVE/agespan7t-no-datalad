library(fslr)

subjs = c('7TAS-003', '7TAS-004', '7TAS-007', '7TAS-010', '7TAS-011', '7TAS-013', '7TAS-017', '7TAS-018', '7TAS-024')
thresholds = c(0.05, 0.15, 0.25)
results = data.frame(matrix(ncol = 3, nrow = 9))
colnames(results) = thresholds
i = 1
for (subj in subjs) {
  probmap = readnii(paste0('/cbica/projects/agespan7T/data/scitran/cnet/7T-MS-agespan/', subj, '/probability_map.nii.gz'))
  gs = readnii(list.files(path = paste0('/cbica/projects/agespan7T/data/scitran/cnet/7T-MS-agespan/', subj), pattern = "mks-bin.nii.gz", recursive = TRUE, full.names = TRUE)[1])
  for (thresh in thresholds) {
    binmap = probmap > thresh
    dir.create(paste0('/cbica/projects/agespan7T/data/scitran/cnet/7T-MS-agespan/', subj, '/thresholds'), showWarnings = FALSE)
    writenii(binmap, paste0('/cbica/projects/agespan7T/data/scitran/cnet/7T-MS-agespan/', subj, '/thresholds/', thresh))
    results$thresh[i] = fsl_dice(gs, binmap)
  }
  i = i + 1
}
write.table(results, file = "results.csv", sep = ",")

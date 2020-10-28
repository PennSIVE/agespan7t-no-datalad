library(fslr)
library(mimosa)

index = as.numeric(Sys.getenv("INDEX"))
train_dir = "/cbica/projects/agespan7T/data/scitran/cnet/7T-MS-agespan"
subjs = c('7TAS-003', '7TAS-004', '7TAS-007', '7TAS-010', '7TAS-011', '7TAS-013', '7TAS-017', '7TAS-018', '7TAS-024')
t1_files = list.files(path = file.path(train_dir, subjs), pattern = "^UNI_ws.nii.gz$", full.names = TRUE, recursive = TRUE)
t2_files = list.files(path = file.path(train_dir, subjs), pattern = "^T1map_ws.nii.gz$", full.names = TRUE, recursive = TRUE)
flair_files = list.files(path = file.path(train_dir, subjs), pattern = "^INV1_ws.nii.gz$", full.names = TRUE, recursive = TRUE)
pd_files = list.files(path = file.path(train_dir, subjs), pattern = "^INV2_ws.nii.gz$", full.names = TRUE, recursive = TRUE)
brainmask_files = list.files(path = file.path(train_dir, subjs), pattern = "^UNI_binmask.nii.gz$", full.names = TRUE, recursive = TRUE)
mask_files = list.files(path = file.path(train_dir, subjs), pattern = "mks-bin.nii.gz$", full.names = TRUE, recursive = TRUE)
filepaths = data.frame(t1 = t1_files, flair = flair_files, t2 = t2_files, pd = pd_files, mask = mask_files, brainmask = brainmask_files)

start = proc.time()
mimosa_training = mimosa_training(
  brain_mask = filepaths$brainmask[-index],
  FLAIR = filepaths$flair[-index],
  T1 = filepaths$t1[-index],
  T2 = filepaths$t2[-index],
  PD = filepaths$pd[-index],
  tissue = FALSE,
  gold_standard = filepaths$mask[-index],
  cores = as.numeric(Sys.getenv('NSLOTS')),
  verbose = TRUE,
  optimal_threshold = seq(0.15, 0.35, 0.025)
)
proc.time() - start

saveRDS(mimosa_training,
        paste0(train_dir, "/", subjs[index], "/mimosa_model.RDS"))
message("model done training!")


## apply model to data ##
print(filepaths$t1[index])

t1.cur = readnii(filepaths$t1[index])
flair.cur = readnii(filepaths$flair[index])
t2.cur = readnii(filepaths$t2[index])
pd.cur = readnii(filepaths$pd[index])
brainmask.cur = readnii(filepaths$brainmask[index])

mimosa_testdata = mimosa_data(
  brain_mask = brainmask.cur,
  FLAIR = flair.cur,
  T1 = t1.cur,
  T2 = t2.cur,
  PD = pd.cur,
  tissue = FALSE,
  cores = as.numeric(Sys.getenv('NSLOTS')),
  verbose = T)

mimosa_testdata_df = mimosa_testdata$mimosa_dataframe
mimosa_candidate_mask = mimosa_testdata$top_voxels

predictions = predict(mimosa_training$mimosa_fit_model,
                      newdata = mimosa_testdata_df,
                      type = "response")
probability_map = niftiarr(brainmask.cur, 0)
probability_map[mimosa_candidate_mask == 1] = predictions

probability_map = fslsmooth(probability_map,
                            sigma = 1.25,
                            mask = brainmask.cur,
                            retimg = TRUE,
                            smooth_mask = TRUE)
writenii(probability_map, paste0(train_dir, "/", subjs[index],
                                 "/probability_map.nii.gz"))

thresh = 0.25
lesmask = ifelse(probability_map > thresh, 1, 0)
writenii(lesmask, paste0(train_dir, "/", subjs[index], "/lesmask_", as.character(thresh * 100), ".nii.gz"))

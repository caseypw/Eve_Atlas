rm(list = ls())
library(drammsr)
library(fslr)
eve_dir = path.expand("~/Dropbox/RegLib_C26_MoriAtlas")
mni_dir = path.expand(file.path(fsldir(), 
  "data", "standard"))
eve.t1 = file.path(eve_dir, 
                   "JHU_MNI_SS_T1_brain.nii.gz")
eve_brain = readNIfTI(eve.t1, 
                      reorient = FALSE)
mni_file = file.path(mni_dir, 
          "MNI152_T1_1mm_brain.nii.gz")
mni_brain = readNIfTI(mni_file, 
                      reorient = FALSE)

template_name = "Rorden"
# template_name = "MNI"

labels = file.path(eve_dir, 
                   paste0(
                    "JHU_MNI_SS_WMPM_Type-", 
                    c("I", "II", "III"), 
                          ".nii.gz"))


out_labels = paste0(nii.stub(labels), 
                           "_to_", 
                           template_name, 
                           "_brain_DRAMMS.nii.gz")
rorden_file = file.path(eve_dir, 
  "betsct1_unsmooth.nii.gz")

template.file = switch(template_name,
                       "Rorden" = rorden_file,
                       "MNI" = mni_file)

rorden_brain = readNIfTI(template.file, 
 reorient = FALSE)

out_eve = paste0(nii.stub(eve.t1), 
 "_to_", template_name, "_brain_DRAMMS.nii.gz")

def = paste0(nii.stub(eve.t1), 
  "_to_", 
  template_name, "_brain_DRAMMS_def.nii.gz")

if (!file.exists(def)) {
  rorden_out_eve = dramms(source = eve_brain, 
                          target = rorden_brain, 
                          outfile = out_eve,
                          outdef = def)
}

if (!all(file.exists(out_labels))) {
  source = labels[1]
  outfile = out_labels[1]
  template = template.file
  interpolation = "nearest.neighbor"
  retimg = FALSE
  verbose = TRUE


  res = mapply(function(source, outfile){
    dramms_warp(
      source = source,
      outfile = outfile,
      def = def,
      interpolation = interpolation,
      verbose = verbose,
      retimg = retimg
      )
    }, labels, out_labels)
}

v2lab = file.path(eve_dir,
                  "JHU_MNI_SS_WMPM_Type-II_V2.0.nii.gz")

v2_out_labels = paste0(
  nii.stub(v2lab), 
                    "_to_", 
                    template_name, 
                    "_brain_DRAMMS.nii.gz")

if (!all(file.exists(v2_out_labels))) {
  source = v2lab[1]
  outfile = v2_out_labels[1]
  template = template.file
  interpolation = "nearest.neighbor"
  retimg = FALSE
  verbose = TRUE
  
  res = mapply(function(source, outfile){
    dramms_warp(
      source = source,
      outfile = outfile,
      def = def,
      interpolation = interpolation,
      verbose = verbose,
      retimg = retimg
    )
  }, v2lab, v2_out_labels)
}


###############################
# Reverse - for RAVENS
###############################
rev_eve = file.path(eve_dir,
   paste0(
    template_name, "_brain", "_to_",
    nii.stub(eve.t1, bn = TRUE), 
    "_DRAMMS.nii.gz")
   )

rev_def = file.path(eve_dir,
   paste0(
    template_name, "_brain", "_to_",
    nii.stub(eve.t1, bn = TRUE), 
    "_DRAMMS_def.nii.gz")
   )


if (!file.exists(rev_def)) {
  rev_out_eve = dramms(
    source = rorden_brain, 
    target = eve_brain, 
    outfile = rev_eve,
    outdef = rev_def)
}

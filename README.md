# How prior expectations shape multisensory perception

This code relates to the experiment and paper [How prior expectations shape multisensory perception](10.1016/j.neuroimage.2015.09.045).

I have uploaded the original results of this study on [neurovault](https://neurovault.org/collections/4172/).

## Original version of the code
The script to run (orginally with matlab 2010a and psychtoolbox version 3.09) the fMRI and behavioral experiments are in the `fMRI` and `psychophysics` folders respectively. Still in need of better documentation. :-(

The original stimuli are on a private OSF project as I am not sure we have from the actors on the videos to make those fully open. Do get in touch if you want to know more.

The original scripts to run the analysis presented in the paper are in the `fMRI_analysis` folder but are really poorly documented. So they are here mostly for posterity and archival purposes.

Scripts for the many other analysis that we tried and were not published or mentioned in the paper are kept in an `archive` folder on the `archives` branch of this repository.

## BIDS data
I have made a BIDS dataset of the original fMRI data. I am checking if this fMRI study had the proper ethical permission to make the data fully open. Bear with me but do get in touch if you want to know more.

## BIDS compatible pipeline of 'all' analysis performed
For the sake of transparency, clarity and reproducibility/replicability, I am working docker based pipeline relying on octave and SPM and using the BIDS format. It is in the `bids_fMRI_analysis` folder.

### Requirements
At the moment this runs under matlab (2018a) and SPM12 (v7219) but I am struggling to make some of the SPM toolboxes play nice with octave. The toolboxes are thus added as submodules to the repository as I sometimes need to add some octave related fix to them.

### How to run the code
1.  `run_preprocessing.m` will run all the different preprocessing pipelines
2.  `run_first_level.m` will run all the different subject level GLMs and computes the contrasts necessary for the group level analysis. See the subfunction `subfun/set_all_GLMS.m` to select which pipelines you want to run.
3.  `run_second_level.m` (WIP) runs the group level analysis corresponding to the analysis published.

### General comments
In general this work is clearer and better documented although not yet perfect. This pipeline also tries to incorporate the vast majority the analysis we tried. For example, below is a list of the different choices that were made (but not explored in a systematic manner). The options that were used for the published results are marked with a \*.

*   despiking the data using [art repair](https://cibsr.stanford.edu/tools/human-brain-project/artrepair-software.html)
  -   `OFF`
  -   `ON` (\*)
  -

*   denoising the data using [GLMdenoise](http://kendrickkay.net/GLMdenoise/)  (1-3 are different ways to denoise the data)
  - `OFF` (\*)
  - `1`
  - `2`
  - `3`

*   high-pass filter:
`none`
`100 seconds`
`200 seconds` (\*)
*   stimulus onset aligned to
auditory component (`A`) of the movie,
the visual component (`V`)
or in between `B` (\*)

*   reaction time effect correction on activations
`ON`
`OFF` (\* original mentions both but only reports results for `OFF`)

*   type of blocks for the context effect (check methods of the manuscript for an explanation of exponential rising blocks)
  -  `none`
  -  `83 seconds boxcar`
  -  `100 seconds boxcar`
  -  `83 seconds exponential`
  -  `100 seconds exponential`

*   include time derivative of the HRF
  -  `OFF`
  -  `ON` (\*)

*   include realignment parameters in the design matrix
  -  `OFF`
  -  `ON` (\*)

*   concatenate design
  - `OFF` (\*)
  - `ON`

While cleaning and documenting this project I realized that some pre-processing pipelines might have had some error (or poor practice) in them but because of bad documenting, I am not sure whether they were the pipeline used for the published results. Those included:
-   running the slice-timing using the first slice as reference and not the mid-volume slice
-   normalizing the data using 2 mm rather than the original EPI resolution (3 mm). See [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5487467/) why this might be a problem if not controlling for final image smoothness when using random field theory to control for multiple correction.

To check whether this affected the results I have also run processing pipelines for those options.

In total all those options would amount to a about 10 000 different models to run.

Some other analysis at the group level were run (combining different contrasts or involving brain-behavioral correlations) but are not taken into account as this pipeline mostly tries to check the robustness of the published results to unreported changes in processing pipelines or subject-level GLM design.

For more information see:
-   multiverse analysis
-   specification curves
-   vibration of effect

Another thing to investigate would be to run model selection on the result of this pipeline.

![Alt Text](monoLogo.PNG?raw=true "MonoLogo")

February 13th, 2017

Assaf Zaritsky - assafzar@gmail.com

## Monolayer spatiotemporal analysis source code
### The repository includes Matlab source code and one test dataset.

- Input: time laspe of monolayer migration experiment (phase contrast)
- Output: speed, directionality and coordinaion kymographs, wound healing rate

### Input

- Input: file name for time-lapse data, parameters (optional).
- Produces output in designated directories.
  - `main(filename, params)`

### Needed parameters
- `params.timePerFrame` % Imaging frequency: time between acquired frames (minutes).
- `params.nRois` % Number of region of interest to segment, 1 - for 1-side advancing monolayer, 2 - wound healing.
- `params.pixelSize` % Phyiscla pixel size (um).
- `params.patchSize` % Patch resolution for PIV and segmentation (um). Tradeoff between noiser motion estimation and reduced resolution.
- `params.nTime` % Number of frames to process (e.g., for 200 minutes set nTime to (200 / `params.timePerFrame`).
- `params.maxSpeed` % Maximal cell speed. Used for the PIV analysis (um / hr). Tradeoff between noisier motion estimation and missing fast motions.
- `params.kymoResolution.maxDistMu` % how deep to go into the monolayer for kymograph analysis (um).

### Test data
- Download raw images via the link: [TestData](https://cloud.biohpc.swmed.edu/index.php/s/SWGQQJySbOI206o/download) , called `Angeles_20150402_14hrs_5min_AA01_7.tif`
- The default parameters in `main.m` were set for this data

### Output folders
- Each time-lapse has its own folder (e.g., `Angeles_20150402_14hrs_5min_AA01_7`). 
- Each time-lapse folder  includes the following sub-folders, each containing per-frame outputs as described next (`.mat` file):
  - `images`: raw images
  - `MF/mf`: PIV (velocity fields per frame)
  - `ROI/roi`: segmentation (ROI per frame)
  - `coordination`: masks of cells moving in coordinated clusters (per frame)

The following folders include summary for all time-lapse analyzed and are located at the parent folder (at the level of the time-lapse folders):
- `healingRate`: healing rate over time in a `.mat` file
- `kymographs`: sub-folders for speed, directionality and coordination, each one holds the kymographs in `.eps` (visualization) and `.mat` (data) formats
- `segmentation`: video showing the visualization over time

-----------------

### Citation

Please cite the following manuscript when using this code:
["Diverse roles of guanine nucleotide exchange factors in regulating collective cell migration"](https://doi.org/10.1101/076125) (https://doi.org/10.1101/076125)

Please contact Assaf Zaritsky, assafzar@gmail.com, for any questions / suggestions / bug reports.

-----------------

+ For more work from the Danuser Lab: http://www.utsouthwestern.edu/labs/danuser/

  (and software: http://www.utsouthwestern.edu/labs/danuser/software/ )

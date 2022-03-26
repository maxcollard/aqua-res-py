# aqua-res-py
Export scripts for converting AQuA res-files to Python-compatible formats

## Usage

### MATLAB

Run `exportAllRes(allRes, includeCells, fileStem, exportDir)` where

* `allRes` is the `allRes` array of structs loaded from the dataset,
* `includeCells` is `false`,
* `fileStem` is the desired base of the filename (appended by `_#.hdf5` for each AQuA res struct),
* `exportDir` is the desired output directory for the HDF5 intermediates (which are very small).

### Python

This function generates HDF5 files with the following keys:

* `name`, `mouseID`, `date`, `tSeriesNum`: taken from the metadata for each raw dataset,
* `fs`: the samping frequency of the recording (Hz),
* `pixelUM`: the image scale (microns per pixel),
* `eventFrames`: the onset frame of each event,
* `mark_x`: marks for each event from AQuA segmentation, for numerous `x`.

See `events-demo.ipynb` for example usage.

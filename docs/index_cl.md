# Welcome to QRMITools

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2530801.svg)](https://doi.org/10.5281/zenodo.2530801) [![status](http://joss.theoj.org/papers/ef8bfb6c31499845d353b6a5af0d6300/status.svg)](http://joss.theoj.org/papers/ef8bfb6c31499845d353b6a5af0d6300)

***

[![wolfram language](\QMRITools\images\wolfram language.png)](https://www.wolfram.com/language/)   [![wolfram workbench](\QMRITools\images\wolfram workbench.jpg)](https://www.wolfram.com/workbench/)   [![eclipse](\QMRITools\images\eclipse.png)](https://www.eclipse.org/)   [![Wolfram Mathematica](\QMRITools\images\wolfram mathematica.png)](http://www.wolfram.com/mathematica/)

***
 
## Content
* [Introduction](#introduction)
* [Latest Release](#latest-release)
* [Documentation](\QMRITools\htmldoc\guide\QMRITools.html){:target="_blank"}
* [Demonstrations](#demonstrations)
* [Functionality](#functionality)
* [Toolboxes](#toolboxes)
* [References](#references)

***

## Introduction

`QMRITools` is written in Mathematica using Wolfram Workbench and Eclipse and contains a collection of tools and functions for processing quantitative MRI data. The toolbox does not provide a GUI and its primary goal is to allow for fast and batch data processing, and facilitate development and prototyping of new functions. The core of the toolbox contains various functions for data manipulation and restructuring.

The toolbox was developed mostly in the context of quantitative muscle, nerve and cardiac magnetic resonance imaging. The library of functions grows along with the research it is used for and started as a toolbox to analyze DWI data of muscle.

The toolbox is developed for the [Wolfram language](https://www.wolfram.com/language/) and maintained using [Wolfram workbench](https://www.wolfram.com/workbench/) for [eclipse](https://www.eclipse.org/) and runs in the latest version of [Wolfram Mathematica](http://www.wolfram.com/mathematica/).

***

## Latest Release

The latesest release can be found [here](https://github.com/mfroeling/QMRITools/releases){:target="_blank"}. 

Install the toolbox in the Mathematica UserBaseDirectory > Applications.

`FileNameJoin[{$UserBaseDirectory, "Applications"}]`

Some functions of QMRITools call on external executables and software.
These executables need to be present in "QMRITools\Applications" and are included in the release.
If for any reason you want to use other (older/newer) versions you can replace them but functionality is not guaranteed.
For the latest version of these tools and their user license please visit their website.

* [dcm2niix](https://github.com/rordenlab/dcm2niix/)
	* dcm2niix.exe
* [Elastix](http://elastix.isi.uu.nl/)
	* elastix.exe
	* transformix.exe

All functionality is tested under Windows 10 with the latest Mathematica version.
The Mathematica code is cross platform compatible with the exception of the external tools which are compiled for each OS.
The toolbox provides compiled versions for each OS but their functionality is not guaranteed.
The Elastix version used is 4.9 with OpenCL support. Additionally Elastix needs to be compiles with the PCA metrics, all DTI related parameters and all affine related parameters.

Although cross platform compatibility is provided I have only limited options for testing so if any issues arise please let me know.  

***

## Demonstrations

The release contains a zip file [DemoAndTest.zip](https://github.com/mfroeling/QMRITools/releases/download/2.0/DemoAndTest.zip) in which there is a file ``demo.nb``, a folder ``DemoData`` and a folder ``Testing``. 
To have a global overview of the functionality of the toolbox you can download this folder and run the ``demo.nb``.
By default the ``demo.nb`` looks for the folders ``DemoData`` and ``Testing`` in the same folder as the notebook.

In the first section of the demo notebook the toolbox is loaded and two tests are performed. The first test is to check of all files that are needed to run the toolbox are present. The second test runs after the toolbox is loaded and checks if all the functions and their options that are defined are correct.

***

## Functionality

The toolbox contains over 250 Functions and options of processing and analyzing data.
A summary of the core functionality is listed below. 

![Overview](\QMRITools\images\overview.png)

* **Diffusion Analysis**
	* Signal drift correction 
	* LLS, WLLS and iWLLS methods
	* REKINDLE outlier detection
	* IVIM fitting (fixed parameters, back-projection and Bayesian fitting)
	* Parameter fitting using histogram analysis
	* Joining and sorting of multiple series of the same volume
	* Joining multiple stacks with slice overlap into one stack
* **Diffusion Gradients optimization**
	* Single and multi shell
	* Rotating and correcting Bmatrix
	* Actual b-value estimation by gradient sequence integration
	* Gradient visualization
* **Noise suppression**
	* LMMSE noise suppression
	* PCA noise suppression based on ramom matrix theory
	* Anisotropic tensor smoothing using diffusion filter.
* **Importing and Exporting**
	* Dicom data (classing and enhanced file format)
	* Nifti data (.nii and .img .hdr, supports .gz files)
	* Compatible with ExplorDTI and Viste for fiber tractography
* **Data visualization**
	* 2D 3D and 4D viewer
	* Multiple images: Transparent overlay, difference and, checkboard overlays
	* Legend bars and image labels
	* Saving to pdf, jpg, animated gif and movie
* **Masking**
	* Automate and threshold masking
	* Extracting parameters form masks
	* Smoothing masks
	* Smoothing muscle segmentation
* **Motion and distortion correction (Registration using elastix)**
	* Rigid, affine, b-spline and cyclic registration 
	* nD to nD registration
	* Automated series processing 
	* Slice to slice motion correction of 3D and 4D data
* **Dixon Reconstruction**
	* B0 phase unwrapping
	* DIXON iDEAL reconstruction with T2start
* **Relaxometry fitting**
	* T2 fitting
	* T1rho fitting
	* Tri Exponential T2 fitting
	* EPG based T2 fitting with slice profile
* **Simulation Framework**
	* Diffuison tensor simulation and analysis
	* Bloch and EPG simulations
	* Cardiac DTI models (fiber architecture)
* **Cardiac Diffusion analysis** 
	* Breathing motion correction
	* Corrupted slice rejection
	* Local myocardial coordinate system calculation
	* helix angle and fiber architecture matrix
	* AHA 17 parameter description
	* Transmural parameter description	

***

## Toolboxes

### CardiacTools
A collection of tools to analyze cardiac data. The main features are cardiac shape analysis which allows defining the hard in a local myocardial coordinate system which allows quantifying and analyzing data. When the cardiac geometry is known there are functions to analyze qMRI parameters in the AH17 model [@Cerqueira2002] or perform transmural sampling of qMRI parameters. 
Most of the functionality is demonstrated in the `demo.nb`.

### CoilTools
A collection of tools to evaluate complex multi-coil data. The functions are specific for analysis of multi-coil magnitude and noise data which allows quantifying per channel SNR. Furthermore, if complex coil sensitivity maps are available it allows performing SENSE g-factor maps simulations.   
This toolbox is not demonstrated in the `demo.nb`.

### DenoiseTools
The toobox provides two algorithms that allow denoising of DWI data. The first is based on and LMMSE framework [@Aja-Fernandez2008] and the second is based on a random matrix theory and Principal component analysis framework [@Veraart2015; @Veraart2016]. Furthermore, it provides an anisotropic filter for denoising the estimated diffusion tensor which provides more reliable fiber orientation analysis [@JeeEunLee].
Most of the functionality is demonstrated in the `demo.nb`.

### DixonTools
An IDEAL based Dixon reconstruction algorithm [@Reeder2005; @Yu2008]. The method provides multi-peak fitting B0 field and T2* correction. The toolbox also provides a function for unwrapping phase data in 2D and 3D based on a best path method [@Abdul-Rahman2007; @Herraez2002]. It also contains a function that allows simulating gradient echo Dixon data.
Most of the functionality is demonstrated in the `demo.nb`.

![IDEAL based Dixon reconstruction: fitted fat fractions as a function of the imposed fat fraction, SNR and B0 field offset.](\QMRITools\images\dixon.png)

### ElastixTools
A wrapper that calls the Elastix registration framework [@Klein2010; @Shamonin2013]. The toolbox determines what registration or transformations need to be performed, exports the related data to a temp folder and calls an automatically generated command line script that performs the registration. After registration is completed the data is again loaded into Mathematica.
Most of the functionality is demonstrated in the `demo.nb`.

### GeneralTools
This toolbox provides core functions used in many other functions and features. The functions comprise amongst others: data cropping, mathematical and statistical operators that ignore zero values, and data rescaling, transformation and padding.
Most of the functionality is demonstrated in the `demo.nb`.

### GradientTools
The main feature is an algorithm that uses static repulsion [@Jones1999; @Froeling2016] to generate homogeneously distributed gradient directions for DWI experiments. It also provides functions to convert bval and bvec files to bmatrix and vice versa.
Most of the functionality is demonstrated in the `demo.nb`.

![The graphical user interface of the gradient generation tool.](\QMRITools\images\gradients.png)

### ImportTools
Allows importing DCM data or DCM header attributes. These functions are rarely used since the toolbox mostly uses the NIfTY data format and provides tools to convert DCM to NIfTI via [dcm2niix](https://github.com/rordenlab/dcm2niix).
This toolbox is not demonstrated in the `demo.nb`.

### IVIMTools
The toolbox includes functions to perform IVIM fitting of DWI data. There are two main functions: non linear fitting and Bayesian fitting [@Orton2014]. 
Some of the functionality is demonstrated in the `demo.nb`.

![Visualization of IVIM fitting.](\QMRITools\images\ivim.png)

### JcouplingTools
A toolbox that allows simulation of NMR spectra using Hamiltonians based on methods from [FID-A](https://github.com/CIC-methods/FID-A). It allows simulating large spin systems [@Castillo2011] and was mainly implemented to investigate fat spectra in TSE [@Stokes2013].
Most of the functionality is demonstrated in the `demo.nb`.

### MaskingTools
Tools for masking and homogenization of data. It provides functions for smoothing cutting and merging masks and functions for the evaluation of data within masks.
Most of the functionality is demonstrated in the `demo.nb`.

### NiftiTools
Import and export of the NIfTI file format. Part of the code is based on previously implemented [nii-converter](https://github.com/tomdelahaije/nifti-converter). For converting DICOM data to the NIfTI file format the toolbox uses [dcm2niix](https://github.com/rordenlab/dcm2niix/releases). It also provides some specialized NIfTI import functions for specific experiments which are probably not generalizable.
Most of the functionality is demonstrated in the `demo.nb`.

### PhysiologyTools
Functions for importing and analyzing Philips physiology logging and RespirAct trace files. The functions are rarely used and not well supported.
This toolbox is not demonstrated in the `demo.nb`.

### PlottingTools
A variety of functions for visualization of various data types. The main functions are 'PlotData' and 'PlotData3D' which allow viewing 2D, 3D and 4D data.
Most of the functionality is demonstrated in the `demo.nb`.

### ProcessingTools
The toolbox comprises a variety of functions that allow data manipulation and analysis. The main functions allow joining multiple data sets into one continuous data set [@Froeling2015] or to split data of two legs into two separate data-sets. Furthermore, it contains a collection of functions for data evaluation and analysis.
Most of the functionality is demonstrated in the `demo.nb`.

### RelaxometryTools
A collection of tools to fit T2, T2*, T1rho and T1 relaxometry data. The main function of this toolbox is an extended phase graph (EPG) [@Weigel2015] method for multi-compartment T2 fitting of multi-echo spin echo data [@Marty2016]. Therefore it provides functions to simulate and evaluate EPG. 
Some of the functionality is demonstrated in the `demo.nb`.

![Demonstration of EPG based T2 fitting: the fitted water T2 relaxation as a function of B1, SNR and fat fraction.](\QMRITools\images\epg-t2.png)

### SimulationTools
The main purpose of this toolbox is to simulate DTI based DWI data and contains some functions to easily perform analysis of the fit results of the simulated signals [@Froeling2013].
Some of the functionality is demonstrated in the `demo.nb`.

### TensorTools
The original toolbox where the project started. The main functions in this toolbox are to fit and evaluate the diffusion tensor model. Various fitting methods are implemented (e.g. LLS, NLS, WLLS, and iWLLS). The default method is an iterative weighted linear least squares approach [@Veraart2013]. The tensor fitting also includes outlier detections using REKINDLE [@Tax2015] and data preparation includes drift correction [@Vos2014].
Most of the functionality is demonstrated in the `demo.nb`.

![MD and FA as a function of SNR and fat fraction. Results are from simulated data using an iWLLS algorithm with outlier rejection.](\QMRITools\images\dti.png)

### VisteTools
Import and export functions for tensor data which can be used in the [vIST/e](http://bmia.bmt.tue.nl/software/viste/) tractography tool.
None of the functionality is demonstrated in the `demo.nb`.

***

![Full leg diffusion tensor fiber tractography](\QMRITools\images\animation-small.gif)

***

## References
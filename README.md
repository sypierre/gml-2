# MDI343 - Challenge 2015
# Shuyu Dong

This is a project for EEG signal clasification. It includes feature extraction based on a Matlab toolbox ScatNet-0.2 proposed by
Data group led by S.Mallat at ENS; the second part of the project consists of simple trials of dimensionality reduction and classification within Scikit-learn.

Contact: shuyu.dong at telecom-paristech dot fr

Directories included in the toolbox
-----------------------------------

`dbs/`   - a directory that contains databases output by feature_extraction.

`feature_extraction/`  - A matlab implementation for extracting and constructing databases that contain features based on scattering tarnsform.

`report/`

I. Feature extraction

Setup
-----
1. load `feature_extraction/` in Matlab
2. run `mdi0.m`, this requires parallel pools of the Matlab version and may take some time (within 14 mins for training/validation and test sets extraction in total). The output `.mat` files will be stored in `dbs/` ready for use of python scripts such as `main0.py`.
3. Notice: in `mdi0.m`, we will need to extract features with two different fashions, choose `ch=0` and then `ch=1` to have both versions of features stored in `dbs/`.


II. Classification

Example 1: run classification with raw feature matrices in `dbs/`
---------------------
1. In `main0.py`, choose the parameter `ch=1` to use "squeezed" features of dimension 10178x67 or `ch=0` to use "stacked" features of dimension 10178x402.
2. run `main0.py`

Example 2: run dimensionality reduction before  classification  feature matrices in `dbs/`
---------------------
1. same choice for features
2. run `main_pcasvm.py` to get new submission text files.

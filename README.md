# Characteristics of HRV Patterns for Different Yoga Postures in Beginners
<p align="center">
  <img width="471" height="286" alt="image" src="https://github.com/user-attachments/assets/0556b6fc-0023-4e4e-82c9-b86dd9ec143d" />
</p>

As part of the ST4Health M2 program - Digital Mental Health track, the project presented in this repository aims to apply an experimental protocol using the Bitalino PsychoBIT in order to reproduce previously published scientific results.

More specifically, building on reported HRV patterns observed across different yoga postures in trained practitioners, we sought to reproduce the same experimental conditions in beginner participants and compare the resulting autonomic responses.

This repository contains all the material required to reproduce the implemented protocol, including data processing scripts and analysis steps.

---
## ©️ Reference
This project is based on a study conducted by [Pitale et al. in 2014](https://ieeexplore.ieee.org/document/7030672)

---
## 🖼️ Content
This repository contains the following elements:
  - Written protocol
    - Protocol.pdf: PDF document describing the complete experimental protocol. Please refer to it for detailed information on data acquisition procedures and software settings.
      
  - Code required to reproduce the experiment
    - poses/: Folder containing posture images used by the acquisition UI.
    - yoga_experiment_ui.m: MATLAB script used for real-time data acquisition during the experiment.
      
  - Example data & analysis scripts
    - raw.zip: Compressed folder containing examples of anonymized raw data recorded using OpenSignals, including ECG (HRV) and PZT (respiration) signals.
    - post_process.m: MATLAB script for signal preprocessing, HRV analysis, and results visualization.

---
## 🏃🏻‍♀️ To run an experiment
### Requirements
To successfully run the data acquisition and processing scripts, ensure the following are installed:
  - MATLAB version: MATLAB R2025a or later
  - Required MATLAB Toolboxes:
    - Signal Processing Toolbox: Required for filtering, R peak detection, and Welch power spectral density estimation.
    - Statistics and Machine Learning Toolbox: Required for basic statistical operations (mean, standard deviation).
  - External Dependencies:
    - Lab Streaming Layer (LSL) for MATLAB: Required only for data acquisition (yoga_experiment_ui.m). Install LSL for MATLAB by following the instructions given on the [official GitHub repository](https://github.com/labstreaminglayer/liblsl-Matlab).

    
    Note: The signal processing script (post_process.m) does not require LSL.

### Data Acquisition
1. Launch OpenSignals and ensure LSL is enabled in the general settings
2. Connect the Bitalino to the computer via Bluetooth; the connection to sensors and settings were set as followed:
    - PZT sensor → A1 port
    - ECG sensor → A4 port
    - Sampling frequency → 1000 Hz
3. Start recording in OpenSignals
4. Run yoga_experiment_ui.m in MATLAB.
5. When the End Session button is pressed, stop the recording and save the .txt data file in OpenSignals.
6. Experiment is complete!


### Data Processing
1. Unzip the raw.zip folder containing the example data files
2. Place the extracted .txt files inside the raw/ directory
3. Run post_process.m in MATLAB to:
    - Preprocess ECG and respiration signals
    - Detect R-peaks and compute RR intervals
    - Estimate HRV power spectra using Welch’s method
    - Compute LF and HF power (normalized units)
    - Generate HRV plots
---

## 📊 Main Results

<img width="1198" height="337" alt="image" src="https://github.com/user-attachments/assets/bfc963b2-baea-4951-b2ff-5e264f1b9bc9" />

Although only a limited number of participants took part in this study, the implemented protocol allowed us to reproduce HRV patterns comparable to those reported in the reference article. 

We can note that clear differences emerged when comparing trained practitioners to beginners. Overall, professional yoga practitioners exhibited a stable autonomic balance, characterized by consistent LF dominance across postures, suggesting efficient autonomic regulation and controlled breathing. In contrast, beginners showed a more variable cardiac autonomic response, with HF power equal to or exceeding LF in several postures.
These differences seem to indicate that beginners respond more strongly to postural changes, likely reflecting a reactive parasympathetic activation rather than a stable autonomic adaptation. This heightened HF activity may be influenced by irregular breathing patterns and increased physical effort, both of which are more likely to happen in less experienced practitioners.

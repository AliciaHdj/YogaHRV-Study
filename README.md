# Characteristics of HRV Patterns for Different Yoga Postures in Beginners
<p align="center">
  <img width="471" height="286" alt="image" src="https://github.com/user-attachments/assets/0556b6fc-0023-4e4e-82c9-b86dd9ec143d" />
</p>

  As part of the ST4Health M2 progam, Digital Mental Health trackn the project presented in this repository aims at applying an experimental protocol using the Bitalino PsychoKit to reproduce scientific results. In particular, following results of HRV patterns in different yoga postures in profesionnales, we tried reproducing the expreriment in beginners to compare the outcomeq. This repository contains all elements required to reproduce the protocol that was put into place to do so.

---
## ©️ Credits
This project is based on a study conducted by [Pitale et al. in 2014](https://ieeexplore.ieee.org/document/7030672)

---
## 🖼️ Content
This repository contains the following elements :
- **Written protocol**
  - PDF describing the full experimental protocol, please refer to it for all details explaining data acquisition steps & software settings
  - Written consent form participants had to fill
- **Codes necessary to reproduce experiment**
  - Image folder containing o ensure comparable performance with the original method, we rely on the same datasets they used, which are both available on the following link : http://www.cbsr.ia.ac.cn/users/xiangyuzhu/projects/3DDFA/main.htm
  - MATLAB script for data acquisition
- **Data examples & Analyzing codes**
  - Folder containing exmaples of raw, anonymized data files recorded using OpenSignals containg HRV and PZT recordings
  - MATLAB script for signal processing

## Requirements
To successfully run the data acquisition scripts, make sure the following MATLAB toolboxes are installed :
- I think only yhe one for the UI is required?
- 
The data exploration and preprocessing steps are thoroughly documented in the [Data_preparation.ipynb](https://github.com/toisonhugo/3DDFA_V2_TF/blob/main/notebooks/Data_preparation.ipynb) notebook. However, the two main steps required before training are summarized below:

1. Generate features files :
   
Run the cells that handle the concatenation of all feature files (e.g., landmarks, pose, identity parameters, etc.) into a unified format under the "Concaténation de toutes les features" section of the notebook 

2. Generate training and evaluation .txt files:

Run the cells located under the "Création des fichiers .txt" section of the notebook. These cells create the .txt files that define the training, validation, and test splits.

Note : To prepare the data correctly, you only need to execute these steps once.

---

## 📊 Main results

<img width="1198" height="337" alt="image" src="https://github.com/user-attachments/assets/bfc963b2-baea-4951-b2ff-5e264f1b9bc9" />

Although only a few participants took part in the experiment, the implanted protocol allowed us to reproduce similar graphs to the based-on article. By comparing average LF/HF of profesionnal to beginners, our main findings were as follow :
1. Autonomic balance differences
LF consistently dominent VS HF equal to or higher in some postures
⟶ Difference in autonomic regulation between the two groups

2. Response to postural changes
Posture change = stable LF dominance in professionals VS HF increases in beginners
⟶ Reactive parasympathetic response for beginners

3. Role of experience and breathing
HF strongly influenced by breathing regularity
⟶ Irregular breathing + Higher physical effort in beginners leads to HF dominance
provide a comparison with the original PyTorch model and a quick insight into the best current performance of our implementation, we report below the average Normalized Mean Error (NME, in pixels), as well as the mean angular error (averaged over yaw, pitch, and roll) on the AFLW2000-3D dataset.



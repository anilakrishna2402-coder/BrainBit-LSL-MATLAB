# BrainBit-LSL-MATLAB

Real-time EEG streaming from a BrainBit headset to MATLAB using Lab Streaming Layer (LSL).


## Overview

This project demonstrates real-time acquisition of EEG signals from a BrainBit headset using NeuroSDK in Python. The acquired signals are streamed over the Lab Streaming Layer (LSL) protocol and received in MATLAB for real-time visualization and further processing.


## Pipeline

BrainBit Headset
        ↓
NeuroSDK (Python)
        ↓
Lab Streaming Layer (LSL)
        ↓
MATLAB Receiver


## Repository Structure

python/
- sample_headphones.py
- SendData.py
- matlab/
    - ReceiveEEG.m

screenshots/

requirements.txt

## Requirements

- Python 3.11
- MATLAB R2026a
- NeuroSDK
- pylsl
- numpy

Install Python packages using:

```bash
pip install -r requirements.txt
```

## How to Run

1. Connect the BrainBit headset.
2. Run the Python sender (`SendData.py` or `sample_headphones.py`).
3. Start `ReceiveEEG.m` in MATLAB.
4. EEG samples are streamed through LSL and received in MATLAB in real time.


## Sample Output

See the screenshots folder for example sender and receiver outputs.


Developed for BrainBit EEG streaming and MATLAB integration using Lab Streaming Layer (LSL).

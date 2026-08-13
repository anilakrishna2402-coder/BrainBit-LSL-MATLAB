# BrainBit-LSL-MATLAB

Real-time EEG streaming from a BrainBit headset to MATLAB using **NeuroSDK** and **Lab Streaming Layer (LSL)**.

## Overview

This project demonstrates real-time acquisition of EEG signals from a BrainBit headset using NeuroSDK in Python. The EEG data is received in **chunks**, streamed through the Lab Streaming Layer (LSL), and received in MATLAB for real-time visualization and further processing.

The chunk-based implementation is designed to handle continuous EEG data efficiently while preserving the four-channel BrainBit signal structure.

## Pipeline

```text
BrainBit Headset
       ↓
NeuroSDK
       ↓
Python
(sample_headphones_chunk.py)
       ↓
LSL EEG Outlet
       ↓
Local Network
       ↓
MATLAB
(ReceiveEEG_Chunk.m)
       ↓
Real-Time EEG Visualization
```

## EEG Configuration

* Device: BrainBit
* Channels: 4 EEG channels
* Sampling Rate: 250 Hz
* Data Transport: Lab Streaming Layer (LSL)
* Python: 3.11
* MATLAB: R2026a

## Repository Structure

```text
BrainBit-LSL-MATLAB/
│
├── sample_headphones_chunk.py
│       └── BrainBit EEG acquisition and chunk-based LSL streaming
│
├── matlab/
│   └── ReceiveEEG_Chunk.m
│       └── LSL EEG receiver and real-time visualization
│
├── requirements.txt
│
├── screenshots/
│       └── Example sender and receiver outputs
│
└── README.md
```

## Requirements

### Software

* Python 3.11
* MATLAB R2026a
* BrainBit NeuroSDK
* Lab Streaming Layer (LSL)
* `pylsl`
* `numpy`

Install the required Python packages using:

```bash
pip install -r requirements.txt
```

## How It Works

### 1. BrainBit EEG Acquisition

The BrainBit headset is connected and accessed through the NeuroSDK.

The Python program receives the EEG signal through the BrainBit signal callback.

The incoming data contains four EEG channels:

```text
Ch1
Ch2
Ch3
Ch4
```

The samples are processed in chunks rather than individually.

### 2. EEG Signal Processing and Quality Check

For each incoming chunk, the Python program extracts the four EEG channels and performs basic signal checks.

The current implementation reports:

* First sample in the chunk
* Last sample in the chunk
* Minimum value for each channel
* Maximum value for each channel
* Mean value for each channel

Example:

```text
--- EEG Quality Check ---

Ch1: Min=0.188089, Max=0.230123, Mean=0.210467
Ch2: Min=0.187972, Max=0.229982, Mean=0.210339
Ch3: Min=0.188079, Max=0.230104, Mean=0.210453
Ch4: Min=0.188086, Max=0.230109, Mean=0.210458
```

These checks are used to verify that incoming samples are changing and that data is being continuously received.

> Note: Basic Min/Max/Mean statistics confirm signal variation and data transmission, but they alone do not establish that the signal is physiologically valid EEG. Further signal-quality and frequency-domain analysis can be performed when required.

### 3. LSL EEG Streaming

The Python program creates an LSL EEG outlet and publishes the four-channel EEG data over the local network.

The stream contains:

```text
Channels: 4
Sampling Rate: 250 Hz
Type: EEG
```

The LSL stream can then be discovered by compatible applications such as MATLAB and ViewA.

### 4. MATLAB Reception

`ReceiveEEG_Chunk.m` searches for the BrainBit EEG LSL stream and receives the incoming samples in chunks.

The received data is stored and used for real-time visualization.

The MATLAB receiver can therefore display the EEG signal while the Python acquisition program continues to receive data from the BrainBit headset.

## Running the System

### Step 1 — Connect BrainBit

Turn on the BrainBit headset and ensure that it is detected by the NeuroSDK.

### Step 2 — Start the Python EEG Stream

Run:

```bash
python sample_headphones_chunk.py
```

The terminal should show continuously arriving EEG samples and chunk information.

### Step 3 — Verify the LSL Stream

Check that the EEG stream is discoverable through LSL.

The expected stream configuration is approximately:

```text
4 ch EEG @ 250 Hz
```

### Step 4 — Start MATLAB

Open MATLAB and run:

```matlab
ReceiveEEG_Chunk
```

MATLAB should locate the BrainBit EEG LSL stream and begin receiving the incoming EEG chunks.

### Step 5 — Visualize the EEG

The MATLAB receiver displays the four EEG channels in real time.

The expected flow is:

```text
BrainBit → Python → LSL → MATLAB → EEG Plot
```

## Network Configuration

LSL uses the local network to discover and transmit streams between applications.

Therefore, the computer running the Python EEG sender and the device running the receiving application must be able to communicate over the same local network.

If the LSL stream is not visible to another device:

1. Check that both devices are connected to the same network.
2. Check Windows Firewall settings.
3. Allow Python/MATLAB/LSL communication through the firewall when required.
4. Verify that the LSL stream is visible locally before troubleshooting the network connection.

## Troubleshooting

### BrainBit is not detected

* Check that the headset is powered on.
* Verify the Bluetooth connection.
* Check that NeuroSDK can detect the device.
* Ensure that no other application is exclusively using the BrainBit device.

### Python receives data but MATLAB does not

Check:

* LSL outlet creation
* Stream name
* Stream type
* Channel count
* Sampling rate
* LSL discovery
* Local network connectivity
* Windows Firewall

### MATLAB cannot find the stream

First verify that the Python sender is running and continuously publishing the LSL stream.

If the stream is visible locally but not on another device, investigate network/firewall configuration.

## Current Implementation

The project currently uses a **chunk-based EEG acquisition and transmission approach**:

```text
BrainBit
   ↓
NeuroSDK
   ↓
sample_headphones_chunk.py
   ↓
EEG chunks
   ↓
LSL Outlet
   ↓
ReceiveEEG_Chunk.m
   ↓
MATLAB
   ↓
Real-time EEG visualization
```

## Future Improvements

Potential extensions include:

* EEG filtering
* Band-pass filtering
* Notch filtering
* Standard deviation and signal-to-noise measurements
* FFT/frequency-domain analysis
* EEG band-power calculation
* Artifact detection
* Improved signal-quality assessment
* Data recording to `.mat` or other formats
* Multi-device LSL streaming and visualization

## Purpose

The project provides a real-time bridge between the **BrainBit EEG headset**, **Python/NeuroSDK**, **Lab Streaming Layer**, and **MATLAB**, enabling EEG acquisition, network streaming, visualization, and subsequent signal processing.

Developed for BrainBit EEG acquisition and real-time MATLAB integration using Lab Streaming Layer (LSL).

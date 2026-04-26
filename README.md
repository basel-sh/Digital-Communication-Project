# Digital Communications Projects
Cairo University — Faculty of Engineering
Electronics and Communications Dept. | 2nd Year

---

## Project 1 — Statistical Analysis of Line Coding

**Folder:** `Part1/`

### What it does
Simulates a digital transmitter generating an ensemble of 500 random waveforms (100 bits each) for three different line coding schemes, then statistically analyzes each one.

### Line Codes Covered
| Code | Logic 0 | Logic 1 |
|---|---|---|
| Unipolar | 0 V | +A |
| Polar NRZ | −A | +A |
| Return to Zero (RZ) | −A (first half), 0 (second half) | +A (first half), 0 (second half) |

### Requirements Implemented
1. Statistical mean across the ensemble
2. Stationarity check (is the mean constant over time?)
3. Ensemble autocorrelation function R_x(τ)
4. Time mean and autocorrelation for a single waveform
5. Ergodicity check (does time mean ≈ ensemble mean?)
6. Bandwidth estimation via FFT

### Files
- `Statistical Analysis of Line Coding for Digital Communication.m` — main MATLAB simulation
- `Project Requirments.pdf` — original project sheet
- `Project1NotFinished.pdf / .docx` — report (in progress)

---

## Project 2 — Matched Filters, Correlators, ISI, and Raised Cosine Filters

**Folder:** `Part2/`  
**Status: In Progress**

### What it does
Simulates a binary PAM communication system over an AWGN channel, evaluating receiver performance using matched filters and correlators, then studies Inter-Symbol Interference (ISI) using raised cosine pulse shaping.

### System Overview
- Transmitter generates binary polar signals (+1, −1) convolved with a pulse shaping function p(t)
- Signal passes through an AWGN channel
- Receiver uses either a **matched filter** h(t) = p(Ts − t) or a **correlator** to maximize SNR

### Requirements

**Part 1 — Noise-Free Analysis (10 bits)**
- Generate 10 random bits and map to ±1
- Upsample and convolve with pulse shape p = [5 4 3 2 1]/sqrt(55)
- Filter with: (i) matched filter, (ii) a rectangular filter
- Compare filter outputs at sampling instants
- Compare matched filter output vs. correlator output

**Part 2 — Noise Analysis (10,000 bits)**
- Add scaled AWGN noise: variance = N0/2
- Calculate BER using matched filter vs. rectangular filter
- Sweep Eb/N0 from −2 dB to +5 dB in 1 dB steps
- Plot simulated BER curves vs. theoretical: BER = 0.5 × erfc(sqrt(Eb/N0))

**Part 3 — ISI and Raised Cosine Filters (100 bits)**
- Use square root raised cosine filters at transmitter and receiver
- Test 4 combinations of rolloff factor R and filter delay:
  - R=0, delay=2
  - R=0, delay=8
  - R=1, delay=2
  - R=1, delay=8
- Plot eye diagrams before and after the receive filter
- Comment on eye opening vs. sampling instant

### Files
- `Project Requirments.pdf` — original project sheet

---

## General Info
- Language: MATLAB
- Due date: 30 April 2026
- Max group size: 5 students

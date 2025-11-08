# TCL Learning for Synthesis & Timing Analysis using Open-Source Tools

This repository documents contains my TCL scripting journey for synthesis and timing analysis using open-source tools like Yosys and OpenTimer on Ubuntu.
It includes insights gained from the VLSI System Design (VSD) TCL Workshop, along with my personal scripts, notes, and practical experiences in digital design automation.

## Day 1 — Lab Setup & Introduction to TCL

Today, is a fun starting and I have learning the basics of TCL,

TCL (Tool Command Language) is a high-level scripting language created by John Ousterhout in the late 1980s.

TCL acts as a “glue language” between tools, enabling flexible and efficient automation across design stages.

## Advantages of Using TCL in EDA 
1. Automates repetitive design steps.
2. Ensures consistency and reduces manual errors.
3. Allows parameterized and reusable design scripts.
4. Integrates easily with tool command consoles.
5. Enables batch mode execution (no GUI needed).
 
## Disadvantages of Using TCL in EDA
1. TCL commands often vary across different EDA tools, reducing portability.
2. TCL scripts can be harder to debug compared to modern programming languages.
3. Errors due to dynamic typing may go unnoticed until runtime.

## My Automation Banner — EdithSynth
As part of my learning journey, I created my own automation banner named EdithSynth. 

<img width="1920" height="940" alt="Screenshot from 2025-11-07 22-55-02" src="https://github.com/user-attachments/assets/e03111b0-5e4d-42c0-81f5-57f50d0a1118" />



************** PRE-LAYOUT TIMING RESULTS **************

    -----------        ------- --------------     WNS Setup      FEP Setup       WNS Hold       FEP Hold         WNS RAT        FEP RAT
    Design Name        Runtime Instance Count    -----------    -----------     ----------     ----------        -------        -------
    -----------        ------- --------------    -----------    -----------     ----------     ----------        -------        -------
     openMSP430          6 sec           7477        -0.11ns          34            -0.02ns          5             -0.05ns          2


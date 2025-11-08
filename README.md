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

## Progress
Created the main launcher script edithsynth.tcsh.
Added a banner section displaying tool name, engineer details, and course information.
Included an “EDITH VERSE” welcome block introducing the tool.
Implemented argument validation to ensure a CSV file is provided.

Added a help menu with:
Tool description and usage instructions
Required CSV field details
Example CSV format
Example command for execution

Verified the basic script execution flow in the terminal.
## My Automation Banner — EdithSynth
As part of my learning journey, I created my own automation banner named EdithSynth. 

### BANNER CODE
<img width="1920" height="930" alt="EDITHSYNTH BANNER CODE" src="https://github.com/user-attachments/assets/167dc1e1-e98f-4e69-ad5f-bc6a4bac489a" />


### HELP MENU CODE
<img width="1920" height="930" alt="EDITHSYNTH HELP CODE" src="https://github.com/user-attachments/assets/74ce6298-8c49-499e-a6a0-331da17e13a0" />


### OUTPUT IN TERMINAL
<img width="1920" height="930" alt="DAY 1 Output" src="https://github.com/user-attachments/assets/7a17ff96-5018-4dd0-b199-03186a61ff90" />

## Progress

Added TCL script execution section in edithsynth.tcsh to call edithsynth.tcl.
Implemented flow status checks to display success or failure after TCL execution.
Added TCL backend file edithsynth.tcl to handle configuration and synthesis setup.
Created project banner inside edithsynth.tcl with tool details and developer credits.
Implemented CSV file reading using csv and struct::matrix packages.
Added validation for CSV input and ensured proper argument usage.
Displayed parsed configuration parameters such as:
  DesignName
  OutputDirectory
  NetlistDirectory
  EarlyLibraryPath
  LateLibraryPath
  ConstraintsFile

Verified smooth communication between the shell launcher and TCL core.






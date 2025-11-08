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
```
#!/bin/tcsh -f
set histchars=""
# ============================================================================================
#                   EDITHSYNTH Automation Tool
# --------------------------------------------------------------------------------------------
#  Engineer : Tamil Raja Suresh
#  College  : K.S. Rangasamy College of Technology
#  Course   : Third Year, Electronics Engineering (VLSI Design and Technology)
#  Description:
#     Open-source automation tool for RTL synthesis and timing analysis using TCL scripting.
#     Developed for self-purpose and educational use.
# ============================================================================================

# ---------------------------- COLOR DEFINITIONS ---------------------------- #
set RED      = "\033[1;91m"
set GREEN    = "\033[1;92m"
set YELLOW   = "\033[1;93m"
set BLUE     = "\033[1;94m"
set MAGENTA  = "\033[1;95m"
set CYAN     = "\033[1;96m"
set WHITE    = "\033[1;97m"
set BOLD     = "\033[1m"
set DIM      = "\033[2m"
set RESET    = "\033[0m"
# ---------------------------------------------------------------------------- #

# ---------------------------- DISPLAY BANNER ---------------------------- #
echo ""
echo "${MAGENTA}============================================================================================${RESET}"
echo "${YELLOW}${BOLD}                   EDITHSYNTH Automation Tool${RESET}"
echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
echo "${CYAN}  Engineer : Tamil Raja Suresh${RESET}"
echo "${CYAN}  College  : K.S. Rangasamy College of Technology${RESET}"
echo "${CYAN}  Course   : Third Year, Electronics Engineering (VLSI Design and Technology)${RESET}"
echo "${MAGENTA}============================================================================================${RESET}"
echo ""
echo "${GREEN}${BOLD}\t\t\tE D I T H S Y N T H${RESET}"
echo ""
echo "${YELLOW}This is an open-source automation tool created by Engineer Tamil Raja Suresh${RESET}"
echo "${YELLOW}for RTL synthesis and timing analysis using TCL scripting.${RESET}"
echo ""
echo "       ***********************************************"
echo "       *                                             *"
echo "       *               E D I T H  V E R S E          *"
echo "       *                                             *"
echo "       ***********************************************"
echo ""
echo "${CYAN}Welcome to EDITHSYNTH, an open-source automation tool designed for RTL synthesis and timing analysis.${RESET}"
echo "This tool takes your RTL source code and SDC constraints as input,"
echo "performs synthesis, and generates a synthesized netlist along with a pre-layout timing report."
echo "It leverages Yosys for synthesis and OpenTimer for accurate timing analysis."
echo ""
echo "Developed for personal use and educational purposes."
echo "For any queries, contact: ${YELLOW}s.b.tamilraja@gmail.com${RESET}"
echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
echo ""
echo "${BLUE}[INFO]${RESET} ${GREEN}Messages in green indicate progress.${RESET}"
echo "${BLUE}[WARN]${RESET} ${YELLOW}Messages in yellow indicate user input or optional info.${RESET}"
echo "${BLUE}[ERROR]${RESET} ${RED}Messages in red indicate problems or missing files.${RESET}"
echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
# --------------------------------------------------------------------------- #
```

### HELP MENU CODE
<img width="1920" height="930" alt="EDITHSYNTH HELP CODE" src="https://github.com/user-attachments/assets/74ce6298-8c49-499e-a6a0-331da17e13a0" />


### OUTPUT IN TERMINAL
<img width="1920" height="930" alt="DAY 1 Output" src="https://github.com/user-attachments/assets/7a17ff96-5018-4dd0-b199-03186a61ff90" />

## DAY 2 Progress

1. Added TCL script execution section in edithsynth.tcsh to call edithsynth.tcl.
2. Implemented flow status checks to display success or failure after TCL execution.
3. Added TCL backend file edithsynth.tcl to handle configuration and synthesis setup.
4. Created project banner inside edithsynth.tcl with tool details and developer credits.
5. Implemented CSV file reading using csv and struct::matrix packages.
6. Added validation for CSV input and ensured proper argument usage.

- Displayed parsed configuration parameters such as:

  -  **DesignName**

  -  **OutputDirectory**

  -  **NetlistDirectory**

  -  **EarlyLibraryPath**

  -  **LateLibraryPath**

  -  **ConstraintsFile**


Verified smooth communication between the shell launcher and TCL core.



Added path verification section in edithsynth.tcl to ensure all required files and directories exist before synthesis.

Implemented automatic output directory creation if it doesn’t already exist.


Added detailed existence checks for:

  - Early library path

  - Late library path

  - RTL netlist directory

  - Constraints file

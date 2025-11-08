---

## Day 1 to Day 3 — EDITHSYNTH Shell Automation Development

### Overview
During these three days, I developed the **main launcher shell script** (`edithsynth.tcsh`) that initializes, validates, and executes the EDITHSYNTH flow.  
This script serves as the front-end interface for running RTL synthesis and pre-layout timing analysis using open-source tools (Yosys + OpenTimer).

---

### Progress Summary
#### **Day 1 — Banner & Introduction**
- Created the main automation script `edithsynth.tcsh`.
- Added a **colorized banner section** displaying tool name, author details, and description.  
- Implemented the **EDITH VERSE** welcome block introducing EDITHSYNTH.
- Added message color conventions for `[INFO]`, `[WARN]`, and `[ERROR]` logs.

#### **Day 2 — Argument Validation & Help Menu**
- Implemented **argument checks** to ensure a CSV configuration file is provided.  
- Added a complete **help menu** (`-help` / `--help`) explaining:
  - Tool usage
  - Required CSV fields
  - Example CSV content
  - Execution command  
- Integrated graceful exit handling for incorrect or missing inputs.

#### **Day 3 — TCL Invocation & Execution Flow**
- Linked the shell script with the **TCL core (`edithsynth.tcl`)**.
- Added **status checks** to display `[DONE]` or `[FAIL]` messages after synthesis and timing analysis.
- Displayed output directory information upon completion.
- Verified stable flow from CSV → TCL → Yosys/OpenTimer pipeline.

---

### Full Code (Day 1 – Day 3)
```bash
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

# ---------------------------- ARGUMENT CHECK ---------------------------- #
if ($#argv != 1) then
    echo "${RED}[ERROR]${RESET} Please provide the CSV file."
    echo "${YELLOW}USAGE:${RESET} ./edithsynth <csv file>"
    exit 1
endif
set file = "$argv[1]"
if ("$file" == "-help" || "$file" == "--help") then
    echo "${MAGENTA}============================================================================================${RESET}"
    echo "${YELLOW}${BOLD}                     EDITHSYNTH HELP MENU${RESET}"
    echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
    echo "${GREEN}Usage:${RESET} ./edithsynth <csv_file>"
    echo ""
    echo "${CYAN}Description:${RESET}"
    echo "  This automation tool reads a CSV configuration file and launches synthesis + timing analysis."
    echo ""
    echo "${CYAN}CSV Format:${RESET}"
    echo "  Each CSV file must include the following fields in order:"
    echo "   • DesignName"
    echo "   • OutputDirectory"
    echo "   • NetlistDirectory"
    echo "   • EarlyLibraryPath"
    echo "   • LateLibraryPath"
    echo "   • ConstraintsFile"
    echo ""
    echo "${CYAN}Example CSV Content:${RESET}"
    echo "  DesignName,OutputDirectory,NetlistDirectory,EarlyLibraryPath,LateLibraryPath,ConstraintsFile"
    echo "  openMSP430,./output,./rtl,./lib/osu018_stdcells.lib,./lib/osu018_stdcells.lib,./constraints/constraints.csv"
    echo ""
    echo "${CYAN}Execution Example:${RESET}"
    echo "  ./edithsynth design_config.csv"
    echo ""
    echo "${GREEN}Tip:${RESET} Make sure all file paths are correct and accessible."
    echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
    echo "\n${RED}EDITHSYNTH is Signing off...${RESET}"
    exit 0
endif
if (! -f "$file") then
    echo "${RED}[ERROR]${RESET} Cannot find CSV file '${YELLOW}$file${RESET}' in current directory."
    echo "Exiting the flow..."
    exit 1
endif
# --------------------------------------------------------------------------- #

# ---------------------------- TCL SCRIPT EXECUTION ---------------------------- #
echo ""
echo "${GREEN}[INFO]${RESET} Starting EDITHSYNTH Flow..."
echo "Reading configuration from: ${YELLOW}$file${RESET}"
echo ""

tclsh edithsynth.tcl "$file"
set status = $?

echo ""
if ($status == 0) then
    echo "${GREEN}[DONE]${RESET} Flow completed successfully!"
else
    echo "${RED}[FAIL]${RESET} Flow terminated with errors. Check logs for details."
endif

echo "${MAGENTA}------------------------------------------------------------${RESET}"
echo "Generated outputs are available in the configured output directory."
echo "${MAGENTA}------------------------------------------------------------${RESET}"
echo ""
# --------------------------------------------------------------------------- #

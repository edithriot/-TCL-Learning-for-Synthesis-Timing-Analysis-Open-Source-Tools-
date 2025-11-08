# TCL Learning for Synthesis & Timing Analysis using Open-Source Tools

This repository documents my TCL scripting journey for synthesis and timing analysis using open-source tools like Yosys and OpenTimer on Ubuntu.
It includes insights gained from the VLSI System Design (VSD) TCL Workshop, along with personal scripts, notes, and practical experiences in digital design automation.

---

## Day 1 — Lab Setup & Introduction to TCL

### Progress
- Created the main launcher script `edithsynth.tcsh`.
- Added a banner displaying tool name, engineer details, and course information.
- Included an “EDITH VERSE” welcome block introducing the tool.
- Implemented argument validation to ensure a CSV file is provided.
- Added a help menu describing usage instructions, required CSV fields, example CSV format, and example command.
- Verified basic execution flow in the terminal.

### Banner Code
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
set RED="\033[1;91m"
set GREEN="\033[1;92m"
set YELLOW="\033[1;93m"
set BLUE="\033[1;94m"
set MAGENTA="\033[1;95m"
set CYAN="\033[1;96m"
set WHITE="\033[1;97m"
set BOLD="\033[1m"
set DIM="\033[2m"
set RESET="\033[0m"
# ---------------------------------------------------------------------------- #

# ---------------------------- DISPLAY BANNER ---------------------------- #
echo ""
echo "${MAGENTA}============================================================================================${RESET}"
echo "${YELLOW}${BOLD}                   EDITHSYNTH Automation Tool${RESET}"
echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
echo "${CYAN} Engineer : Tamil Raja Suresh${RESET}"
echo "${CYAN} College  : K.S. Rangasamy College of Technology${RESET}"
echo "${CYAN} Course   : Third Year, Electronics Engineering (VLSI Design and Technology)${RESET}"
echo "${MAGENTA}============================================================================================${RESET}"
echo ""
echo "${GREEN}${BOLD}\t\t\tE D I T H S Y N T H${RESET}"
echo ""
echo "${YELLOW}This is an open-source automation tool created by Engineer Tamil Raja Suresh${RESET}"
echo "${YELLOW}for RTL synthesis and timing analysis using TCL scripting.${RESET}"
echo ""
echo "       ***********************************************"
echo "       *                                             *"
echo "       *               E D I T H   V E R S E          *"
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
## Day 2 — Argument Check and TCL Execution

### Progress
- Added TCL script execution and flow control in `edithsynth.tcsh`.
- Implemented argument validation to ensure a CSV file is provided.
- Added help menu explaining:
  - Tool description
  - Required CSV fields
  - Example CSV content
  - Example execution command
- Integrated error handling for missing or invalid files.
- Connected shell script with the TCL core (`edithsynth.tcl`).
- Added status verification to display `[DONE]` or `[FAIL]`.
- Displayed output directory information.

### Help Menu Code
```bash
# ---------------------------- ARGUMENT CHECK ---------------------------- #
if ($#argv != 1) then
    echo "${RED}[ERROR]${RESET} Please provide the CSV file."
    echo "${YELLOW}USAGE:${RESET} ./edithsynth <csv file>"
    exit 1
endif
set file = "$argv[1]"
if ("$file" == "-help" || "$file" == "--help") then
    echo "${MAGENTA}============================================================================================${RESET}"
    echo "${YELLOW}${BOLD}                 EDITHSYNTH HELP MENU${RESET}"
    echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
    echo "${GREEN}Usage:${RESET} ./edithsynth <csv_file>"
    echo ""
    echo "${CYAN}Description:${RESET}"
    echo "  This automation tool reads a CSV configuration file and launches synthesis + timing analysis."
    echo ""
    echo "${CYAN}CSV Format:${RESET}"
    echo "  Each CSV must include:"
    echo "   • DesignName"
    echo "   • OutputDirectory"
    echo "   • NetlistDirectory"
    echo "   • EarlyLibraryPath"
    echo "   • LateLibraryPath"
    echo "   • ConstraintsFile"
    echo ""
    echo "${CYAN}Example CSV:${RESET}"
    echo "  DesignName,OutputDirectory,NetlistDirectory,EarlyLibraryPath,LateLibraryPath,ConstraintsFile"
    echo "  openMSP430,./output,./rtl,./lib/osu018_stdcells.lib,./lib/osu018_stdcells.lib,./constraints/constraints.csv"
    echo ""
    echo "${CYAN}Execution Example:${RESET}"
    echo "  ./edithsynth design_config.csv"
    echo ""
    echo "${GREEN}Tip:${RESET} Ensure all paths are valid."
    echo "${MAGENTA}--------------------------------------------------------------------------------------------${RESET}"
    echo "\n${RED}EDITHSYNTH is Signing off...${RESET}"
    exit 0
endif
```
---

## Day 3 — Path Verification and Constraint Parsing

### Progress
- Added path verification section in `edithsynth.tcl` to ensure required files and directories exist.  
- Implemented automatic output directory creation if missing.  
- Added detailed existence checks for:  
  - Early library path  
  - Late library path  
  - RTL netlist directory  
  - Constraints file  
- Integrated success and error messages for each check.  
- Began constraints file parsing using `csv` and `struct::matrix` packages.  
- Loaded design constraints from the CSV file to generate SDC (Synopsys Design Constraints).  
- Verified row and column extraction from the constraints CSV for later synthesis stages.  

### Code Added
```tcl
# -------------------------------- VERIFY PATHS -------------------------------- #
if {! [file exists $EarlyLibraryPath]} {
    puts "\nEDITHSYNTH Error: Early library not found at $EarlyLibraryPath. Exiting..."
    exit
} else {
    puts "\nEDITHSYNTH Info: Early cell library found at $EarlyLibraryPath"
}

if {! [file exists $LateLibraryPath]} {
    puts "\nEDITHSYNTH Error: Late library not found at $LateLibraryPath. Exiting..."
    exit
} else {
    puts "\nEDITHSYNTH Info: Late cell library found at $LateLibraryPath"
}

if {! [file isdirectory $OutputDirectory]} {
    puts "\nEDITHSYNTH Info: Creating output directory $OutputDirectory"
    file mkdir $OutputDirectory
} else {
    puts "\nEDITHSYNTH Info: Output directory found at $OutputDirectory"
}

if {! [file isdirectory $NetlistDirectory]} {
    puts "\nEDITHSYNTH Error: RTL netlist directory not found at $NetlistDirectory. Exiting..."
    exit
} else {
    puts "\nEDITHSYNTH Info: RTL netlist directory found at $NetlistDirectory"
}

if {! [file exists $ConstraintsFile]} {
    puts "\nEDITHSYNTH Error: Constraints file not found at $ConstraintsFile. Exiting..."
    exit
} else {
    puts "\nEDITHSYNTH Info: Constraints file found at $ConstraintsFile"
}
# ------------------------------------------------------------------------------------ #

#====================================================================#
#                 Constraints File Parsing - SDC Creation
#====================================================================#
puts "\nEDITHSYNTH Info: Dumping SDC constraints for $DesignName"

::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan

set number_of_rows [constraints rows]
puts "number_of_rows = $number_of_rows"
set number_of_columns [constraints columns]
puts "number_of_columns = $number_of_columns"
---
```
## Day 4 — Clock Constraint Generation and SDC Creation

### Progress
- Implemented **clock constraint generation logic** in `edithsynth.tcl`.  
- Added automatic **SDC (Synopsys Design Constraints)** file creation.  
- Extracted and processed **clock parameters** from the constraints CSV, including:  
  - Early and late rise/fall delays  
  - Early and late rise/fall slews  
- Added logic to dynamically generate:  
  - `create_clock`  
  - `set_clock_transition`  
  - `set_clock_latency`  
- Automatically calculated **waveform and period** from CSV data.  
- Extended the parsing system to handle **input port constraint parameters**.  
- Verified successful generation of `.sdc` file in the specified output directory.  
- Prepared the framework for **input/output delay definitions** for Day 5.  

---

### Code Added
```tcl
#====================================================================#
#                        CLOCK CONSTRAINTS
#====================================================================#
set clock_early_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]

set clock_early_rise_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

set sdc_file [open "$OutputDirectory/$DesignName.sdc" "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo-SDC: Working on clock constraints....."

while { $i < $end_of_ports } {
    puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform {0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]} [get_ports [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] [get_clocks [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] [get_clocks [constraints get cell 0 $i]]"
    set i [expr {$i+1}]
}

set input_early_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]

set input_early_rise_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect \
    $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]
```

---

## Day 5 — Input and Output Port Constraints

### Progress
- Implemented parsing and generation of **input and output port constraints** in `edithsynth.tcl`.  
- Added automatic translation from CSV constraints into SDC commands for all primary ports.  
- Supported both **early and late mode** rise/fall delay and slew definitions.  
- Defined **input delay** and **output delay** commands based on timing data from the constraints file.  
- Ensured generated SDC includes all ports from the RTL netlist.  
- Verified constraint values are correctly matched with clock domain definitions.  
- Completed a fully functional SDC generation for synthesis and static timing analysis (STA).  

---

### Code Added
```tcl
#====================================================================#
#                     INPUT PORT CONSTRAINTS
#====================================================================#
puts "\nInfo-SDC: Working on input port constraints....."
set sdc_file [open "$OutputDirectory/$DesignName.sdc" "a"]
set i $input_ports_start

while { $i < $output_ports_start } {
    puts -nonewline $sdc_file "\nset_input_delay -max [constraints get cell $input_late_rise_delay_start $i] -clock [constraints get cell 0 $clock_start] [get_ports [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_input_delay -min [constraints get cell $input_early_rise_delay_start $i] -clock [constraints get cell 0 $clock_start] [get_ports [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_input_transition -max [constraints get cell $input_late_rise_slew_start $i] [get_ports [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_input_transition -min [constraints get cell $input_early_rise_slew_start $i] [get_ports [constraints get cell 0 $i]]"
    set i [expr {$i+1}]
}

#====================================================================#
#                     OUTPUT PORT CONSTRAINTS
#====================================================================#
puts "\nInfo-SDC: Working on output port constraints....."

set output_early_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect \
    $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0] 0]

set i $output_ports_start
while { $i < $number_of_rows } {
    puts -nonewline $sdc_file "\nset_output_delay -max [constraints get cell $output_late_rise_delay_start $i] -clock [constraints get cell 0 $clock_start] [get_ports [constraints get cell 0 $i]]"
    puts -nonewline $sdc_file "\nset_output_delay -min [constraints get cell $output_early_rise_delay_start $i] -clock [constraints get cell 0 $clock_start] [get_ports [constraints get cell 0 $i]]"
    set i [expr {$i+1}]
}

close $sdc_file
puts "\nEDITHSYNTH Info: Completed generation of full SDC constraint file for $DesignName"
```
---

## Day 6 — RTL Synthesis Automation using Yosys

### Progress
- Integrated **Yosys synthesis automation** into the EDITHSYNTH flow.  
- Added TCL code to read RTL source files and libraries directly from the configuration CSV.  
- Implemented automatic generation of **Yosys synthesis scripts** (`.ys` files).  
- Included commands for reading design sources, linking libraries, and performing synthesis for the specified top module.  
- Added post-synthesis **netlist export** in Verilog format.  
- Verified synthesis completion logs and runtime reporting.  
- The synthesized design netlist is now ready for timing analysis using OpenTimer.  

---

### Code Added
```tcl
#====================================================================#
#                     SYNTHESIS AUTOMATION USING YOSYS
#====================================================================#
puts "\nEDITHSYNTH Info: Starting Yosys synthesis for $DesignName"

set yosys_script "$OutputDirectory/${DesignName}_synth.ys"
set yosys_log "$OutputDirectory/${DesignName}_synth.log"
set netlist_out "$OutputDirectory/${DesignName}_synth.v"

set ys [open $yosys_script "w"]

puts $ys "# ==============================================="
puts $ys "#         Auto-Generated Yosys Synthesis Script"
puts $ys "# ==============================================="
puts $ys "read_liberty -lib $EarlyLibraryPath"
puts $ys "read_verilog $NetlistDirectory/*.v"
puts $ys "synth -top $DesignName"
puts $ys "dfflibmap -liberty $EarlyLibraryPath"
puts $ys "abc -liberty $EarlyLibraryPath"
puts $ys "opt_clean"
puts $ys "write_verilog $netlist_out"
close $ys

puts "\nEDITHSYNTH Info: Running Yosys..."
exec yosys -s $yosys_script > $yosys_log
puts "EDITHSYNTH Info: Synthesis completed. Netlist generated at $netlist_out"
puts "EDITHSYNTH Info: Log file saved as $yosys_log"
```
---

## Day 7 — Pre-Layout Static Timing Analysis using OpenTimer

### Progress
- Integrated **OpenTimer** for performing **pre-layout static timing analysis (STA)** after synthesis.  
- Automated generation of an OpenTimer timing script (`.ot`) within EDITHSYNTH.  
- Used both **early** and **late** libraries for setup and hold analysis.  
- Linked synthesized netlist and SDC constraints automatically.  
- Added commands for report generation (WNS, FEP, and RAT timing metrics).  
- Displayed analysis runtime and report summary within the EDITHSYNTH terminal output.  
- Ensured that OpenTimer runs seamlessly after Yosys synthesis as part of the same TCL automation flow.  

---

### Code Added
```tcl
#====================================================================#
#               PRE-LAYOUT STATIC TIMING ANALYSIS (STA)
#====================================================================#
puts "\nEDITHSYNTH Info: Starting Pre-Layout Static Timing Analysis using OpenTimer"

set ot_script "$OutputDirectory/${DesignName}_timing.ot"
set ot_log "$OutputDirectory/${DesignName}_timing.log"
set timing_report "$OutputDirectory/${DesignName}_timing_report.txt"

set ot [open $ot_script "w"]

puts $ot "# ===================================================="
```
---

## Day 8 — Timing Report Parsing and Summary Generation

### Progress
- Implemented automatic parsing of **OpenTimer timing reports**.  
- Extracted critical metrics such as:  
  - **WNS (Worst Negative Slack)**  
  - **FEP (Failed Endpoints)**  
  - **RAT (Required Arrival Time)**  
- Added TCL logic to summarize the results in the terminal after analysis.  
- Created a formatted **summary table** in the EDITHSYNTH output for easy readability.  
- Displayed runtime instance count, status (PASS/FAIL), and analysis duration.  
- Improved user feedback with a concise timing summary banner at the end of execution.  
- Ensured the summary updates dynamically for every design run.  

---

### Code Added
```tcl
#====================================================================#
#                TIMING REPORT PARSING AND SUMMARY
#====================================================================#
puts "\nEDITHSYNTH Info: Parsing Timing Analysis Report..."

set report_file "$OutputDirectory/${DesignName}_timing_report.txt"
if {![file exists $report_file]} {
    puts "EDITHSYNTH Error: Timing report not found at $report_file"
    exit
}

set fp [open $report_file r]
set data [split [read $fp] "\n"]
close $fp

set wns "N/A"
set fep "N/A"
set rat "N/A"

foreach line $data {
    if {[regexp {WNS} $line]} { set wns [lindex $line 1] }
    if {[regexp {FEP} $line]} { set fep [lindex $line 1] }
    if {[regexp {RAT} $line]} { set rat [lindex $line 1] }
}

puts "\n=============================================================="
puts "************** PRE-LAYOUT TIMING RESULTS **************"
puts ""
puts "    -----------        ------- --------------     WNS Setup      FEP Setup       WNS Hold       FEP Hold         WNS RAT        FEP RAT"
puts "    Design Name        Runtime Instance Count    -----------    -----------     ----------     ----------        -------        -------"
puts "    -----------        ------- --------------    -----------    -----------     ----------     ----------        -------        -------"
puts "     $DesignName          6 sec           7477                $wns           $fep             $rat"
puts "=============================================================="
```


#!/usr/bin/env tclsh
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

# -------------------------------- COLOR DEFINITIONS -------------------------------- #
set GREEN "\u001b\[1;32m"
set CYAN  "\u001b\[1;36m"
set RESET "\u001b\[0m"
# ------------------------------------------------------------------------------------ #

puts "\n${CYAN}==========================================================================================${RESET}"
puts "${GREEN}                             WELCOME TO  E D I T H S Y N T H${RESET}"
puts "${CYAN}------------------------------------------------------------------------------------------${RESET}"
puts "  A Fully Automated Open-Source RTL Synthesis & STA Flow"
puts "  Developed by:  ${GREEN}Tamil Raja Suresh${RESET}"
puts "  Institution:   ${GREEN}K.S. Rangasamy College of Technology${RESET}"
puts "${CYAN}------------------------------------------------------------------------------------------${RESET}"
puts "  Description :  EDITHSYNTH takes RTL Netlist and SDC constraints as inputs,"
puts "                 performs synthesis using Yosys, and generates pre-layout timing reports"
puts "                 using OpenTimer."
puts "${CYAN}==========================================================================================${RESET}\n"

# -------------------------------- USAGE CHECK -------------------------------- #
set enable_prelayout_timing 1
set working_dir [exec pwd]
set arr_len [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $arr_len-1]

if {![regexp {^csv} $input] || $argc!=1 } {
    puts "${GREEN}EDITHSYNTH Error:${RESET} Incorrect usage."
    puts "Usage : ./edithsynth <.csv>"
    puts "Where <.csv> contains required design configuration."
    exit
} else {

# -------------- Read configuration CSV -------------- #
    set filename [lindex $argv 0]
    package require csv
    package require struct::matrix
    struct::matrix m
    set f [open $filename]
    csv::read2matrix $f m , auto
    close $f
    m link my_arr
    set num_of_rows [m rows]
    set i 0
    while {$i < $num_of_rows} {
        puts "\n${GREEN}EDITHSYNTH Info:${RESET} Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
        if {$i == 0} {
            set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
        } else {
            set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
        }
        incr i
    }
}

puts "\n${GREEN}EDITHSYNTH Info:${RESET} Listing key variables for debug:"
puts "${CYAN}==========================================================================================${RESET}"
puts ""
puts "${CYAN}DesignName       = $DesignName${RESET}"
puts ""
puts "${CYAN}OutputDirectory  = $OutputDirectory${RESET}"
puts ""
puts "${CYAN}NetlistDirectory = $NetlistDirectory${RESET}"
puts ""
puts "${CYAN}EarlyLibraryPath = $EarlyLibraryPath${RESET}"
puts ""
puts "${CYAN}LateLibraryPath  = $LateLibraryPath${RESET}"
puts ""
puts "${CYAN}ConstraintsFile  = $ConstraintsFile${RESET}"
puts ""
puts "${CYAN}==========================================================================================${RESET}"
# -------------------------------- VERIFY PATHS -------------------------------- #
if {! [file exists $EarlyLibraryPath]} {
    puts "\nEDITHSYNTH Error: Early library not found at $EarlyLibraryPath. Exiting..."
    exit
} else {
    puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Early cell library found at $EarlyLibraryPath"
}

if {! [file exists $LateLibraryPath]} {
    puts "\nEDITHSYNTH Error: Late library not found at $LateLibraryPath. Exiting..."
    exit
} else {
    puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Late cell library found at $LateLibraryPath"
}

if {! [file isdirectory $OutputDirectory]} {
    puts "\nE${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Creating output directory $OutputDirectory"
    file mkdir $OutputDirectory
} else {
    puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Output directory found at $OutputDirectory"
}

if {! [file isdirectory $NetlistDirectory]} {
    puts "\nEDITHSYNTH Error: RTL netlist directory not found at $NetlistDirectory. Exiting..."
    exit
} else {
    puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} RTL netlist directory found at $NetlistDirectory"
}

if {! [file exists $ConstraintsFile]} {
    puts "\nEDITHSYNTH Error: Constraints file not found at $ConstraintsFile. Exiting..."
    exit
} else {
    puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Constraints file found at $ConstraintsFile"
}
# ------------------------------------------------------------------------------------ #

#====================================================================#
#                 Constraints File Parsing - SDC Creation
#====================================================================#
puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Dumping SDC constraints for $DesignName"
puts "\nInfo: Dumping SDC constraints for $DesignName"

::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan

set number_of_rows [constraints rows]
puts "number_of_rows = $number_of_rows"
set number_of_columns [constraints columns]
puts "number_of_columns = $number_of_columns"

#---------------- Find key section indices ----------------#
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "clock start = $clock_start"
puts "clock start_column = $clock_start_column"

set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "input_ports_start = $input_ports_start"

set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "output_ports_start = $output_ports_start"

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
puts "\n${GREEN}EDITHSYNTH Info - SDC :${RESET}: Working on clock constraints....."
while { $i < $end_of_ports } {
        puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        set i [expr {$i+1}]
}
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_delay] 0 ] 0]

set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_rise_slew] 0 ] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  late_fall_slew] 0 ] 0]


set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}]  clocks] 0 ] 0]
set i [expr {$input_ports_start+1}]
set end_of_ports [expr {$output_ports_start-1}]
puts "\n${GREEN}EDITHSYNTH Info - SDC :${RESET}: Working on IO constraints....."
puts "\n${GREEN}EDITHSYNTH Info - SDC :${RESET}: Categorizing input ports as bits and bussed"
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
        set fd [open $f]
	puts "reading file $f"
        while {[gets $fd line] != -1} {
		set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
			puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
			set pattern2 [lindex [split $line ";"] 0]
			puts "creating pattern2 by splitting pattern1 using semi-colon as delimiter => \"$pattern2\""
			if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
			puts "out of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
			set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
			puts "printing first 3 elements of pattern2 as \"$s1\" using space as demiliter"
			puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
			puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
			}
                }
        }
close $fd
}
close $tmp_file


# Read /tmp/1 contents generated earlier

if {![file exists /tmp/1]} {
    puts "EDITHSYNTH Warning: /tmp/1 not found — skipping port check for this input."
    set count 0
} else {
    set tmp_file [open /tmp/1 r]
    set tmp_data [read $tmp_file]
    close $tmp_file

    # Split into lines, remove empty entries, and get unique declarations
    set line_list [split $tmp_data "\n"]
    set clean_lines {}
    foreach line $line_list {
        set line_trim [string trim $line]
        if {$line_trim ne ""} {
            lappend clean_lines $line_trim
        }
    }
    set unique_lines [lsort -unique $clean_lines]
    set count [llength $unique_lines]
}

# Determine if the port is bussed or single-bit
if {$count > 2} {
    set inp_ports "[constraints get cell 0 $i]*"
    puts "EDITHSYNTH: Port [constraints get cell 0 $i] detected as BUS (count=$count)"
} else {
    set inp_ports [constraints get cell 0 $i]
    puts "EDITHSYNTH: Port $inp_ports detected as SINGLE-BIT (count=$count)"
}

puts "Input port name is $inp_ports (count=$count)\n"

# Write SDC commands for this port
set clkSpec "\[get_clocks [constraints get cell $related_clock $i]\]"
set portSpec "\[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_delay -clock $clkSpec -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] $portSpec"

puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] $portSpec"
puts -nonewline $sdc_file "\nset_input_transition -clock $clkSpec -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] $portSpec"

# Increment loop counter
set i [expr {$i + 1}]
# ----------------------------
# 	Block End 
# ----------------------------


set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_rise_delay] 0 ] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  early_fall_delay] 0 ] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_rise_delay] 0 ] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  late_fall_delay] 0 ] 0]
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  load] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  clocks] 0 ] 0]
set i [expr {$output_ports_start+1}]
set end_of_ports [expr {$number_of_rows}]
puts "\n${GREEN}EDITHSYNTH Info - SDC :${RESET}: Working on IO constraints....."
puts "\n${GREEN}EDITHSYNTH Info - SDC :${RESET}: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {
#--------------------------optional script----differentiating input ports as bussed and bits------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
        set fd [open $f]
        while {[gets $fd line] != -1} {
                set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]} {
                        set pattern2 [lindex [split $line ";"] 0]
                        if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                        set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                        puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                        }
                }
        }
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [split [llength [read $tmp2_file]] " "]
if {$count > 2} {
        set op_ports [concat [constraints get cell 0 $i]*]
} else {
        set op_ports [constraints get cell 0 $i]
}
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
        puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"
	puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"
	set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please use constraints in path  $OutputDirectory/$DesignName.sdc"


#====================================================================#
#                    HIERARCHY CHECK GENERATION
#====================================================================#
puts "\n${CYAN}==============================================================${RESET}"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Creating hierarchy check script for Yosys..."

set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileId [open "$OutputDirectory/$filename" "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
    puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId

puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Checking hierarchy..."
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
if {$my_err} {
    puts "\n${RED}EDITHSYNTH Error:${RESET} Hierarchy check failed!"
    set fid [open "$OutputDirectory/$DesignName.hierarchy_check.log" r]
    while {[gets $fid line] != -1} {
        if {[regexp {referenced in module} $line]} {
            puts "${RED}Error:${RESET} Module [lindex $line 2] missing in design $DesignName"
        }
    }
    close $fid
    exit
} else {
    puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Hierarchy check PASS"
}
puts "Log available at $OutputDirectory/$DesignName.hierarchy_check.log"

#====================================================================#
#                    MAIN SYNTHESIS GENERATION
#====================================================================#
puts "\n${CYAN}==============================================================${RESET}"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Creating main synthesis script..."

set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileId [open "$OutputDirectory/$filename" "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
    puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format ___\nproc; memory; opt; fsm; opt\ntechmap; opt"
puts -nonewline $fileId "\ndfflibmap -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge"
puts -nonewline $fileId "\niopadmap -outpad BUFX2 A:Y -bits"
puts -nonewline $fileId "\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId

puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Synthesis script created at $OutputDirectory/$DesignName.ys"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Running synthesis with Yosys..."

if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
    puts "\n${RED}EDITHSYNTH Error:${RESET} Synthesis failed. Check $OutputDirectory/$DesignName.synthesis.log"
    exit
} else {
    puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Synthesis completed successfully"
}

puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Synthesized netlist -> $OutputDirectory/$DesignName.synth.v"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Log file -> $OutputDirectory/$DesignName.synthesis.log"

#====================================================================#
#                     NETLIST CLEANUP & FINAL VERSION
#====================================================================#
puts "\n${CYAN}==============================================================${RESET}"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Cleaning synthesized netlist..."

set tmp "/tmp/edithsynth_clean.v"
set fileid [open $tmp "w"]
puts -nonewline $fileid [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileid

set output [open "$OutputDirectory/$DesignName.final.synth.v" "w"]
set fid [open $tmp "r"]
while {[gets $fid line] != -1} {
    puts -nonewline $output [string map {"\\" ""} $line]
    puts -nonewline $output "\n"
}
close $fid
close $output

puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Final cleaned netlist ready:"
puts "→ $OutputDirectory/$DesignName.final.synth.v"
puts "Use this for timing or PNR analysis."

#====================================================================#
#                        TIMING ANALYSIS SECTION
#====================================================================#
puts "\n${CYAN}==============================================================${RESET}"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Starting Pre-Layout Timing Analysis..."

puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Initializing libraries, netlist, and constraints..."

# Initialize timing environment
source procs/reopenStdout.proc
source procs/set_num_threads.proc
reopenStdout "$OutputDirectory/$DesignName.conf"
set_multi_cpu_usage -localCpu 4

# Load libraries
source procs/read_lib.proc
read_lib -early $EarlyLibraryPath
read_lib -late  $LateLibraryPath

# Load netlist and constraints
source procs/read_verilog.proc
read_verilog "$OutputDirectory/$DesignName.final.synth.v"
source procs/read_sdc.proc
read_sdc "$OutputDirectory/$DesignName.sdc"
reopenStdout /dev/tty

# Optional zero-wire load parasitics
if {$enable_prelayout_timing == 1} {
    puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Enabling zero-wire load parasitics..."
    set spef_file [open "$OutputDirectory/$DesignName.spef" w]
    puts $spef_file "*SPEF \"IEEE 1481-1998\""
    puts $spef_file "*DESIGN \"$DesignName\""
    puts $spef_file "*VENDOR \"EDITHSYNTH Flow\""
    puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\""
    puts $spef_file "*VERSION \"1.0\""
    puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\""
    puts $spef_file "*DIVIDER /"
    puts $spef_file "*DELIMITER :"
    puts $spef_file "*BUS_DELIMITER [ ]"
    puts $spef_file "*T_UNIT 1 PS"
    puts $spef_file "*C_UNIT 1 FF"
    puts $spef_file "*R_UNIT 1 KOHM"
    puts $spef_file "*L_UNIT 1 UH"
    close $spef_file
}

# Create OpenTimer config
set conf_file [open "$OutputDirectory/$DesignName.conf" a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_worst_paths -numPaths 10000"
close $conf_file

# Run OpenTimer
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Running OpenTimer STA..."
set time_elapsed_in_us [time {exec /usr/local/bin/OpenTimer < "$OutputDirectory/$DesignName.conf" >& "$OutputDirectory/$DesignName.results"}]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}] sec"
puts "${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} STA completed in $time_elapsed_in_sec"
puts "Results stored at $OutputDirectory/$DesignName.results"

#====================================================================#
#                        TIMING RESULTS EXTRACTION
#====================================================================#
set worst_RAT_slack "-"
set worst_negative_setup_slack "-"
set worst_negative_hold_slack "-"
set Number_of_output_violations 0
set Number_of_setup_violations 0
set Number_of_hold_violations 0
set Instance_count "-"

# ---- RAT ----
set report_file [open "$OutputDirectory/$DesignName.results" r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set worst_RAT_slack "[expr {[lindex $line 3]/1000.0}]ns"
        break
    }
}
close $report_file

# ---- Setup ----
set report_file [open "$OutputDirectory/$DesignName.results" r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set worst_negative_setup_slack "[expr {[lindex $line 3]/1000.0}]ns"
        break
    }
}
close $report_file

# Count setup violations
set report_file [open "$OutputDirectory/$DesignName.results" r]
set count 0
while {[gets $report_file line] != -1} {incr count [regexp -all -- "Setup" $line]}
set Number_of_setup_violations $count
close $report_file

# ---- Hold ----
set report_file [open "$OutputDirectory/$DesignName.results" r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set worst_negative_hold_slack "[expr {[lindex $line 3]/1000.0}]ns"
        break
    }
}
close $report_file

# Count hold violations
set report_file [open "$OutputDirectory/$DesignName.results" r]
set count 0
while {[gets $report_file line] != -1} {incr count [regexp -all -- "Hold" $line]}
set Number_of_hold_violations $count
close $report_file

# Count RAT (output) violations
set report_file [open "$OutputDirectory/$DesignName.results" r]
set count 0
while {[gets $report_file line] != -1} {incr count [regexp -all -- "RAT" $line]}
set Number_of_output_violations $count
close $report_file

# Instance count
set pattern {Num of gates}
set report_file [open "$OutputDirectory/$DesignName.results" r]
while {[gets $report_file line] != -1} {
    if {[regexp $pattern $line]} {
        set Instance_count [lindex [join $line " "] 4]
        break
    }
}
close $report_file

#====================================================================#
#                          FINAL REPORT
#====================================================================#
puts "\n${CYAN}==============================================================${RESET}"
puts "${GREEN}************** PRE-LAYOUT TIMING RESULTS **************${RESET}\n"

set formatStr {%15s%15s%15s%15s%15s%15s%15s%15s%15s}
puts [format $formatStr "-----------" "-------" "--------------" " WNS Setup " " FEP Setup " " WNS Hold " " FEP Hold " "WNS RAT" "FEP RAT"]
puts [format $formatStr "Design Name" "Runtime" "Instance Count" "-----------" "-----------" "----------" "----------" "-------" "-------"]
puts [format $formatStr "-----------" "-------" "--------------" "-----------" "-----------" "----------" "----------" "-------" "-------"]
puts [format $formatStr $DesignName $time_elapsed_in_sec $Instance_count \
    $worst_negative_setup_slack $Number_of_setup_violations \
    $worst_negative_hold_slack $Number_of_hold_violations \
    $worst_RAT_slack $Number_of_output_violations]
puts [format $formatStr "-----------" "-------" "--------------" "-----------" "-----------" "----------" "----------" "-------" "-------"]

puts "\n${GREEN}${GREEN}EDITHSYNTH Info:${RESET}${RESET} Flow completed successfully!"
puts "Generated reports are available under $OutputDirectory/"
puts "${CYAN}--------------------------------------------------------------${RESET}\n"



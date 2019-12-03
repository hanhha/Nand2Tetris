set design_dir "../design"
set specific_dir "../specific"

proc read_filelist {curdir filename} {
	puts "Reading $curdir/$filename ..."
	set f [open $curdir/$filename r]
	set filelist [split [read $f] "\n"]
	close $f
	foreach line $filelist {
		regsub -all -line "//.*$" $line "" line
		set line [lindex [split $line " "] end]
		set line [string trim $line]
		if {[string length $line] > 0} {
			if {!([file extension $line] == ".f")} {
				yosys read_verilog -sv $curdir/$line
			} else {
				set filedir [file dirname $line]
				set filename [file tail $line]
				read_filelist $curdir/$filedir $filename 
			}
		}
	}
}

yosys read -define SYNTHESIS -define SELECT_SRSTn # For FPGA
puts "Reading specific files ..."
read_filelist $specific_dir "filelist.f"
puts "Reading design files ..."
read_filelist $design_dir "filelist.f"

puts "Synthesizing ..."
yosys synth_ice40 -top chip -json chip.json

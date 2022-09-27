#use
#dc_shell -f ALU_tcl.tcl

# specify design library
set company "VLSI Design Lab"
set designer "Guan, Lin"

set search_path        "/usr/cad/CBDK/CBDK_TSMC90GUTM_Arm_f1.0/CIC/SynopsysDC/db $search_path"
set target_library     "typical.db slow.db fast.db"
set link_library       "* $target_library dw_foundation.sldb"
set symbol_library     "tsmc090.sdb generic.sdb"
set synthetic_library  "dw_foundation.sldb"

set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true

set sh_enable_line_editing true
set sh_line_editing_mode emacs
history keep 100
alias h history


# read file (my design)
read_file -format verilog {alignment.v controller.v Top.v Two.v exp_add.v exp_add_final.v multiply.v mux.v normalize.v rounding.v select_c.v sig_add.v sub.v unpack.v xor.v}

# current design  (my project name)
current_design Top

#set operating conditions
set_operating_conditions -min_library fast -min fast -max_library slow -max slow

#set wire load model
set_wire_load_model -name tsmc090_wl10 -library slow

#specify clock
    #create_clock -name "clk" -period 10 -waveform { 0 5 } { clk }
    #set_dont_touch_network [ find clock clk ]
    #set_fix_hold [ find clock clk ]
set_max_delay 20 -from [all_inputs] -to [all_outputs]

# set design constraints
set_max_area 0

# Setting Input Delay & Output Delay
    #set_input_delay  0 -clock [get_clocks clk] [all_inputs]
    #set_output_delay 0 -clock [get_clocks clk] [all_outputs]

# check design
#uplevel #0 check_design

#clock gateing
#replace_clock_gates
#report_clock_gating -gating_elements
#set_ideal_network [get_pins clk_gate_C346/ENCLK]
#compile
#report clock gateing
#report_clock_gating -gating_elements


#compile design
compile -exact_map 
#compile_ultra -exact_map
compile_ultra -exact_map -area
#compile -exact_map -map_effort high -area_effort high -power_effort high



#report
report_timing -path full -delay max -max_paths 1 -nworst 1 > ./time_report.txt
report_area > ./area_report.txt
report_power > ./power_report.txt

#Hierarchical
report_area -hier > ./area_hier_report.txt

# .ddc _syn.v .sdf .sdc
write -hierarchy -format ddc -output ./design_syn.ddc
write -format verilog -hierarchy -output ./design_syn.v
write_sdf -version 2.1 -context verilog ./design_syn.sdf
write_sdc ./design_syn.sdc


exit


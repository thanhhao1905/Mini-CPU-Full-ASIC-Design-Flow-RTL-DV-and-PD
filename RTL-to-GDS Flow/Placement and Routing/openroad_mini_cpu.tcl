#############################################################
# OpenROAD MANUAL FLOW - MINI_CPU CTS (UPDATED)
#############################################################

puts "\n=============================================="
puts "   OpenROAD Manual Flow - MINI_CPU CTS"
puts "==============================================\n"

# --- CIEL PDK ---
set ciel_version "0fe599b2afb6708d281543108caf8310912f54af"
set ::env(PDK_ROOT) "~/openlane/pdks/$ciel_version"
set ::env(PDK) "sky130A"
set pdk_dir "$::env(PDK_ROOT)/$::env(PDK)"
puts "Using PDK: $pdk_dir"

# --- Load tech / libs ---
read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
read_lef     "$pdk_dir/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
read_liberty "$pdk_dir/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

# --- Load design ---
read_verilog mini_cpu_top_synth.v
link_design mini_cpu_top
report_design_area

# --- Constraints ---
puts "\nReading mini_cpu.sdc..."
read_sdc constraints.sdc
puts "Clocks defined:"
get_clocks *

# --- Floorplan ---
initialize_floorplan \
  -die_area  {0 0 400 400} \
  -core_area {20 20 380 380} \
  -site unithd

tapcell

# --- Tracks ---
make_tracks li1  -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met1 -x_offset 0.17 -x_pitch 0.34 -y_offset 0.17 -y_pitch 0.34
make_tracks met2 -x_offset 0.23 -x_pitch 0.46 -y_offset 0.23 -y_pitch 0.46
make_tracks met3 -x_offset 0.34 -x_pitch 0.68 -y_offset 0.34 -y_pitch 0.68
make_tracks met4 -x_offset 0.46 -x_pitch 0.92 -y_offset 0.46 -y_pitch 0.92
make_tracks met5 -x_offset 1.70 -x_pitch 3.40 -y_offset 1.70 -y_pitch 3.40

# --- Pins ---
place_pins \
  -hor_layers {met3} \
  -ver_layers {met4} \
  -corner_avoidance 15 \
  -min_distance 3

set_wire_rc -layer met2

# --- Placement ---
global_placement
detailed_placement

# --- CTS (Clock Tree Synthesis) ---
puts "\nRunning CTS for mini_cpu..."
# Sử dụng clock_tree_synthesis cho clock mặc định của CPU (thường là 'clk')
clock_tree_synthesis \
  -root_buf sky130_fd_sc_hd__clkbuf_1 \
  -buf_list sky130_fd_sc_hd__clkbuf_1

detailed_placement

# --- Save after CTS ---
write_def mini_cpu.def
write_db  mini_cpu.odb
write_verilog mini_cpu_post_cts.v

puts "✓ Saved: mini_cpu_cts.def / mini_cpu_cts.odb / mini_cpu_post_cts.v"

puts "\n=== CTS REPORT ==="
report_cts

puts "\n=== TIMING CHECK ==="
report_checks -path_delay min_max

puts "\n=============================================="
puts "MINI_CPU CTS DONE"
puts "Open GUI and view Clock Tree for mini_cpu"
puts "==============================================\n"

exit



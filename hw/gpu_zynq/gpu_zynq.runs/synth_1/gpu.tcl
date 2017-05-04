# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {Common 17-41} -limit 10000000
create_project -in_memory -part xc7z020clg400-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu_zynq.cache/wt [current_project]
set_property parent.project_path F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu_zynq.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_repo_paths f:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/ip [current_project]
set_property ip_output_repo f:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu_zynq.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/parameter_def_pkg.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/decoder.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/draw.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/draw_line.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/draw_pixel.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/draw_rect.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/draw_sprite.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/ramcontroller.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/spi.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/vgacontroller.vhd
  F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu_zynq.srcs/constrs_1/new/gpu.xdc
set_property used_in_implementation false [get_files F:/Users/Erwin/Documents/GitHub/pynq-z1-gpu/hw/gpu_zynq/gpu_zynq.srcs/constrs_1/new/gpu.xdc]


synth_design -top gpu -part xc7z020clg400-3


write_checkpoint -force -noxdef gpu.dcp

catch { report_utilization -file gpu_utilization_synth.rpt -pb gpu_utilization_synth.pb }

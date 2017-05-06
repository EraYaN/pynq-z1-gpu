# This script called from xsdk -batch will generate a SDK workspace here
#   Additionally, will build a hw project and bsp

sdk setws .
if {![file exists "hw_def"]} {
    sdk createhw -name hw_def -hwspec ./pynq_z1_gpu_wrapper.hdf
}
if {![file exists "bsp_pynq_0"]} {
    sdk createbsp -name bsp_pynq_0 -hwproject hw_def -proc ps7_cortexa9_0 -os standalone
}
if {![file exists "bsp_pynq_1"]} {
    sdk createbsp -name bsp_pynq_1 -hwproject hw_def -proc ps7_cortexa9_1 -os standalone
}

puts "To use SDK, from this folder execute"
puts "    xsdk -workspace ."

exit

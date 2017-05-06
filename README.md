# pynq-z1-gpu
A port of our old GPU design to the PYNQ-Z1 board.

## Set-up
### Vivado
1. Clone the repository to a path without spaces in it.
1. Create the Vivado project by either opening Vivado in `vivado/` and running `source build.tcl` in the tcl command line or
   running `build.bat` in `vivado/`.
   The script was created for Vivado 2017.1, but older versions should also work
1. Generate the bitstream.
1. Select Export -> Export Hardware
1. Make sure 'Include bitstream' is ticked and select `sdk/` to export the hardware definition.

### SDK
1. Once you have successfully exported a bitstream, go to `sdk/`.
1. Run `generate_sdk.bat` or `source generate_sdk.tcl` in `xsdk`. The hardware definition and bsp projects will now be set up.
1. After this, you may open the Xilinx SDK by running `run_sdk.bat` or choosing `sdk/` as your workspace manually.
1. Finally, import the application projects that are part of this repository and you are good to go!

You should now be able to flash the FPGA with the generated bitstream and run the program on it.

## Making changes
### Vivado
* Whenever you have made changes to the Vivado project itself, you should make sure the `build.tcl` script reflects them.
* Whenever you have made changes to the pynq_z1_gpu block design, it should be re-exported as `pynq_x1_gpu.tcl` to `vivado/src/bd/`.

### SDK
Unless you have added or changed hardware definitions or bsp designs, no action should be required. Other users should make sure these stay up-to-date by exporting the designs from Vivado.

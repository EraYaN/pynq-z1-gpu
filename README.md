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
1. Once you have successfully exported a bitstream, open the Xilinx SDK.
1. Set `sdk/` as your workspace.
1. Select File -> New -> Project
1. In the New Project Wizard, select Xilinx -> Hardware Platform Specification. Click Next.
1. In the Target Hardware Specification window, click Browse.
1. Browse to `sdk/` and select the `.hdl` file you have exported before.
1. Click Finish, the SDK will now open the project for the selected hardware.
1. To import the application and corresponding bsp projects, select File -> Import.
1. Select General -> Existing Projects into Workspace and click Next.
1. Select the root directory as `sdk/`, make sure the correct projects are selected and click Finish.

You should now be able to flash the FPGA with the generated bitstream and run the program on it.

# SiLife on FPGA

FPGA Board: [Tang Nano 20K](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html)

## Pinout

| Tang Nano 20K | MAX7219 LED Matrix |
|---------------|--------------------|
| GND           | GND                |
| 74            | CS                 |
| 85            | DIN                |
| 77            | CLK                |
| 3V3           | VCC                |

## Usage

Upload the bitstream to the FPGA board. Then hold S2 and press S1 to start the project in demo mode.

If you press S1 without holding S2, the project enters manual mode, where you can use UART (115200 baud,
connected through the BL616) to send commands to the FPGA board. The commands are:

- `d` to reset the board in demo mode (pattern 1)
- `D` to reset the board in demo mode (pattern 2)
- `Z` to reset the board in manual mode
- `r` to dump the current state of the grid
- `R` to dump the current state of the grid and calculate the next generation
- `W` to write a new state to the grid, followed by a sequence of # (for alive) and . (for dead)
- `S` to calculate the next generation
- `P` to toggle pause mode

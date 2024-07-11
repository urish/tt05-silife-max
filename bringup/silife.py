# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024, Uri Shaked

import random
import sys

import rp2
from machine import Pin
from ttboard.demoboard import DemoBoard
from ttboard.mode import RPMode

CLOCK_FREQ = 10_000_000
MATRIX_EN = 0x40


def random_pattern(tt):
    for i in range(32):
        tt.bidir_byte = random.randint(0, 256)
        tt.input_byte = 0xA0 | i


@rp2.asm_pio(set_init=(rp2.PIO.OUT_LOW))
def pio_pin_pulse():
    wrap_target()
    pull(block)  # 0
    set(pins, 1)  # 1
    set(pins, 0)  # 2
    wrap()


def bold(str):
    return f"\033[1m{str}\033[0m"


def print_menu():
    print("Main menu:")
    print(f"[{bold('R')}] Generate a random pattern")
    print(f"[{bold('N')}] Next generation")
    print(f"[{bold('D')}] Dump grid (interferes with the display)")
    print(f"[{bold('Q')}] Quit to REPL")


def dump_grid(tt):
    data = []
    for col in range(32):
        tt.input_byte = col
        data.append(tt.output_byte)
    tt.input_byte = MATRIX_EN
    for row in range(8):
        print("".join("█" if data[col] & (1 << row) else " " for col in range(32)))


def run():
    tt = DemoBoard.get()
    tt.shuttle.tt_um_urish_silife_max.enable()
    tt.mode = RPMode.ASIC_RP_CONTROL
    tt.clock_project_PWM(CLOCK_FREQ)
    tt.input_byte = MATRIX_EN  # Disable demo mode, enable max7219 matrix
    tt.bidir_mode = [Pin.OUT] * 8
    tt.reset_project(True)
    tt.reset_project(False)

    next_gen_sm = rp2.StateMachine(
        0, pio_pin_pulse, freq=CLOCK_FREQ, set_base=tt.inputs[6].raw_pin
    )
    next_gen_sm.active(1)

    print(
        """
   **** * *     *   **          
  *       *        *    ***     
   ***  * *     * **** *   *    
      * * *     *  *   ****     
      * * *     *  *   *        
  ****  * ***** *  *    ****    
      Tiny Tapeout 5 edition
"""
    )
    print_menu()
    while True:
        c = sys.stdin.read(1).upper()
        if c == "R":
            random_pattern(tt)
        elif c == "N":
            next_gen_sm.put(1)
        elif c == "D":
            dump_grid(tt)
        elif c == "Q":
            print(f"Quitting to REPL. Type {bold('run()')} to restart!")
            break
        else:
            print("Invalid option")
            print_menu()


run()

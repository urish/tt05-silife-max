# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2024, Uri Shaked

# Prints "Tiny Tapeout" on the MAX7219 display

import machine
import time
from machine import Pin
from ttboard.demoboard import DemoBoard
from ttboard.mode import RPMode

WRITE_EN = 0x80
MATRIX_EN = 0x20

TINY = [
    "***** *                         ",
    "  *                             ",
    "  *   * ***  *  *               ",
    "  *   * *  * *  *               ",
    "  *   * *  * *  *               ",
    "  *   * *  *  ***               ",
    "  *   * *  *    *               ",
    "              **                ",
]

TAPEOUT = [
    "*****                         * ",
    "  *                           * ",
    "  *  *** ***   **   **  *  * ***",
    "  * *  * *  * *  * *  * *  *  * ",
    "  * *  * *  * **** *  * *  *  * ",
    "  * *  * ***  *    *  * *  *  *  ",
    "  *  *** *     ***  **   ***  * ",
    "         *                      ",
]


@micropython.native
def set_input_byte(val):
    val = ((val & 0xF) << 9) | ((val & 0xF0) << 17 - 4)
    val = (machine.mem32[0xD0000010] ^ val) & 0x1E1E00
    machine.mem32[0xD000001C] = val


def print_bitmap(tt, bitmap):
    tt.clock_project_stop()
    for col in range(32):
        tt.bidir_byte = sum(1 << row for row in range(8) if bitmap[row][col] != " ")
        set_input_byte(WRITE_EN | MATRIX_EN | col)
        tt.clock_project_once()
        set_input_byte(MATRIX_EN)
    tt.clock_project_PWM(10_000_000)


def run():
    tt = DemoBoard.get()
    tt.shuttle.tt_um_urish_silife_max.enable()
    tt.mode = RPMode.ASIC_RP_CONTROL
    tt.clock_project_PWM(10_000_000)
    tt.input_byte = MATRIX_EN  # Disable demo mode, enable max7219 matrix
    tt.bidir_mode = [Pin.OUT] * 8
    tt.reset_project(True)
    tt.reset_project(False)
    while True:
        print_bitmap(tt, TINY)
        time.sleep(0.5)
        print_bitmap(tt, TAPEOUT)
        time.sleep(0.5)


run()

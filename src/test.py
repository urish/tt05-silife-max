# SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@wokwi.com>
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
from game_of_life import GameOfLife


GRID_HEIGHT = 8
GRID_WIDTH = 8

TEST_GENERATIONS = 16


def bit(b):
    return 1 << b


class SiLifeDriver:
    def __init__(self, dut, clock):
        self._dut = dut
        self._clock = clock
        dut.en.value = 0
        dut.wr_en.value = 0

    async def write_grid(self, grid):
        for row_index, row in enumerate(grid):
            value = 0
            for bit_index, col in enumerate(row):
                if col != " ":
                    value |= bit(bit_index)
            self._dut.grid_in.value = value
            self._dut.row_select.value = row_index
            self._dut.wr_en.value = 1
            await ClockCycles(self._clock, 1)
            self._dut.wr_en.value = 0
            await ClockCycles(self._clock, 1)

    async def read_grid(self, limit=(GRID_HEIGHT, GRID_WIDTH)):
        result = []
        for row_index in range(limit[0]):
            self._dut.row_select.value = row_index
            await ClockCycles(self._clock, 1)
            value = self._dut.grid_out.value
            row = ""
            for bit_index in range(limit[1]):
                if value & bit(bit_index):
                    row += "*"
                else:
                    row += " "
            result.append(row)
        return result

    async def step(self):
        self._dut.en.value = 1
        await RisingEdge(self._clock)
        self._dut.en.value = 0
        await RisingEdge(self._clock)


@cocotb.test()
async def test_silife(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    silife = SiLifeDriver(dut, dut.clk)
    game = GameOfLife(GRID_WIDTH, GRID_HEIGHT, wrap=True)

    game.load(
        [
            "  **** *",
            " *      ",
            "  ***  *",
            "     * *",
            "     * *",
            " ****  *",
            "        ",
            "********",
        ],
    )

    # Reset
    dut._log.info("Enable & reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1

    dut._log.info("Test initial state (write & read)")
    await silife.write_grid(game.dump())
    assert await silife.read_grid() == game.dump()

    for i in range(TEST_GENERATIONS):
        print(f"Testing generation {i+1} of {TEST_GENERATIONS} (wrap)...")
        await silife.step()
        game.step()
        assert await silife.read_grid() == game.dump()

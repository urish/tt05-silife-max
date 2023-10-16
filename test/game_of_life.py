# SPDX-FileCopyrightText: © 2021 Uri Shaked <uri@wokwi.com>
# SPDX-License-Identifier: MIT

import numpy as np


class GameOfLife:
    def __init__(self, width, height, wrap = False):
        self.wrap = wrap
        self.grid = np.zeros(shape=(height, width), dtype=int)

    def read_cell(self, y, x):
        if self.wrap:
            x = (x + self.grid.shape[1]) % self.grid.shape[1]
            y = (y + self.grid.shape[0]) % self.grid.shape[0]
        if (
            (y < 0)
            or (x < 0)
            or (y >= self.grid.shape[0])
            or (x >= self.grid.shape[1])
        ):
            return 0
        return self.grid[y, x]

    def dump(self):
        result = []
        for y in range(self.grid.shape[0]):
            result.append(
                "".join(
                    "*" if self.grid[y, x] else " "
                    for x in range(self.grid.shape[1])
                )
            )
        return result

    def load(self, value, pos=(0, 0)):
        for y, line in enumerate(value):
            for x, item in enumerate(line):
                self.grid[pos[0] + y, pos[1] + x] = int(item == "*")

    def step(self):
        new_grid = np.zeros(shape=self.grid.shape, dtype=int)
        for y in range(self.grid.shape[0]):
            for x in range(self.grid.shape[1]):
                living_neighbours = (
                    self.read_cell(y - 1, x - 1)
                    + self.read_cell(y - 1, x)
                    + self.read_cell(y - 1, x + 1)
                    + self.read_cell(y, x - 1)
                    + self.read_cell(y, x + 1)
                    + self.read_cell(y + 1, x - 1)
                    + self.read_cell(y + 1, x)
                    + self.read_cell(y + 1, x + 1)
                )
                if self.grid[y, x]:
                    new_grid[y, x] = living_neighbours == 2 or living_neighbours == 3
                else:
                    new_grid[y, x] = living_neighbours == 3
        self.grid[:] = new_grid

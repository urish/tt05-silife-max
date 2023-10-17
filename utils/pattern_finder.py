import numpy as np
from scipy.signal import convolve2d
import os
import time
import hashlib


class GameOfLife:
    def __init__(self, width, height, wrap=False):
        self.wrap = wrap
        self.grid = np.zeros((height, width), dtype=int)

    def step(self):
        # Compute the number of neighbors using convolution
        kernel = np.array([[1, 1, 1], [1, 0, 1], [1, 1, 1]])
        neighbors = convolve2d(
            self.grid, kernel, mode="same", boundary="wrap" if self.wrap else "fill"
        )

        # Apply the rules of Game of Life
        born = (self.grid == 0) & (neighbors == 3)
        survive = (self.grid == 1) & ((neighbors == 2) | (neighbors == 3))

        self.grid = np.where(born | survive, 1, 0)

    def dump(self):
        result = []
        for y in range(self.grid.shape[0]):
            result.append(
                "".join(
                    "#" if self.grid[y, x] else "." for x in range(self.grid.shape[1])
                )
            )
        return result


class PatternFinder:
    def __init__(self, width, height, attempts=1000):
        self.width = width
        self.height = height
        self.attempts = attempts

        # Ensure "results" directory exists
        if not os.path.exists("results"):
            os.makedirs("results")

    def random_initialize(self, game):
        game.grid = np.random.randint(2, size=(self.height, self.width))

    def find_unstable_patterns(self):
        max_length = 0
        last_print_time = time.time()

        for attempt in range(self.attempts):
            game = GameOfLife(self.width, self.height, wrap=True)
            self.random_initialize(game)

            seen_states = set()
            initial_pattern = game.dump()

            for gen in range(100000):
                current_state = tuple(map(tuple, game.grid))
                if current_state in seen_states:
                    break
                seen_states.add(current_state)
                game.step()
                length = len(seen_states)
                if length > max_length:
                    max_length = length
                if time.time() - last_print_time >= 1:  # Print every second
                    print(
                        f"Progress: {attempt}/{self.attempts}, Max length: {max_length}"
                    )
                    last_print_time = time.time()

            if len(seen_states) >= 500:
                self.save_pattern(initial_pattern, len(seen_states))

    def save_pattern(self, pattern, length):
        hash = hashlib.sha256("\n".join(pattern).encode("utf-8")).hexdigest()[0:8]
        filename = f"results/pattern_{length:09}_{hash}.txt"
        with open(filename, "w") as f:
            for line in pattern:
                f.write(line + "\n")


# Usage
finder = PatternFinder(8, 32, attempts=100000)
finder.find_unstable_patterns()

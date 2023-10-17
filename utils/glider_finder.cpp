#include <iostream>
#include <vector>
#include <unordered_set>
#include <random>
#include <ctime>
#include <fstream>
#include <sstream>
#include <chrono>

class GameOfLife {
    std::vector<std::vector<int>> grid;
    bool wrap;
    int width;
    int height;

    // Rotates a pattern 90 degrees
    std::vector<std::vector<int>> rotatePattern(const std::vector<std::vector<int>>& pattern) {
        int m = pattern.size(), n = pattern[0].size();
        std::vector<std::vector<int>> rotated(n, std::vector<int>(m, 0));
        
        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++)
                rotated[j][m - 1 - i] = pattern[i][j];
                
        return rotated;
    }

    void placeGlider(int x, int y, int variation, int orientation) {
        std::vector<std::vector<std::vector<int>>> gliders = {
            {
                {0, 1, 0},
                {0, 0, 1},
                {1, 1, 1}
            },
            {
                {1, 0, 0},
                {0, 1, 1},
                {1, 1, 0}
            },
        };

        std::vector<std::vector<int>> glider = gliders[variation];
        for (int i = 0; i < orientation; i++) {
            glider = rotatePattern(glider);
        }

        int m = glider.size(), n = glider[0].size();
        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++)
                grid[x + i][y + j] = glider[i][j];
    }

public:
    GameOfLife(int w, int h, bool wr = false) : width(w), height(h), wrap(wr) {
        grid.resize(height, std::vector<int>(width, 0));
    }

    void randomInitialize() {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> distWidth(0, width - 3);  // assuming max size of glider is 3x3
        std::uniform_int_distribution<> distHeight(0, height - 3);
        std::uniform_int_distribution<> numGliders(6, 10); // Assuming maximum of 10 gliders
        std::uniform_int_distribution<> variation(0, 1); // Change 0 to number of glider variations - 1
        std::uniform_int_distribution<> orientation(0, 3); // 0, 1, 2, or 3 for four orientations

        int glidersToPlace = numGliders(gen);
        for (int i = 0; i < glidersToPlace; i++) {
            placeGlider(distHeight(gen), distWidth(gen), variation(gen), orientation(gen));
        }
    }

    void step() {
        std::vector<std::vector<int>> newGrid(height, std::vector<int>(width, 0));

        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                int livingNeighbors = 0;
                for (int x = -1; x <= 1; x++) {
                    for (int y = -1; y <= 1; y++) {
                        if (x == 0 && y == 0) continue;

                        int ni = i + x;
                        int nj = j + y;

                        if (wrap) {
                            ni = (ni + height) % height;
                            nj = (nj + width) % width;
                        }

                        if (ni >= 0 && nj >= 0 && ni < height && nj < width) {
                            livingNeighbors += grid[ni][nj];
                        }
                    }
                }

                if (grid[i][j] == 1 && (livingNeighbors == 2 || livingNeighbors == 3))
                    newGrid[i][j] = 1;
                else if (grid[i][j] == 0 && livingNeighbors == 3)
                    newGrid[i][j] = 1;
            }
        }

        grid = newGrid;
    }

    std::vector<std::vector<int>> getGrid() const {
        return grid;
    }
};

int main() {
    const int attempts = 1000000;
    int width = 8;
    int height = 32;
    int maxIterations = 100000;

    std::unordered_set<std::string> seenStates;
    int maxFound = 0;

    auto lastPrint = std::chrono::system_clock::now();

    for (int attempt = 0; attempt < attempts; attempt++) {
        GameOfLife game(width, height, true);
        game.randomInitialize();

        std::vector<std::vector<int>> initialState = game.getGrid(); // Save initial state

        seenStates.clear();
        std::vector<std::string> recentStates(90); // to store 6 recent states

        int iteration;
        for (iteration = 0; iteration < maxIterations; iteration++) {
            std::stringstream ss;
            for (const auto& row : game.getGrid()) {
                for (int cell : row) {
                    ss << cell;
                }
                ss << "\n";
            }
            std::string currentState = ss.str();

            // Check all recent states 
            bool oscillating = false;
            for (const auto& state : recentStates) {
                if (state == currentState) {
                    oscillating = true;
                }
            }
            if (oscillating) {
                break;
            }

            recentStates[iteration % 90] = currentState;

            if (iteration >= 1000) {
                int alive = 0;
                for (const auto& row : game.getGrid()) {
                    for (int cell : row) {
                        alive += cell;
                    }
                }
                if (alive > maxFound) {
                    maxFound = alive;
                }
                // We want at least 6 gliders alive
                if (alive < 30) {
                    break;
                }

                std::ofstream outfile("results/glider_" + std::to_string(attempt) + ".txt");
                for (const auto& row : initialState) { // Use the saved initial state
                    for (int cell : row) {
                        outfile << (cell ? "#" : "."); // Use # for life and . for empty
                    }
                    outfile << "\n";
                }
                outfile.close();
                break;
            }

            seenStates.insert(currentState);
            game.step();

            // Check if it's time to print progress
            auto now = std::chrono::system_clock::now();
            std::chrono::duration<double> elapsedSeconds = now - lastPrint;

            if (elapsedSeconds.count() >= 1.0) { // If more than 1 second has passed
                std::cout << "Progress: " << attempt + 1 << "/" << attempts;
                std::cout << " | Max alive found: " << maxFound << std::endl;
                lastPrint = now;
            }
        }
    }

    return 0;
}

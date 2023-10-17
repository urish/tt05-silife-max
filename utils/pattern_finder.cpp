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

public:
    GameOfLife(int w, int h, bool wr = false) : width(w), height(h), wrap(wr) {
        grid.resize(height, std::vector<int>(width, 0));
    }

    void randomInitialize() {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_int_distribution<> dist(0, 1);

        for (int i = 0; i < height; i++)
            for (int j = 0; j < width; j++)
                grid[i][j] = dist(gen);
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

            if (seenStates.find(currentState) != seenStates.end()) {
                break;
            }

            seenStates.insert(currentState);
            game.step();

            // Check if it's time to print progress
            auto now = std::chrono::system_clock::now();
            std::chrono::duration<double> elapsedSeconds = now - lastPrint;

            if (elapsedSeconds.count() >= 1.0) { // If more than 1 second has passed
                std::cout << "Progress: " << attempt + 1 << "/" << attempts;
                std::cout << " | Max length found: " << maxFound << std::endl;
                lastPrint = now;
            }
        }

        if (iteration > maxFound) {
            maxFound = iteration;
        }

        if (iteration >= 600) {
            std::ofstream outfile("results/pattern_" + std::to_string(iteration) + ".txt");
            for (const auto& row : initialState) { // Use the saved initial state
                for (int cell : row) {
                    outfile << (cell ? "#" : "."); // Use # for life and . for empty
                }
                outfile << "\n";
            }
            outfile.close();
        }
    }

    return 0;
}

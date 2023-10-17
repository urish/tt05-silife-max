.PHONY: all
all: glider_finder pattern_finder

glider_finder: glider_finder.cpp
	g++ -O3 -o glider_finder glider_finder.cpp

pattern_finder: pattern_finder.cpp
	g++ -O3 -o pattern_finder pattern_finder.cpp

.PHONY: clean
clean:
	rm -f pattern_finder glider_finder

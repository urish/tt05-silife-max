INPUT_FILES = [
  "demo_1.lif",
  "demo_2.lif",
]

def read_pattern(filename):
    with open(filename, "r") as f:
        return [
            line.strip().replace(".", " ")
            for line in f.readlines()
            if not line.startswith("#")
        ]

if __name__ == "__main__":
    with open("demo_patterns.v", "w") as f:
        for idx, filename in enumerate(INPUT_FILES):
            pattern = read_pattern(filename)
            f.write(f"// Auto generated from {filename}:\n")
            f.write(f"parameter [32*8-1:0] DEMO_PATTERN_{idx} = {{\n")
            for idx, line in enumerate(pattern):
                is_last = idx + 1 == len(pattern)
                sep = " " if is_last else ","
                f.write(
                    f'  8\'b{line.replace("*", "1").replace(" ", "0")}{sep} // {line.replace(" ", ".")}\n'
                )
            f.write("};\n\n")

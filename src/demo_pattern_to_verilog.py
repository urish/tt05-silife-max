INPUT_FILE = "demo_pattern.lif"

with open(INPUT_FILE, "r") as f:
    DEMO_PATTERN = [
        line.strip().replace(".", " ")
        for line in f.readlines()
        if not line.startswith("#")
    ]

if __name__ == "__main__":
    with open("demo_pattern.v", "w") as f:
        f.write(f"// Auto generated from {INPUT_FILE}\n\n")
        f.write("parameter [32*8-1:0] DEMO_PATTERN = {\n")
        for idx, line in enumerate(DEMO_PATTERN):
            is_last = idx + 1 == len(DEMO_PATTERN)
            sep = " " if is_last else ","
            f.write(
                f'  8\'b{line.replace("*", "1").replace(" ", "0")}{sep} // {line.replace(" ", ".")}\n'
            )
        f.write("};\n")

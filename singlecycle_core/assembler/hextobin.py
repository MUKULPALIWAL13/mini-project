# hex_to_bin_file.py

def hex_to_binary_file(input_file="OUTPUT.dat", output_file="bin_final.dat"):
    try:
        with open(input_file, "r") as infile, open(output_file, "w") as outfile:
            for line in infile:
                hex_str = line.strip()
                if hex_str:  # Skip empty lines
                    try:
                        binary_str = format(int(hex_str, 16), '08b')
                        outfile.write(binary_str + "\n")
                    except ValueError:
                        outfile.write(f"Invalid hex: {hex_str}\n")
        print(f"Conversion complete. Output written to '{output_file}'")
    except FileNotFoundError:
        print(f"Error: '{input_file}' not found.")


if __name__ == "__main__":
    hex_to_binary_file()

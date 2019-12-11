#!/usr/bin/env python3

import argparse

import sys

EPILOG = """
Finds lines in a text file with non-ascii characters.
Useful for finding odd rows with bad file encodings.
By default, prints to the console, and accepts input from STDIN

Examples:
    Grep for rows with non-ascii characters:
        cat my_file.txt | ./find_non_ascii.py

    Send output to a file:
        ./find_non_ascii.py --input-file my_file.txt --output-file bad_rows.txt
"""

BLOCK_SIZE = 1024 * 64  # 64kb input blocks
LF_CHAR = ord('\n')


def lines_with_nonascii(input_file):
    input_bytes = input_file.read(BLOCK_SIZE)
    all_ascii = True
    curr_line_bytes = bytearray()

    while len(input_bytes) > 0:
        for i in range(len(input_bytes)):
            one_byte = input_bytes[i]
            curr_line_bytes.append(one_byte)
            if one_byte == LF_CHAR:
                if not all_ascii:
                    yield curr_line_bytes
                    all_ascii = True
                curr_line_bytes = bytearray()
            else:
                if one_byte > 0x7f:
                    all_ascii = False
        input_bytes = input_file.read(BLOCK_SIZE)
    if len(curr_line_bytes) > 0:
        if not all_ascii:
            yield curr_line_bytes


def main():
    parser = argparse.ArgumentParser("find_non_ascii.py")
    parser.add_argument("--input-file", type=argparse.FileType('rb'), default=sys.stdin.buffer)
    parser.add_argument("--output-file", type=argparse.FileType('wb'), default=sys.stdout.buffer)
    args = parser.parse_args()
    for line_bytes in lines_with_nonascii(args.input_file):
        args.output_file.write(line_bytes)


if __name__ == '__main__':
    main()

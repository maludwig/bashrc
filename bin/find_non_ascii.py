#!/usr/bin/env python3

import argparse
import os

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
LF_CHAR = ord("\n")


def lines_with_nonascii(input_file, invert=False, show_line_numbers=False):
    input_bytes = input_file.read(BLOCK_SIZE)
    all_ascii = True
    curr_line_bytes = bytearray()
    line_number = 1

    while len(input_bytes) > 0:
        for i in range(len(input_bytes)):
            one_byte = input_bytes[i]
            curr_line_bytes.append(one_byte)
            if one_byte == LF_CHAR:
                if all_ascii == invert:
                    if show_line_numbers:
                        curr_line_bytes = f"{line_number:08}: ".encode("utf8") + curr_line_bytes
                    yield curr_line_bytes
                all_ascii = True
                line_number += 1
                curr_line_bytes = bytearray()
            else:
                if one_byte > 0x7F:
                    all_ascii = False
        input_bytes = input_file.read(BLOCK_SIZE)
    if len(curr_line_bytes) > 0:
        if all_ascii == invert:
            yield curr_line_bytes


def nonascii_bytes(input_file, invert=False):
    input_bytes = input_file.read(BLOCK_SIZE)
    non_ascii_chars = bytearray()
    while len(input_bytes) > 0:
        for i in range(len(input_bytes)):
            one_byte = input_bytes[i]
            if (one_byte > 0x7F) != invert:
                # If inverted, show everything that is ascii
                non_ascii_chars.append(one_byte)
        if len(non_ascii_chars) >= BLOCK_SIZE:
            yield non_ascii_chars
            non_ascii_chars = bytearray()
        input_bytes = input_file.read(BLOCK_SIZE)
    if len(non_ascii_chars) > 0:
        yield non_ascii_chars


def main():
    parser = argparse.ArgumentParser("find_non_ascii.py")
    parser.add_argument("-v", "--invert", action="store_true", default=False)
    parser.add_argument("-n", "--show-line-numbers", action="store_true", default=False)
    parser.add_argument("--mode", type=str, choices=["line", "l", "char", "c"], default="line")
    parser.add_argument("--input-file", type=argparse.FileType("rb"), default=sys.stdin.buffer)
    parser.add_argument("--output-file", type=argparse.FileType("wb"), default=sys.stdout.buffer)
    parser.add_argument("--suppress-final-linefeed", action="store_true", default=False)
    args = parser.parse_args()

    if args.mode.startswith("c"):
        output_mode = "char"
        file_iterator = nonascii_bytes(args.input_file, args.invert)
    else:
        output_mode = "line"
        file_iterator = lines_with_nonascii(args.input_file, args.invert, args.show_line_numbers)

    for line_bytes in file_iterator:
        args.output_file.write(line_bytes)

    if output_mode == "char" and not args.invert:
        # All linefeeds are ascii, so to keep the command line tidy, output a linefeed at the end
        #   if outputting to a file, do not do this.
        if args.output_file == sys.stdout.buffer:
            if not args.suppress_final_linefeed:
                args.output_file.write(os.linesep.encode("utf8"))


if __name__ == "__main__":
    main()

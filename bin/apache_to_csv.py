#!/usr/bin/env python

import csv
import json
import re
import sys
from datetime import datetime
import argparse
from argparse import RawDescriptionHelpFormatter, ArgumentParser
from io import TextIOWrapper
from os import unlink
from typing import List

EPILOG = """
Parses an Apache Log file into a CSV format, preserving all important data.
Examples:
    # Transform the first few lines of the production.access.log file into a CSV and put the output and errors onto the terminal
    head production.access.log | python apache_to_csv.py

    # Specify input and output files to use directly
    python apache_to_csv.py --input-file production.access.log --output-file /tmp/production.access.log.csv --error-file /tmp/production.access.log.err

    # Customize a list of HTTP codes that are valid, to include HTTP 200 OK, and HTTP 202 Accepted
    head production.access.log | python apache_to_csv.py --valid-http-codes 200 202
"""

COLUMN_NAMES = [
    "IP_ADDRESS",
    "HTTP_BASIC_USER_NAME",
    "REQUEST_DATE",
    "REQUEST_TIME",
    "REQUEST_TIME_ZONE",
    "METHOD",
    "URL",
    "VERSION",
    "HTTP_RESPONSE_CODE",
    "CONTENT_LENGTH_BYTES",
    "REFERRER",
    "USER_AGENT",
]

IPV6_REGEX = r"(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"
APACHE_LOG_REGEX_PARTS = [
    ("IP_ADDRESS", r"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|" + IPV6_REGEX + ")"),
    ("IDENTD", " (-)"),
    ("HTTP_BASIC_USER_NAME", " ([^ ]+)"),
    ("REQUEST_DATE", r" \[([0-9][0-9]\/[A-Z][a-z][a-z]\/20[0-9][0-9])"),
    ("REQUEST_TIME", r":([0-9][0-9]:[0-9][0-9]:[0-9][0-9])"),
    ("REQUEST_TIME_ZONE", r" ([-+][0-9]{4})\] "),
    ("METHOD", r'"(GET|PUT|POST|PATCH|DELETE|OPTIONS)'),
    ("REQUEST_LINE", r' ((\\"|[^"])*)"'),
    ("HTTP_RESPONSE_CODE", r" ([0-9]{3})"),
    ("CONTENT_LENGTH_BYTES", r" ([0-9]+)"),
    ("REFERRER", r' "((\\"|[^"])+)"'),
    ("USER_AGENT", r' "((\\"|[^"])*)"'),
]

DEFAULT_VALID_HTTP_CODES = ["200", "201", "206", "301", "302", "304", "400", "401", "403", "404", "405", "419", "500"]


def check_parsed_line(parsed_apache_line, valid_http_codes):
    suspicion = 0
    if parsed_apache_line["HTTP_RESPONSE_CODE"] not in valid_http_codes:
        suspicion += 1
    http_version_match = re.search(r"HTTP/[0-9.]+", parsed_apache_line["VERSION"])
    if http_version_match is None:
        suspicion += 1
    return suspicion


def parse_apache_line(apache_line, valid_http_codes):
    parsed_data = {}
    remaining_line = apache_line
    for entry_name, entry_regex in APACHE_LOG_REGEX_PARTS:
        match = re.match(entry_regex, remaining_line)
        if match is None:
            raise Exception(f"Unable to parse log line:\n{apache_line}\nFailed at parsing: {entry_name} with data:\n{remaining_line}")
        else:
            parsed_string = match.group(0)
            parsed_data[entry_name] = match.group(1)
            remaining_line = remaining_line[len(parsed_string) :]
    http_version_match = re.search(r" (HTTP/[0-9.]+)", parsed_data["REQUEST_LINE"])
    if http_version_match:
        parsed_string = http_version_match.group(0)
        parsed_data["VERSION"] = http_version_match.group(1)
        parsed_data["URL"] = parsed_data["REQUEST_LINE"][: -len(parsed_string)]
    else:
        parsed_data["VERSION"] = ""
        parsed_data["URL"] = parsed_data["REQUEST_LINE"]
    parsed_data["SUSPICION"] = check_parsed_line(parsed_data, valid_http_codes)
    parsed_data["REQUESTED_AT"] = datetime.strptime(
        parsed_data["REQUEST_DATE"] + " " + parsed_data["REQUEST_TIME"] + " " + parsed_data["REQUEST_TIME_ZONE"], "%d/%b/%Y %H:%M:%S %z"
    ).isoformat()
    return parsed_data


def parse_args():
    parser = ArgumentParser(formatter_class=RawDescriptionHelpFormatter, epilog=EPILOG, description="Apache Parser")
    parser.add_argument("--input-file", help="input file, default: STDIN", type=argparse.FileType("r"), default=sys.stdin)
    parser.add_argument("--output-file", help="output file, default: STDOUT", type=argparse.FileType("w"), default=sys.stdout)
    parser.add_argument("--error-file", help="error Output file, default: STDERR", type=argparse.FileType("w"), default=sys.stderr)
    parser.add_argument(
        "--valid-http-codes",
        help=f"List of valid HTTP Response codes, defaults to: {' '.join(DEFAULT_VALID_HTTP_CODES)}",
        nargs="*",
        default=DEFAULT_VALID_HTTP_CODES,
    )

    parsed_arguments = parser.parse_args()

    for http_code in parsed_arguments.valid_http_codes:
        if not re.match(r"^[1-5][0-9][0-9]", http_code):
            raise parser.error(f"unexpected http status code '{http_code}', expected number between 100 and 599")
    return parsed_arguments


def apache_to_csv(input_file: TextIOWrapper, output_file: TextIOWrapper, error_file: TextIOWrapper, valid_http_codes: List[str]):
    parsed_lines = []
    has_errors = False
    for apache_line in input_file:
        try:
            parsed_line = parse_apache_line(apache_line, valid_http_codes)
            if parsed_line["SUSPICION"] == 0:
                del parsed_line["SUSPICION"]
                parsed_lines.append(parsed_line)
            else:
                has_errors = True
                error_file.write(("=" * 30) + "\n")
                error_file.write(apache_line)
                error_file.write(json.dumps(parsed_line) + "\n\n")

        except Exception as e:
            has_errors = True
            error_file.write(("=" * 30) + "\n")
            error_file.write(f"{e}\n\n")

    if not has_errors:
        error_file_path = error_file.name
        error_file.close()
        unlink(error_file_path)
    writer = csv.DictWriter(output_file, parsed_lines[0].keys(), lineterminator="\n")
    writer.writeheader()
    writer.writerows(parsed_lines)


def main():
    args = parse_args()
    apache_to_csv(args.input_file, args.output_file, args.error_file, args.valid_http_codes)


if __name__ == "__main__":
    main()

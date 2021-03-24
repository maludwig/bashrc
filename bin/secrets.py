#!/usr/bin/env python

"""
Prerequisites:
  Python 3.3+
  Pip packages:
    pip install pycryptodome argcomplete

This script encrypts and decrypts arbitrary secrets, including strings and files, with
  arbitrary keys. It uses SHA512 to ensure message integrity,
  and to detect when a bad decryption key is used. It uses scrypt to generate the
  encryption key bytes from a string passphrase. It uses PGP AES encryption to
  generate a unique ciphertext per message, even if messages are identical.
  This script works on Ubuntu, Windows, and OSX.

Examples:
    # Encrypt a file
    ./secrets.py encrypt \
      --input-file /tmp/my_plaintext_config.json \
      --output-file /tmp/my_encrypted_config.bin \
      --key 'SUPERSECRETPASSWORD'

    # Decrypt a file
    ./secrets.py decrypt \
      --input-file /tmp/my_encrypted_config.bin \
      --output-file /tmp/my_plaintext_config.json \
      --key 'SUPERSECRETPASSWORD'

    # Generate a secret key from a password
    ./secrets.py derive_key \
      --password 'SUPERSECRETPASSWORD'
"""

import argparse
import hashlib
import re
from argparse import RawDescriptionHelpFormatter, ArgumentParser
from os import unlink
import json
from getpass import getpass

import argcomplete
from Crypto.Cipher import AES
from Crypto.Protocol.KDF import scrypt

EPILOG = __doc__

SCRYPT_PARAMS = 16384, 8, 1

# SHA512 hash length, in bytes
HASH_LENGTH = 64


def pretty_json_print(o):
    json_string = json.dumps(o, indent=2)
    print(json_string)

class DecryptionFailure(BaseException):
    pass


def hash_bytes(input_bytes):
    m = hashlib.sha512()
    m.update(input_bytes)
    return m.hexdigest()


def hash_string(input_string):
    return hash_bytes(input_string.encode())


def derive_key(password):
    salt = hash_string(password)
    n, r, p = SCRYPT_PARAMS
    secret_key = scrypt(password, salt, 16, n, r, p)
    return secret_key


def encrypt_file(input_file, output_file, secret_key):
    input_file_bytes = input_file.read()
    file_hash_hex = hash_bytes(input_file_bytes)
    file_hash_bytes = bytes.fromhex(file_hash_hex)
    cipher = AES.new(secret_key, AES.MODE_OPENPGP)
    plaintext = file_hash_bytes + input_file_bytes
    eiv_and_ciphertext = cipher.encrypt(plaintext)
    output_file.write(eiv_and_ciphertext)


def decrypt_file(input_file, output_file, secret_key):
    input_file_bytes = input_file.read()

    eiv_size = AES.block_size + 2
    eiv = input_file_bytes[:eiv_size]
    ciphertext = input_file_bytes[eiv_size:]

    cipher = AES.new(secret_key, AES.MODE_OPENPGP, eiv)
    plaintext = cipher.decrypt(ciphertext)

    output_file_bytes = plaintext[HASH_LENGTH:]
    file_hash_hex = hash_bytes(output_file_bytes)
    expected_file_hash_bytes = bytes.fromhex(file_hash_hex)

    actual_file_hash_bytes = plaintext[:HASH_LENGTH]
    if expected_file_hash_bytes == actual_file_hash_bytes:
        output_file.write(output_file_bytes)
    else:
        raise DecryptionFailure("Decryption failed, try another key")


def main():
    args = parse_args()
    secret_key = derive_key(args.password)
    if args.module == "derive_key":
        pretty_json_print({"result": "success", "key_bytes": secret_key.hex()})
    elif args.module == "encrypt":
        encrypt_file(args.input_file, args.output_file, secret_key)
        if not args.keep:
            args.input_file.close()
            unlink(args.input_file.name)
        pretty_json_print({"result": "success"})
    elif args.module == "decrypt":
        try:
            decrypt_file(args.input_file, args.output_file, secret_key)
            if not args.keep:
                args.input_file.close()
                unlink(args.input_file.name)
            pretty_json_print({"result": "success"})
        except DecryptionFailure as ex:
            pretty_json_print({"result": "failure", "error": str(ex)})
            exit(1)


def parse_args():
    parser = ArgumentParser(formatter_class=RawDescriptionHelpFormatter, epilog=EPILOG, description="Secret storage")
    parser.add_argument("module", help="The action to perform", choices=["encrypt", "decrypt", "derive_key"], type=str)
    parser.add_argument("--input-file", help="Input file", type=argparse.FileType("rb"))
    parser.add_argument("--output-file", help="Output file", type=argparse.FileType("wb"))
    parser.add_argument("--password", help="Encryption key/password (will prompt if not provided)", type=str)
    parser.add_argument("--keep", help="Do not delete input file", action="store_true")

    argcomplete.autocomplete(parser)
    parsed_arguments = parser.parse_args()

    if not parsed_arguments.password:
        parsed_arguments.password = getpass()

    if parsed_arguments.module in ("encrypt", "decrypt"):
        if parsed_arguments.module == "encrypt":
            if parsed_arguments.input_file is None:
                raise parser.error("--input-file is required for encryption")
            if parsed_arguments.output_file is None:
                output_file_path = f"{parsed_arguments.input_file.name}.secret"
                parsed_arguments.output_file = open(output_file_path, "wb")
        elif parsed_arguments.module == "decrypt":
            if parsed_arguments.input_file is None:
                raise parser.error("--input-file is required for decryption")
            if parsed_arguments.output_file is None:
                match = re.match(r"^(.*).secret$", parsed_arguments.input_file.name)
                if match:
                    output_file_path = match[1]
                else:
                    output_file_path = f"{parsed_arguments.input_file.name}.plain"
                parsed_arguments.output_file = open(output_file_path, "wb")
    return parsed_arguments


if __name__ == "__main__":
    main()

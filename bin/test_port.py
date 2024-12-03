import re
import socket
import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description="Check if a TCP port is open on a remote host."
    )
    parser.add_argument("host", help="Remote host's IP address or domain name.")
    parser.add_argument("port", type=int, help="TCP port number to check.")
    parser.add_argument(
        "--timeout",
        type=float,
        default=3.0,
        help="Connection timeout in seconds. Default is 3 seconds.",
    )
    parser.add_argument(
        "--local-ip",
        help="Local IP address to bind to. Default is all available interfaces.",
    )
    return parser.parse_args()


def is_ipv4(ip):
    """
    Check if a string is a valid IPv4 address.
    """
    if re.match(r"^\d+\.\d+\.\d+\.\d+$", ip):
        return True
    return False


def is_ipv6(ip):
    """
    Check if a string is a valid IPv6 address.
    """
    if re.match(r"^[0-9a-fA-F:]+$", ip):
        return True
    return False


def list_local_ips(include_ipv4=True, include_ipv6=True):
    """
    List all local IP addresses of the machine.
    """
    local_ipv4s = set()
    local_ipv6s = set()
    hostname = socket.gethostname()

    try:
        # Get all addresses associated with the hostname
        for addr_info in socket.getaddrinfo(hostname, None):
            _family, _socktype, _proto, _canonname, addr = addr_info
            if len(addr) == 2:
                ip, _port = addr
            elif len(addr) == 4:
                ip, _port, _flowinfo, _scopeid = addr

            if is_ipv4(ip):
                local_ipv4s.add(ip)
            if is_ipv6(ip):
                local_ipv6s.add(ip)
    except socket.gaierror:
        pass

    result = []
    # Add loopback addresses
    if include_ipv4:
        result.append("127.0.0.1")
        result += list(local_ipv4s)

    if include_ipv6:
        result.append("::1")
        result += list(local_ipv6s)
    return result


def is_port_open(host, port, timeout, local_ip=None):
    """
    Check if a TCP port is open on the specified host.
    :param host: The remote host's IP address or domain name.
    :param port: The TCP port number to check.
    :param timeout: Timeout in seconds for the connection attempt.
    :param local_ip: Local IP address to bind to. Default is None.
    :return: True if the port is open, False otherwise.
    """
    if local_ip and is_ipv4(local_ip):
        family = socket.AF_INET
    elif local_ip and is_ipv6(local_ip):
        family = socket.AF_INET6
    else:
        family = socket.AF_INET
    with socket.socket(family, socket.SOCK_STREAM) as sock:
        sock.settimeout(timeout)
        if local_ip:
            try:
                sock.bind(
                    (local_ip, 0)
                )  # Bind to the specified local IP and any available port
            except socket.error as e:
                raise Exception(f"Failed to bind to {local_ip}: {e}")
        try:
            sock.connect((host, port))
            return True
        except socket.timeout:
            return False
        except socket.error:
            return False


# Example usage:
def main():
    args = parse_args()
    local_ips = list_local_ips()
    if args.local_ip:
        local_ips = [ip for ip in local_ips if ip == args.local_ip]
    if not local_ips:
        if args.local_ip:
            raise Exception(f"Local IP address unavailable: {args.local_ip}")
        else:
            raise Exception("No local IP addresses available.")
    for ip in local_ips:
        # print(ip)
        connected = is_port_open(args.host, args.port, args.timeout, ip)
        if connected:
            print(f"Port {args.port} on {args.host} is open from {ip}.")
        else:
            print(f"Port {args.port} on {args.host} is unreachable from {ip}.")


if __name__ == "__main__":
    main()

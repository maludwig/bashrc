from argparse import ArgumentParser, RawDescriptionHelpFormatter
from collections import defaultdict

import psycopg
from psycopg.rows import dict_row

EPILOG = """
    Order tables for import based on foreign key dependencies, so that tables with foreign keys are created after the tables they reference.
    Example:
        python ordering.py --db-url 'postgresql://username:password@localhost:5432/db_name'
"""


def parse_args():
    parser = ArgumentParser(
        description="Order tables for import based on foreign key dependencies, so that tables with foreign keys are created after the tables they reference.",
        formatter_class=RawDescriptionHelpFormatter,
        epilog=EPILOG,
    )
    parser.add_argument(
        "--db-url",
        help="Database URL, example: 'postgresql://postgres:password@localhost:5432/db_name'",
        required=True,
    )
    parser.add_argument(
        "--no-dependencies",
        action="store_true",
        help="Do not print foreign key dependencies",
    )
    parser.add_argument(
        "--no-table-order", action="store_true", help="Do not print table order"
    )
    return parser.parse_args()


def get_table_names(conn):
    """
    Retrieves all table names from the public schema.
    Modify the schema if your tables are in a different schema.
    """
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        """
        )
        rows = cur.fetchall()
        table_names = []
        for row in rows:
            table_names.append(row["table_name"])
    return table_names


def get_foreign_key_dependencies(conn):
    """
    Retrieves foreign key dependencies between tables.
    Returns a list of tuples in the form (table_name, referenced_table_name).
    """
    with conn.cursor() as cur:
        cur.execute(
            """
                SELECT
                    tc.table_name AS table_name,
                    ccu.table_name AS referenced_table_name
                FROM
                    information_schema.table_constraints AS tc
                        JOIN information_schema.key_column_usage AS kcu
                             ON tc.constraint_name = kcu.constraint_name
                                 AND tc.table_schema = kcu.table_schema
                        JOIN information_schema.constraint_column_usage AS ccu
                             ON ccu.constraint_name = tc.constraint_name
                                 AND ccu.table_schema = tc.table_schema
                WHERE tc.constraint_type = 'FOREIGN KEY'
                  AND tc.table_schema = 'public'
                ORDER BY tc.table_name;
        """
        )
        dependencies = []
        for row in cur.fetchall():
            entry = (row["table_name"], row["referenced_table_name"])
            dependencies.append(entry)
        return dependencies


def print_dependencies(entries: list[tuple[str, str]]):
    for table_name, referenced_table_name in entries:
        print(f"{table_name} needs {referenced_table_name}")


def load_table_dependencies(entries: list[tuple[str, str]]):
    table_dependencies = defaultdict(list)
    for table_name, referenced_table_name in entries:
        table_dependencies[table_name].append(referenced_table_name)
    return table_dependencies


def get_table_order(table_dependencies: dict[str, list[str]], table_names: list[str]):
    """
    Computes the order in which tables should be created based on their dependencies.
    Tables with no dependencies should be created first.
    """
    # A deep copy is required to avoid modifying the original lists in the dictionary
    remaining_dependencies = {k: v.copy() for k, v in table_dependencies.items()}
    table_order = []
    visited = set()
    while remaining_dependencies:
        for table_name in table_names:
            if table_name not in visited:
                if table_name not in remaining_dependencies:
                    table_order.append(table_name)
                    visited.add(table_name)
        for visited_table_name in visited:
            other_table_names = list(remaining_dependencies.keys())
            for other_table_name in other_table_names:
                other_dependencies = remaining_dependencies[other_table_name]
                while visited_table_name in other_dependencies:
                    other_dependencies.remove(visited_table_name)
                if not other_dependencies:
                    del remaining_dependencies[other_table_name]
        table_order.append("")
    return table_order


def connect_to_db(db_url):
    connection = psycopg.connect(db_url, row_factory=dict_row)
    print("Connection to database established")
    return connection


def main():
    args = parse_args()

    conn = connect_to_db(args.db_url)
    table_names = get_table_names(conn)
    foreign_key_dependencies = get_foreign_key_dependencies(conn)
    if not args.no_dependencies:
        print_dependencies(foreign_key_dependencies)
        print("=" * 80)
    if not args.no_table_order:
        table_dependencies = load_table_dependencies(foreign_key_dependencies)
        table_order = get_table_order(table_dependencies, table_names)
        for table_name in table_order:
            print(table_name)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import argparse
import subprocess


def find_missing_apps(apps: list[str]) -> list:
    missing = []
    for app in apps:
        package = app
        if "::" in app:
            app, package = app.split("::")
        try:
            subprocess.check_output(f"command -v {app}", shell=True)
        except subprocess.CalledProcessError:
            missing.append(package)
    return missing


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="PROG", usage="%(prog)s [options]")
    parser.add_argument(
        "apps",
        nargs="+",
        help=(
            "The apps to check. Optionally use '::' to separate the app from "
            "the name used by the package manager (e.g. rg::ripgrep)"
        ),
    )
    args = parser.parse_args()
    missing = find_missing_apps(args.apps)
    print(" ".join(missing))

#!/usr/bin/env python3
"""
Cross-Platform Build & Release Script for GPX Compiler.
Works natively on Windows, Linux, and macOS.
"""

import sys
import os
import shutil
import argparse
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent


def run_cmd(cmd, desc):
    print(f"\n>> {desc}...")
    print(f"$ {' '.join(str(c) for c in cmd)}")
    res = subprocess.run(cmd, cwd=PROJECT_ROOT)
    if res.returncode != 0:
        print(f"[ERROR] Step failed with exit code {res.returncode}: {desc}", file=sys.stderr)
        sys.exit(res.returncode)


def main():
    parser = argparse.ArgumentParser(description="GPX Compiler Cross-Platform Release Tool")
    parser.add_argument("version", type=str, help="Release version (e.g. v0.2.0 or 0.2.0)")
    parser.add_argument("--notes", type=str, default="GPX Compiler Release", help="Release notes summary")
    parser.add_argument("--skip-publish", action="store_true", help="Build artifacts without publishing to GitHub")
    args = parser.parse_args()

    version = args.version if args.version.startswith("v") else f"v{args.version}"

    print("=" * 50)
    print(f"  GPX Compiler: Packaging & Release {version}")
    print(f"  Platform: {sys.platform} ({os.name})")
    print(f"  Root: {PROJECT_ROOT}")
    print("=" * 50)

    # 1. Run Automated Test Suite
    run_cmd([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_*.py"], "Running test suite")

    # 2. Build Standalone Native Executable via PyInstaller
    dist_bin_dir = PROJECT_ROOT / "dist" / "bin"
    dist_bin_dir.mkdir(parents=True, exist_ok=True)
    binary_name = "gpx.exe" if sys.platform == "win32" else "gpx"
    run_cmd(
        [
            sys.executable, "-m", "PyInstaller",
            "--onefile",
            "--name", "gpx",
            "--distpath", str(dist_bin_dir),
            "compiler/main.py",
            "--noconfirm"
        ],
        "Building standalone binary"
    )

    # 3. Build Universal Python Package Wheel
    dist_dir = PROJECT_ROOT / "dist"
    run_cmd([sys.executable, "-m", "pip", "wheel", ".", "-w", str(dist_dir), "--no-deps"], "Building universal wheel")

    wheels = sorted(dist_dir.glob("*.whl"), key=lambda p: p.stat().st_mtime, reverse=True)
    latest_wheel = wheels[0] if wheels else None

    built_binary = dist_bin_dir / binary_name
    print("\n" + "=" * 50)
    print("  Artifacts Built Successfully:")
    print(f"  - Binary: {built_binary}")
    if latest_wheel:
        print(f"  - Wheel:  {latest_wheel}")
    print("=" * 50)

    # 4. Publish to GitHub Releases (if gh CLI is available and not skipped)
    if not args.skip_publish:
        if shutil.which("gh"):
            release_cmd = [
                "gh", "release", "create", version,
                str(built_binary),
                str(latest_wheel) if latest_wheel else "",
                "--title", f"GPX Compiler {version}",
                "--notes", args.notes
            ]
            release_cmd = [c for c in release_cmd if c]
            run_cmd(release_cmd, f"Publishing release {version} to GitHub")
            print(f"\n[SUCCESS] Release {version} is live on GitHub!")
        else:
            print("\n[NOTE] GitHub CLI ('gh') not found in PATH. Skipping remote upload.")


if __name__ == "__main__":
    main()

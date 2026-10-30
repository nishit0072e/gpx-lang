#!/usr/bin/env python3
"""
=============================================================================
VEGA RISC-V SDK in GPX - Automated Full Test & Build Verification Runner
Iterates across all ported GPX examples, builds them using the official
RISC-V toolchain, and verifies 100% artifact generation (ELF, BIN, HEX, DUMP).
=============================================================================
"""

import sys
import os
import subprocess
from pathlib import Path

def run_build_all() -> bool:
    sdk_gpx_root = Path(__file__).resolve().parent
    repo_root = sdk_gpx_root.parent
    tools_bin = repo_root / "vega-tools-windows" / "bin"
    make_exe = tools_bin / "make.exe"

    if not make_exe.exists():
        print(f"Error: make.exe not found at {make_exe}", file=sys.stderr)
        return False

    examples_dir = sdk_gpx_root / "examples"
    example_makefiles = list(examples_dir.rglob("Makefile"))

    if not example_makefiles:
        print(f"No examples found in {examples_dir}", file=sys.stderr)
        return False

    print("====================================================================")
    print("      VEGA RISC-V SDK (GPX Port) - Automated Build Test Suite       ")
    print(f" Found {len(example_makefiles)} Example Projects across Peripherals")
    print("====================================================================")

    passed = 0
    failed = 0
    results = []

    # Ensure project root is in PYTHONPATH
    env = os.environ.copy()
    env["PYTHONPATH"] = str(repo_root)

    for idx, mf in enumerate(sorted(example_makefiles), 1):
        example_folder = mf.parent
        rel_path = example_folder.relative_to(examples_dir)
        print(f"\n[{idx}/{len(example_makefiles)}] Building example: {rel_path} ...")

        # 1. Clean previous build
        subprocess.run(
            [str(make_exe), "clean"],
            cwd=str(example_folder),
            env=env,
            capture_output=True,
            text=True
        )

        # 2. Compile and link all targets
        res = subprocess.run(
            [str(make_exe), "all"],
            cwd=str(example_folder),
            env=env,
            capture_output=True,
            text=True
        )

        build_dir = example_folder / "build"
        elf_files = list(build_dir.glob("*.elf")) if build_dir.exists() else []
        bin_files = list(build_dir.glob("*.bin")) if build_dir.exists() else []
        hex_files = list(build_dir.glob("*.hex")) if build_dir.exists() else []
        dump_files = list(build_dir.glob("*.dump")) if build_dir.exists() else []

        if res.returncode == 0 and elf_files and bin_files and hex_files and dump_files:
            elf_file = elf_files[0]
            bin_size = bin_files[0].stat().st_size
            print(f"  [PASS] {rel_path} -> ELF ({elf_file.name}), Flash Bin ({bin_size:,} bytes)")
            passed += 1
            results.append((str(rel_path), "PASS", f"{bin_size:,} B"))
        else:
            print(f"  [FAIL] {rel_path}")
            if res.stderr:
                print(f"         Error: {res.stderr.strip()[:300]}")
            failed += 1
            results.append((str(rel_path), "FAIL", "-"))

    print("\n====================================================================")
    print("                        BUILD TEST SUMMARY                          ")
    print("====================================================================")
    for name, status, size in results:
        status_str = "[PASS]" if status == "PASS" else "[FAIL]"
        print(f"  {status_str:7} {name:<35} {size:>12}")
    print("--------------------------------------------------------------------")
    print(f"  Total: {len(example_makefiles)} | Passed: {passed} | Failed: {failed}")
    print("====================================================================")

    return failed == 0

if __name__ == "__main__":
    success = run_build_all()
    sys.exit(0 if success else 1)

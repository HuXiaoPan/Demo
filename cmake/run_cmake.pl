#!/usr/bin/perl -I.
# Usage: run_cmake.pl [cmake options]
# cmake options: Usually not needed. Intended for debugging e.g. --trace --debug-output
use cmake::RunCmake;
run_cmake();

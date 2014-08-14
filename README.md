DartTypeStripper
================

Simple Command line tool to remove types from dart programs.

## Introduction

This tool is written by Jesper Lindstrøm Nielsen [jstroem] and Troels Leth Jensen [tleth] as part of a study in Dart at Aarhus University @ 2014.

## Install

When cloned you should get the packages needed to use via. `pub build`.

## Run

To use the tool just do:

	./strip.dart [-p] [-o dir] file(s)

There is two optional flags to put in.

Partial `-p` or `--partial` that disables type stripping from method and function signatures.
Output `-o` or `--output` gives the location to place the stripped files. If abscent output will be printed to stdout.


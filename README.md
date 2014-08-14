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
partial `-p` or `--partial` is a flag which does the stripper does not remove method and function types.
output `-o` or `--output` is a flag to give a output folder and all the files given into the tool will be put in there. Otherwise the output will come in the pipe.


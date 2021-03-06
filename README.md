DartTypeStripper
================

Simple Command line tool to remove types from dart programs.

## Introduction

This tool is written by Jesper Lindstrøm Nielsen and Troels Leth Jensen as part of a study in Dart at Aarhus University @ 2014.

## Install

When cloned you should get the packages needed to use via. `pub get`.

## Run

To use the tool just do:

	./strip.dart [-p] [-w --override] file(s)

The tool implement these flags:

Partial `-p` or `--partial` that disables type stripping from method and function signatures.

Similarly, '-g' or '--keep-generics' preserves any naked generic types, i.e. T will be kept but List<T> will be removed in a class where T is a type argument.

Override `-w` or `--override` flag to specify of the given file should be overriden whit the stripped result.



## Tests

We have tested this tool on all the official dart samples and the packages they use. All tests were positive, this means that if you have a working program with types you can remove them using this tool and the stripped version will work.


#!/bin/bash

(for f in $(ls expected/)
do
    if [ $(diff <(cat expected/$f) <(./bin/strip.dart tests/$f)|wc -l) -eq 0 ]
    then echo -e $f '\033[0;32mPass\033[0m'
    else echo -e $f '\033[0;31mFail\033[0m'
    fi
    
done)|column -t

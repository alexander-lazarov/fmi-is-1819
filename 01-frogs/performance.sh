#!/bin/bash

set -e

bundle exec ruby performance.rb > times.dat
gnuplot -e "\
    set terminal png; \
    set output 'performance.png'; \
    set xlabel 'n'; \
    set ylabel 't(s)'; \
    plot 'times.dat' \
"

/Users/a/.iterm2/imgcat performance.png

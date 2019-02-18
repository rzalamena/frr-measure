set encoding utf8
set term pngcairo enhanced color size 800, 600

set title "FRR instances memory usage"
set xlabel "number of processes (bgpd, staticd, zebra)"
set ylabel "memory usage (non shared) in MiB"

set style line 10 linewidth 0.5 linecolor "#333333"
set grid xtics ytics mytics ls 10
set xtics 40
set ytics 100

set datafile separator ","
plot "empty.dat" using 1:($2 / 1024) \
     with lines \
     title "memory usage / process number"

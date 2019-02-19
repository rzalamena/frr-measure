set encoding utf8
set term pngcairo enhanced color size 1200, 800

set title "FRR instances memory usage"
set xlabel "number of processes (bgpd, staticd, zebra)"
set ylabel "memory usage (non shared) in MiB"

set style line 10 linewidth 0.5 linecolor "#333333"
set style line 20 linewidth 1.25

set grid xtics ytics mxtics mytics ls 10
set xtics 30
set ytics 100
set xrange [1:800]
set yrange [1:3200]

set datafile separator ","
plot \
     "empty.dat" using 1:($2 / 1024) title "no prefixes" with lines linewidth 4, \
     "100.dat" using 1:($2 / 1024) title "100 prefixes" with lines linewidth 4

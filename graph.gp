set encoding utf8
set term pngcairo enhanced color size 1920, 1200

set title "FRR instances memory usage"
set xlabel "number of processes (bgpd, staticd, zebra)"
set ylabel "memory usage (non shared) in MiB"

set style line 10 linewidth 0.5 linecolor "#333333"
set style line 20 linewidth 1.25

set grid xtics ytics ls 10
set xtics 30
set ytics 120
set xrange [1:800]
set yrange [1:5400]

set datafile separator ","
plot \
     "10000.dat" using 1:($2 / 1024) title "10000 prefixes" with lines linewidth 3, \
     "1000.dat" using 1:($2 / 1024) title "1000 prefixes" with lines linewidth 3, \
     "100.dat" using 1:($2 / 1024) title "100 prefixes" with lines linewidth 3, \
     "empty.dat" using 1:($2 / 1024) title "no prefixes" with lines linewidth 3

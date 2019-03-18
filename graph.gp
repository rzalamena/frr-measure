set encoding utf8
set term pngcairo enhanced color size 1800, 1800

set xlabel "number of instances (bgpd, staticd, zebra, isisd, ospfd)"
set ylabel "memory usage (non shared) in MiB"
set y2label "memory usage (non shared) in MiB"

set style line 10 linewidth 0.5 linecolor "#333333"

set grid xtics ytics ls 10
set xtics 15
set ytics 350
set y2tics 350
set xrange [1:255]
set yrange [1:6300]
set y2range [1:6300]

set datafile separator ","


set multiplot layout 3, 1

set title "FRR instances with 10.000 prefixes"
plot \
     "10000.dat" using ($1 / 3):($3 / 1024) title "bgpd" with lines linewidth 3, \
     "10000.dat" using ($1 / 3):($4 / 1024) title "staticd" with lines linewidth 3, \
     "10000.dat" using ($1 / 3):($5 / 1024) title "zebra" with lines linewidth 3, \
     "10000.dat" using ($1 / 3):($6 / 1024) title "ospfd" with lines linewidth 3, \
     "10000.dat" using ($1 / 3):($7 / 1024) title "isisd" with lines linewidth 3, \
     "10000.dat" using ($1 / 3):($2 / 1024) title "bgpd+staticd+zebra+ospfd+isisd" with lines linewidth 3

set title "FRR instances with 1.000 prefixes"
plot \
     "1000.dat" using ($1 / 3):($3 / 1024) title "bgpd" with lines linewidth 3, \
     "1000.dat" using ($1 / 3):($4 / 1024) title "staticd" with lines linewidth 3, \
     "1000.dat" using ($1 / 3):($5 / 1024) title "zebra" with lines linewidth 3, \
     "1000.dat" using ($1 / 3):($6 / 1024) title "ospfd" with lines linewidth 3, \
     "1000.dat" using ($1 / 3):($7 / 1024) title "isisd" with lines linewidth 3, \
     "1000.dat" using ($1 / 3):($2 / 1024) title "bgpd+staticd+zebra" with lines linewidth 3

set title "FRR instances with no prefixes"
plot \
     "empty.dat" using ($1 / 3):($3 / 1024) title "bgpd" with lines linewidth 3, \
     "empty.dat" using ($1 / 3):($4 / 1024) title "staticd" with lines linewidth 3, \
     "empty.dat" using ($1 / 3):($5 / 1024) title "zebra" with lines linewidth 3, \
     "empty.dat" using ($1 / 3):($6 / 1024) title "ospfd" with lines linewidth 3, \
     "empty.dat" using ($1 / 3):($7 / 1024) title "isisd" with lines linewidth 3, \
     "empty.dat" using ($1 / 3):($2 / 1024) title "bgpd+staticd+zebra" with lines linewidth 3

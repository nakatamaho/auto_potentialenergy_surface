set encoding utf8
set terminal pdfcairo color enhanced font "Helvetica,18"
#set terminal postscript eps enhanced color
#set xrange [0.8:6]
#set xlabel font "Helvetica,20" 
#set ylabel font "Helvetica,20" 
#set key font "Helvetica,25"
set yrange [-109.5:-107.5]
set xrange [0.5:4.0]
plot "N2.SV/data_CCSDT" using 1:2 smooth csplines linewidth 4, \
     "N2.SV/data_fullCI" using 1:2 smooth csplines linewidth 4, \
     "N2.SV/data_MP2" using 1:2 smooth csplines linewidth 4, \
     "N2.SV/data_Hartree-Fock" using 1:2 smooth csplines linewidth 4

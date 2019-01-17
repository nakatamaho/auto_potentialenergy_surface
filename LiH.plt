set encoding utf8
set xrange [0.8:5]
set yrange [-8.05:-7.7]
set xlabel font "Helvetica,20" 
set ylabel font "Helvetica,20" 
set key font "Helvetica,25"
plot "LiH.631g/data_CCSDT"  using 1:2 smooth csplines linewidth 4, \
     "LiH.631g/data_fullCI" using 1:2 smooth csplines linewidth 4, \
     "LiH.631g/data_MP2"    using 1:2 smooth csplines linewidth 4, \
     "LiH.631g/data_Hartree-Fock" using 1:2 smooth csplines linewidth 4

#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
SYSTEM="LiH.631g"
METHODS="Hartree-Fock MP2 CCSDT fullCI"
RUNGMS=~/Documents/bin/gamess/rungms
NEEDCALC=1
DISTANCES=""
for i in {7..50} #0.7A to 5.0A
do
   _tmp=`echo "$i/10" | bc -l` 
   distance=`printf "%3.1f" $_tmp`
   DISTANCES="$DISTANCES $distance"
done

if [ x$NEEDCALC = x"1" ]; then
for distance in $DISTANCES; do
    for method in $METHODS; do
        cd $SCRIPT_DIR
        mkdir -p $SCRIPT_DIR/$SYSTEM/$distance
        cp $SCRIPT_DIR/$SYSTEM/test_inp/_${SYSTEM}.${method}.gamess.inp $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp
        sed -i.bak "s/1.0000/${distance}/g" $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp
        rm $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp.bak
        rm $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.dat
        $RUNGMS $SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp 2>&1 | tee $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log
        rm $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.F*
        rm $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.dat
     done
done
fi

for method in $METHODS; do
  rm -f $SCRIPT_DIR/$SYSTEM/data_$method
done
for distance in $DISTANCES; do
    for method in $METHODS; do
    if [ x"$method" = x"Hartree-Fock" ]; then
        _ene=`grep "FINAL RHF ENERGY" $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log | awk '{print $5}' `
        echo "$distance $_ene" >> $SCRIPT_DIR/$SYSTEM/data_$method
    fi
    if [ x"$method" = x"MP2" ]; then
        _ene=`grep "E(MP2)" $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log | awk '{print $2}'`
        echo "$distance $_ene" >> $SCRIPT_DIR/$SYSTEM/data_$method
    fi
    if [ x"$method" = x"CCSDT" ]; then
        _ene=`grep "CCSD(T) ENERGY" $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log | awk '{print $3}'`
        echo "$distance $_ene" >> $SCRIPT_DIR/$SYSTEM/data_$method
    fi
    if [ x"$method" = x"fullCI" ]; then
        _ene=`grep 'STATE   1  ENERGY' $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log | awk '{print $4}'`
        echo "$distance $_ene" >> $SCRIPT_DIR/$SYSTEM/data_$method
    fi
    done
done
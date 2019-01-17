#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
SYSTEM="N2.SV"
METHODS="Hartree-Fock MP2 CCSDT fullCI"
RUNGMS=/work/pubchem/pm6/pkg/bin/rungms
NEEDCALC=0
CORES=40
DISTANCES=""
for i in {7..60} #N-N distance from 0.7A to 6.0A
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
        sed -i.bak "s/XXXXXX/${distance}/g" $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp
        rm -f $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp.bak
        rm -f $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.dat
        if [ x"$method" = x"fullCI" ]; then
            $RUNGMS $SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp 00 $CORES 2>&1 | tee $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log
        else
            $RUNGMS $SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.inp 2>&1 | tee $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.log
        fi
        rm -f $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.F*
        rm -f $SCRIPT_DIR/$SYSTEM/$distance/${SYSTEM}.${method}.${distance}.gamess.dat
        rm -f ${SYSTEM}.${method}.${distance}.gamess.F*
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
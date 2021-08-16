#!/bin/bash -e

NPROC=256
WALLTIME=75

cd $(dirname ${BASH_SOURCE[0]})
ROOTDIR=$PWD

EVENT='NKT'
#MODEL='s40rts_crust1.0'
MODEL='1D_ak135f_no_mud'

SOLVER="$ROOTDIR/_compile/specfem3d_globe-c4c30a79"
INPUT="$ROOTDIR/input/$EVENT/$MODEL/DATA"

function recompile {
    cd $SOLVER
    cp $INPUT/* DATA/
    echo
    echo "Compiling..."
    echo
    make clean > compile.log
    make >> compile.log
}


# recompile solver?
echo ""
while true; do
    read -p "Recompile solver? (usually takes about 5 minutes) ([y]/n) " input
    echo
    case $input in
        [Yy]* ) recompile; break;;
        "" ) recompile; break;;
        [Nn]* ) break;;
    esac
done
echo ""


# check if directory already exist
cd $ROOTDIR
DIR="_run/$EVENT/$MODEL"
if [ -d $DIR ]; then
    echo "Already exists:"
    echo "  $DIR"
    echo
    while true; do
        read -p "Remove existing directory? (y/[n]) " input
        echo
        case $input in
            [Yy]* ) rm -rf $DIR; break;;
            "" ) exit;;
            [Nn]* ) exit;;
        esac
    done
fi


echo ""
echo "Submitting jobs..."
echo ""

for src in Mrr Mtt Mpp Mrt Mrp Mtp
do
   WORKDIR="_run/$EVENT/$MODEL/$src"
   mkdir -p $WORKDIR
   echo "$WORKDIR"

   cp -r $SOLVER/bin $WORKDIR/bin

   mkdir -p $WORKDIR/DATA
   cp -r $SOLVER/DATA/* $WORKDIR/DATA
   cp -r $INPUT/* $WORKDIR/DATA
   cp $WORKDIR/DATA/CMTSOLUTION{_$src,}

   mkdir -p $WORKDIR/DATABASES_MPI
   mkdir -p $WORKDIR/OUTPUT_FILES

   cp run.bash $WORKDIR/
   cd $WORKDIR/
   sbatch --ntasks=$NPROC --time=$WALLTIME ./run.bash $NPROC

   cd $ROOTDIR

done
echo ""



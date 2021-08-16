#!/bin/bash -e

NPROC=$1

mpirun -np $NPROC bin/xmeshfem3D
mpirun -np $NPROC bin/xspecfem3D


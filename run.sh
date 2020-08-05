#!/bin/sh
# $Id: run.sh,v 1.1.1.1 2020/08/05 00:00:00 seiji Exp seiji $

exe=gcell
ncores=32

npx=${1:-8}
npy=${2:-$npx}
nppn=${3:-$ncores}
nlen=${4:-1000000}
npad=${5:-0}

nmpi=`expr $npx \* $npy`

wkdir=wk.${nmpi}mpi-${nppn}ppn.`date +%Y%m%d_%H%M%S`
mkdir -p $wkdir
cd       $wkdir
ln -s ../$exe

cat << EOF > PBS
#!/bin/sh -x
#PBS -N GCELL
#PBS -j oe
#PBS -l nodes=`expr $nmpi / $nppn`:ppn=$ncores
#PBS -l walltime=01:00:00

cd \$PBS_O_WORKDIR

#ulimit -s unlimited
#ulimit -c unlimited

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CRAY_LD_LIBRARY_PATH}
export NO_STOP_MESSAGE=1

/usr/bin/time -p aprun -n$nmpi -N$nppn -S`expr $nppn / 2` -j1 -ss -cc cpu ./$exe << END > run.log 2>&1
 $npx $npy
 $nlen $npad
END

cat run.log

EOF

chmod a+x PBS
qsub PBS


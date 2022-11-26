#!/bin/sh

#Compilar Sequencial
echo "=================Compilar SEQUENCIAL=================" 
gcc bruteForce.c -o bruteForce -std=c99 -O3

#Executar sequencial
echo "=================Executar SEQUENCIAL================="
./bruteForce "$1"

#Compilar OMP
echo "====================Compilar OMP===================="
gcc bruteForce-omp.c -o bfomp -fopenmp -lm -std=c99 -O3

#Compilar CUDA
echo "====================Compilar CUDA===================="
nvcc bruteForce-cuda.cu -o bruteForce-cuda

#Compilar MPI
echo "====================Compilar MPI===================="
mpicc bruteForce-mpi.c -o bruteForce-mpi -fopenmp -std=c99 -O3

#Executar MPI
echo "====================Executar MPI===================="
for((i = 2; i <= 32; i*=2))
do
    echo MPI "$i"
    mpirun -x MXM_LOG_LEVEL=error -quiet -np "$i" --allow-run-as-root ./bruteForce-mpi _Hacka1
done

if [[  -f "speedup.dat" ]]; then
rm -rf speedup.dat
fi

if [[  -f "speedup_cuda.dat" ]]; then
rm -rf speedup_cuda.dat
fi

#Executa OMP
echo "===================Executar OMP==================="
for((i = 2; i <= 128; i*=2))
do
    echo OMP "$i"
    OMP_NUM_THREADS=$i ./bfomp "$1"
done

#Executa cuda
echo "==================Executar CUDA=================="
for((i = 2; i <= 1024; i*=2))
do
    echo CUDA "$i"
    ./bruteForce-cuda "$1" "$i"
done

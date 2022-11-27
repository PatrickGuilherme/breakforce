#!/bin/sh

#Compilar Sequencial
echo "==Compilar sequencial==" 
gcc bruteForce.c -o bruteForce -std=c99 -O3

#Executar sequencial
echo "==Executar sequencial=="
./bruteForce "$1"

#Compilar OMP
echo "==Compilar OMP=="
gcc bruteForce-omp.c -o bfomp -fopenmp -lm -std=c99 -O3

#Compilar CUDA
echo "==Compilar Cuda=="
nvcc bruteForce-cuda.cu -o bruteForce-cuda

#Compilar MPI
echo "==Compilar mpi=="
mpicc bruteForce-mpi.c -o bruteForce-mpi -fopenmp -std=c99 -O3


if [[  -f "speedup.dat" ]]; then
rm -rf speedup.dat
fi

if [[  -f "speedup_cuda.dat" ]]; then
rm -rf speedup_cuda.dat
fi

if [[  -f "speedup_mpi.dat" ]]; then
rm -rf speedup_mpi.dat
fi


#Executar MPI
echo "==Executar mpi=="
for((i = 2; i <= 32; i*=2))
do
    echo MPI "$i"
    mpirun -x MXM_LOG_LEVEL=error -quiet -np "$i" --allow-run-as-root ./bruteForce-mpi "$1"
done

#Executa OMP
echo "==Executar OMP=="
for((i = 2; i <= 128; i*=2))
do
    echo OMP "$i"
    OMP_NUM_THREADS=$i ./bfomp "$1"
done

#Executa cuda
echo "==Executar cuda=="
for((i = 2; i <= 1024; i*=2))
do
    echo CUDA "$i"
    ./bruteForce-cuda "$1" "$i"
done

#Plotando os gráficos
bash plotScript_print.sh speedup.dat OMP comparison_omp.png Threads
bash plotScript_print.sh speedup_mpi.dat MPI comparison_mpi.png Processors
bash plotScript_print.sh speedup_cuda.dat CUDA comparison_cuda.png Threads/Block

#!/bin/sh

#Compilar Sequencial
echo "==Compilar sequencial==" 
gcc bruteForce.c -o bruteForce -std=c99 -O3

echo "==Executar sequencial=="
./bruteForce "$1"

#Compilar OMP
echo "==Compilar OMP=="
gcc bruteForce-omp.c -o bfomp -fopenmp -lm -std=c99 -O3

#Compilar CUDA
echo "==Compilar Cuda=="
nvcc bruteForce-cuda.cu -o bruteForce-cuda

if [[  -f "speedup.dat" ]]; then
rm -rf speedup.dat
fi

if [[  -f "speedup_cuda.dat" ]]; then
rm -rf speedup_cuda.dat
fi

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

#!/bin/sh

rm -r *.so
rm -r *.o

gcc -c -fPIC select.cpp
gcc -shared -o libSelect.so select.o

nvcc --shared -o libCudaSelect.so cuda_select.cu --compiler-options '-fPIC'

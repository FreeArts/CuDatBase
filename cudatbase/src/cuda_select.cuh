#include <iostream>
#include <numeric>
#include <stdlib.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define CUDA_CHECK_RETURN(value) CheckCudaErrorAux(__FILE__,__LINE__, #value, value)

void testCuda(void);
static void CheckCudaErrorAux (const char *, unsigned, const char *, cudaError_t);
float *gpuReciprocal(float *data, unsigned size);
float *cpuReciprocal(float *data, unsigned size);
void initialize(float *data, unsigned size);

int work(void);

void callExample(int a[5],int b[5],int c[5]);

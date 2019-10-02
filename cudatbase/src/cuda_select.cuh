#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <numeric>
#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <string>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <vector>

using namespace std;

//--------Real Functions ---------
class CudaSelect{

public:
	CudaSelect();
	virtual ~CudaSelect();
	void copyDataToDevice();
	void copyDataToDevice(const vector<vector<long int>> &f_dataBase_r);


private:
	thrust::device_vector<vector<long int>> m_databseOnCuda_v;


};


//----------------------------------------------

#define CUDA_CHECK_RETURN(value)                                               \
  CheckCudaErrorAux(__FILE__, __LINE__, #value, value)

void testCuda(void);
static void CheckCudaErrorAux(const char *, unsigned, const char *,
                              cudaError_t);
float *gpuReciprocal(float *data, unsigned size);
float *cpuReciprocal(float *data, unsigned size);
void initialize(float *data, unsigned size);

void parallelANDmethod(vector<vector<long int>> *f_collectDataVector_p,
                       const vector<vector<long int>> &f_OR_collectDataVector_r,
                       vector<vector<long int>> &f_AND_collectDataVector_r,
                       vector<vector<long int>> &f_workDataVector);

void parallelORandMerge(const vector<vector<string>> *f_collectDataVector_p,
                        const vector<vector<string>> &f_OR_collectDataVector_r,
                        vector<vector<string>> &f_AND_collectDataVector_r);

void CopySelectRuleToDevice(vector<string> f_selectRule_v);

int work(void);

void callExample(int a[5], int b[5], int c[5]);

void testVector();

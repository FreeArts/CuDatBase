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
class CudaSelect {

public:
  CudaSelect();
  virtual ~CudaSelect();

  void copyDataToDevice(const vector<vector<long int>> &f_dataBase_r,
                        const unsigned int f_databaseRowSize_ui,
                        unsigned int f_databaseColumnSize_ui,
                        thrust::device_vector<long int> &f_DeviceDataBase_r);
  void CudaRun(const vector<string> &f_selectRule,
               const vector<vector<long int>> &f_dataBase_r,
               const vector<string> &f_dataBaseHeader_v);

private:
  void
  and_method(thrust::device_vector<long int> *f_collectDataVector_p,
             const thrust::device_vector<long int> &f_OR_collectDataVector_r,
             thrust::device_vector<long int> &f_AND_collectDataVector_r,
             thrust::device_vector<long int> &f_workDataVector);

  void equal(int input, string f_SelectRule_str,
             thrust::device_vector<long int> &dataBase_r,
             const vector<string> &f_dataBaseHeader_v,
             thrust::device_vector<long int> *f_collectDataVector_p,
             thrust::device_vector<long int> &f_workDataVector, bool &firstRun,
             unsigned int f_rowNumber_ui, unsigned int f_columnNumber_ui);
};

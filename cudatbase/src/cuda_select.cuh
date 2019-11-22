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
                        const unsigned long int f_databaseRowSize_ui,
                        unsigned long int f_databaseColumnSize_ui,
                        thrust::device_vector<long int> &f_DeviceDataBase_r);

  void CudaRun(const vector<string> &f_selectRule,
               const vector<vector<long int>> &f_dataBase_r,
               const vector<string> &f_dataBaseHeader_v);

  void copyDataFromDevice(const unsigned long int f_databaseRowSize_ui,
                          const unsigned long int f_databaseColumnSize_ui,
                          const thrust::host_vector<long int> &f_resultVector);

  vector<vector<long int>> getQueryResult() const;

private:
  void and_method(thrust::device_vector<long int> *f_collectDataVector_p,
                  thrust::device_vector<long int> &f_AND_collectDataVector_r,
                  thrust::device_vector<long int> &f_workDataVector,
                  unsigned long int l_databaseRowSize_ui,
                  unsigned long int l_databaseColumnSize_ui);

  void find(int whereIsTheTargetCharacter, string f_SelectRule_str,
            thrust::device_vector<long int> &dataBase_r,
            const vector<string> &f_dataBaseHeader_v,
            thrust::device_vector<long int> *f_collectDataVector_p,
            thrust::device_vector<long int> &f_workDataVector,
            unsigned long int f_rowNumber_ui,
            unsigned long int f_columnNumber_ui, string f_mathRule_str);

  bool m_firstRun_b;
  bool m_firstMethodWasOr_b;
  vector<vector<long int>> m_resultDatabase_v;

  void calculateGridFillMethod(unsigned long int &f_necessaryBlockNumber_r,
                               unsigned long int &f_necessaryThreadNumber_r,
                               const unsigned long int f_rowNumber_ui);

  void calculateGridBalanceMethod(unsigned long int &f_necessaryBlockNumber_r,
                                  unsigned long int &f_necessaryThreadNumber_r,
                                  const unsigned long int f_rowNumber_ui);
};

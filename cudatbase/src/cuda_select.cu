#include "cuda_select.cuh"
#include <cooperative_groups.h>
#include <vector>

CudaSelect::CudaSelect() {

  m_firstMethodWasOr_b = true;
  m_firstRun_b = true;

  m_resultDatabase_v.clear();
}

CudaSelect::~CudaSelect() {}

__global__ void searcData(long int *f_dataBase_p, long int *f_resultLines_p,
                          const unsigned int f_databaseRowSize_ui,
                          const unsigned int f_databaseColumnSize_ui,
                          const unsigned int f_targetWord_ui) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;
  int columnThread = blockIdx.y * blockDim.y + threadIdx.y;

  long int l_tmpWordContainer_li =
      f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + columnThread];

  if (l_tmpWordContainer_li == f_targetWord_ui) {

    for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

      long int l_dataBaseFoundedLineContent_li =
          f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
      f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
          l_dataBaseFoundedLineContent_li;
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

__global__ void searcDataInColumn(long int *f_dataBase_p,
                                  long int *f_resultLines_p,
                                  const unsigned int f_databaseRowSize_ui,
                                  const unsigned int f_databaseColumnSize_ui,
                                  const long int f_targetWord_ui,
                                  const unsigned int f_targetColumn) {

  int rowThread = blockIdx.x * blockDim.x + threadIdx.x;

  // printf("%i \n",rowThread);
  long int l_tmpWordContainer_li =
      f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + f_targetColumn];

  if (l_tmpWordContainer_li == f_targetWord_ui) {

    for (int l_it_x = 0; l_it_x < f_databaseColumnSize_ui; l_it_x++) {

      long int l_dataBaseFoundedLineContent_li =
          f_dataBase_p[(rowThread * f_databaseColumnSize_ui) + l_it_x];
      f_resultLines_p[l_it_x + (rowThread * f_databaseColumnSize_ui)] =
          l_dataBaseFoundedLineContent_li;
    }
  }
  // auto syncOnlyThreads= cooperative_groups::this_thread();
  // auto syncGroup = cooperative_groups::this_thread_block();
  // syncGroup.sync();
  // syncOnlyThreads.sync();
  __syncthreads();
}

void CudaSelect::copyDataToDevice(
    const vector<vector<long int>> &f_dataBase_r,
    const unsigned int f_databaseRowSize_ui,
    unsigned int f_databaseColumnSize_ui,
    thrust::device_vector<long int> &f_DeviceDataBase_r) {

  int l_tmpDatabaseContainer_i[f_databaseRowSize_ui][f_databaseColumnSize_ui];

  unsigned int l_it_x = 0;
  unsigned int l_it_y = 0;

  for (vector<long int> vec : f_dataBase_r) {
    for (long int vector_member : vec) {
      l_tmpDatabaseContainer_i[l_it_x][l_it_y] = vector_member;
      l_it_y++;
    }
    l_it_y = 0;
    l_it_x++;
  }

  // ToDo! What??
  thrust::copy(&(l_tmpDatabaseContainer_i[0][0]),
               &(l_tmpDatabaseContainer_i[f_databaseRowSize_ui]
                                         [f_databaseColumnSize_ui]),
               f_DeviceDataBase_r.begin());
}

void CudaSelect::copyDataFromDevice(
    const unsigned int f_databaseRowSize_ui,
    const unsigned int f_databaseColumnSize_ui,
    const thrust::host_vector<long int> &f_resultVector) {

  vector<long int> l_tmpDatabaseContainer_v;
  for (int x = 0; x < f_databaseRowSize_ui; x++) {

    l_tmpDatabaseContainer_v.clear();
    for (int y = 0; y < f_databaseColumnSize_ui; y++) {
      long int l_tmpVectorValu =
          f_resultVector[(x * f_databaseColumnSize_ui) + y];

      l_tmpDatabaseContainer_v.push_back(l_tmpVectorValu);
    }
    m_resultDatabase_v.push_back(l_tmpDatabaseContainer_v);
  }
}

void CudaSelect::CudaRun(const vector<string> &f_selectRule,
                         const vector<vector<long int>> &f_dataBase_r,
                         const vector<string> &f_dataBaseHeader_v) {

  unsigned int l_databaseRowSize_ui = f_dataBase_r.size();
  unsigned int l_databaseColumnSize_ui = f_dataBaseHeader_v.size();

  thrust::device_vector<long int> *l_collectDataVector_p(NULL);
  thrust::device_vector<long int> l_workDataVector(l_databaseRowSize_ui *
                                                   l_databaseColumnSize_ui);

  thrust::device_vector<long int> l_AND_collectDataVector(
      l_databaseRowSize_ui * l_databaseColumnSize_ui);

  thrust::device_vector<long int> l_DeviceDatabase(l_databaseRowSize_ui *
                                                   l_databaseColumnSize_ui);

  // ToDo: Rename it for host_Copy.......
  thrust::host_vector<long int> l_foundedResult(l_databaseRowSize_ui *
                                                l_databaseColumnSize_ui);

  vector<long int> resultVector(l_databaseRowSize_ui * l_databaseColumnSize_ui);

  copyDataToDevice(f_dataBase_r, l_databaseRowSize_ui, l_databaseColumnSize_ui,
                   l_DeviceDatabase);

  //---------------------R-U-N----------------------
  m_firstRun_b = true;
  m_firstMethodWasOr_b = true;

  int whereIsTheTargetCharacter;
  l_collectDataVector_p = &l_AND_collectDataVector;

  for (string l_rule_str : f_selectRule) {
    whereIsTheTargetCharacter = l_rule_str.find("&");
    if (whereIsTheTargetCharacter != (-1)) {

      and_method(l_collectDataVector_p, l_AND_collectDataVector,
                 l_workDataVector, l_databaseRowSize_ui,
                 l_databaseColumnSize_ui);

      if (m_firstMethodWasOr_b)
        m_firstMethodWasOr_b = false;

      continue;
    }

    whereIsTheTargetCharacter = l_rule_str.find("|");
    if (whereIsTheTargetCharacter != (-1)) {

      continue;
    }

    /// first will be find date="2010"
    whereIsTheTargetCharacter = l_rule_str.find("=");
    if (whereIsTheTargetCharacter != (-1)) {
      equal(whereIsTheTargetCharacter, l_rule_str, l_DeviceDatabase,
            f_dataBaseHeader_v, l_collectDataVector_p, l_workDataVector,
            l_databaseRowSize_ui, l_databaseColumnSize_ui);

      continue;
    }
  }

  l_foundedResult = l_AND_collectDataVector;

  /*
   for (int x = 0; x < l_databaseRowSize_ui; x++) {
     for (int y = 0; y < l_databaseColumnSize_ui; y++) {
       printf("cuda %lu ", l_foundedResult[(x * l_databaseColumnSize_ui) + y]);
     }
     printf("\n");
   }*/

  copyDataFromDevice(l_databaseRowSize_ui, l_databaseColumnSize_ui,
                     l_foundedResult);
}

void CudaSelect::and_method(
    thrust::device_vector<long int> *f_collectDataVector_p,
    thrust::device_vector<long int> &f_AND_collectDataVector_r,
    thrust::device_vector<long int> &f_workDataVector,
    unsigned int f_rowNumber_ui, unsigned int f_columnNumber_ui) {

  thrust::host_vector<long int> nullInitVector(
      f_rowNumber_ui * f_columnNumber_ui); // by default Null vector
  f_workDataVector = nullInitVector;

  /// put collectDataVector_p contain to AND_collectDataVector_r by indirect
  // f_collectDataVector_p = &f_AND_collectDataVector_r;

  /// f_collectDataVector_p point to f_AND_collectDataVector_r !!!!!!!!!!!
  /// put the AND_collectDataVector_r contains to l_workDataVector by directly
  f_workDataVector = f_AND_collectDataVector_r;

  // similar to f_collectDataVector_p->clear();
  f_AND_collectDataVector_r = nullInitVector;
}

void CudaSelect::equal(int whereIsTheTargetCharacter, string f_SelectRule_str,
                       thrust::device_vector<long int> &dataBase_r,
                       const vector<string> &f_dataBaseHeader_v,
                       thrust::device_vector<long int> *f_collectDataVector_p,
                       thrust::device_vector<long int> &f_workDataVector,
                       unsigned int f_rowNumber_ui,
                       unsigned int f_columnNumber_ui) {

  /// date="2010"
  unsigned int l_targetColumnNumber_ui = 0;
  /// cut "=2010" part
  string column = f_SelectRule_str.substr(0, whereIsTheTargetCharacter);
  /// cut "date=" part
  string tmp_row = f_SelectRule_str.substr(whereIsTheTargetCharacter + 1,
                                           f_SelectRule_str.size());
  long int row = std::stol(tmp_row);

  /// find "date" number of column //PC side
  for (unsigned int l_it_y = 0; l_it_y < f_dataBaseHeader_v.size();
       l_it_y++) // Todo optimalize to parallel search!!
  {
    string l_column = f_dataBaseHeader_v.at(l_it_y);
    if (l_column == column) {
      l_targetColumnNumber_ui = l_it_y;
    }
  }

  if ((m_firstRun_b == true) || (m_firstMethodWasOr_b == true)) {
    /// if first time run the query, search the lines from original database
    /// else we search from workDataVector
    dim3 necessaryGridSize(f_rowNumber_ui);
    searcDataInColumn<<<1, necessaryGridSize>>>(
        thrust::raw_pointer_cast(dataBase_r.data()),
        thrust::raw_pointer_cast(f_collectDataVector_p->data()), f_rowNumber_ui,
        f_columnNumber_ui, row, l_targetColumnNumber_ui);

    // Debug point
    /*thrust::host_vector<long int> l_foundedResult(3 * 4);
    l_foundedResult= *f_collectDataVector_p;

    for (int x = 0; x < 3; x++) {
      for (int y = 0; y < 4; y++) {
        printf("result %lu ", l_foundedResult[(x * 4) + y]);
      }
      printf("\n");
    }*/

    cudaDeviceSynchronize();
    m_firstRun_b = false;

  }

  else {

    dim3 necessaryGridSize(f_rowNumber_ui);
    searcDataInColumn<<<1, necessaryGridSize>>>(
        thrust::raw_pointer_cast(f_workDataVector.data()),
        thrust::raw_pointer_cast(f_collectDataVector_p->data()), f_rowNumber_ui,
        f_columnNumber_ui, row, l_targetColumnNumber_ui);

    cudaDeviceSynchronize();
  }
}

vector<vector<long int>> CudaSelect::getQueryResult() const {

  return m_resultDatabase_v;
}
